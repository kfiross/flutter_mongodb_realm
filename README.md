# flutter_mongo_stitch

Unofficial Flutter plugin for using MongoDB Stitch services.


## Getting started
For using it on your app:

```dart
import 'package:flutter_mongo_stitch/flutter_mongo_stitch.dart';
```

For API reference [check here](https://pub.dartlang.org/documentation/flutter_mongo_stitch/latest/)

The minimum required it's Android 5.0(API 21) or iOS 11.0

## Setup

#### Android and iOS
Doesn't require any step besides adding as a dependency

#### Web
On your project files, added in `web\index.html`:<br>
Make sure you imported the javascript files:
```html
<head>
... other configurations

    <!-- Importing the official Javascript CDN SDK-->
    <script src="https://s3.amazonaws.com/stitch-sdks/js/bundles/4.9.0/stitch.js"></script>
    
    <!-- Importing the file that connects between dart & js implementations used by the web plugin-->
    <script src='https://fluttermongostitch.s3.us-east-2.amazonaws.com/stitchUtils.js'></script>

</head>
```

## Supported Features

<b>Database support:</b>
* Insert
* Find
* Delete
* Update
* Watch (also to specified IDs or with Filter)
* Aggregate \[X]


<b>Auth Providers:</b>
* Email/Password
* Anonymously
* Google \[X]
* Facebook \[X]

<b>Authentication</b>
* Auth Listener
* Reset Password
* Login/Sign in/Logout

<b>Functions</b>
* Calling a Stitch function

<b>Note:</b> Other more features will come in the future :)

<b>Note:</b> \[X] = Not implemented on Web

## Usage
### Initialization
Inorder to connect a StitchApp to flutter add your main function:
```dart
main() async{
  // ADD THESE 2 LINES
  WidgetsFlutterBinding.ensureInitialized();
  await MongoStitchClient.initializeApp(<your_app_id>);
  
  // other configurations..
  
  runApp(MyApp());
}
```

Inorder to use the client define:
```dart
  final client = MongoStitchClient();
```

### Authentication

 Inorder to use the auth part define:
```dart
final auth = client.auth;
```

You can retrieve the current logged user by:
```dart
final user = client.auth.user;

// for more details (like email,birthday) use his 'profile' attribute
// For example:
final userEmail = user.profile.email;
```

#### Login
Login a user with Anonymous provider:
```dart
CoreStitchUser mongoUser = await auth.loginWithCredential(AnonymousCredential());
```

Login a user with Email\Password provider:
```dart
CoreStitchUser mongoUser = await auth.loginWithCredential(
  UserPasswordCredential(username: <email_address>, password: <password>));
```

For login with Facebook import the required flutter's package and configure in the native side as their instructions.

Login a user using Google provider:

<b>
    Inorder to make Google login works, please follow the follwing instructions use the following:<br><br>
    1. Remove (if used) the version used from pubspec.yaml (ex. google_sign_in: ^4.5.1) <br>
    2. Use git repo version instead (copy from below)<br>
    3. In dart code use also serverClientId parmeter
    <br><br>
    This has to be done in order to get the auth code need by the Mongo Stitch SDK
</b>

calling on flutter:
```dart
CoreStitchUser mongoUser = await auth.loginWithCredential(
  GoogleCredential(
    serverClientId: <Google Server Client Id>, // just the start from "<ID>.apps.googleusercontent.com"   
    scopes: <list of scopes>,
));
```
in pubspec.yaml:
```
.. (other dependencies)
google_sign_in:
  git:
    url: git://github.com/fbcouch/plugins.git
    path: packages/google_sign_in
    ref: server-auth-code
```


```dart
CoreStitchUser mongoUser = await auth.loginWithCredential(
  GoogleCredential(
    serverClientId: <Google Server Client Id>, // just the start from "<ID>.apps.googleusercontent.com"   
    scopes: <list of scopes>,
));
```

Login a user using Facebook provider:
```dart
CoreStitchUser mongoUser = await auth.loginWithCredential(
  FacebookCredential(<access_token>));
```

<b>NOTE: In any case , if mongoUser != null the login was successful.</b>

#### Register
```dart
// Login a user with Email\Password
CoreStitchUser mongoUser = await auth.registerWithEmail(
    email: <email_address>, password: <password>);
```

#### Logout
```dart
// Logout the current user:
await auth.logout()
```

#### Reset Password
You can send an email to reset user password:
(email must be linked to an existing account)
```dart
await client.auth.sendResetPasswordEmail(<YOUR_DESIRED_EMAIL>);
```

#### Auth Listener
You can be notified when the auth state changes, such as login/logout..
```dart
/// for using as smart navigation according to user logged in or not
StreamBuilder _authBuilder(BuildContext context) {
  return StreamBuilder(
    stream: client.auth.authListener(),
    builder: (context, AsyncSnapshot snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.none:case ConnectionState.waiting:
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
filtering can be used with QuerySelector class for more robust code
```dart

// fetch all document in the collection
var docs = collection.find();

// fetch all document in the collection applying some filter
var docs = collection.find(
  filter: {
    "year": QuerySelector.gt(2010)..lte(2014), // == 'year'>2010 && 'year'<=2014
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


// the same as above, but just get the first matched one
var document = await collection.findOne();

var document = await collection.findOne(
  filter: {
    "year": QuerySelector.gt(2010)..lte(2014), // == 'year'>2010 && 'year'<=2014
});


// fetch the number of document in the collection
int collectionSize = await collection.count();

// count the number of document that apply to some filter
int size = await collection.count({
    "age": 25,
});
```

#### Delete
filtering can be used with QuerySelector class for more robust code
```dart
// fetch all documents in the collection
var deletedDocs = await collection.deleteMany({});

// fetch the first document in the collection applying some filter
var deletedDocs = await collection.deleteOne({"age": 24});

// fetch all document in the collection applying some filter
var deletedDocs = 
  await collection.deleteMany({"age": QuerySelector.gte(24)});
```

#### Update
```dart

await collection.updateMany(
  // adding a filter (optional)
  filter:{
    "name": "adam",
  },

  // adding an update operation (as matched the MongoDB SDK ones)
  update: UpdateSelector.set({
    "quantity": 670,
  })
);

// OR
await collection.updateOne(
  // the same as above, just it's updated the only first matched one
)
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
  "age": QuerySelector.lte(26)
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
for calling a defined stitch function "sum" with argument 3&4
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
> - [PayPal](https://www.paypal.me/naama24198/)



### Note: flutter_mongo_stitch is not directly and/or indirectly associated/affiliated with MongoDB<sup>TM</sup> , Flutter or Google LLC.
