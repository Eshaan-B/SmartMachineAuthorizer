import 'package:flutter/material.dart';
import 'tabs_screen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = "/loginPage";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xff0C475B), Color(0xff168A91)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(child: Image.asset('assets/images/Fablab.png')),
                  const SizedBox(
                    height: 20,
                  ),
                  const TextField(
                    decoration: InputDecoration(
                        labelText: 'Enter SRM email',
                        suffixIcon: Icon(Icons.email),
                        filled: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff168A91)))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const TextField(
                    decoration: InputDecoration(
                        labelText: 'Enter SRM email',
                        suffixIcon: Icon(Icons.vpn_key_outlined),
                        filled: true,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.deepOrangeAccent))),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(TabsScreen.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xff168A91),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Text('Login'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
