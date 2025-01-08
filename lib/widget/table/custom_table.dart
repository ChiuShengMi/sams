import 'package:flutter/material.dart';
import 'table_styles.dart';

class CustomTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> data;
  final void Function(int rowIndex)? onRowTap; // onRowTap 추가

  CustomTable({
    required this.headers,
    required this.data,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TableStyles.cellDecoration,
      child: Column(
        children: [
          _buildHeaderRow(),
          ..._buildDataRows(context),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      decoration: TableStyles.headerDecoration,
      child: Row(
        children: headers
            .map((header) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8.0),
                    child: Text(
                      header,
                      textAlign: TextAlign.center,
                      style: TableStyles.headerTextStyle,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  List<Widget> _buildDataRows(BuildContext context) {
    return data.asMap().entries.map((entry) {
      int rowIndex = entry.key;
      List<String> rowData = entry.value;

      return _HoverableRow(
        rowIndex: rowIndex,
        rowData: rowData,
        onTap: () {
          if (onRowTap != null) onRowTap!(rowIndex);
        },
      );
    }).toList();
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
          duration: const Duration(milliseconds: 10),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isHovered ? Colors.deepPurple[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
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
                          style: TableStyles.cellTextStyle,
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
