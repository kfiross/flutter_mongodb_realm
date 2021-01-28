import 'package:flutter/material.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'reset_pass_screen.dart';

enum LoginState { login, register }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  var _email;
  var _password;

  var client = MongoRealmClient();
  var _state = LoginState.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome To MongoRealm"),
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
            Container(
              width: 300,
              child: TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email'),
                autocorrect: false,
                validator: (val) => val.isEmpty ? "Name can't be empty." : null,
                onSaved: (val) => _email = val,
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: 300,
              child: TextFormField(
                initialValue: _password,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                autocorrect: false,
                validator: (String val) {
                  if (val.isEmpty) return "Password can't be empty.";

                  if (val.length < 6)
                    return "Password must be at least 6 charcaters long";

                  return null;
                },
                onSaved: (val) => _password = val,
              ),
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
                ? Column(
                    children: <Widget>[
                      Container(
                        width: 200,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: RaisedButton(
                          color: Colors.red,
                          child: Text("Login as Anonymous",
                              style: TextStyle(color: Colors.white)),
                          onPressed: _loginAnonymously,
                        ),
                      ),
                      Container(
                        width: 200,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: RaisedButton(
                          color: Colors.red,
                          child: Text("Login with Facebook",
                              style: TextStyle(color: Colors.white)),
                          onPressed: _loginWithFacebook,
                        ),
                      ),
                      Container(
                        width: 200,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: RaisedButton(
                          color: Colors.red,
                          child: Text("Login with Google",
                              style: TextStyle(color: Colors.white)),
                          onPressed: _loginWithGoogle,
                        ),
                      ),
                    ],
                  )
                : Container(),
            SizedBox(height: 12),
            InkWell(
              child: Text("Forgot password?"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ResetPasswordScreen()));
              },
            ),
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

  void _loginAnonymously() async {
    CoreRealmUser mongoUser =
        await client.auth.login(Credentials.anonymous());

    if (mongoUser != null) {
      // String userId = mongoUser.id;
//      Navigator.pushReplacement(
//          context, MaterialPageRoute(builder: (_) => HomeScreen()));

      Fluttertoast.showToast(
          msg: "Welcome Geust!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    }
  }

  _loginWithGoogle() async {
    CoreRealmUser mongoUser =
        await client.auth.login(Credentials.google(
      serverClientId: "614805511929-lc92msgps9tr32slg8hqt9taqa3q3kbv",
      scopes: ["email"],
    ));

    if (mongoUser != null) {
      print("logged in as ${mongoUser.id}");

      Fluttertoast.showToast(
        msg: "Welcome Google user!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    } else {
      print("wrong pass or username");
    }
  }

  _loginWithFacebook() async {
    final FacebookLogin fbLogin = FacebookLogin();

    fbLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;

    FacebookLoginResult result = await fbLogin.logIn([
      'email',
      'public_profile',
    ]);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        var facebookToken = await fbLogin.currentAccessToken;
        String accessToken = facebookToken.token;

        CoreRealmUser mongoUser = await client.auth
            .login(Credentials.facebook(accessToken));

        if (mongoUser != null) {
          print("logged in as ${mongoUser.id}");

          Fluttertoast.showToast(
            msg: "Welcome Facebook user!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
          );
        } else {
          print("wrong pass or username");
        }

        break;

      case FacebookLoginStatus.cancelledByUser:
        break;

      case FacebookLoginStatus.error:
        break;
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
          CoreRealmUser mongoUser = await client.auth.login(
              Credentials.emailPassword(_email, _password)
//            AnonymousCredential()
              );

          if (mongoUser != null) {
            // String userId = mongoUser.id;
//            Navigator.pushReplacement(
//                context, MaterialPageRoute(builder: (_) => HomeScreen()));

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
