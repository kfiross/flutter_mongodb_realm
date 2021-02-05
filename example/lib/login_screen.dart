import 'package:flutter/material.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

   //  GoogleSignIn _googleSignIn = GoogleSignIn(
   //    scopes: [
   //      'email',
   //    ],
   // //    serverClientId: // "762586994135-je9l46njk4hf63fb1k2jjmh6ep7nk9bv.apps.googleusercontent.com",
   // // "762586994135-je9l46njk4hf63fb1k2jjmh6ep7nk9bv.apps.googleusercontent.com"
   //  );
   //
   //  var s = await _googleSignIn.signIn();
   //  var a = await s.authentication;

    // var idToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjAzYjJkMjJjMmZlY2Y4NzNlZDE5ZTViOGNmNzA0YWZiN2UyZWQ0YmUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI5NTExNjI5MDg4MjMta2VzYjc1Ymd1ZTNidWpkazhyaTBtZ2VyaGhtdnU1MmMuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI5NTExNjI5MDg4MjMtNnQ3a3AxbzFncWs1cWJmbGJvZXQ4Y25rYWRqYjAzdmYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTU3NjY0MDY0NzgwMDI2Mjc2MzIiLCJlbWFpbCI6ImtmaXIyNTgxMkBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6IktmaXJvc3MgTWF0aXR5YWh1IiwicGljdHVyZSI6Imh0dHBzOi8vbGg0Lmdvb2dsZXVzZXJjb250ZW50LmNvbS8tMjJYUThDcVlpMVEvQUFBQUFBQUFBQUkvQUFBQUFBQUFBQUEvQU1adXVjbWl1UGZ0WkVaMnhQQVh6R2hIRzJJN3BKZzVwUS9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiS2Zpcm9zcyIsImZhbWlseV9uYW1lIjoiTWF0aXR5YWh1IiwibG9jYWxlIjoiZW4iLCJpYXQiOjE2MTIzNTg1MzAsImV4cCI6MTYxMjM2MjEzMH0.nP-qstM_zz4ZaCy9vlIkT0FuIwjGR0mK9GBJvTTTcIkq8EIgAOw4D9o5-_HhhbgxrRpXjIj5pV3G0iGWMTSDz1kEpsS9a1UvTfEG_Gpmr2IDSGZ6e0K-XsBPlviH7KiEXW1NJ_V5ZSNlvl6O4P2F9q0PhPcFlJpjWUxxPvSGXlMC3rFZAM4QkXbG55te1yasebexF04yKcB4_4n35GnoGkYN4jsFUX3sMD9sMVMYBAqoaTtQgIXf8yQyLwoomBNt_hgUtyHx-iW7KCQhy6G9wczdkswdakfbVCQ73yXvw7bQGt2Y57mOgGc7WqjP0Xz8m-M2G0kldmRZDV1KZJL5uA";


    CoreRealmUser mongoUser =
        await client.auth.login(//WithCredential(

            GoogleCredential(
                serverClientId: "762586994135-je9l46njk4hf63fb1k2jjmh6ep7nk9bv",
                scopes: ["email"],
            )


    //
    //       Credentials.google(
    //   serverClientId:
    //         // "762586994135-sop8bd99tsec7ng40v3r7r8bu6sk487u",
    //       // "762586994135-b58vl2afhuq76a74ho28c2pm5hi07kbk",
    //          "762586994135-je9l46njk4hf63fb1k2jjmh6ep7nk9bv",
    //   scopes: ["email"],
    // ),
        );

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

        CoreRealmUser mongoUser =
            await client.auth.login(Credentials.facebook(accessToken));


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
          CoreRealmUser mongoUser = await client.auth.login(//(WithCredential(
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
