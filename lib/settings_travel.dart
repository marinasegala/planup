import 'dart:io';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crea_radio_button/crea_radio_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect/multiselect.dart';
import 'package:planup/db/travel_rep.dart';
import 'package:planup/home.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'db/users_rep.dart';
import 'model/travel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'model/user_account.dart';

class SettingTravel extends StatefulWidget {
  final Travel travel;
  const SettingTravel({Key? key, required this.travel}) : super(key: key);

  @override
  State<SettingTravel> createState() => _SettingTravelState();
}

class _SettingTravelState extends State<SettingTravel> {
  // ignore: unused_field
  final _key = GlobalKey<State>();
  String changePeriod = "Giornata";
  bool changedata = false;

  // ignore: unused_field
  List<DateTime?> _dialogCalendarPickerValue = [];

  String date = '';

  final currentUser = FirebaseAuth.instance.currentUser!;
  List<String> friends = [];
  List<String> asFriend = [];
  List<String> listid = [];
  List<String> finalFriend = [];
  List<String> finalFriendId = [];
  List<String> selectedFriends = [];
  List<String> selectedFriendsId = [];
  String namefriend = '';
  Map<String, dynamic> toMap() {
    return {
      'name': namefriend,
    };
  }

  List<String> hasAlready = [];

  late List<UserAccount> users = [];
  final UsersRepository usersRepository = UsersRepository();
  final TravelRepository travelRepository = TravelRepository();

  void getUsers() {
    // obtain users from the repository and add to the list
    usersRepository.getUsers().then((usersList) {
      setState(() {
        users = usersList;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers();
    oldPhoto = widget.travel.photo;
  }

  XFile? image;
  File? file;
  String imageUrl = '';
  String uniqueFileName = '';
  final ImagePicker picker = ImagePicker();
  String? oldPhoto;

  Future<void> updateItem(String field, String newField) {
    return FirebaseFirestore.instance
        .collection('travel')
        .doc(widget.travel.referenceId)
        .update({field: newField});
  }

  Future<void> updateItemNum(String field, int newField) {
    return FirebaseFirestore.instance
        .collection('travel')
        .doc(widget.travel.referenceId)
        .update({field: newField});
  }

  Future getImageFromGallery() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    uploadFile();
  }

  Future<void> getImageFromCamera() async {
    image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    uploadFile();
  }

  void uploadFile() async {
    // get a reference to storage root
    Reference storageReference = FirebaseStorage.instance.ref();
    Reference referenceDirImage = storageReference.child('images');

    // create a reference for the image to be stored
    uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference imageReference = referenceDirImage.child(uniqueFileName);

    // handle errors/success
    try {
      // store the image
      await imageReference.putFile(File(image!.path));

      // success: get the download url
      imageUrl = await imageReference.getDownloadURL();

      // update the UI
      setState(() {
        widget.travel.photo = imageUrl;
      });
    } catch (e) {
      print(e);
    }
  }

  void choosePhoto() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text(AppLocalizations.of(context)!.uploadMethod),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      getImageFromGallery();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.image),
                        Text(AppLocalizations.of(context)!.gallery),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      getImageFromCamera();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.camera),
                        Text(AppLocalizations.of(context)!.camera),
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

  String _getValueText(
      CalendarDatePicker2Type datePickerType, List<DateTime?> values) {
    values =
        values.map((e) => e != null ? DateUtils.dateOnly(e) : null).toList();
    var valueText = (values.isNotEmpty ? values[0] : null)
        .toString()
        .replaceAll('00:00:00.000', '');

    if (datePickerType == CalendarDatePicker2Type.multi) {
      valueText = values.isNotEmpty
          ? values
              .map((v) => v.toString().replaceAll('00:00:00.000', ''))
              .join(', ')
          : 'null';
    } else if (datePickerType == CalendarDatePicker2Type.range) {
      if (values.isNotEmpty) {
        final startDate = values[0].toString().replaceAll('00:00:00.000', '');
        final endDate = values.length > 1
            ? values[1].toString().replaceAll('00:00:00.000', '')
            : 'null';
        valueText = '$startDate to $endDate';
      } else {
        return 'null';
      }
    }

    return valueText;
  }

  get(String where, String add) {
    FirebaseFirestore.instance
        .collection('friends')
        .where(where, isEqualTo: currentUser.uid)
        .get()
        .then(
      (querySnapshot) {
        // print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          if (where == 'userid') {
            friends.add(docSnapshot.get(add));
          } else {
            asFriend.add(docSnapshot.get(add));
          }
        }
      },
    );
  }

  getfinal(String idTravel) {
    for (var id in friends) {
      if (asFriend.contains(id) && !listid.contains(id)) {
        listid.add(id);
        FirebaseFirestore.instance
            .collection('users')
            .where('userid', isEqualTo: id)
            .get()
            .then(
          (querySnapshot) {
            for (var docSnapshot in querySnapshot.docs) {
              setState(() {
                finalFriend.add(docSnapshot.get('name'));
                finalFriendId.add(docSnapshot.get('userid'));
                finalFriendId.add(docSnapshot.get('name'));
              });
            }
          },
        );
      }
    }

    for (var x = 0; x < finalFriendId.length; x++) {
      FirebaseFirestore.instance
          .collection('travel')
          .doc(idTravel)
          .get()
          .then((querySnapshot) {
        for (var part in querySnapshot.get('list part')) {
          if (part == finalFriendId[x]) {
            for (var name in finalFriend) {
              if (name == finalFriendId[x + 1]) {
                finalFriend.remove(name);
                hasAlready.add(finalFriendId[x]);
                finalFriendId.removeAt(x);
                finalFriendId.remove(name);
              }
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> deleteItem(String id, String collection) {
      return FirebaseFirestore.instance
          .collection(collection)
          .doc(id)
          .delete()
          .then(
            (doc) => print("Document deleted"),
            onError: (e) => print("Error updating document $e"),
          );
    }

    getUsers();

    List<RadioOption> options = [
      RadioOption("Giornata", AppLocalizations.of(context)!.oneDay),
      RadioOption("Weekend", AppLocalizations.of(context)!.weekend),
      RadioOption("Settimana", AppLocalizations.of(context)!.week),
      RadioOption("Altro", AppLocalizations.of(context)!.other),
    ];
    String updateName = widget.travel.name;
    var id = widget.travel.referenceId;

    get('userid', 'userIdFriend');
    get('userIdFriend', 'userid');
    getfinal(id as String);

    buildCalendarDialogButton(bool alone) {
      const dayTextStyle =
          TextStyle(color: Colors.black, fontWeight: FontWeight.w700);
      final weekendTextStyle =
          TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600);
      final anniversaryTextStyle = TextStyle(
        color: Colors.red[400],
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
      );
      final config = CalendarDatePicker2WithActionButtonsConfig(
        dayTextStyle: dayTextStyle,
        calendarType: CalendarDatePicker2Type.range,
        selectedDayHighlightColor: Colors.purple[800],
        closeDialogOnCancelTapped: true,
        firstDayOfWeek: 1,
        weekdayLabelTextStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        controlsTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        centerAlignModePicker: true,
        customModePickerIcon: const SizedBox(),
        selectedDayTextStyle: dayTextStyle.copyWith(color: Colors.white),
        dayTextStylePredicate: ({required date}) {
          TextStyle? textStyle;
          if (date.weekday == DateTime.saturday ||
              date.weekday == DateTime.sunday) {
            textStyle = weekendTextStyle;
          }
          if (DateUtils.isSameDay(date, DateTime(2021, 1, 25))) {
            textStyle = anniversaryTextStyle;
          }
          return textStyle;
        },
        dayBuilder: ({
          required date,
          textStyle,
          decoration,
          isSelected,
          isDisabled,
          isToday,
        }) {
          Widget? dayWidget;
          if (date.day % 3 == 0 && date.day % 9 != 0) {
            dayWidget = Container(
              decoration: decoration,
              child: Center(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Text(
                      MaterialLocalizations.of(context).formatDecimal(date.day),
                      style: textStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 27.5),
                      child: Container(
                        height: 4,
                        width: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: isSelected == true
                              ? Colors.white
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return dayWidget;
        },
        yearBuilder: ({
          required year,
          decoration,
          isCurrentYear,
          isDisabled,
          isSelected,
          textStyle,
        }) {
          return Center(
            child: Container(
              decoration: decoration,
              height: 36,
              width: 72,
              child: Center(
                child: Semantics(
                  selected: isSelected,
                  button: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        year.toString(),
                        style: textStyle,
                      ),
                      if (isCurrentYear == true)
                        Container(
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(left: 5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () async {
            final values = await showCalendarDatePicker2Dialog(
              context: context,
              config: config,
              dialogSize: const Size(325, 400),
              borderRadius: BorderRadius.circular(15),
              dialogBackgroundColor: Colors.white,
            );
            if (values != null) {
              // ignore: avoid_print
              date = _getValueText(config.calendarType, values);
              setState(() {
                _dialogCalendarPickerValue = values;
              });
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                  // ignore: use_build_context_synchronously
                  SnackBar(
                      content:
                          // ignore: use_build_context_synchronously
                          Text(AppLocalizations.of(context)!.changeDateSaved)));
            }
          },
          child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.06),
              child: Text(
                  alone
                      ? AppLocalizations.of(context)!.changeDate
                      : AppLocalizations.of(context)!.calendar,
                  style: const TextStyle(fontSize: 16))),
        ),
      );
    }

    int count = hasAlready.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        scrollable: true,
                        title: Text(AppLocalizations.of(context)!.sureToDelete),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'No'),
                            child: Text(AppLocalizations.of(context)!.no),
                          ),
                          TextButton(
                            onPressed: () {
                              //remove id from list
                              FirebaseFirestore.instance
                                  .collection('travel')
                                  .doc(widget.travel.referenceId)
                                  .get()
                                  .then((querySnapshot) {
                                List<String> list = [];
                                for (var item
                                    in querySnapshot.get('list part')) {
                                  if (item != currentUser.uid) {
                                    list.add(item);
                                  }
                                }
                                print(list);
                                if (list.isEmpty) {
                                  travelRepository.deleteTravel(widget.travel);
                                } else {
                                  updateItem('userid', '');
                                  return FirebaseFirestore.instance
                                      .collection('travel')
                                      .doc(widget.travel.referenceId)
                                      .update({'list part': list});
                                }
                              });

                              //decrement numFriend
                              FirebaseFirestore.instance
                                  .collection('travel')
                                  .doc(widget.travel.referenceId)
                                  .get()
                                  .then((querySnapshot) {
                                print(querySnapshot.data());
                                int num = querySnapshot.get('numFriend') - 1;
                                updateItemNum('numFriend', num);
                              });

                              //remove all shopping
                              FirebaseFirestore.instance
                                  .collection('shopping')
                                  .where('trav',
                                      isEqualTo: widget.travel.referenceId)
                                  .where('userid', isEqualTo: currentUser.uid)
                                  .get()
                                  .then((querySnapshot) {
                                for (var docSnapshot in querySnapshot.docs) {
                                  deleteItem(docSnapshot.id, 'shopping');
                                }
                              });
                              //remove all note
                              FirebaseFirestore.instance
                                  .collection('note')
                                  .where('trav',
                                      isEqualTo: widget.travel.referenceId)
                                  .where('userid', isEqualTo: currentUser.uid)
                                  .get()
                                  .then((querySnapshot) {
                                for (var docSnapshot in querySnapshot.docs) {
                                  print(docSnapshot.data());
                                  deleteItem(docSnapshot.id, 'note');
                                }
                              });
                              //remove all checklist
                              FirebaseFirestore.instance
                                  .collection('check')
                                  .where('trav',
                                      isEqualTo: widget.travel.referenceId)
                                  .where('creator', isEqualTo: currentUser.uid)
                                  .get()
                                  .then((querySnapshot) {
                                for (var docSnapshot in querySnapshot.docs) {
                                  deleteItem(docSnapshot.id, 'check');
                                }
                              });
                              //remove all location
                              FirebaseFirestore.instance
                                  .collection('location')
                                  .where('travelid',
                                      isEqualTo: widget.travel.referenceId)
                                  .where('userid', isEqualTo: currentUser.uid)
                                  .get()
                                  .then((querySnapshot) {
                                for (var docSnapshot in querySnapshot.docs) {
                                  deleteItem(docSnapshot.id, 'location');
                                }
                              });
                              //remove all places
                              FirebaseFirestore.instance
                                  .collection('places')
                                  .where('travelid',
                                      isEqualTo: widget.travel.referenceId)
                                  .where('userid', isEqualTo: currentUser.uid)
                                  .get()
                                  .then((querySnapshot) {
                                for (var docSnapshot in querySnapshot.docs) {
                                  deleteItem(docSnapshot.id, 'places');
                                }
                              });
                              //remove all ticket
                              FirebaseFirestore.instance
                                  .collection('ticket')
                                  .where('trav',
                                      isEqualTo: widget.travel.referenceId)
                                  .where('userid', isEqualTo: currentUser.uid)
                                  .get()
                                  .then((querySnapshot) {
                                for (var docSnapshot in querySnapshot.docs) {
                                  deleteItem(docSnapshot.id, 'ticket');
                                }
                              });
                              setState(() {});
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => const HomePage()));
                            },
                            child: Text(AppLocalizations.of(context)!.yes),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(
                Icons.highlight_remove_outlined,
                size: 30,
              ))
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Container(
              width: MediaQuery.of(context).size.height * 0.15,
              height: MediaQuery.of(context).size.height * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: widget.travel.photo!.isNotEmpty
                  ? ClipOval(
                      child: Material(
                        child: Image.network(
                          widget.travel.photo!,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    )
                  : ClipOval(
                      child: Material(
                        child: Padding(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            size: 50,
                          ),
                        ),
                      ),
                    )),
          ElevatedButton(
            onPressed: () {
              choosePhoto();
              // reload the page
            },
            child: Text(AppLocalizations.of(context)!.changePhoto),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                icon: const Icon(Icons.pin_drop_outlined),
                hintText: AppLocalizations.of(context)!
                    .hintTextNameTravel(widget.travel.name),
                counterText:
                    AppLocalizations.of(context)!.counterTextNameTravel,
              ),
              onChanged: (text) => updateName = text,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Text(
              AppLocalizations.of(context)!.changeDateFrom(widget.travel.date!),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          widget.travel.date == 'Giornata' ||
                  widget.travel.date == 'Settimana' ||
                  widget.travel.date == 'Weekend' ||
                  widget.travel.date == 'Altro' ||
                  widget.travel.date == 'One day' ||
                  widget.travel.date == 'Week' ||
                  widget.travel.date == 'Other'
              ? ToggleSwitch(
                  minWidth: MediaQuery.of(context).size.width * 0.3,
                  cornerRadius: 20.0,
                  activeBgColor: const [Color.fromARGB(255, 59, 94, 115)],
                  inactiveBgColor: const Color.fromARGB(255, 223, 227, 229),
                  initialLabelIndex: null,
                  doubleTapDisable: true,
                  totalSwitches: 2,
                  labels: [
                    AppLocalizations.of(context)!.period,
                    AppLocalizations.of(context)!.date
                  ],
                  customTextStyles: const [TextStyle(fontSize: 16)],
                  onToggle: (index) {
                    index == 0
                        ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                scrollable: true,
                                title: Text(
                                    AppLocalizations.of(context)!.changePeriod),
                                content: Padding(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.01),
                                  child: Form(
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1),
                                          child: RadioButtonGroup(
                                              options: options,
                                              preSelectedIdx: 0,
                                              vertical: true,
                                              textStyle: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black),
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              selectedColor:
                                                  const Color.fromARGB(
                                                      255, 195, 190, 190),
                                              mainColor: const Color.fromARGB(
                                                  255, 195, 190, 190),
                                              selectedBorderSide:
                                                  const BorderSide(
                                                      width: 2,
                                                      color: Color.fromARGB(
                                                          255, 64, 137, 168)),
                                              buttonWidth: MediaQuery
                                                          .of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              buttonHeight:
                                                  MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                              callback: (RadioOption val) {
                                                setState(() {
                                                  changePeriod = val.label;
                                                  date = changePeriod;
                                                  changedata = true;
                                                });
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                      child: Text(
                                          AppLocalizations.of(context)!.send),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .changePeriodSaved)));
                                        Navigator.of(context).pop();
                                      })
                                ],
                              );
                            })
                        : showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  scrollable: true,
                                  title: Text(
                                      AppLocalizations.of(context)!.addTicket),
                                  content: buildCalendarDialogButton(false));
                            });
                  },
                )
              : buildCalendarDialogButton(true),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              child: DropDownMultiSelect(
                onChanged: (List<String> x) {
                  setState(() {
                    selectedFriends = x;
                  });
                },
                options: finalFriend,
                selectedValues: selectedFriends,
                whenEmpty: AppLocalizations.of(context)!.addFriends,
                icon: const Icon(Icons.person_add_alt_1_outlined),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('travel')
                    .doc(id)
                    .get()
                    .then((DocumentSnapshot documentSnapshot) {
                  if (documentSnapshot.exists) {
                    if (imageUrl != oldPhoto && imageUrl != '') {
                      updateItem('photo', imageUrl);
                    }
                    if (updateName != widget.travel.name) {
                      updateItem('name', updateName);
                    }
                    if (date != widget.travel.date && date != '') {
                      if (date.contains('null')) {
                        date = date.substring(0, 10);
                      }
                      updateItem('exactly date', date);
                    }
                    if (selectedFriends.isNotEmpty) {
                      hasAlready.add(currentUser.uid);
                      count = hasAlready.length;
                      for (var x in selectedFriends) {
                        for (var i = 0; i < finalFriendId.length; i++) {
                          if (x == finalFriendId[i]) {
                            hasAlready.add(finalFriendId[i - 1]);
                            count++;
                          }
                        }
                      }
                      updateItemNum('numFriend', count);
                      return FirebaseFirestore.instance
                          .collection('travel')
                          .doc(widget.travel.referenceId)
                          .update({'list part': hasAlready});
                    }
                  }
                });
                // check
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(AppLocalizations.of(context)!.processingData)));
                setState(() {});
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (builder) => const HomePage()));
              },
              child: Text(
                AppLocalizations.of(context)!.modify,
                style: const TextStyle(fontSize: 16),
              )),
        ],
      ),
    );
  }
}
