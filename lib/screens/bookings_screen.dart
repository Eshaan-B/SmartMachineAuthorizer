import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

import 'dart:convert';

class BookingsScreen extends StatefulWidget {
  static const routeName = "/bookingsPage";

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  TextEditingController _controller = new TextEditingController();

  bool authorized = false;
  int relayStatus = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('bookings').get(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var bookings = dataSnapshot.data!.docs;

        return bookings.length <= 0
            ? const Center(child: Text("No bookings"))
            : ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (ctx, index) {
              var booking = bookings[index];
              DateTime dt = DateTime.parse(booking['date']);
              relayStatus = booking['relay'];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) =>
                        AlertDialog(
                          title: const Text("Enter OTP"),
                          actions: [
                            TextButton(
                              child: Text('Submit'),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                CollectionReference bookings = FirebaseFirestore
                                    .instance
                                    .collection('bookings');
                                var otp = booking['otp'];
                                print(otp.runtimeType);
                                if (int.parse(_controller.text) == otp) {


                                  //updating to firestore
                                  await FirebaseFirestore.instance
                                      .collection('bookings')
                                      .doc(booking['id'])
                                      .update({
                                    'otpVerified': true,
                                    'relay': relayStatus == 1 ? 0 : 1
                                  });
                                  //updating to realtimeDB
                                  FirebaseDatabase database =
                                      FirebaseDatabase.instance;
                                  DatabaseReference ref =
                                  FirebaseDatabase.instance.ref(
                                      "bookings/${booking["machineTypeId"]}/${booking["machineId"]}/${booking["id"]}");
                                  await ref.update({
                                    "otpVerified": true,
                                    "relay": relayStatus == 1 ? 0 : 1
                                  });

                                  setState(() {
                                    authorized = true;
                                   relayStatus = relayStatus == 1 ? 0 : 1;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Machine authorized")));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Incorrect password. Try again later")));
                                }
                              },
                            ),
                          ],
                          content: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter OTP',
                            ),
                          ),
                        ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              booking["machineName"],
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.circle,
                              color: relayStatus == 1
                                  ? Colors.green
                                  : Colors.red,
                              size: 10,
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        //DATE:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                                "Date: ${DateFormat.yMMMd()
                                    .format(dt)
                                    .toString()}"),
                            Text("Time slot: ${booking["timeSlot"]} hrs"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}
