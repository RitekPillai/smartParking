import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartparking/pages/helpPage.dart';
import 'package:smartparking/pages/historyPage.dart';
import 'package:smartparking/pages/housetoUser.dart';
import 'package:smartparking/pages/nearByParking.dart';
import 'package:smartparking/pages/profilePage.dart';
import 'package:smartparking/pages/scannerPage.dart';
import 'package:smartparking/pages/subscription.dart';
import 'package:smartparking/pages/userFeedBack.dart';
import 'package:smartparking/widgets/quickAction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:text_gradiate/text_gradiate.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final supabase = Supabase.instance.client;

  String? getCurrentUserId() {
    final User? user = supabase.auth.currentUser;

    return user!.id;
  }

  Future<String?> fetchUsername() async {
    final String? userId = getCurrentUserId();
    if (userId == null) {
      print('Error: No logged-in user found.');
      return null;
    }

    try {
      final data = await supabase
          .from('users')
          .select("username")
          .eq('id', userId)
          .maybeSingle();

      if (data != null && data.containsKey('username')) {
        debugPrint("---------------------------${data['username']}");
        return data['username'] as String;
      }

      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Row(
            children: [
              FutureBuilder<String?>(
                future: fetchUsername(),
                builder: (context, snapshot) {
                  String username = "";
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    username = "";
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    username = snapshot.data!;
                  }
                  if (snapshot.hasData && snapshot.data == null) {
                    username = 'null';
                  }
                  return Text(
                    'Hello, $username',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        actions: [_buildCustomAppBar()],
      ),
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
            Padding(
              padding: EdgeInsets.all(8),
              child: GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QRCode()),
                    ),
                  ),
                  quickActiontitle(
                    Icons.location_pin,
                    "NearBy Parking",
                    "Find parking areas near you",
                    const Color(0xff00b546),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NearbyParkingScreen(),
                      ),
                    ),
                  ),
                  quickActiontitle(
                    Icons.credit_card,
                    "Subscription Plans",
                    "Save more with monthly plans",
                    const Color(0xffa230fc),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionPage(),
                      ),
                    ),
                  ),
                  quickActiontitle(
                    Icons.history,
                    "Booking History",
                    "View your past bookings",
                    const Color(0xfff95500),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Container(
                width: double.infinity,
                height: 350,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "How it Works",
                        style: GoogleFonts.alexandria(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    howItworksTile(
                      "1",
                      "Search",
                      "Find Parking near your destination",
                      Colors.blue.shade100,
                      Colors.blue,
                    ),
                    howItworksTile(
                      "2",
                      "Select",
                      "Choose duration and pay",
                      Colors.green.shade100,
                      Colors.green,
                    ),
                    howItworksTile(
                      "3",
                      "Park",
                      "Show confirmation",
                      Colors.purple.shade100,
                      Colors.purple,
                    ),
                    howItworksTile(
                      "4",
                      "Enjoy",
                      "Hassle-free parking experience",
                      Colors.orange.shade100,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(height: 200),
            ListTile(
              title: const Text('Home'),
              leading: const Icon(Icons.home),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage()),
                );
              },
            ),
            ListTile(
              title: const Text('Profile'),
              leading: const Icon(Icons.person),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profilepage()),
                );
              },
            ),
            ListTile(
              title: Text("How to Use", style: GoogleFonts.alexandria()),
              leading: const Icon(Icons.menu_book_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HowToUsePage()),
              ),
            ),
            ListTile(
              title: Text("Help", style: GoogleFonts.alexandria()),
              leading: const Icon(Icons.help),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SmartParkingApp()),
              ),
            ),
            ListTile(
              title: Text("Feedback", style: GoogleFonts.alexandria()),
              leading: const Icon(Icons.messenger_outline_sharp),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget howItworksTile(
  String no,
  String title,
  String description,
  Color background,
  Color text,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(shape: BoxShape.circle, color: background),

          child: Center(
            child: Text(
              no,
              style: TextStyle(
                color: text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.alexandria(
              color: Colors.black,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(description, style: GoogleFonts.alexandria(fontSize: 15)),
        ],
      ),
    ],
  );
}
