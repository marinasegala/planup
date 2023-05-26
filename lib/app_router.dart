import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:planup/create_travel.dart';
import 'package:planup/friend_profile.dart';
import 'package:planup/friends.dart';
import 'package:planup/home.dart';
import 'package:planup/login.dart';
import 'package:planup/model/travel.dart';
import 'package:planup/model/user_account.dart';
import 'package:planup/profile.dart';
import 'package:planup/setting_profile.dart';
import 'package:planup/travel_info.dart';
import 'package:planup/widgets/checklist.dart';
import 'package:planup/widgets/create_note.dart';
import 'package:planup/widgets/create_shop.dart';
import 'package:planup/widgets/maps.dart';
import 'package:planup/widgets/notes.dart';
import 'package:planup/widgets/shopping.dart';
import 'package:planup/widgets/tickets.dart';

class AppRouter {
  final GoRouter goRouter = GoRouter(
    debugLogDiagnostics: true,

    // this is the initial default page
    initialLocation: '/',

    // each route has a name and a path
    // each route path has to start with a '/'
    // every route can have a subroute -> see below

    // differences between go and push:
    // -  go: replaces the current route with the new route -> it create a new route stack
    // - push: pushes the new route on the current route stack -> it adds a new route to the current route stack
    // pop: removes the current route from the route stack -> it removes the current route from the route stack

    // the name is used to navigate to the route with goNamed and pushNamed

    // the builder is used to build the widget for the route
    // we can pass the current context and the current state of the route to the builder
    // the state contains the current route and the extra data
    // the extra data can be used to pass data to the route -> see below
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
          // every root route can have subroutes
          // subroutes are defined in the routes property
          // the path of a subroute is relative to the path of the parent route
          // so the path does not require a leading '/'
          routes: [
            GoRoute(
              path: 'setting_profile',
              name: 'setting_profile',
              builder: (context, state) => const SettingsProfile(),
            )
          ]),
      GoRoute(
          path: '/friends',
          name: 'friends',
          builder: (context, state) => const FriendPage(),
          routes: [
            GoRoute(
                path: 'friend_profile',
                name: 'friend_profile',
                builder: (context, state) {
                  // create the needed data for the route in this way
                  // Object extra = state.extra as Object;
                  UserAccount friend = state.extra as UserAccount;

                  // then pass the data to the route
                  return FriendProfile(friend: friend);
                })
          ]),
      GoRoute(
          path: '/home_travel',
          name: 'home_travel',
          builder: (context, state) {
            Travel travel = state.extra as Travel;
            return TravInfo(trav: travel);
          },
          routes: [
            GoRoute(
              path: 'create_travel',
              name: 'create_travel',
              builder: (context, state) => const CreateTravelPage(),
            ),
            GoRoute(
              path: 'tickets',
              name: 'tickets',
              builder: (context, state) {
                Travel travel = state.extra as Travel;
                return Tickets(trav: travel);
              },
            ),
            GoRoute(
              path: 'map',
              name: 'map',
              builder: (context, state) {
                Travel travel = state.extra as Travel;
                return MapsPage(trav: travel);
              },
            ),
            GoRoute(
                path: 'shopping',
                name: 'shopping',
                builder: (context, state) {
                  Travel travel = state.extra as Travel;
                  return Shopping(trav: travel);
                },
                routes: [
                  GoRoute(
                    path: 'create_shopping',
                    name: 'create_shopping',
                    builder: (context, state) {
                      String travel = state.extra as String;
                      return CreateShopItem(travel: travel);
                    },
                  )
                ]),
            GoRoute(
              path: 'checklist',
              name: 'checklist',
              builder: (context, state) {
                Travel travel = state.extra as Travel;
                return ItemCheckList(trav: travel);
              },
            ),
            GoRoute(
                path: 'notes',
                name: 'notes',
                builder: (context, state) {
                  Travel travel = state.extra as Travel;
                  return Notes(trav: travel);
                },
                routes: [
                  GoRoute(
                    path: 'create_note',
                    name: 'create_note',
                    builder: (context, state) {
                      String travel = state.extra as String;
                      return CreateNote(travel: travel);
                    },
                  )
                ])
          ]),
    ],
  );
}
