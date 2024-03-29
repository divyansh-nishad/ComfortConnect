import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:talkspace/screens/homepage.dart';

class SignUpForm extends StatefulWidget {
  final Function()? onTap;
  const SignUpForm({Key? key, required this.onTap}) : super(key: key);
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _gender;
  late bool _isFemale;
  late int _age;
  late String _password;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  void wrongErrorMessage(String message) {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Text(message, style: TextStyle(color: Colors.white)),
        );
      }),
    );
  }

  // sign user up method
  void signUserUp() async {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      if (_name.isEmpty) {
        wrongErrorMessage("Full Name cannot be empty");
      }

      await registerUserWithEmailandPassword(_name, _email, _password)
          .then((value) async {
        Navigator.pop(context);
        if (value == true) {}
      });
    } on FirebaseAuthException catch (e) {
      wrongErrorMessage(e.message!);
    }
  }

  Future registerUserWithEmailandPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        // call our database service to update the user data.
        user.updateDisplayName(fullName);
        // await DatabaseService(uid: user.uid).savingUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register here',
            style: GoogleFonts.balsamiqSans(
              // color: Colors.grey,
              fontSize: 20,
            )),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Image(
                  image: AssetImage('assets/images/sign.png'),
                  height: 120,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('ComfortConnect',
                      style: GoogleFonts.balsamiqSans(
                        // color: Colors.grey,
                        fontSize: 24,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Help us train our AI to better understand your mental health",
                    style: GoogleFonts.balsamiqSans(
                      color: Colors.deepPurpleAccent,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  style: GoogleFonts.balsamiqSans(
                      // color: Colors.grey,
                      // fontSize: 20,
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  style: GoogleFonts.balsamiqSans(
                      // color: Colors.grey,
                      // fontSize: 20,
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  style: GoogleFonts.balsamiqSans(
                      // color: Colors.grey,
                      // fontSize: 20,
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your gender';
                    }
                    if (value == 'Female') {
                      _isFemale = true;
                    } else {
                      _isFemale = false;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _gender = value!;
                  },
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  style: GoogleFonts.balsamiqSans(
                      // color: Colors.grey,
                      // fontSize: 20,
                      ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _age = int.parse(value!);
                  },
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  style: GoogleFonts.balsamiqSans(
                      // color: Colors.grey,
                      // fontSize: 20,
                      ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        signUserUp();
                        // _submitForm();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const MentalHealthApp()),
                        // );
                        // perform sign-up action
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Text(
                      'Sign up',
                      style: GoogleFonts.balsamiqSans(
                          // color: Colors.grey,
                          // fontSize: 20,
                          ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(color: Colors.brown.shade300),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        widget.onTap!();
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Build the request body as a Map
      Map<String, dynamic> requestBody = {
        'name': _name,
        'email': _email,
        // 'phoneNumber': _phoneNumber,
        'age': _age,
        'gender': _gender,
        'isFemale': _isFemale,
        // 'menstrualCycle': _menstrualCycle,
      };

      // Convert the request body to JSON format
      String requestBodyJson = json.encode(requestBody);

      try {
        // Send the POST request to the server
        http.Response response = await http.post(
          Uri.parse(
              'https://abbe-2409-4051-99-9893-6f4b-4200-be67-8763/api/register'),
          headers: {'Content-Type': 'application/json'},
          body: requestBodyJson,
        );

        if (response.statusCode == 200) {
          // Request successful, do something with the response
          print('POST request successful');
          print(response.body);
        } else {
          // Request failed
          print('POST request failed with status: ${response.statusCode}');
        }
      } catch (error) {
        // An error occurred
        print('Error sending POST request: $error');
      }
    }
  }
}
