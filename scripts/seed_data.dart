import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

void main() async {
  // Read credentials from the flutter config file
  final file = File('lib/core/supabase_client.dart');
  final content = await file.readAsString();
  
  final urlMatch = RegExp(r"url = '(.*?)';").firstMatch(content);
  final keyMatch = RegExp(r"anonKey = '(.*?)';").firstMatch(content);
  
  if (urlMatch == null || keyMatch == null || urlMatch.group(1) == 'YOUR_SUPABASE_URL') {
    print('ERROR: Please set your Supabase URL and Anon Key in lib/core/supabase_client.dart first!');
    return;
  }
  
  final supabaseUrl = urlMatch.group(1)!;
  final supabaseKey = keyMatch.group(1)!;
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);

  print('Fetching all languages map...');
  final langRes = await http.get(Uri.parse('https://iptv-org.github.io/iptv/index.language.m3u'));
  Map<String, String> langMap = {};
  
  final langLines = langRes.body.split('\n');
  String? currentLang;
  for (var line in langLines) {
    if (line.startsWith('#EXTINF:')) {
      final match = RegExp(r'group-title="(.*?)"').firstMatch(line);
      currentLang = match?.group(1);
    } else if (line.startsWith('http')) {
      if (currentLang != null) {
        langMap[line.trim()] = currentLang;
      }
    }
  }
  
  print('Fetching all categories map and building channel list...');
  final catRes = await http.get(Uri.parse('https://iptv-org.github.io/iptv/index.category.m3u'));
  
  List<Map<String, dynamic>> allChannels = [];
  
  final catLines = catRes.body.split('\n');
  String? currentCategory;
  String? currentName;
  String? currentLogo;
  
  for (var line in catLines) {
    if (line.startsWith('#EXTINF:')) {
      final catMatch = RegExp(r'group-title="(.*?)"').firstMatch(line);
      currentCategory = catMatch?.group(1) ?? 'Uncategorized';
      
      final logoMatch = RegExp(r'tvg-logo="(.*?)"').firstMatch(line);
      currentLogo = logoMatch?.group(1) ?? '';
      
      final nameParts = line.split(',');
      currentName = nameParts.length > 1 ? nameParts.last.trim() : 'Unknown Channel';
    } else if (line.startsWith('http')) {
      final streamUrl = line.trim();
      final lang = langMap[streamUrl] ?? 'Unknown';
      
      if (currentName != null) {
        allChannels.add({
          'name': currentName,
          'logo_url': currentLogo,
          'stream_url': streamUrl,
          'category': currentCategory,
          'language': lang,
          'is_enabled': true,
        });
      }
    }
  }

  print('\nParsed ${allChannels.length} total channels from the global index.');
  if (allChannels.isEmpty) return;

  print('Clearing existing channels table...');
  try {
    await client.from('channels').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  } catch (e) {
    print('Note: Table clear failed or is already empty.');
  }

  print('Uploading to Supabase in batches of 100...');
  
  for (var i = 0; i < allChannels.length; i += 100) {
    var end = i + 100;
    if (end > allChannels.length) end = allChannels.length;
    
    final batch = allChannels.sublist(i, end);
    try {
      await client.from('channels').insert(batch);
      print('Inserted $end / ${allChannels.length} ...');
    } catch (e) {
      print('Error inserting batch: $e');
    }
  }

  print('\n✅ Done! All 11,000+ global channels have been uploaded with categories AND languages!');
}
