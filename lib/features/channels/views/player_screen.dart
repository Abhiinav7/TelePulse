import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../models/channel.dart';
import '../../../core/theme.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final Channel channel;

  const PlayerScreen({super.key, required this.channel});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late VideoPlayerController _controller;
  bool _hasError = false;
  bool _isLoading = true;
  bool _showControls = true;
  
  bool _isMuted = false;
  bool _isLandscape = false; 

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.streamUrl),
      );

      await _controller.initialize();
      
      _controller.addListener(() {
        if (_controller.value.hasError && !_hasError) {
          _handleStreamError();
        }
      });

      await _controller.play();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _startHideControlsTimer();
      }
    } catch (e) {
      _handleStreamError();
    }
  }

  Future<void> _handleStreamError() async {
    if (!mounted || _hasError) return;
    
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
    
    // We intentionally removed the Supabase auto-delete logic here!
    // Free IPTV streams constantly go down due to server overload and come back up later.
    // Deleting them on a single failure is too aggressive.
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller.dispose();
    super.dispose();
  }
  
  void _startHideControlsTimer() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _controller.value.isPlaying) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }
  
  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
    _startHideControlsTimer();
  }
  
  void _toggleFullscreen() {
    setState(() {
      _isLandscape = !_isLandscape;
    });
    
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    _startHideControlsTimer();
  }

  void _goBack() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeviceLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: GestureDetector(
        onTap: _toggleControls,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: AppTheme.cyan))
            else if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: AppTheme.magenta, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Stream Error',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This channel is currently unavailable or offline.\nPlease try again later.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppTheme.brandGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: AppTheme.magenta.withValues(alpha: 0.4), blurRadius: 18)],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        onPressed: _goBack,
                        child: const Text('Go Back', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: isDeviceLandscape
                    ? SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.size.width > 0 ? _controller.value.size.width : 1280,
                            height: _controller.value.size.height > 0 ? _controller.value.size.height : 720,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      )
                    : AspectRatio(
                        aspectRatio: _controller.value.aspectRatio > 0 ? _controller.value.aspectRatio : 16 / 9,
                        child: VideoPlayer(_controller),
                      ),
              ),
              
            if (!_isLoading && !_hasError && _controller.value.isBuffering)
              const Center(child: CircularProgressIndicator(color: Colors.white)),
              
            if (_showControls || _isLoading || _hasError)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                padding: EdgeInsets.fromLTRB(16, isDeviceLandscape ? 16 : 40, 16, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.deepSpace.withValues(alpha: 0.9), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                      onPressed: _goBack,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.channel.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          shadows: [Shadow(color: AppTheme.cyan, blurRadius: 10)],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    if (!_hasError)
                      IconButton(
                        icon: Icon(
                          isDeviceLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: _toggleFullscreen,
                      ),
                      
                    if (!_hasError)
                      IconButton(
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: _toggleMute,
                      ),
                  ],
                ),
              )),
              
            if (!_isLoading && !_hasError && _showControls)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.brandGradient,
                    boxShadow: [
                      BoxShadow(color: AppTheme.magenta.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 2),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 56,
                    padding: const EdgeInsets.all(14),
                    icon: Icon(
                      _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
                      });
                      _startHideControlsTimer();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
