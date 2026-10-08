import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient(
    'https://gsfdepviubuwewgmlvyp.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzZmRlcHZpdWJ1d2V3Z21sdnlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkzNzgxNzgsImV4cCI6MjEwNDk1NDE3OH0.IYuseV1fwg5HvoVtazvjqO5kcBjD8lvVbh8Hh2aJ9hc'
  );

  final response = await client.from('channels').select().ilike('name', '%24 News%');
  final list = response as List<dynamic>;
  
  print('Found ${list.length} channels matching "24 News"');
  
  if (list.length > 1) {
    // Keep the first one, delete the rest
    for (int i = 1; i < list.length; i++) {
      final id = list[i]['id'];
      print('Deleting duplicate ID: $id');
      await client.from('channels').delete().eq('id', id);
    }
    print('Duplicates removed!');
  }
}
