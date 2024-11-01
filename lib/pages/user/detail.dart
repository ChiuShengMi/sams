import 'package:flutter/material.dart';
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';

class UserDetail extends StatelessWidget {
  final TextEditingController loginEmailInputController =
      TextEditingController(); // Login E-mail Id
  final TextEditingController dataIdInputController =
      TextEditingController(); // Data Id
  final TextEditingController userNameInputController =
      TextEditingController(); // User Name
  final TextEditingController phoneNumberController =
      TextEditingController(); // Phone Number

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Actionbar(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [SmallButton(text: '修正', onPressed: () {})],
                )
              ]),
              CustomInputContainer(
                title: 'User Detail',
                inputWidgets: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 5, child: Text('Login E-mail')),
                      SizedBox(width: 16),
                      Expanded(flex: 1, child: Text('property')),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2, child: Text('data Id')),
                      SizedBox(width: 16),
                      Expanded(flex: 2, child: Text('User Name')),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2, child: Text('Phone Number')),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2, child: Text('classGroup')),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(text: '戻る', onPressed: () {}),
                  SizedBox(width: 16),
                  CustomButton(text: '確認', onPressed: () {}),
                  SizedBox(width: 16)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
