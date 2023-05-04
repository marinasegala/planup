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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Il mio profilo"),
      ),
      body: Align(
        alignment: Alignment.topCenter, //aligns to topCenter
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.fromLTRB(0, 31, 0, 10),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                )),
            const Text("Mario", style: TextStyle(fontSize: 25)),
            const Text("mario_rossi", style: TextStyle(fontSize: 15)),
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
          child: Container(
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
          ),
        ))
    .toList();
