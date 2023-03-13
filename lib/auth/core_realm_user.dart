import 'credentials/stitch_credential.dart';
import 'mongo_realm_auth.dart';

/// A user that belongs to a MongoDB Stitch application.
class CoreRealmUser {
  final String? id;
  final String? deviceId;
  final StitchUserProfile? profile;

  final _realmAuth = MongoRealmAuth();
  CoreRealmUser({
    required this.id,
    this.deviceId,
    this.profile,
  });

  Future<CoreRealmUser?> linkCredentials(StitchCredential credential){
    return _realmAuth.linkCredentials(credential);
  }

  Future<String> getRefreshToken() {
    return _realmAuth.getRefreshToken();
  }

//  final String loggedInProviderType;
//  final String loggedInProviderName;
  //final StitchUserProfileImpl profile;
  Future<bool> get isLoggedIn {
    return _realmAuth.isLoggedIn();
  }
//  final DateTime lastAuthActivity;

  static fromMap(Map? map) {
    return (map == null)
        ? null
        : CoreRealmUser(
            id: map["id"],
            deviceId: map["device_id"],
            profile: StitchUserProfile.fromMap(map['profile'] ?? Map()));
  }
}

class StitchUserProfile {
  final String? name;
  final String? email;
  final String? pictureUrl;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? birthday;
  final String? minAge;
  final String? maxAge;

  StitchUserProfile({
    this.name,
    this.email,
    this.pictureUrl,
    this.firstName,
    this.lastName,
    this.gender,
    this.birthday,
    this.minAge,
    this.maxAge,
  });

  StitchUserProfile.fromMap(Map map)
      : name = map["name"] ?? '',
        email = map["email"] ?? '',
        pictureUrl = map["pictureUrl"] ?? '',
        firstName = map["firstName"] ?? '',
        lastName = map["lastName"] ?? '',
        gender = map["gender"] ?? '',
        birthday = map["birthday"] ?? '',
        minAge = map["minAge"] ?? '',
        maxAge = map["maxAge"] ?? '';
}
