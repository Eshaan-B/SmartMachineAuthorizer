import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/machine_item.dart';

class MachinesPage extends StatelessWidget {
  static const routeName = '/machinesPage';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('machineType').get(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final documents = dataSnapshot.data!.docs;
        documents.forEach((doc) {
          print(doc['name']);
        });

        return documents.isEmpty
            ? const Center(child: Text("No machines in the Fablab!"))
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return MachineItem(
                      machineType: documents[index],
                    );
                  },
                ),
              );
      },
    );
  }
}
