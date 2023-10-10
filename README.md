# flutter_mongodb_realm

Unofficial Flutter plugin for using MongoDB Realm services on Android, iOS and web.

## Getting started
For using it on your app:

```dart
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';
```

For API reference [check here](https://pub.dartlang.org/documentation/flutter_mongodb_realm/latest/)

The minimum requirements are:
 - Android 7.0 (API 24)
 - iOS 13.0

## Setup
Doesn't require any setup besides adding as a dependency
Web integration automatically!

## Supported Features

**Database support (MongoDB Atlas):**
* Insert
* Find
* Delete
* Update
* Watch (also to specified IDs or with Filter)
* Aggregate \[X]


**Auth Providers:**
* Email/Password
* Anonymously
* Google \[X]
* Facebook \[X]
* JWT
* Custom Authentication Function
* Apple ID \[X]


**Authentication:**
* Auth Listener
* Reset Password
* Login/Sign in/Logout
* Link User Identities [X]
* Access token or Refresh token

<b>Functions</b>
* Calling a Realm function

<b>Note:</b> Other more features will come in the future :)

<b>Note:</b> \[X] = Not implemented on Web

## Usage
### Initialization
Inorder to connect a RealmApp to flutter add your main function:
```dart
main() async{
  // ADD THESE 2 LINES
  WidgetsFlutterBinding.ensureInitialized();
  await RealmApp.init(<your_app_id>);
  
  // other configurations..
  
  runApp(MyApp());
}
```

In order to use the client define:
```dart
  final client = MongoRealmClient();
```

### Authentication

In order to use authentication-related operations you have to use `RealmApp` object:
```dart
final Realm app = RealmApp();
```

You can retrieve the current logged user by:
```dart
final user = app.currentUser;

// for more details (like email,birthday) use his 'profile' attribute
// For example:
final userEmail = user.profile.email;
```

#### Login
You can log in using the following providers:
* __Anonymous__
```dart
CoreRealmUser? mongoUser = await app.login(Credentials.anonymous());
```

* __Email\Password__
```dart
CoreRealmUser? mongoUser = await app.login(
  Credentials.emailPassword(username: <email_address>, password: <password>));
```

* __Facebook__

In order to login with Facebook import the required flutter's package and configure in the native side as their instructions.

usage:
```dart
CoreRealmUser? mongoUser = await app.login(
  Credentials.facebook(<access_token>));
```


* __Google__

Inorder to make Google login works, please follow the following instructions use the following:<br><br>
1. Create project in Firebase
2. Add a web app
3. Go to Google Cloud Platorm -> API & services -> Credentials
   [https://console.cloud.google.com/apis/credentials?project=[YOUR_PROJECT_ID]]
4. use the client ID of *WEB*
5. use this client ID and client secret on MongoDB's as Google Authentication
6. create SHA-1 for the app and add it to Firebase project you created
7. Take the serverAuthCode after login, this will work if all set correctly
<br><br>
This has to be done in order to get the auth code need by the Mongo Realm SDK


Calling on Flutter:

```dart
 GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
    clientId: '[YOUR_APP_ID].apps.googleusercontent.com'
);

var account = await _googleSignIn.signIn();
var serverAuthCode = account?.serverAuthCode;

CoreRealmUser? mongoUser = await app.login(GoogleCredential2(serverAuthCode!));
```

* __Custom JWT__
```dart
CoreRealmUser? mongoUser = await app.login(Credentials.jwt(<token>);
```

* __Custom (Auth) Function__
```dart
MongoDocument payload = MongoDocument({
  "username": "bob"
})
CoreRealmUser? mongoUser = await app.login(Credentials.function(payload);
```


* __Apple ID__
1. Add a dependency that implementing signing in with apple, such as [apple_sign_in](https://pub.dev/packages/apple_sign_in), or [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple) 

2. In your Flutter app, retrieve Identify token from the login results
```dart
// taken from the example project using the apple_sign_in plugin
final appleResult = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    if (appleResult.error != null) {
      // handle errors from Apple here
    }

    var idToken =  String.fromCharCodes(appleResult.credential.identityToken);
```
3. Use the token in the `login` function with the `Credentials.apple` auth provider
```dart
CoreRealmUser? mongoUser = app.login(Credentials.apple(idToken));
```

* Custom (Auth) Function:
```dart
MongoDocument payload = MongoDocument({
  "username": "bob"
})
CoreRealmUser mongoUser = await app.login(Credentials.function(payload);
```

<b>NOTE: In any case , if mongoUser != null the login was successful.</b>

#### Register
Register a user with Email\Password

```dart
CoreRealmUser? mongoUser = await app.registerWithEmail(
    email: <email_address>, password: <password>);
```

#### Logout
```dart
await app.currentUser.logout();   // Logout the current user
```

#### Reset Password
You can send an email to reset user password:
(email must be linked to an existing account)
```dart
await app.sendResetPasswordEmail(<YOUR_DESIRED_EMAIL>);
```

#### Auth Listener
You can be notified when the auth state changes, such as login/logout..
```dart
/// for using as smart navigation according to user logged in or not
StreamBuilder _authBuilder(BuildContext context) {
  return StreamBuilder(
    stream: app.authListener(),
    builder: (context, AsyncSnapshot snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.none:
        case ConnectionState.waiting:
          // show loading indicator
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        case ConnectionState.active:
          // log error to console
          if (snapshot.error != null) {
            return Container(
              alignment: Alignment.center,
              child: Text(snapshot.error.toString()),
            );
          }

          // redirect to the proper page
          return snapshot.hasData ? HomeScreen() : LoginScreen();

          default:
            return LoginScreen();
        }
      },
  );
}
```


#### Link User Identities
The app can then link the new identity with the current user.
```dart
CoreRealmUser? mongoUser = app.login(Credentials.anonymous());
user.linkCredentials(Credentials.emailPassword("email", "password"));
```

### Database
To get access to a collection:
```dart
  final collection = client.getDatabase(<database_name>).getCollection(<collection_name>);
```
#### Insert
```dart

collection.insertOne(MongoDocument({
  // key-value pairs describing the document
}));

// OR

List<MongoDocument> documents = ...;
collection.insertMany(documents);
```

#### Find
filtering can be used with QueryOperator class for more robust code
```dart

// fetch all document in the collection
var docs = collection.find();

// fetch all document in the collection applying some filter
var docs = collection.find(
  filter: {
    "year": QueryOperator.gt(2010)..lte(2014), // == 'year'>2010 && 'year'<=2014
});

// optional: can also add find options (projection/limit/sort)
var docs = await collection.find(
  filter: {
    "year": QueryOperator.gt(2010)..lte(2014),
  },
  options: RemoteFindOptions(
    projection: {
      "title": ProjectionValue.INCLUDE,
      "rated": ProjectionValue.INCLUDE,
      "year": ProjectionValue.INCLUDE,
    },
    limit: 70,
    sort: {
      "year": OrderValue.ASCENDING,
    }
  ),
);
```
#### FindIterable
Cleaner way for using `find`
```dart
var docs = await collection.findIterable()
     .limit(70)
     .filter({
       "year": QueryOperator.gt(2010)..lte(2014),
     }).projection({
       "title": ProjectionValue.INCLUDE,
       "rated": ProjectionValue.INCLUDE,
       "year": ProjectionValue.INCLUDE,
     }).sort({
       "year": OrderValue.ASCENDING,
     })
     .find();  // IMPORTANT TO CALL!!
```

#### FindOne
like`find`, but only the first document matched
```dart
// the same as above, but just get the first matched one
var document = await collection.findOne();

var document = await collection.findOne(
  filter: {
    "year": QueryOperator.gt(2010)..lte(2014), // == 'year'>2010 && 'year'<=2014
});


// fetch the number of document in the collection
int collectionSize = await collection.count();

// count the number of document that apply to some filter
int size = await collection.count({
    "age": 25,
});
```


#### Delete
filtering can be used with QueryOperator class for more robust code
```dart
// fetch all documents in the collection
var deletedDocs = await collection.deleteMany({});

// fetch the first document in the collection applying some filter
var deletedDocs = await collection.deleteOne({"age": 24});

// fetch all document in the collection applying some filter
var deletedDocs = 
  await collection.deleteMany({"age": QueryOperator.gte(24)});
```

#### Update
Updating the only first matched document:
```dart
await collection.updateOne(
  // adding a filter (optional)
  filter:{
    "_id": ObjectId('601204a6a80d3fbab2e3a73f'),
  },

  // adding an update operation (as matched the MongoDB SDK ones)
  update: UpdateSelector.set({
    "age": 26,
  });
);
```
Updating the only all matched documents:

```dartawait collection.updateMany(
  // adding a filter (optional)
  filter:{
    "name": "adam",
  },

  // adding an update operation (as matched the MongoDB SDK ones)
  update: UpdateSelector.set({
    "quantity": 670,
  });

  // removing 'apples' from 'favs' array
  update: UpdateOperator.pull({
     "favs": QueryOperator.in$(['apples'])
  });
  
  // adding 'tomatoes' & 'onions into 'favs' array
  update: UpdateOperator.push({
     "favs": ArrayModifier.each(['tomatoes','onions'])
  });
);
```

#### Watch


First, Get the stream to subscribed to any document change in the collection
```dart
final stream = collection.watch();

// (optional) can watch only specified documents by their ids:
// 1. if they defined as ObjectId type
final stream2 = myCollection.watch(ids: ["5eca2d9fff448a4cbf8f6627"]);

// 2. if they defined as String type (`asObjectIds` is true by default)
final stream3 = myCollection.watch(ids: ["22", "8"], asObjectIds: false);
```

OR get the stream to subscribed to  a part of the collection applying
filter on the listened documents
```dart
final streamFilter = collection.watchWithFilter({
  "age": QueryOperator.lte(26)
});
```

Afterwards, set a listener to a change in the collection
```dart
stream.listen((data) {
  // data contains JSON string of the document that was changed
  var fullDocument = MongoDocument.parse(data);
  
  // Do other stuff...
});
```

#### Aggregation
define Pipeline Stages for aggregation, i.e:
```dart
List<PipelineStage> pipeline = [
  PipelineStage.addFields({
    "totalHomework": AggregateOperator.sum("homework"),
    "totalQuiz": AggregateOperator.sum("quiz"),
  }),
  PipelineStage.addFields({
    "totalScore": AggregateOperator.add(
        ["totalHomework", "totalQuiz", "extraCredit"]),
  }),
];
```

And then set the pipelines stages to the aggregate function:
```dart
 var list = await collection.aggregate(pipeline);
```

Another usages (not all stages are supported):
```
List<PipelineStage> pipeline = [
  PipelineStage.skip(2),
  PipelineStage.match({"status": "A"}),
  PipelineStage.group(
    "cust_id",
    accumulators: {"total": AggregateOperator.sum("amount")},
  ),
];

List<PipelineStage> pipeline = [
  PipelineStage.sample(2),
];

// can also RAW typed one
List<PipelineStage> pipeline = [

  PipelineStage.raw({
        //... some expression according to the MongoDB API
  }),
  PipelineStage.raw({
        //... some expression according to the MongoDB API
  }),
  ...
];
```



### Functions
for calling a defined Realm function "sum" with argument 3&4
```dart
var result = await client.callFunction("sum", args: [3, 4])
```
You can also add a timeout (in ms), i.e 60 seconds:
```dart
var result = await client.callFunction("sum", args: [3, 4], requestTimeout: 60000)
```

# Donate

> If you found this project helpful or you learned something from the source code and want to thank me, consider buying me a cup of :coffee:
>
> - [PayPal](https://www.paypal.me/kfiross/)



### Note: flutter_mongo_realm is not directly and/or indirectly associated/affiliated with MongoDB<sup>TM</sup> , Flutter or Google LLC.
