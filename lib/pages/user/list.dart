import 'package:flutter/material.dart';
import 'package:sams/widget/actionbar.dart';
import 'package:sams/widget/appbar.dart';
import 'package:sams/widget/button/custom_button.dart';
import 'package:sams/widget/custom_input_container.dart';
import 'package:sams/widget/dropbox/custom_dropdown.dart';
import 'package:sams/widget/searchbar/custom_input.dart';
import 'package:sams/widget/table/custom_table.dart';

class UserList extends StatelessWidget {
  final TextEditingController searchInputController = TextEditingController();

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
                children: [
                  Expanded(
                      flex: 1,
                      child: Customdropdown(
                        hintText: 'Select Option',
                        items: [],
                        onChanged: (value) {},
                        size: DropboxSize.medium,
                      )),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 4,
                      child: CustomInput(
                          controller: searchInputController,
                          hintText: 'Search')),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(child: MediumButton(text: '検索', onPressed: () {}))
                ],
              )
            ]),
            CustomInputContainer(title: 'User List', inputWidgets: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: CustomTable(headers: [
                    '授業名',
                    '教師',
                    '授業曜日',
                    '時間割',
                    'QRコード',
                    '教室',
                    '号館',
                    '編集'
                  ], data: [
                    [
                      'Math',
                      'Mr. A',
                      'Mon',
                      '10:00',
                      'QR123',
                      '101',
                      'Bldg 1',
                      'Edit'
                    ],
                    [
                      'Science',
                      'Ms. B',
                      'Tue',
                      '11:00',
                      'QR456',
                      '202',
                      'Bldg 2',
                      'Edit'
                    ],
                    [
                      'History',
                      'Dr. C',
                      'Wed',
                      '09:00',
                      'QR789',
                      '303',
                      'Bldg 3',
                      'Edit'
                    ],
                  ])),
                ],
              )
            ])
          ],
        ),
      )),
    );
  }
}
