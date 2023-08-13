import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widget/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _islogin = true;
  final _formKey = GlobalKey<FormState>();
  var _enterdEmail = "";
  var _enterdPassword = "";
  File? _imageSelected;
  var _isUploading = false;
  var _username = "";
  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || !_islogin && _imageSelected == null) {
      return;
    }
    _formKey.currentState!.save();
    try {
      setState(() {
        _isUploading = true;
      });
      if (_islogin) {
        //login logic
        final userLogin = _firebase.signInWithEmailAndPassword(
          email: _enterdEmail,
          password: _enterdPassword,
        );
        print(userLogin);
      } else {
        //register logic

        // ignore: unused_local_variable
        final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enterdEmail,
          password: _enterdPassword,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${userCredential.user!.uid}.jpg");
        await storageRef.putFile(_imageSelected!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("theusers")
            .doc(userCredential.user!.uid)
            .set({
          'username': _username,
          'email': _enterdEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (eror) {
      if (eror.code == "email-already-in-use") {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(eror.message ?? "Auth Field")));
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(
              top: 30,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Image.asset("assets/images/chat.png"),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_islogin)
                        UserImagePicker(
                          onSelectedImage: (pickedImage) {
                            _imageSelected = pickedImage;
                          },
                        ),
                      if (!_islogin)
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: "UserName",
                          ),
                          enableSuggestions: false,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 4) {
                              return "5 xaraf kama yarankaro username ku!";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _username = newValue!;
                          },
                        ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Email",
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains("@")) {
                            return "Iska hubi in uu emailku shaqynyo";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enterdEmail = newValue!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Password",
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return "kama yaraan karo 6 charater";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enterdPassword = newValue!;
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      if (_isUploading) CircularProgressIndicator(),
                      if (!_isUploading)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                          onPressed: _submit,
                          child: Text(_islogin ? "Login" : "Singup"),
                        ),
                      if (!_isUploading)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _islogin = !_islogin;
                            });
                          },
                          child: Text(_islogin
                              ? "Create  and account"
                              : "i have anaccount"),
                        )
                    ],
                  )),
            ),
          )
        ]),
      )),
    );
  }
}
