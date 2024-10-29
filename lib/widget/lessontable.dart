// import 'package:flutter/material.dart';

// class Lessontable extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.all(Radius.circular(20.0)),
//             border: Border.all(color: Colors.black, width: 0.1),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Table(
//                   columnWidths: const {
//                     0: FlexColumnWidth(1),
//                     1: FlexColumnWidth(2),
//                     2: FlexColumnWidth(1),
//                     3: FlexColumnWidth(2),
//                     4: FlexColumnWidth(1),
//                     5: FlexColumnWidth(1),
//                     6: FlexColumnWidth(1),
//                     7: FlexColumnWidth(1),
//                     8: FlexColumnWidth(2),
//                   },
//                   children: [
//                     TableRow(
//                       decoration: BoxDecoration(
//                         color: Colors.purple,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(20.0),
//                           topRight: Radius.circular(20.0),
//                         ),
//                       ),
//                       children: const [
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16.0, horizontal: 8.0),
//                           child: Text('授業名',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16.0, horizontal: 8.0),
//                           child: Text('教師',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16.0, horizontal: 8.0),
//                           child: Text('授業曜日',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16.0, horizontal: 8.0),
//                           child: Text('時間割',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16.0, horizontal: 8.0),
//                           child: Text('QRコード',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16.0, horizontal: 8.0),
//                           child: Text('教室',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16.0, horizontal: 8.0),
//                           child: Text('号館',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 16.0, horizontal: 8.0),
//                           child: Text('編集',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                       ],
//                     ),
//                     ...List.generate(10, (index) {
//                       return buildRow('2223028${index}', 'クォン ドンヒョク', 'SE2A',
//                           'データベース演習', '出席', '2024-05-15', '3', '編集リンク');
//                     }),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   TableRow buildRow(
//     BuildContext context,
//     String subjectName,
//     String teacherName,
//     String date,
//     String classPeriod,
//     String QRcode,
//     String classroom,
//     String place,
//     String editLink,
//   ) {
//     return TableRow(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
//           child: Text(subjectName,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
//           child: Text(teacherName,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
//           child: Text(date,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
//           child: Text(classPeriod,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
//           child: Text(QRcode,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
//           child: Text(classroom,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
//           child: Text(place,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//         InkWell(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => EditPage()),
//             );
//           },
//           child: Padding(
//           padding:const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
//           child: Text(editLink,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//     );],
//     );
//   }
// }
import 'package:flutter/material.dart';

class Lessontable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            border: Border.all(color: Colors.black, width: 0.1),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(1),
                    5: FlexColumnWidth(1),
                    6: FlexColumnWidth(1),
                    7: FlexColumnWidth(1),
                    8: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('授業名',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('教師',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('授業曜日',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('時間割',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('QRコード',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('教室',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('号館',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Text('編集',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...List.generate(10, (index) {
                      return buildRow(context, '2223028${index}', 'クォン ドンヒョク',
                          'SE2A', 'データベース演習', '出席', '2024-05-15', '3', '編集リンク');
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow buildRow(
    BuildContext context,
    String subjectName,
    String teacherName,
    String date,
    String classPeriod,
    String QRcode,
    String classroom,
    String place,
    String editLink,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(subjectName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(teacherName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(date,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(classPeriod,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(QRcode,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(classroom,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(place,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        InkWell(
          onTap: () {
            // Navigator.push(context
            //     //MaterialPageRoute(builder: (context) => EditPage()),
            //     )
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Text(editLink,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
        ),
      ],
    );
  }
}
