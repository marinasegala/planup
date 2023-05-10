import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

final List<String> images = [
  'assets/montagna.jpg',
  'assets/vienna.jpg',
];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String? name;
  late String? profilePhoto;
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      final user = FirebaseAuth.instance.currentUser;
      for (final providerProfile in user!.providerData) {
        name = providerProfile.displayName;
        profilePhoto = providerProfile.photoURL;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Il mio profilo"),
      ),
      body: Align(
        alignment: Alignment.topCenter, //aligns to topCenter
        child: Column(
          children: [
            const Row(),
            const SizedBox(height: 20),
            profilePhoto != null
                ? ClipOval(
                    child: Material(
                      child: Image.network(
                        profilePhoto as String,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )
                : const ClipOval(
                    child: Material(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.person,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 15),
            Text(name as String, style: const TextStyle(fontSize: 22)),
            //const Text("mario_rossi", style: TextStyle(fontSize: 15)),
            const Divider(
              color: Colors.white,
              height: 20,
            ),
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 2.0,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
              ),
              items: imageSliders,
            ),
          ],
        ),
      ),
    );
  }
}

final List<Widget> imageSliders = images
    .map((item) => Container(
          margin: const EdgeInsets.all(5.0),
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              child: Stack(
                children: <Widget>[
                  Image.asset(item, fit: BoxFit.cover, width: 1000.0),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(200, 0, 0, 0),
                            Color.fromARGB(0, 0, 0, 0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Text(
                        'No. ${images.indexOf(item)} image',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ))
    .toList();
