import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> data;
  final void Function(int rowIndex)? onDetailTap;

  CustomTable({
    required this.headers,
    required this.data,
    this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
        columnWidths: {
          for (int i = 0; i < headers.length; i++) i: FlexColumnWidth(1),
        },
        children: [
          _buildHeaderRow(),
          ..._buildDataRows(),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
      ),
      children: headers
          .map((header) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ))
          .toList(),
    );
  }

  List<TableRow> _buildDataRows() {
    return data.asMap().entries.map((entry) {
      int rowIndex = entry.key;
      List<String> rowData = entry.value;

      return TableRow(
        decoration: BoxDecoration(
          color: rowIndex % 2 == 0 ? Colors.white : Colors.grey.shade100,
        ),
        children: rowData.asMap().entries.map((cellEntry) {
          int cellIndex = cellEntry.key;
          String cellData = cellEntry.value;

          // Check if it's the "詳細" column
          if (cellIndex == headers.length - 1 && onDetailTap != null) {
            return GestureDetector(
              onTap: () => onDetailTap!(rowIndex),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  cellData,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              cellData,
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      );
    }).toList();
  }
}
