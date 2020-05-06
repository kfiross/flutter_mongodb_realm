import 'stitch_credential.dart';

class FacebookCredential extends StitchCredential{
  final List<String> permissions;
  FacebookCredential({this.permissions});
}