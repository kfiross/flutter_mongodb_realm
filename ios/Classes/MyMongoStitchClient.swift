//
//  MyMongoStitchClient.swift
//  fluttermongostitch
//
//  Created by kfir Matityahu on 16/04/2020.
//

import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

import RealmSwift




extension AnyBSONValue{
    func toSimpleType() -> Any{
        
        if let value = self.value as? Double{
            return value
        }
        
        if let value = self.value as? String{
            return value
        }
        
        if let value = self.value as? Document{
            return value.extendedJSON
        }
        
        if let value = self.value as? Array<Any>{
            return value
        }
        
        if let value = self.value as? ObjectId{
            return value.hex
        }
        
        if let value = self.value as? Bool{
            return value
        }
        
        if let value = self.value as? NSDate{
            return value.timeIntervalSince1970
        }
        
        if let value = self.value as? Int32{
            return value
        }
        
        if let value = self.value as? Int64{
            return value
        }
        
        if let value = self.value as? Decimal128{
            return value.doubleValue ?? 0.0
        }
        
//        switch(self.value.bsonType){
//        case BSONNumber:
//            return (self.value as BSONNumber).;
//        default:
//            return ""
//        }
        return self.value as? String ?? "";
    }
}

// cumbersome workaround solution
// TODO: convert any (possible) value into 'BSONValue'
class BsonExtractor {    
    static func getValue(of: Any) -> BSONValue?{
        let value = of
        
        if let bsonValue = value as? Double {
            return bsonValue
        }
        
        else if let bsonValue = value as? Int64 {
            return bsonValue
        }
        
        else if let bsonValue = value as? String {
            return bsonValue
        }
        
        else if let bsonValue = value as? Int {
            return bsonValue
        }
        
        
        else if let bsonValue = value as? Double {
            return bsonValue
        }
        
        
        // TODO: check this conversion
        if let bsonValue = value as? Array<Any> {
            return bsonValue
        }
        
        return nil
    }
}


enum MyError : Error {
    case nilError
}


class MyMongoStitchClient {
    var client: RemoteMongoClient
    var appClient: StitchAppClient
    var app: App
    lazy var auth = appClient.auth
    
    init(client: RemoteMongoClient, appClient: StitchAppClient, app: App) {
        self.client = client
        self.appClient = appClient
        self.app = app
    }
    
    //MARK: Auth
    func signInAnonymously(
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
    ) {
        guard false/*#available(iOS 13.0, *)*/ else{
            self.signInAnonymously_s(onCompleted: onCompleted, onError: onError)
            return
        }
        
        self.app.login(credentials: Credentials.anonymous) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user.toMap())
                break
                
            case .failure(let error):
                onError("\(error)")
                break
            }
        }
    }
    
    func signInWithUsernamePassword(
        username: String,
        password: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
    ) {

        guard false/*#available(iOS 13.0, *)*/ else{
            self.signInWithUsernamePassword_s(username: username, password: password, onCompleted: onCompleted, onError: onError)
            return
        }
        
        self.app.login(
            credentials: Credentials.emailPassword(email: username, password: password)
        ) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user.toMap())
                break
                
            case .failure(let error):
                onError("UsernamePassword Provider Login failed \(error)")
                break
            }
        }
    }
    
    func signInWithGoogle(
        authCode: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
        ) {
        
        guard false/*#available(iOS 13.0, *)*/ else{
            self.signInWithGoogle_s(authCode: authCode, onCompleted: onCompleted, onError: onError)
            return
        }
        
        self.app.login(
            credentials: Credentials.google(serverAuthCode: authCode)
        ) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user.toMap())
                break
                
            case .failure(let error):
                onError("Google Provider Login failed \(error)")
                break
            }
        }
    }
    
    
    func signInWithFacebook(
        accessToken: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
        ) {
        
        guard false/*#available(iOS 13.0, *)*/ else{
            self.signInWithFacebook_s(accessToken: accessToken, onCompleted: onCompleted, onError: onError)
            return
        }
        
        self.app.login(
            credentials: Credentials.facebook(accessToken: accessToken)
        ) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user.toMap())
                break
                
            case .failure(let error):
                onError("Facebook Provider Login failed \(error)")
                break
            }
        }
    }
    
    // todo: check this
    func signInWithJWT(
        accessToken: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
        ){
        
        guard false else {
            self.signInWithJWT_s(accessToken: accessToken, onCompleted: onCompleted, onError: onError)
            return
        }
        
//        self.app.login(
//            credentials: Credentials.jwt(token: accessToken)
//        ) { authResult in
//            switch(authResult){
//            case .success(let user):
//                onCompleted(user)
//                break
//
//            case .failure(let error):
//                onError("JWT Provider Login failed \(error)")
//                break
//
//            }
//        }
    }
    
    func signInWithCustomFunction(
        json: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
        ){
        
        guard false else {
            self.signInWithCustomFunction_s(json: json, onCompleted: onCompleted, onError: onError)
            return
        }
        
//        self.app.login(
//            credentials: Credentials.function(payload: payload)
//        ) { authResult in
//            switch(authResult){
//            case .success(let user):
//                onCompleted(user)
//                break
//
//            case .failure(let error):
//                onError("Custom Function Provider Login failed: \(error)")
//                break
//
//            }
//        }
    }
    
    func signInWithApple(
        idToken: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
        ){
        
        guard false else {
            self.signInWithApple_s(idToken: idToken, onCompleted: onCompleted, onError: onError)
            return
        }
    }
    
    func registerWithEmail(
        email: String,
        password: String,
        onCompleted: @escaping (Bool)->Void,
        onError: @escaping (String?)->Void
    ) {
        
//        let emailPassClient = self.auth.providerClient(
//            fromFactory: userPasswordClientFactory
//        )
        
        let emailPassClient = app.emailPasswordAuth
        
        emailPassClient.registerUser(email: email, password: password) { error in
            guard error == nil else {
                onError("Error registering new user: \(error!.localizedDescription)")
                return
            }
            
            onCompleted(true)
        }
    }

    
    func logout(
        onCompleted: @escaping (Bool)->Void,
        onError: @escaping (String?)->Void
    ) {
        guard false/*#available(iOS 13.0, *)*/ else{
            self.logout_s(onCompleted: onCompleted, onError: onError)
            return
        }
        
        self.app.currentUser?.logOut(
            completion: { error in
                guard error == nil else {
                    onError("Cannot logout user: \(error!.localizedDescription)")
                    return
                }
                
                onCompleted(true)
            }
        )
    }
    
    func sendResetPasswordEmail(
        email: String,
        onCompleted: @escaping ()->Void,
        onError: @escaping (String?)->Void
    ) {
        let emailPassClient = app.emailPasswordAuth
        
        emailPassClient.sendResetPasswordEmail(email, completion: {(error) in
            guard error == nil else {
                onError("Reset password email not sent: \(error!.localizedDescription)")
                return
            }
            onCompleted()
        })
        
//        let emailPassClient = self.auth.providerClient(fromFactory: userPasswordClientFactory)
//
//        return emailPassClient.sendResetPasswordEmail(toEmail: email) { result in
//        switch result {
//        case .success(let _):
//            onCompleted()
//        case .failure(let error):
//            onError("Failed to send a reset password email: \(error)")
//            }
//        }
    }
    
    func getUser() -> StitchUser? {
        return self.auth.currentUser //self.app.currentUser
    }
    
    func getUserId() -> String? {
        return self.auth.currentUser?.id // self.app.currentUser?.id
    }
    
    // MARK: Database (MongoDB Atlas)
    /*private*/ func getCollection(databaseName: String?, collectionName: String?) throws
        -> RemoteMongoCollection<Document>? {
        if(databaseName == nil || collectionName == nil) {
            throw MyError.nilError
        }
    
        return client.db(databaseName!).collection(collectionName!)
    }
    
    func insertDocument(
        databaseName: String?,
        collectionName: String?,
        data: Dictionary<String, Any>?,
        onCompleted: @escaping (BSONValue?)->Void,
        onError: @escaping (String?)->Void
     ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
        
            var document = Document()
            for (key) in data!.keys{
                let value = data![key]
                
                if (value != nil){
                    document[key] = BsonExtractor.getValue(of: value!)
                }
            }
            
            
            collection?.insertOne(document) { result in
                switch result {
                case .success(let result):
                    print("Successfully inserted item with _id: \(result.insertedId))");
                    onCompleted(result.insertedId)
                case .failure(let error):
                    onError("Failed to insert a document: \(error)")
                }
            }
        }
        catch {
            onError("Failed to insert a document")
        }
    }
    
    func insertDocuments(
        databaseName: String?,
        collectionName: String?,
        list: Array<String>?,
        onCompleted: @escaping ([Int64: BSONValue]?)->Void,
        onError: @escaping (String?)->Void
    ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            if(list == nil){
               onError("Insertion failed. No document")
            }
            
            let documents = try list!.map({ try Document.init(fromJSON: $0) })
            
            collection?.insertMany(documents) { result in
                switch result {
                case .success(let result):
                    print("Successfully inserted docs with the ids: \(result.insertedIds))");
                    onCompleted(result.insertedIds)
                case .failure(let error):
                    onError("Failed to insert documents: \(error)")
                }
            }
        }
        catch {
            onError("Failed to insert a document")
        }
    }
    
 
    func deleteDocument(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
        
            
            collection?.deleteOne(document) { result in
                switch result {
                case .success(let result):
                    onCompleted(result)
                case .failure(let error):
                    onError("Failed to delete a document : \(error)")
                }
            }
        }
        catch {
            onError("Failed to delete a document")
        }
    }
    
    
    func deleteDocuments(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
            
            collection?.deleteMany(document) { result in
                switch result {
                case .success(let result):
                    onCompleted(result)
                case .failure(let error):
                    onError("Failed to delete documents : \(error)")
                }
            }
        
        }
        catch {
            onError("Failed to delete documents")
        }
    }
  
  
    func findDocuments(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        projectionJson: String?,
        limit: Int?,
        sortJson: String?,
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            // options (optional) attributes
            var projectionBson = Document()
            var docsLimit:Int64? = nil
            var sortBson:Document? = nil
            
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
            
            if (projectionJson != nil) {
                projectionBson = try Document.init(fromJSON: projectionJson!)
            }
            
            if(limit != nil){
                docsLimit = Int64(limit!)
            }
            
            if (sortJson != nil){
                sortBson = try Document.init(fromJSON: sortJson!)
            }
            
            let options = RemoteFindOptions(
                limit: docsLimit,
                projection: projectionBson,
                sort: sortBson
            )
            
            let task = collection?.find(document, options: options)

            
            task!.toArray(){result in
                switch result {
                case .success(let results):
                    let queryResults =  results.map({ $0.extendedJSON })
                    onCompleted(queryResults)
                case .failure(let error):
                    onError("Failed to find documents: \(error)")
                }
            }
        }
        catch {
            onError("Failed to find documents")
        }
    }
    
 
    func findDocument(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        projectionJson: String?,
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            var projectionBson = Document()
            
            if (filterJson != nil) {
                document = try Document.init(fromJSON: filterJson!)
            }
            
            if (projectionJson != nil) {
               projectionBson = try Document.init(fromJSON: projectionJson!)
            }
            
            let options = RemoteFindOptions(
                projection: projectionBson
            )
            
            collection?.findOne(document, options: options) { result in
                switch result {
                case .success(let result):
                    onCompleted(result?.extendedJSON)
                    break
                case .failure(let error):
                    onError("Failed to find item: \(error)")
                    break
                }
            }
        }
        catch {
            onError("Failed to find item")
        }
    }
    

    func countDocuments(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        onCompleted: @escaping (Any)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
        
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }

            
            collection?.count(document) { result in
                switch result {
                case .success(let result):
                    onCompleted(result)
                case .failure(let error):
                    onError("Failed to count collection: \(error)")
                }
            }
        
        }
        catch {
            onError("Failed to count collection")
        }
    }
    
    //
    func updateDocument(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        updateJson: String,
        onCompleted: @escaping (Any)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
            let update = try Document.init(fromJSON: updateJson)
            
            collection?.updateOne(filter: document, update: update) { result in
                switch result {
                case .success(let result):
                    onCompleted([result.matchedCount, result.modifiedCount])
                case .failure(let error):
                    onError("Failed to update collection: \(error)")
                }
            }
            
        }
        catch {
            onError("Failed to count collection")
        }
    }
    
    func updateDocuments(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        updateJson: String,
        onCompleted: @escaping (Any)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
            
            let update = try Document.init(fromJSON: updateJson)
            
            collection?.updateMany(filter: document, update: update) { result in
                switch result {
                case .success(let result):
                    onCompleted([result.matchedCount, result.modifiedCount])
                case .failure(let error):
                    onError("Failed to update collection: \(error)")
                }
            }
            
        }
        catch {
            onError("Failed to update collection")
        }
    }
    
    
    func aggregate(
        databaseName: String?,
        collectionName: String?,
        pipelineList: Array<String>?,
        onCompleted: @escaping (Any)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            let documents = try pipelineList!.map({ try Document.init(fromJSON: $0) })
            
            collection?.aggregate(documents).toArray() { result in
                switch result {
                case .success(let results):
                    let aggregateResults =  results.map({ $0.extendedJSON })
                    onCompleted(aggregateResults)
                case .failure(let error):
                    onError("Failed to perform aggregate: \(error)")
                }
            }
        }
        catch {
            onError("Failed to perform aggregate")
        }
    }
    
    
    func callFunction(name: String,
                      args: Array<Any>?,
                      requestTimeout: Int64?,
                      onCompleted: @escaping (Any)->Void,
                      onError: @escaping (String?)->Void
        ){
        
        var argsBson = [BSONValue]()
        args?.forEach { value in
            argsBson.append(BsonExtractor.getValue(of: value) ?? "")
        }
        
        var timeoutInSeconds:TimeInterval = 15
        if (requestTimeout != nil){
            timeoutInSeconds = Double(requestTimeout!)/1000.0
        }
        
        self.appClient.callFunction(
            withName: name,
            withArgs: argsBson,
            withRequestTimeout: timeoutInSeconds ){ (result: StitchResult<AnyBSONValue>) in
            
                switch result {
                case .success(let data):
                    onCompleted(data.value)//toSimpleType())
                case .failure(let error):
                    onError("Failed to call function: \(error)")
            }
        }
    }
    
    //MARK: - Legacy Stitch SDK Auth -

    private func signInAnonymously_s(
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
    ) {
        self.auth.login(withCredential: AnonymousCredential()) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user.toMap())
                break
                
            case .failure(let error):
                onError("\(error)")
                break
            }
        }
    }

    private func signInWithUsernamePassword_s(
        username: String,
        password: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
    ) {

        self.auth.login(
            withCredential: UserPasswordCredential(withUsername: username, withPassword: password)
        ) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user.toMap())
                break
                
            case .failure(let error):
                onError("UsernamePassword Provider Login failed \(error)")
                break
            }
        }
    }

    private func signInWithGoogle_s(
        authCode: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
        ) {
        
        self.auth.login(
            withCredential: GoogleCredential(withAuthCode: authCode)
        ) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user.toMap())
                break
                
            case .failure(let error):
                onError("Google Provider Login failed \(error)")
                break
            }
        }
    }


    func signInWithFacebook_s(
        accessToken: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
        ) {
        
        self.auth.login(
            withCredential: FacebookCredential(withAccessToken: accessToken)
        ) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user.toMap())
                break
                
            case .failure(let error):
                onError("Facebook Provider Login failed \(error)")
                break
            }
        }
    }
    
    func signInWithJWT_s(
        accessToken: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
        ) {
        
        self.auth.login(
            withCredential: CustomCredential(withToken: accessToken)
        ) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user.toMap())
                break
                
            case .failure(let error):
                onError("Facebook Provider Login failed \(error)")
                break
            }
        }
    }
    private func signInWithApple_s(
        idToken: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
    ){
//        let data = idToken.data(using: .utf8)!
        let appleCredential = AppleCredential.init(identityTokenString: idToken)

        self.auth.login(withCredential: appleCredential
        ) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user.toMap())
                break
                
            case .failure(let error):
                onError("AppleID Provider Login failed \(error)")
                break
            }
        }
    }

    private func signInWithCustomFunction_s(
        json: String,
        onCompleted: @escaping ([String:Any])->Void,
        onError: @escaping (String?)->Void
    ){
//        var payload = RealmSwift.Document()
//        var map = [String:AnyObject]()
//      //  do{
//            if let data = json.data(using: .utf8) {
//                    do {
//                        map = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:AnyObject]
//                    } catch {
//                        print("Something went wrong")
//                    }
//                for (key,value) in map{
//                    payload[key] = value as? AnyBSON
//                }
//        }
//            catch{
//            onError("Failed to send Payload")
//        }
        
//        CustomCredential(withToken: accessToken)
        
         var payload = Document()
        
        do{
            payload = try Document.init(fromJSON: json)
        }
        catch{
            
        }

        let credential = FunctionCredential.init(payload: payload)
        
     
//            FunctionCredential(payload: payload)
        
//        self.app.login(credentials: Credentials.function(payload: payload)
//        ) { authResult in
//            switch authResult {
//               case .success(let user):
//                   onCompleted(user.toMap())
//                   break
//
//               case .failure(let error):
//                   onError("Custom Function Provider Login failed \(error)")
//                   break
//               }
//        }


        self.auth.login(
            withCredential: credential
        ) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user.toMap())
                break

            case .failure(let error):
                onError("Custom Function Provider Login failed \(error)")
                break
            }
        }
            
    }

    private func logout_s(
        onCompleted: @escaping (Bool)->Void,
        onError: @escaping (String?)->Void
    ) {
        self.auth.logout { result in
            switch result {
            case .success(_):
                onCompleted(true)
                break
                
            case .failure(let error):
                onError("Cannot logout user: \(error)")
                break
            }
        }
        
    }
}

