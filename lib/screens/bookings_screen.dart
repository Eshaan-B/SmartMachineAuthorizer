import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatelessWidget {
  static const routeName = "/bookingsPage";
  TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('bookings').get(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var bookings = dataSnapshot.data!.docs;

        return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (ctx, index) {
              var booking = bookings[index];
              DateTime dt = DateTime.parse(booking['date']);
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Enter OTP"),
                      actions: [
                        TextButton(
                          child: Text('Submit'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (_controller.text == "260640") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(
                                      content: Text("Machine authorized")));
                            } else
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text(
                                      "Incorrect password. Try again ater")));
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
                        Text(
                          booking["machineName"],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        //DATE:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                                "Date: ${DateFormat.yMMMd().format(dt).toString()}"),
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
