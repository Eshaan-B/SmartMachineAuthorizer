import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/select_machine.dart';
import '../utils/booking_status.dart';
import 'dart:math';

class DateSelection extends StatefulWidget {
  dynamic machineTypeDoc;
  final int length;

  DateSelection({required this.machineTypeDoc, required this.length});

  @override
  _DateSelectionState createState() => _DateSelectionState();
}

class _DateSelectionState extends State<DateSelection> {
  DateTime? _pickedDate;
  bool _isLoading = false;
  String? bookingId = null;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
    ).then((selectedDate) {
      if (selectedDate == null) return;

      setState(() {
        //_pickedDate = DateFormat.yMMMd().format(selectedDate).toString();
        _pickedDate = selectedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _pickedDate != null
          ? FloatingActionButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                      });
                      //generating random OTP

                      Random rnd = new Random();
                      var otp = rnd.nextInt(1000000) + 100000;
                      await FirebaseFirestore.instance
                          .collection('bookings')
                          .add({
                        'id': null,
                        'status': Status.inProgress.toString(),
                        'date': _pickedDate?.toIso8601String(),
                        'machineName': widget.machineTypeDoc['name'],
                        'machineTypeId': widget.machineTypeDoc.id.toString(),
                        'machineId': null,
                        'userId': null,
                        'timeSlot': null,
                        'otp': otp,
                        'otpVerified': false,
                      }).then((docRef) async {
                        bookingId = docRef.id.toString();
                        await FirebaseFirestore.instance
                            .collection('bookings')
                            .doc(docRef.id.toString())
                            .update({'id': bookingId}).then((_) {
                          Navigator.of(context)
                              .pushNamed(SelectMachine.routeName, arguments: {
                            'machineType': widget.machineTypeDoc,
                            'bookingId': bookingId,
                            'date': _pickedDate,
                            'otp': otp
                          });
                        }).catchError((err) {
                          print("Error while updating bookingId");
                          throw err;
                        });
                      }).catchError((err) {
                        print(err);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("And error occured - $err")));
                      });
                      setState(() {
                        _isLoading = false;
                      });
                    },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.arrow_forward,
                        ),
                        Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
            )
          : Container(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        children: [
          const Text(
            'Step 1 of 2',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Selected machine:    ",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(widget.machineTypeDoc['name'])
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text('Number of machines available:  ${widget.length}'),
            ],
          ),
          const Divider(),
          Row(
            children: const [
              Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            widget.machineTypeDoc['description'],
            style: const TextStyle(
                height: 1.3, color: Colors.blueGrey, fontSize: 14),
          ),
          const Divider(),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () => _presentDatePicker(),
            child: const Text("Click here to pick date"),
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your picked date: ',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              _pickedDate == null
                  ? const Text('No date picked')
                  : Text(
                      DateFormat.yMMMd().format(_pickedDate!).toString(),
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
