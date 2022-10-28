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
        clientId: '247144301956-9500dqr72gsfva7pnr6qq8apda63pblj.apps.googleusercontent.com'
    );

    bool isLogged = await _googleSignIn.isSignedIn();
    if(isLogged){
      await _googleSignIn.signOut();
    }
    var account = await _googleSignIn.signIn();
    var serverAuthCode = account?.serverAuthCode;

    CoreRealmUser? mongoUser = await app.login(GoogleCredential2(serverAuthCode!));

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
