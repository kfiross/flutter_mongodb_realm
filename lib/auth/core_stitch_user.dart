import 'package:flutter/foundation.dart';

/// A user that belongs to a MongoDB Stitch application.
class CoreStitchUser {
  final String id;
  final String deviceId;

  CoreStitchUser({@required this.id, @required this.deviceId});

//  final String loggedInProviderType;
//  final String loggedInProviderName;
  //final StitchUserProfileImpl profile;
//  final bool isLoggedIn;
//  final DateTime lastAuthActivity;

  static fromMap(Map<String, dynamic> map) {
    return CoreStitchUser(
      id: map["id"],
      deviceId: map["device_id"],
    );
  }
}
