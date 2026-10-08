import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_overlay.dart';
import '../providers/channel_providers.dart';
import '../../../core/theme.dart';
import 'proxy_image.dart';
import '../../../shared/futuristic.dart';

class GroupCard extends StatefulWidget {
  final String title;
  final String imageUrl;

  const GroupCard({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Consumer(
        builder: (context, ref, child) {
          return InkWell(
            onFocusChange: (focused) {
              setState(() => _isFocused = focused);
            },
            onHover: (hovered) {
              setState(() => _isFocused = hovered);
            },
            onTap: () {
              ref.read(searchQueryProvider.notifier).setQuery(widget.title);
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => const SearchOverlay(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: AnimatedScale(
              scale: _isFocused ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 160,
                decoration: glassTile(active: _isFocused),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ProxyImage(
                          imageUrl: widget.imageUrl,
                          fallbackIcon: Icon(Icons.category, size: 48, color: AppTheme.cyan.withValues(alpha: 0.6)),
                        ),
                      ),
                    ),
                    // Gradient overlay for readability
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.violet.withValues(alpha: 0.55),
                            Colors.black.withValues(alpha: 0.80),
                            AppTheme.magenta.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            shadows: [Shadow(color: AppTheme.cyan, blurRadius: 12)],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
