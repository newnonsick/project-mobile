import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/myhomepage.dart';
import 'package:project/page/loginpage.dart';
import 'package:project/page/setusernamepage.dart';
import 'package:project/utils/showtoast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isSecure = true;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink,
              Colors.orange[800]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery.of(context).size.width * 0.4,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      colors: <Color>[
                                        Colors.pink,
                                        Colors.orange[800]!,
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: const Text('LiveScore',
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                )),
                            const SizedBox(height: 25),
                            Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: emailController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        final emailRegex = RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                        if (!emailRegex.hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Enter your email',
                                        hintStyle: TextStyle(
                                          color: Colors.pink[800],
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.pink[800]!,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      obscureText: isSecure,
                                      controller: confirmPasswordController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          hintText: 'Password',
                                          hintStyle: TextStyle(
                                            color: Colors.pink[800],
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.pink[800]!)),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isSecure = !isSecure;
                                              });
                                            },
                                            icon: toggleSecure(),
                                          )),
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      obscureText: isSecure,
                                      controller: passwordController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        if (value != passwordController.text) {
                                          return 'Password does not match';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          hintText: 'Confirm Password',
                                          hintStyle: TextStyle(
                                            color: Colors.pink[800],
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.pink[800]!)),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isSecure = !isSecure;
                                              });
                                            },
                                            icon: toggleSecure(),
                                          )),
                                    ),
                                  ],
                                )),
                            const SizedBox(height: 25),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 15,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    final email = emailController.text;
                                    final password = passwordController.text;
                                    final uid = await registerWithEmailAndPass(
                                        email, password);
                                    if (uid == null) {
                                      ShowToast.show('Failed to register', Colors.red, Colors.white, ToastGravity.BOTTOM);
                                    } else if (uid == 'Email already in use') {
                                      ShowToast.show('Email already in use', Colors.red, Colors.white, ToastGravity.BOTTOM);
                                    } else {
                                      Get.off(() => const LoginPage(),
                                          transition: Transition.fade);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Register',
                                    style: TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Get.off(() => const LoginPage(),
                                    transition: Transition.leftToRight);
                              },
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: 'Login here',
                                      style: TextStyle(
                                        color: Colors.pink,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Text('or'),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 5,
                                    blurRadius: 15,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final user = await signInWithGoogle();
                                  if (user != null) {
                                    login(user.user!.uid);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png',
                                      width: 30,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('Continue with Google',
                                        style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget toggleSecure() {
    return Icon(
      isSecure ? Icons.visibility_off : Icons.visibility,
    );
  }

  Future<String?> registerWithEmailAndPass(
      String email, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // await credential.user!.updateDisplayName(username);
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email already in use';
      }
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }


  void login(String uid) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    if (userSnapshot.docs.isEmpty) {
      var db = FirebaseFirestore.instance.collection('users');
      var token = await getFcmToken();
      db.add({
        'uid': uid,
        'fcmTokens': [token],
        'coins': 0,
        'username': FirebaseAuth.instance.currentUser!.displayName ?? '',
        'guessedCorrect': 0,
        'guessedWrong': 0,
        'correctStreak': 0,
      });
    } else {
      var db = FirebaseFirestore.instance.collection('users');
      var token = await getFcmToken();
      db.doc(userSnapshot.docs[0].id).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'username': FirebaseAuth.instance.currentUser!.displayName ?? '',
      });
    }

    if (_isUserAlreadySetUsername()) {
      Get.off(() => const MyHomePage(), transition: Transition.rightToLeft);
    } else {
      Get.off(() => const SetUsernamePage(),
          transition: Transition.rightToLeft);
    }
  }

  Future<String> getFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  bool _isUserAlreadySetUsername() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.displayName != null && user.displayName!.isNotEmpty;
    }
    return false;
  }
}
