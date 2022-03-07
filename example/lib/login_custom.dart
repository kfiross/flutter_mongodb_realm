import 'package:flutter/material.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';

class CustomLoginScreen extends StatefulWidget {
  @override
  _CustomLoginScreenState createState() => _CustomLoginScreenState();
}

class _CustomLoginScreenState extends State<CustomLoginScreen> {
  final formKey = GlobalKey<FormState>();
  final app = RealmApp();
  String? _username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Custom Function Login"),
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
                initialValue: _username,
                decoration: InputDecoration(labelText: 'Username'),
                autocorrect: false,
                validator: (val) =>
                    val != null && val.isEmpty ? "Name can't be empty." : null,
                onSaved: (val) => _username = val ?? "",
              ),
            ),
            SizedBox(height: 36),
            Container(
              width: 200,
              child: RaisedButton(
                color: Colors.red,
                child: Text('Login', style: TextStyle(color: Colors.white)),
                onPressed: _submitForm,
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();

      //hides keyboard
      FocusScope.of(context).requestFocus(FocusNode());

      CoreRealmUser? mongoUser = await app.login(
        Credentials.customFunction(MongoDocument.single('username', _username)),
      );

      if (mongoUser != null) {
        Navigator.pop(context);
      }
    }
  }
}
