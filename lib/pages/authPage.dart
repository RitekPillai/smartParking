import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool isObscucure = true;
  bool isLogin = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );

    final passwordRegex = RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,20}$",
    );

    final supabaseAuth = Supabase.instance.client.auth;
    final supabase = Supabase.instance.client;
    void signUp(String email, String password, String name) async {
      try {
        final AuthResponse res = await supabaseAuth.signUp(
          email: email,
          password: password,
        );

        final user = res.user;

        if (user != null) {
          var snackBar = SnackBar(content: Text('Sign up successful!!.'));
          await supabase.from('users').insert({
            'id': user.id,
            'username': name,
          });
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } on AuthException catch (e) {
        print(e.message);
      } catch (e) {
        print('An unexpected error occurred: $e');
      }
    }

    void login(String email, String password) async {
      try {
        final AuthResponse res = await supabaseAuth.signInWithPassword(
          email: email,
          password: password,
        );

        // The 'session' and 'user' objects are non-null on success
        if (res.session != null && res.user != null) {
          var snackBar = SnackBar(content: Text('Login successful! '));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } on AuthException catch (e) {
        print(e.message);
      } catch (e) {
        print('An unexpected error occurred: $e');
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xfff3f8fe),
            Color(0xfff3f8fe),
            Color(0xfff3f8fe),
            Color(0xfff3f8fe),
            Color(0xfff3f8fe),

            Colors.lightGreenAccent,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const SizedBox(height: 100),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: Container(
                  width: double.infinity,
                  height: 700,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.blue, Colors.green],
                          ),
                        ),
                        child: Icon(
                          Icons.car_crash,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),

                        child: isLogin
                            ? Text(
                                key: ValueKey(0),
                                "Welcome Back!",
                                style: GoogleFonts.alexandria(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              )
                            : Text(
                                "Welcome!!!",
                                style: GoogleFonts.alexandria(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                      ),
                      const SizedBox(height: 5),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: isLogin
                            ? Text(
                                key: ValueKey(0),
                                " Login To find your perfect Parking Spot",
                                style: GoogleFonts.alexandria(
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                key: ValueKey(1),
                                "SignUp to Create Your Account",
                                style: GoogleFonts.alexandria(
                                  color: Colors.black,
                                ),
                              ),
                      ),
                      const SizedBox(height: 35),

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                textAlign: TextAlign.start,
                                "Email Address",
                                style: GoogleFonts.alexandria(fontSize: 15),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: TextFormField(
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email cannot be empty';
                                  }
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.mail_outline,
                                    color: Colors.grey,
                                    size: 25,
                                  ),
                                  hintText: "example@gmail.com",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            const SizedBox(height: 5),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              child: !isLogin
                                  ? SizedBox(
                                      key: ValueKey(0),
                                      height: 90,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20.0,
                                            ),
                                            child: Text(
                                              textAlign: TextAlign.start,
                                              "FullName",
                                              style: GoogleFonts.alexandria(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                            ),
                                            child: TextFormField(
                                              errorBuilder:
                                                  (context, errorText) {
                                                    return Text(errorText);
                                                  },
                                              maxLines: 1,
                                              controller: nameController,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Full name can not be null";
                                                }

                                                return null;
                                              },

                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  size: 25,
                                                  color: Colors.grey,
                                                ),

                                                hintText: "Enter Your Fullname",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                textAlign: TextAlign.start,
                                "Password",
                                style: GoogleFonts.alexandria(fontSize: 15),
                              ),
                            ),

                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: TextFormField(
                                errorBuilder: (context, errorText) {
                                  return Text(errorText);
                                },
                                maxLines: 1,
                                controller: passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return " password can not be empty";
                                  }
                                  if (!passwordRegex.hasMatch(value)) {
                                    return 'Password must be 8-20 characters, include uppercase,  lowercase, number, and a special character (@\$!%*?&).';
                                  }
                                  return null;
                                },
                                obscureText: isObscucure ? true : false,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock_outlined,
                                    size: 25,
                                    color: Colors.grey,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isObscucure = !isObscucure;
                                      });
                                    },
                                    icon: Icon(
                                      isObscucure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_rounded,
                                    ),
                                  ),
                                  hintText: "Enter Your Password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [Colors.blue, Colors.green],
                                  ),
                                ),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    shadowColor: WidgetStatePropertyAll(
                                      Colors.transparent,
                                    ),
                                    backgroundColor: WidgetStatePropertyAll(
                                      Colors.transparent,
                                    ),
                                    fixedSize: WidgetStatePropertyAll(
                                      Size(350, 50),
                                    ),
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),

                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      if (isLogin) {
                                        login(
                                          emailController.text,
                                          passwordController.text,
                                        );
                                      } else {
                                        signUp(
                                          emailController.text,
                                          passwordController.text,
                                          nameController.text,
                                        );
                                      }
                                    } else {
                                      debugPrint("Form invalid");
                                    }
                                  },
                                  child: Text(
                                    isLogin ? "Login" : "SignUp",
                                    style: GoogleFonts.alexandria(
                                      color: Colors.white,

                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: isLogin
                                      ? Text(
                                          key: ValueKey(0),
                                          "Don't have a account?",
                                          style: GoogleFonts.poppins(),
                                        )
                                      : Text(
                                          key: ValueKey(1),
                                          "Already have a account?",
                                          style: GoogleFonts.poppins(),
                                        ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isLogin = !isLogin;
                                    });
                                  },
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    child: isLogin
                                        ? Text(
                                            key: ValueKey(0),
                                            "Register Now",
                                            style: GoogleFonts.poppins(
                                              color: Colors.blueAccent,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : Text(
                                            key: ValueKey(1),
                                            "Login now",
                                            style: GoogleFonts.poppins(
                                              color: Colors.blueAccent,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
