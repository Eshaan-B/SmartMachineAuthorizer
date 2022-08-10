import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_time.dart';

class SelectMachine extends StatefulWidget {
  static const routeName = '/selectMachine';

  @override
  _SelectMachineState createState() => _SelectMachineState();
}

class _SelectMachineState extends State<SelectMachine> {
  dynamic machineType;
  String? bookingId;
  DateTime? bookingDate;
  int? otp;

  // Booking currentBooking;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    machineType = routeArgs['machineType'];
    bookingId = routeArgs['bookingId'];
    bookingDate=routeArgs['date'];
    otp = routeArgs['otp'];
  }

  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void selectMachine(dynamic selectedMachine) async {
    setState(() {
      _isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({
      'machineId': selectedMachine.id,
    }).then((_) {
      Navigator.of(context).pushNamed(SelectTime.routeName, arguments: {
        'machineType': machineType,
        'machine': selectedMachine,
        'bookingId': bookingId,
        'date': bookingDate,
        'otp':otp
      });
    }).catchError((err) {
      print(err);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("An error occured - $err")));
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .delete();
        return true;
      },
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Select a ${machineType['name']}'),
          ),
          body: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('machineType/${machineType.id}/machines')
                .get(),
            builder: (ctx, AsyncSnapshot<QuerySnapshot> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              var machines = dataSnapshot.data!.docs;

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: machines.length,
                itemBuilder: (context, index) {
                  return GridTile(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        selectMachine(machines[index]);
                      },
                      child: Container(
                        height: 500,
                        child: Card(
                          elevation: 4,
                          child: Center(
                            child: Text(
                                "${machines[index]['machineType']} ${index + 1}"),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          )),
    );
  }
}
