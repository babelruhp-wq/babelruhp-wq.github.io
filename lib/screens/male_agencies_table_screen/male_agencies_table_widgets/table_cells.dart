import 'package:flutter/material.dart';

class TableCells {
  final Color gridColor;
  const TableCells({required this.gridColor});

  Widget headerCell(String text, {double w = 150, bool last = false}) {
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          right: last ? BorderSide.none : BorderSide(color: gridColor, width: 1),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget gridCellText(String text, {double w = 150, bool last = false}) {
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          right: last ? BorderSide.none : BorderSide(color: gridColor, width: 1),
        ),
      ),
      child: Center(
        child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget gridCellWidget(Widget child, {double w = 150, bool last = false}) {
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          right: last ? BorderSide.none : BorderSide(color: gridColor, width: 1),
        ),
      ),
      child: Center(child: child),
    );
  }
}
