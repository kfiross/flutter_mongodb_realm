## [2.0.0-nullsafety.0]
* Migrated into Null-Safety

## [1.2.6]
* a list of objects turned into one object (issue #31)

## [1.2.5+2]
* README updated.

## [1.2.5+1]
* Fixed `pub.dev` score.

## [1.2.5]
* Added `Sign With Apple ID` auth provider.

## [1.2.4]
* Return null for empty `findOne` Query. (issue #23)

## [1.2.3]
* Updated `insertOne` and `insertMany` to return results of inserted ids. (issue #22)

## [1.2.2]
* `ObjectId` can be used (Also fixing issue #18). 

## [1.2.1+1]
* README updated.

## [1.2.1]
* Using the latest web plugin version.

## [1.2.0]
* Added `Custom JWT` auth provider.
* Added `Custom Function` auth provider.

## [1.1.0]
**Major Update:**<br>
Package now uses names close to the native one introduced in Realm SDK:
* `client.auth` now deprecated in favor of `app`:
    * `auth.loginWithCredential` now deprecated in favor of `app.login`<br>
    for example:
      - `AnonymusCredential()` => `Credentails.anonymus()`
      - `UserPasswordCredential(..)` => `Credentails.emailPassword(..)`
      - `FacebookCredential(..)` => `Credentails.facebook(..)`
      <br>
      and so on..
      
    * `auth.logout()` now deprecated in favor of `app.currentUser.logout()`
    * `auth.user` now deprecated in favor of `app.currentUser`
* Initialization app: use `Realm.init(<APP_ID>)` instead `MongoClient.initializeApp(<APP_ID>)`


## [1.0.0]
* BREAKING CHANGES: Renamed package to `flutter_mongodb_realm` and every `xxStitch` object to `xxRealm` object 

## [0.8.1]
* fixed issue with default app set

## [0.8.0]
* Updated for no-setup at web

## [0.7.1]
* Using the web plugin as endorsed plugin

## [0.7.0]
* Added web support by default

## [0.7.0-dev.6]
* Added web support (for using `sendResetPassword`)

## [0.7.0-dev.5]
* Added web support (for using `authListener()` stream)

## [0.7.0-dev.4]
* Added web support (for using `watch` on collection and calling Stitch Functions)

## [0.7.0-dev.3]
* Added web support (for Auth usage, not included Facebook\Google login)

## [0.7.0-dev.2]
* updated README for using on web

## [0.7.0-dev.1]
* Added web support (for Database usage)

## [0.6.1]
* Added support of watch collection with specified list of ids
* Fixed `watchWithFilter()` to work correctly

## [0.6.0]

<b> Breaking Changes </b>
* Google/Facebook login dependencies used outside of the plugin
* fix bug crashing the app when using plugin on new Flutter projects

## [0.5.1]

* Added auth listener support also on iOS

## [0.5.0]

* Added auth listener support inorder to monitor auth state changes (Android only)

## [0.4.2]

* Added `sendResetPasswordEmail`,`getUser` functions

## [0.4.1+2]

* Fixed bugs for not using correctly defined timeout in calling a stitch function

## [0.4.1+1]

* Updated dependencies

## [0.4.1]

* Added support of using aggregation on a collection

## [0.4.0+2]

* Now using id-part only for auth code instead full string

## [0.4.0+1]

* Bug fixing

## [0.4.0]

* Added Google and Facebook as available login providers

## [0.3.0]

* Updated `find` and `findOne` collection functions to be able to use projection/sort/limit

## [0.2.0+3]

* Fixed missing find/insert results.

## [0.2.0]

* Added support for calling a Stitch function.

## [0.1.0]

* Initial release.
