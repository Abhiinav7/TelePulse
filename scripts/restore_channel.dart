import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient(
    'https://gsfdepviubuwewgmlvyp.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzZmRlcHZpdWJ1d2V3Z21sdnlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkzNzgxNzgsImV4cCI6MjEwNDk1NDE3OH0.IYuseV1fwg5HvoVtazvjqO5kcBjD8lvVbh8Hh2aJ9hc'
  );

  final channel = {
    'name': '24 News',
    'logo_url': 'https://sund-images.sunnxt.com/202222/300x300_24News_202222_d63feca0-79ae-47ea-b75a-66c17d456f4c.png',
    'stream_url': 'https://mumt07.tangotv.in/zHjX9OFlTWENTYFOURNEWS/index.m3u8',
    'category': 'News',
    'language': 'Malayalam',
    'is_enabled': true
  };

  try {
    await client.from('channels').insert(channel);
    print('Successfully restored 24 News!');
  } catch (e) {
    print('Error: $e');
  }
}
