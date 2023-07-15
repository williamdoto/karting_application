import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _email, _password;
  String _errorMessage = ''; // Error message variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey),
                  // labelText: "Email",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black)),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.grey,
                  ),
                ),
                validator: (input) =>
                    !input!.contains('@') ? 'Please enter a valid email' : null,
                onSaved: (input) => _email = input!,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey),
                  // labelText: 'Password',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black)),
                  prefixIcon: Icon(
                    Icons.key,
                    color: Colors.grey,
                  ),
                  suffixIcon: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgetpassword');
                    },
                    child: Text(
                      "Forget Password?",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                validator: (input) =>
                    input!.length < 8 ? 'You need at least 8 characters' : null,
                onSaved: (input) => _password = input!,
                obscureText: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    child: Text("Create account"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      textStyle: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                child: Text("Login"),
                onPressed: _submit,
              ),
              SizedBox(height: 10), // Add some space between the button and error message
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _auth.signInWithEmailAndPassword(email: _email, password: _password);
        // Navigate to the home page after successful login
        Navigator.pushNamed(context, '/home');
      } catch (e) {
        print(e);
        setState(() {
          _errorMessage = 'Invalid email or password'; // Set the error message
        });
      }
    }
  }
}
