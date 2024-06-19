import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class SyncDetailsTable extends StatelessWidget {
  final int? count;
  final DateTime? lastSync;

  const SyncDetailsTable(this.count, this.lastSync);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: GoogleFonts.robotoMono(),
      child: Table(
        columnWidths: const {0: FixedColumnWidth(100)},
        children: [
          TableRow(
            children: [
              const Text('Entries'),
              Text(count?.toString() ?? 'N/A'),
            ],
          ),
          TableRow(
            children: [
              const Text('Last Sync'),
              Text(
                (lastSync != null) ? timeago.format(lastSync!) : 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
