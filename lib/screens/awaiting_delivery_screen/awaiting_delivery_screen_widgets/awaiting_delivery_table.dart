import 'package:babel_final_project/models/awaiting_delivery_row.dart';
import 'package:flutter/material.dart';

class AwaitingDeliveryTable extends StatefulWidget {
  const AwaitingDeliveryTable({super.key});

  @override
  State<AwaitingDeliveryTable> createState() => _AwaitingDeliveryTableState();
}

class _AwaitingDeliveryTableState extends State<AwaitingDeliveryTable> {
  final TextEditingController searchCtrl = TextEditingController();

  int pageSize = 10;
  int pageIndex = 0; // 0-based

  // دي الداتا الأصلية (Mock)
  final List<AwaitingDeliveryRow> allRows = List.generate(732, (i) {
    return AwaitingDeliveryRow(
      index: i + 1,
      workerName: "NAME ${i + 1}",
      passportNo: "EQ${1000000 + i}",
      sponsor: "Sponsor ${i + 1}",
      nationalId: "${1000000000 + i}",
      officeName: "Eshal",
      arrival: "26/12/2025",
      notes: "",
    );
  });

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterRows(allRows, searchCtrl.text);
    final paged = _pageRows(filtered, pageIndex, pageSize);


    return LayoutBuilder(
      builder: (context, constraints) {
        // لو parent مديش ارتفاع (unbounded) ندي ارتفاع افتراضي
        final double height = constraints.maxHeight.isFinite ? constraints.maxHeight : 650;

        return SizedBox(
          height: height,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                _buildToolbar(context),
                const SizedBox(height: 10),

                Expanded(
                  child: _buildTable(context, paged),
                ),

                const SizedBox(height: 10),
                _buildPagination(context, total: filtered.length),
              ],
            ),
          ),
        );
      },
    );
  }
  // =========================
  // Filtering + Paging
  // =========================
  List<AwaitingDeliveryRow> _filterRows(List<AwaitingDeliveryRow> rows, String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return rows;

    return rows.where((r) {
      return r.workerName.toLowerCase().contains(query) ||
          r.passportNo.toLowerCase().contains(query) ||
          r.sponsor.toLowerCase().contains(query) ||
          r.nationalId.toLowerCase().contains(query) ||
          r.officeName.toLowerCase().contains(query);
    }).toList();
  }

  List<AwaitingDeliveryRow> _pageRows(List<AwaitingDeliveryRow> rows, int page, int size) {
    final start = page * size;
    if (start >= rows.length) return const [];
    final end = (start + size) > rows.length ? rows.length : (start + size);
    return rows.sublist(start, end);
  }

  // =========================
  // Toolbar
  // =========================
  Widget _buildToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x11000000)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 220,
            height: 36,
            child: TextField(
              controller: searchCtrl,
              onChanged: (_) {
                setState(() => pageIndex = 0);
              },
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 18),
                hintText: "بحث",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const Spacer(),
          _pageSizeDropdown(),
          const SizedBox(width: 8),
          _toolBtn("طباعة", onTap: () {}),
          _toolBtn("Pdf", onTap: () {}),
          _toolBtn("Excel", onTap: () {}),
          _toolBtn("Csv", onTap: () {}),
          _toolBtn("حذف", onTap: () {}, danger: true),
        ],
      ),
    );
  }

  Widget _pageSizeDropdown() {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x22000000)),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: DropdownButton<int>(
        value: pageSize,
        underline: const SizedBox(),
        items: const [10, 25, 50, 100]
            .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() {
            pageSize = v;
            pageIndex = 0;
          });
        },
      ),
    );
  }

  Widget _toolBtn(String text, {required VoidCallback onTap, bool danger = false}) {
    return SizedBox(
      height: 34,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: danger ? Colors.red : const Color(0xFF374151),
          side: BorderSide(
            color: danger ? Colors.red.shade200 : const Color(0x22000000),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        child: Text(text),
      ),
    );
  }

  // =========================
  // Table
  // =========================
  Widget _buildTable(BuildContext context, List<AwaitingDeliveryRow> rows) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x11000000)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 42,
          dataRowMinHeight: 42,
          dataRowMaxHeight: 46,
          dividerThickness: 0.6,
          columns: const [
            DataColumn(label: Text("#")),
            DataColumn(label: Text("اسم العاملة")),
            DataColumn(label: Text("رقم جواز السفر")),
            DataColumn(label: Text("صاحب العمل")),
            DataColumn(label: Text("رقم الهوية")),
            DataColumn(label: Text("اسم المكتب")),
            DataColumn(label: Text("الوصول")),
            DataColumn(label: Text("الملاحظات الأخرى")),
            DataColumn(label: Text("الإجراءات")),
          ],
          rows: List.generate(rows.length, (i) {
            final r = rows[i];

            return DataRow(
              color: MaterialStateProperty.resolveWith((_) {
                return i.isEven ? const Color(0xFFF7F7F7) : Colors.white;
              }),
              cells: [
                DataCell(Text("${r.index}")),
                DataCell(Text(r.workerName)),
                DataCell(Text(r.passportNo)),
                DataCell(Text(r.sponsor)),
                DataCell(Text(r.nationalId)),
                DataCell(Text(r.officeName)),
                DataCell(Text(r.arrival)),
                DataCell(Text(r.notes)),
                DataCell(_rowActions(r)),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _rowActions(AwaitingDeliveryRow r) {
    return Row(
      spacing: 6,
      children: [
        _smallGreenBtn("تسليم", onTap: () {}),
        _smallGreenBtn("طباعة", onTap: () {}),
      ],
    );
  }

  Widget _smallGreenBtn(String text, {required VoidCallback onTap}) {
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF84C341),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  // =========================
  // Pagination
  // =========================
  Widget _buildPagination(BuildContext context, {required int total}) {
    final totalPages = (total / pageSize).ceil().clamp(1, 1000000);
    final start = total == 0 ? 0 : (pageIndex * pageSize) + 1;
    final end = ((pageIndex + 1) * pageSize) > total
        ? total
        : ((pageIndex + 1) * pageSize);

    return Row(
      children: [
        IconButton(
          onPressed: pageIndex > 0 ? () => setState(() => pageIndex--) : null,
          icon: const Icon(Icons.chevron_right), // RTL
        ),
        ..._pageButtons(totalPages),
        IconButton(
          onPressed: pageIndex < totalPages - 1
              ? () => setState(() => pageIndex++)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        const Spacer(),
        Text("$start-$end of $total"),
      ],
    );
  }

  List<Widget> _pageButtons(int totalPages) {
    final from = (pageIndex - 2).clamp(0, totalPages - 1);
    final to = (pageIndex + 2).clamp(0, totalPages - 1);

    return List.generate(to - from + 1, (i) {
      final p = from + i;
      final selected = p == pageIndex;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          height: 32,
          width: 32,
          child: OutlinedButton(
            onPressed: () => setState(() => pageIndex = p),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: BorderSide(
                color: selected
                    ? const Color(0xFF3A4262)
                    : const Color(0x22000000),
              ),
              backgroundColor:
              selected ? const Color(0x0F3A4262) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              "${p + 1}",
              style: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    });
  }
}
