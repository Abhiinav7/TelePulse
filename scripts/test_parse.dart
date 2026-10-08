import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final catRes = await http.get(Uri.parse('https://iptv-org.github.io/iptv/index.category.m3u'));
  final langRes = await http.get(Uri.parse('https://iptv-org.github.io/iptv/index.language.m3u'));
  
  Set<String> cats = {};
  for (var line in catRes.body.split('\n')) {
    if (line.startsWith('#EXTINF:')) {
      final match = RegExp(r'group-title="(.*?)"').firstMatch(line);
      if (match != null) cats.add(match.group(1)!);
    }
  }
  
  Set<String> langs = {};
  for (var line in langRes.body.split('\n')) {
    if (line.startsWith('#EXTINF:')) {
      final match = RegExp(r'group-title="(.*?)"').firstMatch(line);
      if (match != null) langs.add(match.group(1)!);
    }
  }
  
  print('Categories: ${cats.length}');
  print('Languages: ${langs.length}');
}
