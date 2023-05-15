import 'package:go_router/go_router.dart';
import 'package:planup/home.dart';
import 'package:planup/login.dart';

final GoRouter goRouter = GoRouter(routes: <GoRoute>[
  GoRoute(
      path: '/',
      name: 'main',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
            path: '/friends',
            name: 'friends',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: '/:friendid',
                name: 'friendProfile',
                builder: (context, state) => const HomePage(),
              ),
            ]),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const HomePage(),
        ),
      ]),
  GoRoute(
    path: '/login',
    name: 'login',
    builder: (context, state) => const LoginPage(),
  ),
]);
