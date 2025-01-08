import 'package:flutter/material.dart';

class Lessontable extends StatelessWidget {
  final List<Map<String, dynamic>> lessonData;
  final String course;

  Lessontable({required this.lessonData, required this.course});

  @override
  Widget build(BuildContext context) {
    List<String> headers = [
      "授業名",
      "教室",
      "コース",
      "曜日",
      "時間",
      "号館",
    ];

    List<List<String>> data = lessonData.map((lesson) {
      return [
        lesson['CLASS']?.toString() ?? 'N/A',
        lesson['CLASSROOM']?.toString() ?? 'N/A',
        lesson['COURSE']?.toString() ?? 'N/A',
        lesson['DAY']?.toString() ?? 'N/A',
        lesson['TIME']?.toString() ?? 'N/A',
        lesson['PLACE']?.toString() ?? 'N/A',
      ];
    }).toList();

    return Column(
      children: [
        _buildHeaderRow(headers),
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _HoverableRow(
                rowIndex: index,
                rowData: data[index],
                onTap: () {
                  final selectedLesson = lessonData[index];
                  print("Selected Lesson: ${selectedLesson['CLASS']}");
                  // 상세 화면 이동 로직 추가 가능
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(List<String> headers) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: headers
            .map((header) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8.0),
                    child: Text(
                      header,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _HoverableRow extends StatefulWidget {
  final int rowIndex;
  final List<String> rowData;
  final VoidCallback onTap;

  const _HoverableRow({
    required this.rowIndex,
    required this.rowData,
    required this.onTap,
  });

  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            color: isHovered ? Colors.deepPurple[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 2,
                      offset: Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: widget.rowData
                .map((cellData) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 8.0),
                        child: Text(
                          cellData,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
