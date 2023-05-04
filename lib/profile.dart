import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

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
            ImageSlideshow(
              width: 300,
              height: 200,
              initialPage:
                  0, // The page to show when first creating the [ImageSlideshow].
              indicatorColor: Colors.blue,
              indicatorRadius: 3,
              indicatorBackgroundColor: Colors.grey,
              autoPlayInterval: 3000,
              isLoop: true,
              // The widgets to display in the [ImageSlideshow], add the sample image file into the images folder
              children: [
                Image.asset(
                  'images/sample_image_1.jpg',
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  'images/sample_image_2.jpg',
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
