import 'package:flutter/material.dart';

import '../../widgets/c_screen_title.dart';
import '../../widgets/only_back_button_bottom_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: const <Widget>[
            CScreenTitle(title: "Profile"),
            CircleAvatar(
              maxRadius: 100,
              minRadius: 80,
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO Save data
        },
        label: const Text("Save"),
        icon: const Icon(Icons.save),
      ),
      bottomNavigationBar: const OnlyBackButtonBottomAppBar(),
    );
  }
}
