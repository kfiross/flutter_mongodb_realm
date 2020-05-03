# flutter_mongo_stitch

A Flutter plugin for using MongoStitch services.


## Getting started
For using it on your app:

```dart
import 'package:flutter_mongo_stitch/flutter_mongo_stitch.dart';
```

For API reference [check here](https://pub.dartlang.org/documentation/flutter_mongo_stitch/latest/)

The minimum required it's Android 5.0(API 21) or iOS 11.0

## Supported Features

<b>Database support:</b>
* Insert
* Find
* Delete
* Update
* Watch

<b>Auth Providers:</b>
* Email/Password
* Anonymously

<<b>Functions</b>
* Calling a Stitch function

<b>Note:</b> Other features will come in the future (like Functions)

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

#### Login
```dart
//  Inorder to use the auth part define:
final auth = client.auth;

// Login a user with Email\Password provider:
CoreStitchUser mongoUser = await auth.loginWithCredential(
    UserPasswordCredential(username: <email_address>, password: <password>));

// Login a user with Anonymous provider:
CoreStitchUser mongoUser = await auth.loginWithCredential(AnonymousCredential());

//NOTE: In any case , if mongoUser != null the login was successful.
```

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
collection.find();

// fetch all document in the collection applying some filter
collection.find({
  "year": QuerySelector.gt(2010)..lte(2014), // == 'year'>2010 && 'year'<=2014
});

// the same as above, but just get the first matched one
collection.findOne();

collection.findOne({
  "year": QuerySelector.gt(2010)..lte(2014),
});


// fetch the number of document in the collection
collection.count();

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
```dart

// get the stream to subscribed to the all the collection
final stream = collection.watch();

// OR get the stream to subscribed to  a part of the collection applying
// filter on the listened documents
final stream = collection.watchWithFilter({
  "age": QuerySelector.lte(26)
});

// listen to a change in the collection
stream.listen((data) {
  // data contains JSON string of the document that was changed
  var fullDocument = MongoDocument.parse(data);
  
  // Do other stuff...
});
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


### Note: flutter_mongo_stitch is not directly and/or indirectly associated/affiliated with MongoDB<sup>TM</sup> , Flutter or Google LLC.
<!--#### Aggregation-->
<!--```dart-->


<!--```-->
