import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planup/model/travel.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'db/travel_rep.dart';

//TODO: far partire il calendario da 'oggi'
// class CreateTravelPage extends StatelessWidget {

//   CreateTravelPage({super.key});

//   final DataRepository repository = DataRepository();

// XFile? image;
// final ImagePicker picker = ImagePicker();
// Future getImage(ImageSource media) async {
//   var img = await picker.pickImage(source: media);

//   setState(() {
//     image = img;
//   });
// }

//   @override
//   Widget build(BuildContext context) {
// return Scaffold(
//   resizeToAvoidBottomInset: false,
//   appBar: AppBar(
//     title: const Text('Crea il tuo viaggio'),
//   ),
//   body: Align(
//       alignment: Alignment.topCenter, //aligns to topCenter
//       child: Column(
//         children: [
//           //Container(
//               //padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
//               image != null
//                 ? Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.file(
//                         //to show image, you type like this.
//                         File(image!.path),
//                         fit: BoxFit.cover,
//                         width: MediaQuery.of(context).size.width,
//                         height: 300,
//                       ),
//                     ),
//                   )
//                 : const Text(
//                     "No Image",
//                     style: TextStyle(fontSize: 20),
//                   ),
//           CreateTravelForm(),
//         ],
//       )),
// );
//   }
// }

class CreateTravelPage extends StatefulWidget {
  CreateTravelPage({Key? key}) : super(key: key);

  @override
  State<CreateTravelPage> createState() => _CreateTravelFormState();
}

//TODO - capire perche il codice image non funziona
class _CreateTravelFormState extends State<CreateTravelPage> {
  final _formKey = GlobalKey<FormState>();

  String? nameTrav;
  String part = '';
  final DataRepository repository = DataRepository();
  bool _swapDate = false;
  String date = '';
  final List<bool> _selectedDate = [false, false, false];

  XFile? image;
  File? file;
  final ImagePicker picker = ImagePicker();
  Future getImageFromGallery() async {
    image = await picker.pickImage(source: ImageSource.gallery);
  }

  Future<void> getImageFromCamera() async {
    image = await picker.pickImage(source: ImageSource.camera);
  }

  List<DateTime?> _dialogCalendarPickerValue = [
    DateTime(2021, 8, 10),
    DateTime(2021, 8, 13),
  ];

  String _getValueText(
    CalendarDatePicker2Type datePickerType,
    List<DateTime?> values,
  ) {
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

  @override
  Widget build(BuildContext context) {
    _buildCalendarDialogButton() {
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
        padding: const EdgeInsets.all(15),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
            onPressed: () async {
              final values = await showCalendarDatePicker2Dialog(
                context: context,
                config: config,
                dialogSize: const Size(325, 400),
                borderRadius: BorderRadius.circular(15),
                value: _dialogCalendarPickerValue,
                dialogBackgroundColor: Colors.white,
              );
              if (values != null) {
                // ignore: avoid_print
                date = _getValueText(config.calendarType, values);
                print(date);
                setState(() {
                  _dialogCalendarPickerValue = values;
                });
              }
            },
            child: const Center(
                child: Text(
              'Apri il calendario',
              style: TextStyle(fontSize: 16),
            )),
          ),
        ]),
      );
    }

    var macroCharts = _buildCalendarDialogButton();
    var microCharts = Center(
        child: ToggleSwitch(
      initialLabelIndex: _swapDate ? 0 : 1,
      minWidth: 85.0,
      minHeight: 50.0,
      activeBgColor: const [Color.fromARGB(255, 59, 94, 115)],
      inactiveBgColor: const Color.fromARGB(255, 223, 227, 229),
      totalSwitches: 4,
      labels: const ['Giornata', 'Weekend', 'Settimana', 'Altro'],
      onToggle: (index) {
        switch (index) {
          case 0:
            date = 'Giornata';
            break;
          case 1:
            date = 'Weekend';
            break;
          case 2:
            date = 'Settimana';
            break;
          case 3:
            date = 'Altro';
            break;
        }

        // setState(() {
        //   _swapDate = !_swapDate;
        // });
        print('switched to $index -- $date');
      },
    ));

    var swapTile = Container(
      child: (_swapDate) ? macroCharts : microCharts,
    );

    void myAlert() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: const Text('Please choose media to select'),
              content: Container(
                height: MediaQuery.of(context).size.height / 6,
                child: Column(
                  children: [
                    ElevatedButton(
                      //if user click this button, user can upload image from gallery
                      onPressed: () {
                        Navigator.pop(context);
                        getImageFromGallery();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.image),
                          Text('From Gallery'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      //if user click this button. user can upload image from camera
                      onPressed: () {
                        Navigator.pop(context);
                        getImageFromCamera();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.camera),
                          Text('From Camera'),
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Crea il tuo viaggio'),
      ),
      body: Align(
        alignment: Alignment.topCenter, //aligns to topCenter
        child: Column(
          children: [
            //Container(
            //padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
            ElevatedButton(
              onPressed: () {
                myAlert();
              },
              child: const Text('Upload Photo'),
            ),
            const SizedBox(height: 10),
            image != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        //to show image, you type like this.
                        File(image!.path),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.pin_drop_outlined),
                          border: OutlineInputBorder(),
                          hintText: 'Inserire il nome del viaggio'),
                      onChanged: (text) => nameTrav = text,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.groups_outlined),
                          border: OutlineInputBorder(),
                          hintText: 'Numero di partecipanti'),
                      onChanged: (text) => part = text,
                    ),
                  ),
                  Column(children: [
                    const Row(
                      children: [
                        SizedBox(
                          width: 10,
                          height: 50,
                        ),
                        Text(
                          'Durata del viaggio',
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                    const SizedBox.shrink(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'So già le date del mio viaggio',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        ToggleSwitch(
                          initialLabelIndex: _swapDate ? 0 : 1,
                          minWidth: 45.0,
                          minHeight: 27.0,
                          activeBgColor: const [
                            Color.fromARGB(255, 59, 94, 115)
                          ],
                          inactiveBgColor:
                              const Color.fromARGB(255, 223, 227, 229),
                          totalSwitches: 2,
                          fontSize: 16,
                          labels: const ['Si', 'No'],
                          onToggle: (index) {
                            setState(() {
                              _swapDate = !_swapDate;
                            });
                            print('switched to $index $_swapDate');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    swapTile,
                  ]),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (FirebaseAuth.instance.currentUser != null) {
                            if (nameTrav != null && part.isNotEmpty) {
                              final newTrav = Travel(nameTrav!,
                                  partecipant: part,
                                  userid:
                                      FirebaseAuth.instance.currentUser?.uid,
                                  date: date);
                              repository.add(newTrav);
                              //Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data')));
                              Navigator.pop(context);
                            }
                          }
                        },
                        child:
                            const Text('Invia', style: TextStyle(fontSize: 16)),
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
