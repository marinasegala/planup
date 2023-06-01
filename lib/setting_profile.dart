import 'package:flutter/material.dart';
import 'package:planup/db/authentication_service.dart';
import 'package:planup/login.dart';

class SettingsProfile extends StatefulWidget {
  const SettingsProfile({super.key});
  @override
  State<SettingsProfile> createState() => _SettingsProfile();
}

class _SettingsProfile extends State<SettingsProfile>{
  void choosePhoto() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Seleziona il metodo di caricamento'),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      // getImageFromGallery();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.image),
                        Text('Galleria'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      // getImageFromCamera();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.camera),
                        Text('Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.pop(context, true), // passing true
                icon: const Icon(Icons.clear),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Impostazioni'),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 1),
        body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          // Container(
          //     width: 100,
          //     height: 100,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       border: Border.all(
          //         color: Colors.grey[300]!,
          //         width: 1,
          //       ),
          //     ),
          //     child: widget.travel.photo!.isNotEmpty
          //         ? ClipOval(
          //             child: Material(
          //               child: Image.network(
          //                 widget.travel.photo!,
          //                 fit: BoxFit.fitHeight,
          //               ),
          //             ),
          //           )
          //         : const ClipOval(
          //             child: Material(
          //               child: Padding(
          //                 padding: EdgeInsets.all(16.0),
          //                 child: Icon(
          //                   Icons.add_a_photo_outlined,
          //                   size: 60,
          //                 ),
          //               ),
          //             ),
          //           )),
          // ElevatedButton(
          //   onPressed: () {
          //     choosePhoto();
          //     // reload the page
          //   },
          //   child: const Text('Cambia Foto'),
          // ),
          Center(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              onPressed: () {
                AuthenticationServices().signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => const LoginPage()));
              },
              child: const Text(
                "SIGN OUT",
                style: TextStyle(
                    fontSize: 18, letterSpacing: 2.2, color: Colors.blueGrey),
              ),
            ),
          )
          ]),
        );
  }
}
