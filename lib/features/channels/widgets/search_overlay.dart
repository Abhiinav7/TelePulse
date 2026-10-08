import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../providers/channel_providers.dart';
import 'channel_card.dart';
import '../../../shared/futuristic.dart';

class SearchOverlay extends ConsumerWidget {
  const SearchOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredChannels = ref.watch(filteredChannelsProvider);
    final initialQuery = ref.read(searchQueryProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Guarantee the search query is wiped clean when the overlay closes,
        // even if they used the Android hardware back button!
        ref.read(searchQueryProvider.notifier).setQuery('');
      },
      child: Scaffold(
        backgroundColor: AppTheme.deepSpace.withValues(alpha: 0.96),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Colors.transparent,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.5)),
              boxShadow: [BoxShadow(color: AppTheme.cyan.withValues(alpha: 0.2), blurRadius: 14)],
            ),
            child: TextFormField(
            initialValue: initialQuery == 'All Channels' ? '' : initialQuery,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search channels, categories, languages...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).setQuery(value);
            },
          ),
          ),
        ),
        body: AuroraBackground(child: filteredChannels.isEmpty
            ? const Center(
                child: Text(
                  'No channels found.',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredChannels.length,
                itemBuilder: (context, index) {
                  return FadeSlideIn(index: index, child: ChannelCard(channel: filteredChannels[index]));
                },
              )),
      ),
    );
  }
}
