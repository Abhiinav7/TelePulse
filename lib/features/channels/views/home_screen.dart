import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel.dart';
import '../providers/channel_providers.dart';
import '../widgets/category_row.dart';
import '../widgets/group_row.dart';
import '../widgets/search_overlay.dart';
import '../../../core/theme.dart';
import '../../../shared/futuristic.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getFirstLogo(List<Channel> channels) {
    for (var c in channels) {
      if (c.logoUrl.isNotEmpty) return c.logoUrl;
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelsProvider);

    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      extendBodyBehindAppBar: true,
      appBar: channelsAsync.isLoading ? null : AppBar(
        backgroundColor: AppTheme.deepSpace.withValues(alpha: 0.55),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: const SizedBox.expand(),
          ),
        ),
        title: GradientText(
          'TelePulse',
          gradient: AppTheme.brandGradient,
          style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              side: BorderSide(color: AppTheme.cyan.withValues(alpha: 0.5)),
            ),
            color: AppTheme.cyan,
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => const SearchOverlay(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: AuroraBackground(child: channelsAsync.when(
        data: (channels) {
          if (channels.isEmpty) {
            return const Center(child: Text('No channels available.'));
          }

          final groupedByCategory = ref.watch(groupedByCategoryProvider);
          final groupedByLanguage = ref.watch(groupedByLanguageProvider);

          final featuredCatNames = ['Education', 'Entertainment', 'Kids', 'Movies', 'Music', 'Sports'];
          final otherCatNames = groupedByCategory.keys.where((c) => !featuredCatNames.contains(c)).toList()..sort();
          
          final Map<String, String> otherCategoryGroups = {};
          for (var cat in otherCatNames) {
            otherCategoryGroups[cat] = _getFirstLogo(groupedByCategory[cat] ?? []);
          }

          final featuredLangNames = ['Malayalam', 'Hindi', 'Tamil', 'English', 'Kannada', 'Telugu'];
          final otherLangNames = groupedByLanguage.keys.where((l) => !featuredLangNames.contains(l)).toList()..sort();

          final Map<String, String> otherLanguageGroups = {};
          for (var lang in otherLangNames) {
            otherLanguageGroups[lang] = _getFirstLogo(groupedByLanguage[lang] ?? []);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight + 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryRow(title: 'All Channels', channels: channels),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GradientText(
                    'FEATURED CATEGORIES',
                    style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 8),
                ...featuredCatNames.map((name) {
                  final catChannels = groupedByCategory[name] ?? [];
                  if (catChannels.isEmpty) return const SizedBox.shrink();
                  return CategoryRow(title: name, channels: catChannels);
                }),
                GroupRow(title: 'More Categories', items: otherCategoryGroups),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GradientText(
                    'FEATURED LANGUAGES',
                    style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 8),
                ...featuredLangNames.map((name) {
                  final langChannels = groupedByLanguage[name] ?? [];
                  if (langChannels.isEmpty) return const SizedBox.shrink();
                  return CategoryRow(title: name, channels: langChannels);
                }),
                GroupRow(title: 'More Languages', items: otherLanguageGroups),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
        loading: () => _buildSplashScreen(context),
        error: (err, stack) => Center(child: Text('Error: $err')),
      )),
    );
  }

  Widget _buildSplashScreen(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _PulsingLogo(),
          const SizedBox(height: 28),
          GradientText(
            'TelePulse',
            gradient: AppTheme.brandGradient,
            style: GoogleFonts.orbitron(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SYNCING LIVE CHANNELS...',
            style: GoogleFonts.orbitron(
              color: AppTheme.cyan.withValues(alpha: 0.8),
              fontSize: 13,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                minHeight: 4,
                color: AppTheme.magenta,
                backgroundColor: Color(0x22FFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingLogo extends StatefulWidget {
  const _PulsingLogo();

  @override
  State<_PulsingLogo> createState() => _PulsingLogoState();
}

class _PulsingLogoState extends State<_PulsingLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final v = Curves.easeInOut.transform(_c.value);
        return Transform.scale(
          scale: 0.92 + 0.12 * v,
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.brandGradient,
              boxShadow: [
                BoxShadow(color: AppTheme.magenta.withValues(alpha: 0.35 + 0.35 * v), blurRadius: 30 + 40 * v, spreadRadius: 4 + 10 * v),
                BoxShadow(color: AppTheme.cyan.withValues(alpha: 0.2 + 0.2 * v), blurRadius: 60, spreadRadius: 2),
              ],
            ),
            child: const Icon(Icons.live_tv_rounded, size: 70, color: Colors.white),
          ),
        );
      },
    );
  }
}
