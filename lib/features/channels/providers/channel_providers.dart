import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/channel.dart';

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (e) {
    return null;
  }
});

final channelsProvider = FutureProvider<List<Channel>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return []; 
  
  const int limit = 1000;
  const int maxPages = 15; 
  
  List<Future<List<dynamic>>> futures = [];
  
  for (int i = 0; i < maxPages; i++) {
    int offset = i * limit;
    futures.add(
      client
          .from('channels')
          .select()
          .eq('is_enabled', true)
          .order('name')
          .range(offset, offset + limit - 1)
          .then((response) => response as List<dynamic>)
          .catchError((_) => <dynamic>[])
    );
  }
  
  final results = await Future.wait(futures);
  
  List<Channel> allChannels = [];
  for (var page in results) {
    if (page.isNotEmpty) {
      allChannels.addAll(page.map((json) => Channel.fromJson(json as Map<String, dynamic>)));
    }
  }
  
  return allChannels;
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final filteredChannelsProvider = Provider<List<Channel>>((ref) {
  final channels = ref.watch(channelsProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  
  if (query.isEmpty) return channels;
  
  return channels.where((channel) {
    return channel.name.toLowerCase().contains(query) ||
           channel.category.toLowerCase().contains(query) ||
           channel.language.toLowerCase().contains(query);
  }).toList();
});

// Fix: Always group by the FULL channel list, not the search-filtered one!
final groupedByCategoryProvider = Provider<Map<String, List<Channel>>>((ref) {
  final channels = ref.watch(channelsProvider).value ?? [];
  final map = <String, List<Channel>>{};
  
  for (var channel in channels) {
    if (!map.containsKey(channel.category)) {
      map[channel.category] = [];
    }
    map[channel.category]!.add(channel);
  }
  return map;
});

// Fix: Always group by the FULL channel list, not the search-filtered one!
final groupedByLanguageProvider = Provider<Map<String, List<Channel>>>((ref) {
  final channels = ref.watch(channelsProvider).value ?? [];
  final map = <String, List<Channel>>{};
  
  for (var channel in channels) {
    if (!map.containsKey(channel.language)) {
      map[channel.language] = [];
    }
    map[channel.language]!.add(channel);
  }
  return map;
});
