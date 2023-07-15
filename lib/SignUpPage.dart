import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _email, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              validator: (input) => !input!.contains('@')
                  ? 'Please enter a valid email'
                  : null,
              onSaved: (input) => _email = input!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              validator: (input) =>
                  input!.length < 8 ? 'You need at least 8 characters' : null,
              onSaved: (input) => _password = input!,
              obscureText: true,
            ),
            ElevatedButton(
              child: Text("Sign Up"),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
        Navigator.of(context).pop();
      } catch (e) {
        print(e);
      }
    }
  }
}
