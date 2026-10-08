import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel.dart';
import 'channel_card.dart';
import 'search_overlay.dart';
import '../providers/channel_providers.dart';
import '../../../core/theme.dart';
import '../../../shared/futuristic.dart';

class CategoryRow extends ConsumerWidget {
  final String title;
  final List<Channel> channels;

  const CategoryRow({
    super.key,
    required this.title,
    required this.channels,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (channels.isEmpty) return const SizedBox.shrink();

    // Limit to 15 channels
    final displayCount = channels.length > 15 ? 15 : channels.length;
    final showViewAll = channels.length > 15;

    void handleViewAll() {
      // If it's the "All Channels" master list, just clear the filter to show everything
      if (title == 'All Channels') {
        ref.read(searchQueryProvider.notifier).setQuery('');
      } else {
        ref.read(searchQueryProvider.notifier).setQuery(title);
      }
      
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => const SearchOverlay(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: SectionTitle(title)),
              if (showViewAll)
                TextButton(
                  onPressed: handleViewAll,
                  child: const GradientText(
                    'VIEW ALL',
                    style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: displayCount + (showViewAll ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == displayCount) {
                // View All Card at the end of the row
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: InkWell(
                    onTap: handleViewAll,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: AppTheme.brandGradient,
                        boxShadow: [
                          BoxShadow(color: AppTheme.magenta.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 36),
                            SizedBox(height: 8),
                            Text('View All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return FadeSlideIn(index: index, child: ChannelCard(channel: channels[index]));
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
