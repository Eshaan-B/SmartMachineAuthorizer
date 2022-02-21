import 'package:flutter/material.dart';
import 'machines.dart';
import 'bookings_screen.dart';

class TabsScreen extends StatelessWidget {
  static const routeName = '/tabsScreen';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Smart Machine Authorizer'),
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              tabs: [
                 Tab(
                  text: "Machines",
                  icon: Icon(Icons.engineering),
                ),
                 Tab(
                  text: "My Bookings",
                  icon: Icon(Icons.list_alt_outlined),
                )
              ],
            ),
            centerTitle: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20))),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.white, Color(0xffCDCDCD)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
            ),
            child: TabBarView(
              children: [
                MachinesPage(),
                BookingsScreen(),
              ],
            ),
          )),
    );
  }
}
