import 'package:flutter/material.dart';
import 'table_styles.dart';

class CustomTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> data;
  final void Function(int index)? onRowTap; // onRowTap 추가

  CustomTable({
    required this.headers,
    required this.data,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TableStyles.cellDecoration,
      child: Table(
        columnWidths: {
          for (int i = 0; i < headers.length; i++) i: FlexColumnWidth(1),
        },
        children: [
          _buildHeaderRow(),
          ..._buildDataRows(context),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: TableStyles.headerDecoration,
      children: headers
          .map((header) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: TableStyles.headerTextStyle,
                ),
              ))
          .toList(),
    );
  }

  List<TableRow> _buildDataRows(BuildContext context) {
    return data.asMap().entries.map((entry) {
      int rowIndex = entry.key;
      List<String> rowData = entry.value;

      return TableRow(
        decoration: BoxDecoration(
          color: rowIndex % 2 == 0 ? Colors.white : Colors.grey[100],
        ),
        children: rowData.map((cellData) {
          return GestureDetector(
            onTap: () {
              if (onRowTap != null) onRowTap!(rowIndex);
            },
            child: _buildTableCell(cellData),
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TableStyles.cellTextStyle,
      ),
    );
  }
}
