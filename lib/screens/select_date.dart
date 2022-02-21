//USE machineType.name and compare to machine name on firebase and make queries

import 'package:flutter/material.dart';
import '../widgets/date_selection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectDate extends StatefulWidget {
  static const routeName = '/selectDate';

  @override
  _SelectDateState createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> {
  var machineType;
  bool isInit = true;
  List listOfMachines = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (isInit) {
      var routeArgs =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      machineType = routeArgs['doc'];
      isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select date'),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("machineType/${machineType.id.toString()}/machines")
              .get(),
          builder: (ctx, AsyncSnapshot<QuerySnapshot> dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var machines = dataSnapshot.data!.docs;
            // machines.forEach((doc) {
            //   print(doc.id);
            // });
            print(machines.length);
            return DateSelection(
              machineTypeDoc: machineType,
              length: machines.length,
            );
          },
        ));
  }
}
