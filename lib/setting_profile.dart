import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:planup/db/authentication_service.dart';

class SettingsProfile extends StatelessWidget {
  const SettingsProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 1),
        body: Container(
          padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
          child: ListView(children: [
            const Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.blueGrey,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Account",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(
              height: 15,
              thickness: 2,
            ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Modifica profilo",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                )
              ],
            ),
            const SizedBox(
              height: 450,
            ),
            Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
                onPressed: () {
                  AuthenticationServices().signOut();
                  context.go('/login');
                },
                child: const Text(
                  "SIGN OUT",
                  style: TextStyle(
                      fontSize: 18, letterSpacing: 2.2, color: Colors.blueGrey),
                ),
              ),
            )
          ]),
        ));
  }
}
