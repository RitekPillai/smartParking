import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_gradiate/text_gradiate.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Find Your Perfect ",
                      style: GoogleFonts.alexandria(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Center(
                      child: TextGradiate(
                        text: Text(
                          textAlign: TextAlign.center,
                          "Parking Spot",
                          style: GoogleFonts.alexandria(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        colors: [Colors.blue, Colors.green],
                      ),
                    ),
                  ],
                ),
                Text(
                  "Search,book,and park with ease",
                  style: GoogleFonts.alexandria(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
                CupertinoSearchTextField(),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              textAlign: TextAlign.start,
              "Quick Actions",
              style: GoogleFonts.alexandria(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),
            GridView(
              shrinkWrap:
                  true, // <--- ADDED for use inside a Column/SingleChildScrollView
              physics:
                  const NeverScrollableScrollPhysics(), // Prevent GridView from scrolling independently
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15.0,
                crossAxisSpacing: 15.0,
                childAspectRatio: 0.8,
              ),
              children: [
                quickActiontitle(
                  Icons.qr_code,
                  "Scan Qr Code",
                  "Quick entry by scanning parking QR",
                  Colors.blue,
                ),
                quickActiontitle(
                  Icons.location_pin,
                  "NearBy Parking",
                  "Find parking areas near you",
                  const Color(0xff00b546),
                ),
                quickActiontitle(
                  Icons.credit_card,
                  "Subscription Plans",
                  "Save more with monthly plans",
                  const Color(0xffa230fc),
                ),
                quickActiontitle(
                  Icons.history,
                  "Booking History",
                  "View your past bookings",
                  const Color(0xfff95500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget quickActiontitle(
  IconData icons,
  String titile,
  String discription,
  Color color,
) {
  return Container(
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
  );
}
