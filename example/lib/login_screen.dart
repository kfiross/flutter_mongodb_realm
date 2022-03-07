import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:google_sign_in/google_sign_in.dart';

import 'login_custom.dart';
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
  var app = RealmApp();
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
                validator: (val) =>
                    val != null && val.isEmpty ? "Name can't be empty." : null,
                onSaved: (val) => _email = val,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 300,
              child: TextFormField(
                initialValue: _password,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                autocorrect: false,
                validator: (val) {
                  if (val != null && val.isEmpty)
                    return "Password can't be empty.";

                  if (val!.length < 6)
                    return "Password must be at least 6 charcaters long";

                  return null;
                },
                onSaved: (val) => _password = val,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: 220,
              child: RaisedButton(
                color: Colors.red,
                child: Text((_state == LoginState.login) ? 'Login' : 'Register',
                    style: TextStyle(color: Colors.white)),
                onPressed: _submitForm,
              ),
            ),
            SizedBox(height: 12),
            if (_state == LoginState.login) ...[
              Column(
                children: <Widget>[
                  Container(
                    width: 220,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RaisedButton(
                      color: Colors.red,
                      child: Text("Login as Anonymous",
                          style: TextStyle(color: Colors.white)),
                      onPressed: _loginAnonymously,
                    ),
                  ),
                  Container(
                    width: 220,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RaisedButton(
                      color: Colors.red,
                      child: Text("Login with Facebook",
                          style: TextStyle(color: Colors.white)),
                      onPressed: _loginWithFacebook,
                    ),
                  ),
                  Container(
                    width: 220,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RaisedButton(
                      color: Colors.red,
                      child: Text("Login with Google",
                          style: TextStyle(color: Colors.white)),
                      onPressed: _loginWithGoogle,
                    ),
                  ),
                  Container(
                    width: 220,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RaisedButton(
                      color: Colors.red,
                      child: Text("Login with Custom Function",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CustomLoginScreen())),
                    ),
                  ),
                  Container(
                    width: 220,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: SignInWithAppleButton(
                      onPressed: _loginWithApple,
                    ),
                  ),
                ],
              )
            ],
            const SizedBox(height: 12),
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
    CoreRealmUser? mongoUser = await app.login(Credentials.anonymous());

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
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );

    var s = await _googleSignIn.signIn();
    var serverAuthCode = s?.serverAuthCode;

    // var idToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjAzYjJkMjJjMmZlY2Y4NzNlZDE5ZTViOGNmNzA0YWZiN2UyZWQ0YmUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI5NTExNjI5MDg4MjMta2VzYjc1Ymd1ZTNidWpkazhyaTBtZ2VyaGhtdnU1MmMuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI5NTExNjI5MDg4MjMtNnQ3a3AxbzFncWs1cWJmbGJvZXQ4Y25rYWRqYjAzdmYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTU3NjY0MDY0NzgwMDI2Mjc2MzIiLCJlbWFpbCI6ImtmaXIyNTgxMkBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6IktmaXJvc3MgTWF0aXR5YWh1IiwicGljdHVyZSI6Imh0dHBzOi8vbGg0Lmdvb2dsZXVzZXJjb250ZW50LmNvbS8tMjJYUThDcVlpMVEvQUFBQUFBQUFBQUkvQUFBQUFBQUFBQUEvQU1adXVjbWl1UGZ0WkVaMnhQQVh6R2hIRzJJN3BKZzVwUS9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiS2Zpcm9zcyIsImZhbWlseV9uYW1lIjoiTWF0aXR5YWh1IiwibG9jYWxlIjoiZW4iLCJpYXQiOjE2MTIzNTg1MzAsImV4cCI6MTYxMjM2MjEzMH0.nP-qstM_zz4ZaCy9vlIkT0FuIwjGR0mK9GBJvTTTcIkq8EIgAOw4D9o5-_HhhbgxrRpXjIj5pV3G0iGWMTSDz1kEpsS9a1UvTfEG_Gpmr2IDSGZ6e0K-XsBPlviH7KiEXW1NJ_V5ZSNlvl6O4P2F9q0PhPcFlJpjWUxxPvSGXlMC3rFZAM4QkXbG55te1yasebexF04yKcB4_4n35GnoGkYN4jsFUX3sMD9sMVMYBAqoaTtQgIXf8yQyLwoomBNt_hgUtyHx-iW7KCQhy6G9wczdkswdakfbVCQ73yXvw7bQGt2Y57mOgGc7WqjP0Xz8m-M2G0kldmRZDV1KZJL5uA";

    CoreRealmUser? mongoUser = await app.login(//WithCredential(

        // ignore: deprecated_member_use
        // GoogleCredential(
        //     serverClientId: '762586994135-gqn337ha77t07clhs4rs6lcbl1f87a6s',
        //     scopes: ["email"],
        // )

        GoogleCredential2(serverAuthCode!));

    // CoreRealmUser? mongoUser =
    //     await app.login(//WithCredential(
    //
    //         // ignore: deprecated_member_use
    //         GoogleCredential(
    //             serverClientId: "762586994135-gqn337ha77t07clhs4rs6lcbl1f87a6s",
    //             scopes: ["email"],
    //         )

    //
    //       Credentials.google(
    //   serverClientId:
    //         // "762586994135-sop8bd99tsec7ng40v3r7r8bu6sk487u",
    //       // "762586994135-b58vl2afhuq76a74ho28c2pm5hi07kbk",
    //          "762586994135-je9l46njk4hf63fb1k2jjmh6ep7nk9bv",
    //   scopes: ["email"],
    // ),
    //     );

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
    final FacebookAuth fbLogin = FacebookAuth.i;

    LoginResult result = await fbLogin.login(
      permissions: ['email', 'public_profile'],
      loginBehavior: LoginBehavior.webOnly,
    );

    switch (result.status) {
      case LoginStatus.success:
        var facebookToken = result.accessToken;
        String accessToken = facebookToken!.token;

        CoreRealmUser? mongoUser =
            await app.login(Credentials.facebook(accessToken));

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

      case LoginStatus.cancelled:
        break;

      case LoginStatus.failed:
        break;

      case LoginStatus.operationInProgress:
        break;
    }
  }

  void _loginWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ]);

    if (credential.identityToken == null) {
      // handle errors from Apple here
      return;
    }

    var idToken = credential
        .identityToken!; // String.fromCharCodes(credential.identityToken!);

    CoreRealmUser? mongoUser = await app.login(Credentials.apple(idToken));

    if (mongoUser != null) {
      print("logged in as ${mongoUser.id}");

      Fluttertoast.showToast(
        msg: "Welcome AppleID user!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    } else {
      print("wrong pass or username");
    }
  }

  void _submitForm() async {
    final form = formKey.currentState;
    form!.save();
    if (form.validate()) {
      //hides keyboard
      FocusScope.of(context).requestFocus(FocusNode());

      if (_state == LoginState.login) {
        try {
          CoreRealmUser? mongoUser =
              await app.login(Credentials.emailPassword(_email, _password));

          if (mongoUser != null) {
            String userId = mongoUser.id!;
            print("Logged in as id=$userId");

            // Navigator.pushReplacement(
            //     context, MaterialPageRoute(builder: (_) => HomeScreen()));

            Fluttertoast.showToast(
                msg: "Welcome back!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1);
          } else {
            return buildErrorDialog(context, "wrong email or password");
          }
        } on Exception catch (_) {}
      } else if (_state == LoginState.register) {
        bool isSuccess = await app.registerUser(_email, _password);
        if (isSuccess) {
          var mongoUser =
              await app.login(Credentials.emailPassword(_email, _password));

          String userId = mongoUser!.id!;
          print("Logged in as id=$userId");

          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (_) => HomeScreen()));

          Fluttertoast.showToast(
              msg: "Hello there!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        }
      }
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
