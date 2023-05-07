import 'package:flutter/material.dart';
import 'package:planup/home.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const SizedBox(height: 150),

        // logo
        Image.asset(
          'assets/planup.jpeg',
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

        const LoginButton(),

        const SizedBox(
          height: 25,
        )
      ]),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //onTap: ,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text("Sign In",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )),
        ),
      ),
    );
  }
}
