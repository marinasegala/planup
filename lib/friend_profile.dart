import 'package:flutter/material.dart';
import 'package:planup/model/userAccount.dart';

class FriendProfile extends StatefulWidget {
  const FriendProfile({super.key, required this.friend});

  final UserAccount friend;

  @override
  State<FriendProfile> createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  late UserAccount friendUser;
  String? name;
  String? profilePhoto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friend.name),
      ),
      body: Align(
        alignment: Alignment.topCenter,
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
                      shape: CircleBorder(
                          side: BorderSide(color: Colors.black, width: 1)),
                      child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          )),
                    ),
                  ),
            const SizedBox(height: 15),
            Text(widget.friend.name, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
