import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';


import 'package:calendar_app/constants/constants.dart';
import 'package:calendar_app/models/event.dart';


class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  late Map<DateTime, List<Event>> selectedEvents = {};

  CalendarFormat format = CalendarFormat.month;

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  final dateFormatterForView = DateFormat('EEE, MMM d yyyy');
  final dateFormatterForRequest = DateFormat('yyyy-MM-dd');

  DateTime formatDateForRequest(DateTime date) {
    String formattedFocusDayString = dateFormatterForRequest.format(date);
    return DateTime.parse(formattedFocusDayString);
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  late String token = '';

  List<Event> getEventsFromDay(DateTime date) {
    String formattedDateString = dateFormatterForRequest.format(date);
    DateTime formattedDate = DateTime.parse(formattedDateString);
    return selectedEvents[formattedDate] ?? [];
  }

  Future<void> setupInitialData() async {
    EasyLoading.show();
    await getToken().then((value) => token = value ?? '');
    final response = await http.get(
      Uri.parse('$beUrl/api/events'),
      headers: <String, String> {
        'Authorization': 'Bearer $token',
      });
    var bodyResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      for (var eventData in bodyResponse['data']) {
        DateTime date = DateTime.parse(eventData['attributes']['date']);
        Event event = Event(
          id: eventData['id'],
          date: date,
          name: eventData['attributes']['name'],
          description: eventData['attributes']['description']);
        setState(() {
          if (selectedEvents[date] != null) {
            selectedEvents[date]?.add(event);
          } else {
            selectedEvents[date] = [event];
          }
        });
      }
    } else if (response.statusCode != 403) {
      showSnackBar(context, bodyResponse['error']['message']);
    }
    EasyLoading.dismiss();
  }

  @override
  void initState() {
    setupInitialData();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('CalendarApp', style: TextStyle(color: Colors.lightGreen[900])),
        elevation: 1.0,
        centerTitle: true,
        backgroundColor: Colors.grey[50],
      ),
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              focusedDay: selectedDay,
              firstDay: DateTime(1950),
              lastDay: DateTime(2050),
              // day changed
              onDaySelected: (DateTime selectDay, DateTime focusDay) {
                setState(() {
                  selectedDay = formatDateForRequest(selectDay);
                  focusedDay = formatDateForRequest(focusDay);
                });
              },
              selectedDayPredicate: (DateTime date) {
                return isSameDay(selectedDay, date);
              },
              eventLoader: getEventsFromDay,
              // to style the calendar
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: Colors.grey[350],
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                selectedTextStyle: const TextStyle(color: Colors.black),
                todayDecoration: BoxDecoration(
                  color: Colors.lightGreen[900],
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            Divider(
              height: 30,
              thickness: 1,
              endIndent: 0,
              color: Colors.grey[300],
            ),
            Text(dateFormatterForView.format(selectedDay).toString(),
            style: const TextStyle(
                fontSize: 16
              )
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: getEventsFromDay(selectedDay).isNotEmpty ? getEventsFromDay(selectedDay).map((Event event) => ListTile(
                    title: Text(event.name),
                    subtitle: Text(event.description),
                    onTap: () {
                      TextEditingController nameEditController = TextEditingController(text: event.name);
                      TextEditingController descriptionEditController = TextEditingController(text: event.description);
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(20.0))),
                              content: SizedBox(
                                height: 400,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          const Text('Edit Event',
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 20.0,
                                                color: Colors.black,
                                              ),
                                              onPressed: () async {
                                                EasyLoading.show();
                                                int id = event.id;
                                                final response = await http
                                                    .delete(Uri.parse(
                                                    '$beUrl/api/events/$id'),
                                                    headers: <String, String>{
                                                      'content-type': 'application/json',
                                                      'Authorization': 'Bearer $token',
                                                    }
                                                );
                                                if (response.statusCode == 200) {
                                                  selectedEvents[selectedDay]
                                                      ?.remove(event);
                                                } else {
                                                  var bodyResponse = json.decode(
                                                      response.body);
                                                  showSnackBar(context, bodyResponse['error']['message']);
                                                }
                                                EasyLoading.dismiss();
                                                Navigator.pop(context);
                                                setState(() {});
                                                return;
                                              }
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time_outlined),
                                          const SizedBox(width: 10),
                                          Text(dateFormatterForView.format(
                                              selectedDay).toString()),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      TextFormField(
                                        controller: nameEditController,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(
                                                  15),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey[500]!,
                                                  width: 1.0),
                                              borderRadius: BorderRadius.circular(
                                                  15),
                                            ),
                                            labelText: 'Name',
                                            labelStyle: TextStyle(
                                                color: Colors.grey[500])
                                        ),
                                        cursorColor: Colors.grey,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 2,
                                      ),
                                      const SizedBox(height: 15),
                                      TextFormField(
                                        controller: descriptionEditController,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(
                                                  15),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey[500]!,
                                                  width: 1.0),
                                              borderRadius: BorderRadius.circular(
                                                  15),
                                            ),
                                            labelText: 'Description',
                                            labelStyle: TextStyle(
                                                color: Colors.grey[500])
                                        ),
                                        cursorColor: Colors.grey,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: Text("Cancel", style: TextStyle(
                                      color: Colors.lightGreen[900]!)),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (nameEditController.text.isNotEmpty) {
                                      EasyLoading.show();
                                      Map data = {
                                        'data': {
                                          'name': nameEditController.text,
                                          'description': descriptionEditController.text
                                        }
                                      };
                                      int id = event.id;
                                      final response = await http.put(
                                          Uri.parse('$beUrl/api/events/$id'),
                                          headers: <String, String>{
                                            'content-type': 'application/json',
                                            'Authorization': 'Bearer $token',
                                          },
                                          body: json.encode(data)
                                      );
                                      var bodyResponse = json.decode(response.body);
                                      if (response.statusCode == 200) {
                                        var responseData = bodyResponse['data'];
                                        event.name = responseData['attributes']['name'];
                                        event.description = responseData['attributes']['description'];
                                      } else {
                                        showSnackBar(context, bodyResponse['error']['message']);
                                      }
                                      EasyLoading.dismiss();
                                      Navigator.pop(context);
                                      nameEditController.clear();
                                      descriptionEditController.clear();
                                      setState(() {});
                                      return;
                                    } else {
                                      showSnackBar(context, "Name can't be empty");
                                    }
                                  },
                                  child: const Text("Update",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                      );
                    }
                  )).toList() :
                  [const Padding(
                    padding: EdgeInsets.fromLTRB(0, 75, 0, 0),
                    child: Text('No Events', style: TextStyle(color: Colors.grey)),
                  )],
                )
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Icon(Icons.add),
        backgroundColor: Colors.lightGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: const Text("Add Event"),
              content: SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_outlined),
                          const SizedBox(width: 10),
                          Text(dateFormatterForView.format(selectedDay).toString()),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder:OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[500]!, width: 1.0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Colors.grey[500])
                        ),
                        cursorColor: Colors.grey,
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder:OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[500]!, width: 1.0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.grey[500])
                        ),
                        cursorColor: Colors.grey,
                        keyboardType: TextInputType.multiline,
                        maxLines: 8,
                      ),
                    ]
                  ),
                )
              ),
              actions: [
                TextButton(
                  child: Text("Cancel", style: TextStyle(color: Colors.lightGreen[900]!)),
                  onPressed: () {
                    nameController.clear();
                    descriptionController.clear();
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      EasyLoading.show();
                      Map data = {
                          'data': {
                            'date': dateFormatterForRequest.format(selectedDay).toString(),
                            'name': nameController.text,
                            'description': descriptionController.text
                          }
                      };
                      final response = await http.post(Uri.parse('$beUrl/api/events'),
                          headers: <String, String> {
                          'content-type': 'application/json',
                          'Authorization': 'Bearer $token',
                          },
                          body: json.encode(data)
                      );
                      if (response.statusCode == 200) {
                        var responseData = json.decode(response.body)['data'];
                        Event newEvent = Event(
                            id: responseData['id'],
                            date: DateTime.parse(responseData['attributes']['date']),
                            name: responseData['attributes']['name'],
                            description: responseData['attributes']['description']);
                        if (selectedEvents[selectedDay] != null) {
                          selectedEvents[selectedDay]?.add(newEvent);
                        } else {
                          selectedEvents[selectedDay] = [newEvent];
                        }
                      } else {
                        var bodyResponse = json.decode(response.body);
                        showSnackBar(context, bodyResponse['error']['message']);
                      }
                      EasyLoading.dismiss();
                      Navigator.pop(context);
                      nameController.clear();
                      descriptionController.clear();
                      setState((){});
                      return;
                    }
                    showSnackBar(context, "Name can't be empty");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text("Add", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          );
        }
      ),
    );
  }
}