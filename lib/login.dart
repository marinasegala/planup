import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/authentication_service.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/home.dart';
import 'package:planup/model/user_account.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const SizedBox(height: 150),

        // logo
        Image.asset(
          'assets/planup_black.png',
          height: 150,
          width: 150,
        ),
        const SizedBox(height: 50),

        const Text('Welcome to PlanUp\n please sign in with google',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16,
              letterSpacing: 1.5,
            )),

        const SizedBox(height: 25),

        LoginButton(),

        const SizedBox(
          height: 25,
        )
      ]),
    );
  }
}

class LoginButton extends StatelessWidget {
  LoginButton({super.key});

  final UsersRepository repository = UsersRepository();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        onPressed: () async {
          User user = await AuthenticationServices().signInWithGoogle();
          final userExists = await repository.userExists(user.email!);
          if (!userExists) {
            await repository.addUser(UserAccount(
                user.displayName!, user.email!, user.uid, user.photoURL!));
          }
          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomePage()));
        },
        child: const Text('Sign in with Google'),
      ),
    );
  }
}
