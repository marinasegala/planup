// import 'dart:io';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crea_radio_button/crea_radio_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planup/home.dart';
import 'package:planup/home_travel.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'model/travel.dart';

class SettingTravel extends StatefulWidget {
  final Travel travel;
  const SettingTravel({Key? key, required this.travel}) : super(key: key);

  @override
  State<SettingTravel> createState() => _SettingTravelState();
}

class _SettingTravelState extends State<SettingTravel> {
  
  String changePeriod = "Giornata";
  List<RadioOption> options = [
    RadioOption("GIORNATA", "Giornata"),
    RadioOption("WEEKEND", "Weekend"),
    RadioOption("SETTIMANA", "Settimana"),
    RadioOption("ALTRO", "Altro"),
  ];
  bool changedata = false;
  bool _swapDate = false;
  List<DateTime?> _dialogCalendarPickerValue = [];
  String date = '';

  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();
  XFile? image;
  String imageUrl = '';
  String uniqueFileName = '';
  final ImagePicker picker = ImagePicker();

  Future<void> updateItem(String field, String newField) {
    return FirebaseFirestore.instance
        .collection('travel')
        .doc(widget.travel.referenceId)
        .update({field: newField}).then((value) => print("Update"),
            onError: (e) => print("Error updating doc: $e"));
  }

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

  @override
  Widget build(BuildContext context) {
    String updateName = widget.travel.name;
    bool canupdateDate = false;
    var id = widget.travel.referenceId;

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
              print(date);
              setState(() {
                _dialogCalendarPickerValue = values;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cambio Data Salvato')));
            }
          },
          child: Center(
            child: Text(alone ? 'Cambio data' : 'Apri il calendario' , 
              style: const TextStyle(fontSize: 16)
          )),
        ),
      );
          
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
              width: 100,
              height: 100,
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
                  : const ClipOval(
                      child: Material(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            size: 60,
                          ),
                        ),
                      ),
                    )),
          ElevatedButton(
            onPressed: () {
              choosePhoto();
              // reload the page
            },
            child: const Text('Cambia Foto'),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                icon: const Icon(Icons.pin_drop_outlined),
                hintText: 'Nome del viaggio: ${widget.travel.name}',
                counterText: 'Scrivi per modificare il nome',
              ),
              onChanged: (text) => updateName = text,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const SizedBox(height: 30),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Cambio la data "', style: TextStyle(fontSize: 17),),
              Text(widget.travel.date as String, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 17),),
              const Text('" con',  style: TextStyle(fontSize: 17),),
          ],),
          const SizedBox(height: 10,),
          widget.travel.date == 'Giornata' || widget.travel.date == 'Settimana' || widget.travel.date == 'Weekend' || widget.travel.date == 'Altro'
          ? ToggleSwitch(
              minWidth: 100.0,
              cornerRadius: 20.0,
              activeBgColor: const [ Color.fromARGB(255, 59, 94, 115)],
              inactiveBgColor:const Color.fromARGB(255, 223, 227, 229),
              initialLabelIndex: null,
              doubleTapDisable: true, 
              totalSwitches: 2,
              labels: const ['Periodo', 'Data'],
              customTextStyles: const [TextStyle(fontSize: 16)],
              onToggle: (index) {
                index == 0
                ? showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      title: const Text('Cambio Periodo del Viaggio'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              RadioButtonGroup(
                                options: options,
                                preSelectedIdx: 0,
                                vertical: true,
                                textStyle: const TextStyle(fontSize: 15, color: Colors.black),
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                selectedColor: const Color.fromARGB(255, 195, 190, 190),
                                mainColor: const Color.fromARGB(255, 195, 190, 190),
                                selectedBorderSide: const BorderSide(width: 2, color: Color.fromARGB(255, 64, 137, 168)),
                                buttonWidth: 105,
                                buttonHeight: 35,
                                callback: (RadioOption val) {
                                  setState(() {
                                    changePeriod = val.label;
                                    date = changePeriod;
                                    changedata = true;
                                  });
                              }),
                              
                            ],
                          ),
                        ),
                      ),
                      actions: [ ElevatedButton(
                        child: const Text("Invia"),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cambio Periodo Salvato')));
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
                      title: const Text('Cambio Periodo del Viaggio'),
                      content: buildCalendarDialogButton(false));
                  });
              },
            )
          : buildCalendarDialogButton(true),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('travel')
                    .doc(id)
                    .get()
                    .then((DocumentSnapshot documentSnapshot) {
                  if (documentSnapshot.exists) {
                    if (updateName != widget.travel.name) {
                      updateItem('name', updateName);
                    }
                    if(date != widget.travel.date){
                      if (date.contains('null')) {
                        date = date.substring(0, 10);
                      }
                      updateItem('exactly date', date);
                    }
                  }
                });
                // check
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')));
                setState(() {});
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Invia',
                style: TextStyle(fontSize: 16),
              )),
        ],
      ),
    );
  }
}