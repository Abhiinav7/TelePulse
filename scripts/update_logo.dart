import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient(
    'https://gsfdepviubuwewgmlvyp.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzZmRlcHZpdWJ1d2V3Z21sdnlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkzNzgxNzgsImV4cCI6MjEwNDk1NDE3OH0.IYuseV1fwg5HvoVtazvjqO5kcBjD8lvVbh8Hh2aJ9hc'
  );

  final url = 'https://upload.wikimedia.org/wikipedia/commons/0/01/TwentyFour_News_logo.png';
  
  await client.from('channels')
    .update({'logo_url': url})
    .eq('name', '24 News');
    
  print('Updated logo for 24 News!');
}
