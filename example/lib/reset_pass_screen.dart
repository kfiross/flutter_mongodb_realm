import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mongo_stitch/flutter_mongo_stitch.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final client = MongoStitchClient();
  String _email;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Center(child: _form()),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
            width: 300,
            child: TextFormField(
              initialValue: _email,
              decoration: InputDecoration(labelText: 'Email'),
              autocorrect: false,
              validator: (val) => val.isEmpty ? "Email can't be empty." : null,
              onSaved: (val) => _email = val,
            ),
          ),
          SizedBox(height: 12),
          RaisedButton(
            child: Text("Reset Password"),
            onPressed: _sendEmail,
          )
        ],
      ),
    );
  }

  void _sendEmail() async {
    final form = _formKey.currentState;
    form.save();

    if (form.validate()) {
      try {
        final success = await client.auth
            .sendResetPasswordEmail(_email); //"kfir25812@gmail.com");
        print(success);
      } on PlatformException catch (e) {
        print(e.message ?? 'Unknown error');
      }
    }
  }
}
