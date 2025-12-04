import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget quickActiontitle(
  IconData icons,
  String titile,
  String discription,
  Color color,
  GestureTapCallback onPressed,
) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 300,
      height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(200),
            spreadRadius: 2,
            blurRadius: 10,

            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icons, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 5),
            child: Text(
              titile,
              style: GoogleFonts.alexandria(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(discription, style: GoogleFonts.alexandria()),
          ),
        ],
      ),
    ),
  );
}
