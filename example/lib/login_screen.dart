import 'package:flutter/material.dart';
import 'package:flutter_mongo_stitch/flutter_mongo_stitch.dart';

import 'home_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum LoginState { login, register }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  var _email = "";//""kfir25816@gmail.com";
  var _password = "";//"12345678";

  var client = MongoStitchClient();
  var _state = LoginState.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login To MongoStitch"),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: _loginForm(),
        ),
      ),
    );
  }

  Widget _loginForm() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              initialValue: _email,
              decoration: InputDecoration(labelText: 'Email'),
              autocorrect: false,
              validator: (val) => val.isEmpty ? "Name can't be empty." : null,
              onSaved: (val) => _email = val,
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: _password,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              autocorrect: false,
              validator: (String val) {
                if (val.isEmpty) return "Password can't be empty.";

                if (val.length < 8)
                  return "Password must be at least 8 charcaters long";

                return null;
              },
              onSaved: (val) => _password = val,
            ),
            SizedBox(height: 36),
            Container(
              width: 200,
              child: RaisedButton(
                color: Colors.red,
                child: Text((_state == LoginState.login) ? 'Login' : 'Register',
                    style: TextStyle(color: Colors.white)),
                onPressed: _submitForm,
              ),
            ),
            SizedBox(height: 12),
            (_state == LoginState.login)
                ? Container(
                    width: 200,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RaisedButton(
                      color: Colors.red,
                      child: Text("Login as Anonymous",
                          style: TextStyle(color: Colors.white)),
                      onPressed: _loginAnonymously,
                    ),
                  )
                : Container(),
            Container(
              width: 200,
              child: RaisedButton(
                color: Colors.green,
                child: Text(
                    "Go to ${(_state == LoginState.login) ? 'register' : 'login'}",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  setState(() {
                    _state = (_state == LoginState.login)
                        ? LoginState.register
                        : LoginState.login;
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _loginAnonymously() async{
    CoreStitchUser mongoUser = await client.auth.loginWithCredential(
        AnonymousCredential()
    );

    if (mongoUser != null) {
      // String userId = mongoUser.id;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));


      Fluttertoast.showToast(
          msg: "Welcome Geust!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    }
  }

  void _submitForm() async {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();

      //hides keyboard
      FocusScope.of(context).requestFocus(FocusNode());

      if (_state == LoginState.login) {
        try {
          CoreStitchUser mongoUser = await client.auth.loginWithCredential(
              UserPasswordCredential(username: _email, password: _password)
//            AnonymousCredential()
              );

          if (mongoUser != null) {
            // String userId = mongoUser.id;
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));

            Fluttertoast.showToast(
                msg: "Welcome back!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1);
          } else {
            return buildErrorDialog(context, "wrong email or password");
          }
        } on Exception catch (_) {}
      } else if (_state == LoginState.register) {}
    }
  }
}

Future buildErrorDialog(BuildContext context, _message) {
  return showDialog(
    builder: (context) {
      return AlertDialog(
        title: Text('Something went wrong...'),
        content: Text(_message),
        actions: <Widget>[
          FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
      );
    },
    context: context,
  );
}
