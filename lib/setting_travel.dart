import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format_field/date_format_field.dart';
import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planup/travel_info.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'model/travel.dart';

class SettingsTrav extends StatefulWidget {
  final Travel trav;
  const SettingsTrav({Key? key, required this.trav}) : super(key: key);

  @override
  State<SettingsTrav> createState() => _SettingTravState();
}

class _SettingTravState extends State<SettingsTrav> {
  bool _swapDate = false;
  String date = 'Giornata';
  List<DateTime?> _dialogCalendarPickerValue = [];

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
    String updateName = widget.trav.name;
    String updatePart = widget.trav.partecipant;
    String? updateDate = widget.trav.date;

    Future<void> updateTravel(String id, String field, String newField) async {
      return FirebaseFirestore.instance
          .collection("travel")
          .doc(id)
          .update({field: newField})
          .then(
            (value) => print("DocumentSnapshot successfully updated!"),
            onError: (e) => print("Error updating document $e")
          );
    }
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
    
   
    var macroCharts = buildCalendarDialogButton();
    var microCharts = Center(
        child: ToggleSwitch(
          initialLabelIndex: 0,
          isVertical: true,
          minWidth: 85.0,
          minHeight: 30.0,
          activeBgColor: const [Color.fromARGB(255, 59, 94, 115)],
          inactiveBgColor: const Color.fromARGB(255, 223, 227, 229),
          totalSwitches: 4,
          labels: const ['Giornata', 'Weekend', 'Settimana', 'Altro'],
          onToggle: (index) {
            switch (index) {
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
    

    Future<void> _changedata() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog( // <-- SEE HERE
            title: const Text('Cambio date'),
            actions: <Widget>[
              ToggleSwitch(
                initialLabelIndex: _swapDate ? 0 : 1,
                minWidth: 50.0,
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
                },
              ),
              swapTile,
              
              TextButton(
                child: const Text('Salva', style: TextStyle(fontSize: 15),),
                onPressed: () {

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> _showAlertDialog() async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog( // <-- SEE HERE
            title: const Text('Vuoi modificare la data del viaggio?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No', style: TextStyle(fontSize: 20),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Si', style: TextStyle(fontSize: 20),),
                onPressed: () {
                  Navigator.of(context).pop();
                  _changedata();
                },
              ),
            ],
          );
        },
      );
    }

    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Impostazioni'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            
          ),
          
          body: Column(
            children: [
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: 
                TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                      icon: const Icon(Icons.pin_drop_outlined),
                      hintText: 'Nome del viaggio:  ${widget.trav.name}',
                      counterText: 'Scrivi per modificare il nome del viaggio',
                      ),
                  onChanged: (text) => updateName = text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: 
                TextField(
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      icon: const Icon(Icons.group_outlined),
                      hintText: 'Numero di partecipanti:  ${widget.trav.partecipant}',
                      counterText: 'Scrivi per modificare il numero di partecipanti',),
                  onChanged: (text) => updatePart = text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () { _showAlertDialog(); }, 
                  child: Container(
                    child: Row( children: [
                      const Icon(Icons.date_range_outlined, color: Color.fromARGB(255, 135, 132, 125),),
                      const SizedBox(width: 16,),
                      Text('Data:  ${widget.trav.date}', style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 93, 91, 87)),),
                    ],),
                  ),
                ),),
                // TextField(
                //   autofocus: false,
                  
                //   decoration: InputDecoration(
                //       icon: const Icon(Icons.date_range_outlined),
                //       hintText: 'Data:  ${trav.date}',
                //       counterText: 'Modifica data/durata del viaggio',
                //       ),
                      
                //   onChanged: (text) => updatePart = text,
                // ),
              
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser != null) {
                        FirebaseFirestore.instance
                          .collection('travel')
                          .where("name", isEqualTo: widget.trav.name)
                          .where('partecipant', isEqualTo: widget.trav.partecipant)
                          .get()
                          .then( (querySnapshot) {
                            for (var docSnapshot in querySnapshot.docs) {
                              if(updateName != widget.trav.name) updateTravel(docSnapshot.id, 'name', updateName);
                              if(updatePart != widget.trav.partecipant) updateTravel(docSnapshot.id, 'partecipant', updatePart);
                              
                            }
                          },);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Invia', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
