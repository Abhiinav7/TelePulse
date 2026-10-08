import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/channel.dart';
import '../../../core/theme.dart';
import 'proxy_image.dart';
import '../../../shared/futuristic.dart';

class ChannelCard extends StatefulWidget {
  final Channel channel;

  const ChannelCard({super.key, required this.channel});

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: InkWell(
        onFocusChange: (focused) {
          setState(() {
            _isFocused = focused;
          });
        },
        onHover: (hovered) {
          setState(() {
            _isFocused = hovered;
          });
        },
        onTap: () {
          context.push('/player', extra: widget.channel);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ProxyImage(
                        imageUrl: widget.channel.logoUrl,
                        fallbackIcon: Icon(Icons.tv, size: 48, color: AppTheme.cyan.withValues(alpha: 0.6)),
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: _isFocused
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.violet, AppTheme.magenta],
                            ),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                          ),
                          child: Text(
                            widget.channel.name,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
