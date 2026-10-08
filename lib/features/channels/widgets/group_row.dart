import 'package:flutter/material.dart';
import 'group_card.dart';
import '../../../shared/futuristic.dart';

class GroupRow extends StatelessWidget {
  final String title;
  final Map<String, String> items; // Map of Title -> ImageUrl

  const GroupRow({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final entries = items.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SectionTitle(title),
        ),
        SizedBox(
          height: 140, // Same height as ChannelCard row
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return FadeSlideIn(
                index: index,
                child: GroupCard(
                  title: entries[index].key,
                  imageUrl: entries[index].value,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
