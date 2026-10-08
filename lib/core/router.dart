import 'package:go_router/go_router.dart';
import '../features/channels/views/home_screen.dart';
import '../features/channels/views/player_screen.dart';
import '../features/channels/models/channel.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) {
        final channel = state.extra as Channel;
        return PlayerScreen(channel: channel);
      },
    ),
  ],
);
