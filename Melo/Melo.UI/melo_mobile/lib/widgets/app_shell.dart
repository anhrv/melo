import 'package:flutter/material.dart';
import 'package:melo_mobile/providers/audio_player_service.dart';
import 'package:provider/provider.dart';
import 'mini_player.dart';
import 'full_player.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({required this.child, super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AudioPlayerService? _audioService;
  String? _lastSongUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final service = context.read<AudioPlayerService>();
    if (_audioService != service) {
      _audioService?.removeListener(_handleAudioStateChange);
      _audioService = service;
      _audioService!.addListener(_handleAudioStateChange);
    }
  }

  void _handleAudioStateChange() {
    if (!mounted) return;

    final currentUrl = _audioService?.currentSongUrl;
    final isExpanded = _audioService?.isExpanded ?? false;

    if (currentUrl != null && currentUrl != _lastSongUrl) {
      _lastSongUrl = currentUrl;

      if (!isExpanded) {
        _audioService?.expandPlayer();
        _showFullPlayer(context);
      }
    }
  }

  void _showFullPlayer(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(_FullPlayerRoute());
  }

  @override
  void dispose() {
    _audioService?.removeListener(_handleAudioStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showPlayer =
        context.watch<AudioPlayerService>().currentSongUrl != null;
    final isExpanded = context.watch<AudioPlayerService>().isExpanded;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: widget.child),
              if (showPlayer && !isExpanded) const SizedBox(height: 80),
            ],
          ),
          const PlayerOverlay(),
        ],
      ),
    );
  }
}

class PlayerOverlay extends StatelessWidget {
  const PlayerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = context.watch<AudioPlayerService>();
    final showPlayer = audioService.currentSongUrl != null;
    final isExpanded = audioService.isExpanded;

    if (!showPlayer) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 80,
      child: Material(
        color: Colors.black,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!isExpanded) {
              audioService.expandPlayer();
              _showFullPlayer(context);
            }
          },
          onVerticalDragUpdate: (details) {
            if (!isExpanded &&
                details.primaryDelta != null &&
                details.primaryDelta! < -12) {
              audioService.expandPlayer();
              _showFullPlayer(context);
            }
          },
          child: const MiniPlayer(),
        ),
      ),
    );
  }

  void _showFullPlayer(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(_FullPlayerRoute());
  }
}

PageRoute _FullPlayerRoute() {
  return PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black.withOpacity(0.7),
    barrierDismissible: true,
    pageBuilder: (context, animation, secondaryAnimation) {
      return WillPopScope(
        onWillPop: () async {
          context.read<AudioPlayerService>().collapsePlayer();
          return true;
        },
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta != null && details.primaryDelta! > 12) {
              Navigator.of(context).pop();
              context.read<AudioPlayerService>().collapsePlayer();
            }
          },
          child: const Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: FullPlayer(),
            ),
          ),
        ),
      );
    },
    transitionsBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: anim,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
  );
}
