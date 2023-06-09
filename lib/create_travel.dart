import 'dart:io';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crea_radio_button/crea_radio_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect/multiselect.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/model/travel.dart';
import 'package:planup/model/user_account.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'db/travel_rep.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateTravelPage extends StatefulWidget {
  const CreateTravelPage({Key? key}) : super(key: key);

  @override
  State<CreateTravelPage> createState() => _CreateTravelFormState();
}

class _CreateTravelFormState extends State<CreateTravelPage> {
  final _formKey = GlobalKey<FormState>();

  final currentUser = FirebaseAuth.instance.currentUser!;

  // final FriendsRepository friendRepository = FriendsRepository();
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

  String? nameTrav;
  String part = '';
  final TravelRepository repository = TravelRepository();
  bool _swapDate = false;
  String date = 'Giornata';

  XFile? image;
  File? file;
  String imageUrl = '';
  String uniqueFileName = '';

  final ImagePicker picker = ImagePicker();

  late List<UserAccount> users = [];
  final UsersRepository usersRepository = UsersRepository();

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
    setState(() {});
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
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  // ignore: unused_field
  List<DateTime?> _dialogCalendarPickerValue = [];

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

  getfinal() {
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
  }

  @override
  Widget build(BuildContext context) {
    getUsers();
    get('userid', 'userIdFriend');
    get('userIdFriend', 'userid');
    getfinal();
    buildCalendarDialogButton() {
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
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01),
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
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width * 0.1,
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
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height * 0.01),
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.height * 0.01),
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
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
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
              }
            },
            child: Center(
                child: Text(
              AppLocalizations.of(context)!.calendar,
              style: const TextStyle(fontSize: 16),
            )),
          ),
        ]),
      );
    }

    List<RadioOption> options = [
      RadioOption("Giornata", AppLocalizations.of(context)!.oneDay),
      RadioOption("Weekend", AppLocalizations.of(context)!.weekend),
      RadioOption("Settimana", AppLocalizations.of(context)!.week),
      RadioOption("Altro", AppLocalizations.of(context)!.other),
    ];

    var macroCharts = buildCalendarDialogButton();
    var microCharts = Center(
      child: RadioButtonGroup(
          options: options,
          preSelectedIdx: 0,
          spaceBetween: 12.0,
          betweenMultiLines: 12.0,
          vertical: false,
          multilineNumber: 3,
          textStyle: const TextStyle(fontSize: 15, color: Colors.black),
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          selectedColor: const Color.fromARGB(255, 195, 190, 190),
          mainColor: const Color.fromARGB(255, 195, 190, 190),
          selectedBorderSide: const BorderSide(
              width: 2, color: Color.fromARGB(255, 64, 137, 168)),
          buttonWidth: MediaQuery.of(context).size.width * 0.4,
          buttonHeight: MediaQuery.of(context).size.height * 0.05,
          callback: (RadioOption val) {
            setState(() {
              date = val.label;
            });
          }),
    );
    var swapTile = Container(
      child: (_swapDate) ? macroCharts : microCharts,
    );

    // select the photo for the travel
    void choosePhoto() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.clear),
                ),
              ],
            );
          });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createTravel),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: image != null
                    ? ClipOval(
                        child: Image.file(
                          //to show image, you type like this.
                          File(image!.path),
                          fit: BoxFit
                              .fitWidth, //this is fit the image in the circle
                        ),
                      )
                    : ClipOval(
                        child: Icon(
                          Icons.add_a_photo,
                          size: MediaQuery.of(context).size.width * 0.1,
                        ),
                      )),
            ElevatedButton(
              onPressed: () {
                choosePhoto();
              },
              child: Text(AppLocalizations.of(context)!.uploadPhoto),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.022,
                        vertical: MediaQuery.of(context).size.height * 0.02),
                    child: TextFormField(
                      autofocus: true,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.pin_drop_outlined),
                          border: const OutlineInputBorder(),
                          hintText:
                              AppLocalizations.of(context)!.insertNameTravel),
                      onChanged: (text) => nameTrav = text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.requiredField;
                        }
                        return null;
                      },
                    ),
                  ),
                  Column(children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.knownDate,
                          style: const TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        ToggleSwitch(
                          initialLabelIndex: _swapDate ? 0 : 1,
                          minWidth: MediaQuery.of(context).size.width * 0.14,
                          minHeight: MediaQuery.of(context).size.height * 0.04,
                          activeBgColor: const [
                            Color.fromARGB(255, 59, 94, 115)
                          ],
                          inactiveBgColor:
                              const Color.fromARGB(255, 223, 227, 229),
                          totalSwitches: 2,
                          fontSize: 16,
                          labels: [
                            AppLocalizations.of(context)!.yes,
                            AppLocalizations.of(context)!.no
                          ],
                          onToggle: (index) {
                            setState(() {
                              _swapDate = !_swapDate;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    swapTile,
                  ]),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Center(
                    child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.022),
                    child: !_swapDate
                      ? Text(AppLocalizations.of(context)!.selectedDate(date),
                              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic), )
                      : date.length>10
                        ? Text(AppLocalizations.of(context)!.selectedDate(date),
                              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic), )
                        : SizedBox.shrink(),
                  ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.022),
                    child: Text(AppLocalizations.of(context)!.hintInsertFriends,
                        style: TextStyle(color: Colors.grey[700])),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.height * 0.022,
                          vertical: MediaQuery.of(context).size.height * 0.015),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (FirebaseAuth.instance.currentUser != null) {
                            if (_formKey.currentState!.validate()) {
                              if (date.contains('null')) {
                                date = date.substring(0, 10);
                              }
                              var count = 1;
                              selectedFriendsId.add(FirebaseAuth
                                  .instance.currentUser?.uid as String);
                              for (var x in selectedFriends) {
                                for (var i = 0; i < finalFriendId.length; i++) {
                                  if (x == finalFriendId[i]) {
                                    selectedFriendsId.add(finalFriendId[i - 1]);
                                    count++;
                                  }
                                }
                              }

                              final newTrav = Travel(nameTrav!,
                                  userid:
                                      FirebaseAuth.instance.currentUser?.uid,
                                  date: date,
                                  listPart: selectedFriendsId,
                                  photo: imageUrl,
                                  numFriend: count);
                              repository.add(newTrav);

                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .processingData)));
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.send,
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
