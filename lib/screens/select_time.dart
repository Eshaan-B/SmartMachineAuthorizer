import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/booking_status.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'tabs_screen.dart';

class SelectTime extends StatefulWidget {
  static const routeName = '/selectTime';

  @override
  _SelectTimeState createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  List<String> timeSlots = [
    "0000 - 130",
    "0200 - 330",
    "0400 - 530",
    "0600 - 730",
    "0800 - 930",
    "1000 - 11.30",
    "1200 - 1330",
    "1400 - 1530",
    "1600 - 1730",
    "1800 - 1930",
    "2000 - 2130",
    "2200 - 2330",
  ];
  bool isInit = false;
  dynamic machineType;
  dynamic machine;
  String? bookingId;
  DateTime? bookingDate;
  bool isLoading = false;
  int? otp;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    machineType = routeArgs['machineType'];
    machine = routeArgs['machine'];
    bookingId = routeArgs['bookingId'];
    bookingDate = routeArgs['date'];
    otp=routeArgs['otp'];
  }

  Future<bool> updateToRealtime(var myData) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "bookings/${myData["machineTypeId"]}/${myData["machineId"]}/${bookingId}");
    try {
      await ref.set({"bookingId": myData["id"], "otpVerified": false,"otp":otp,"latest":1});
      return true;
    } catch (err) {
      print(err.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time slot selection')),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection(
                "machineType/${machineType.id}/machines/${machine.id}/timeSlots")
            .get(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          var slots = dataSnapshot.data!.docs;

          return ListView.builder(
            itemCount: slots.length,
            itemBuilder: (ctx, index) {
              var slot = slots[index];
              return Card(
                color: (slot['status'] == "booked")
                    ? Colors.redAccent
                    : Colors.greenAccent,
                child: ListTile(
                  title: Text("${slot.id.toString()} hrs"),
                  onTap: (slot['status'] == "booked")
                      ? null
                      : () async {
                          showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                    title: const Text("Confirm booking"),
                                    content: Text(
                                      "Selected booking date:\n ${DateFormat.yMMMd().format(bookingDate!).toString()}\nSelected time slot:\n  ${slot.id} hrs \n\nDo you want to confirm your booking?",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        letterSpacing: 1.2,
                                        fontSize: 15,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('No'),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('bookings')
                                              .doc(bookingId)
                                              .delete();
                                          Navigator.popUntil(
                                            context,
                                            ModalRoute.withName(
                                                TabsScreen.routeName),
                                          );
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Yes'),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection(
                                                  'machineType/${machineType.id}/machines/${machine.id}/timeSlots')
                                              .doc(slot.id)
                                              .update({
                                            'status': "booked",
                                          });
                                          //updating timeSlots in bookings
                                          await FirebaseFirestore.instance
                                              .collection('bookings')
                                              .doc(bookingId)
                                              .update({
                                            'timeSlot': slot.id.toString(),
                                            'status':
                                                Status.completed.toString()
                                          });
                                          dynamic myData;

                                          await FirebaseFirestore.instance
                                              .collection('bookings')
                                              .where('id', isEqualTo: bookingId)
                                              .get()
                                              .then((data) {
                                            myData = data.docs[0].data();
                                            print("myData fetched");
                                            print(myData);
                                          }).catchError((err) {
                                            print(
                                                "Error while fetching myData");
                                            print(err);
                                          });
                                          //updating bookings in machines
                                          FirebaseFirestore.instance
                                              .collection(
                                                  'machineType/${machineType.id}/machines/${machine.id}/bookings')
                                              .doc(bookingId)
                                              .set(myData)
                                              .then((value) => print(
                                                  "BookingId pushed to machine"))
                                              .catchError((err) {
                                            print(
                                                "Error while pushing bookingId to machine");
                                            print(err);
                                          });
                                          //updating to realtimeDB
                                          await updateToRealtime(myData);

                                          Navigator.popUntil(
                                              context,
                                              ModalRoute.withName(
                                                  TabsScreen.routeName));
                                          //Navigator.of(context).pop();
                                          print('popped');
                                        },
                                      )
                                    ],
                                  ));
                        },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
