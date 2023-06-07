import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/db/authentication_service.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/home.dart';
import 'package:planup/model/user_account.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),

        // logo
        Image.asset(
          'assets/planup_black.png',
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width * 0.5,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),

        Text(AppLocalizations.of(context)!.welcomeOnPlanUp,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 16,
              letterSpacing: 1.5,
            )),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        const LoginButton(),
      ]),
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({super.key});

  @override
  State<StatefulWidget> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  final UsersRepository repository = UsersRepository();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: OutlinedButton.styleFrom(
          shadowColor: Colors.black,
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.15),
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

          if (mounted) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const HomePage()));
          }
        },
        child: Text(AppLocalizations.of(context)!.signInWithGoogle),
      ),
    );
  }
}
