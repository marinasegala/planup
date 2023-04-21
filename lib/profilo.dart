import 'dart:ui';

import 'package:flutter/material.dart';

class Profilo extends StatelessWidget{
  const Profilo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
          alignment: Alignment.topCenter,//aligns to topCenter
          child: Column(children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 50, 0, 10),
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/profile.jpg'),
              )
            ),
            const Text("Mario", style: TextStyle(fontSize: 30)),
            const Text("mario_rossi", style: TextStyle(fontSize: 20))
          ],)
          
        ),
      );
  }
}

// Padding(//gives empty space around the CircleAvatar
//                 padding: EdgeInsets.all(50.0),
//                 child: CircleAvatar(
//                   radius: 60,//radius is 35.
//                   backgroundImage: AssetImage('assets/profile.jpg'),//AssetImage loads image URL.
//                 ),
//           ),

// import 'package:flutter/material.dart';
// //import 'package:font_awesome_flutter/font_awesome_flutter.dart';


// class Profilo extends StatelessWidget {
//   const Profilo({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
          
//           title: Text("Round Image with Button"
//           ),
//         ),
//         body: Padding(
//           padding: EdgeInsets.all(10),
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Container(
        //         decoration: BoxDecoration(
        //           // borderRadius: BorderRadius.circular(10),
        //           // boxShadow: [
        //           //   BoxShadow(
        //           //     color: Colors.grey.withOpacity(0.5),
        //           //     spreadRadius: 10,
        //           //     blurRadius: 5,
        //           //     offset: Offset(0, 3),
        //           //   ),
        //           // ],
        //         ),
        //         child: CircleAvatar(
        //           radius: 50,
        //           backgroundImage: AssetImage("assets/Image/Paspotr.jpg"),
        //         ),
        //       ),
        //       SizedBox(
        //         height: 10,
        //       ),
        //       Text(
        //         "Mahfozur Rahman  ",
        //         style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        //       ),
        //       SizedBox(
        //         height: 18,
        //       ),
        //       Text("Mahfozur Rahman"),
        //       SizedBox(
        //         height: 20,
        //       ),
              
        //     ],
        //   ),
        // ),
//       ),
//     );
//   }
// }