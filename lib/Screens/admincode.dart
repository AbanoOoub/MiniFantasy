import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:minifantasy/Screens/admin.dart';

import '../widgets.dart';

class AdminCodePage extends StatelessWidget {
  const AdminCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController codeController = new TextEditingController();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          defaultFormField(
            label: 'Code',
            type: TextInputType.text,
            controller: codeController,
            prefix: Icons.lock,
            isPassword: true,
            context: context,
          ),
          SizedBox(height: 10),
          defaultBottom(
              width: 200.0,
              text: 'Enter',
              onPressed: () {
                if (codeController.text == "Lotfy_Fantasy1") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AdminPage()),
                  );
                } else {
                  Fluttertoast.showToast(msg: 'Please don\'t to this again');
                }
              }),
        ],
      ),
    );
  }
}
