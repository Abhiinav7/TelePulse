import 'package:flutter/material.dart';

class ProxyImage extends StatefulWidget {
  final String imageUrl;
  final Widget fallbackIcon;

  const ProxyImage({
    super.key,
    required this.imageUrl,
    required this.fallbackIcon,
  });

  @override
  State<ProxyImage> createState() => _ProxyImageState();
}

class _ProxyImageState extends State<ProxyImage> {
  bool _useProxy = false;
  bool _completelyFailed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.isEmpty || _completelyFailed) {
      return widget.fallbackIcon;
    }

    final currentUrl = _useProxy
        // Using corsproxy.io is much more reliable than wsrv.nl because it acts as a true transparent proxy
        ? 'https://corsproxy.io/?${Uri.encodeComponent(widget.imageUrl)}'
        : widget.imageUrl;

    return Image.network(
      currentUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        if (!_useProxy) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _useProxy = true;
              });
            }
          });
          return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _completelyFailed = true;
              });
            }
          });
          return widget.fallbackIcon;
        }
      },
    );
  }
}
