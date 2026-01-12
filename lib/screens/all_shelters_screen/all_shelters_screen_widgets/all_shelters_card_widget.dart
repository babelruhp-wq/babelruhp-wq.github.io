import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../localization/translator.dart';

class AllSheltersCardWidget extends StatelessWidget {
  final Map item;
  final int index;
  final VoidCallback onAwaitingDeliveryTap;

  const AllSheltersCardWidget({super.key, required this.item, required this.onAwaitingDeliveryTap, required this.index});

  @override
  Widget build(BuildContext context) {
    final Color base = Color(item['color'] as int);
    final String title = tr(context, item['key']);
    final String number = "${item['number']}";

    return InkWell(
      onTap: index == 0 ? onAwaitingDeliveryTap : null,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                spreadRadius: 0,
                offset: Offset(0, 10),
                color: Color(0x14000000),
              ),
            ],
            border: Border.all(color: const Color(0x11000000)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        base.withOpacity(0.95),
                        base.withOpacity(0.75),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: const Icon(
                          Icons.home_work_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Row(
                    children: [
                      // Big number
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              number,
                              style: GoogleFonts.cairo(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111827),
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),

                // Bottom subtle line
                Container(height: 1, color: const Color(0x0F000000)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
