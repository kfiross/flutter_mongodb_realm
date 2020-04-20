//
//  MongoAtlasClient.swift
//  mongoatlasflutter
//
//  Created by kfir Matit on 16/04/2020.
//

import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

// cumbersome workaround solution
// TODO: convert any (possible) value into 'BSONValue'
class BsonExtractor {
    static func getValue(of: Any) -> BSONValue?{
        let value = of
        
        if let bsonValue = value as? String {
            return bsonValue
        }
        
        if let bsonValue = value as? Int {
            return bsonValue
        }
        
        
        if let bsonValue = value as? Double {
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


class MongoAtlasClient {
    var client: RemoteMongoClient
    var auth: StitchAuth
    
    init(client: RemoteMongoClient, auth: StitchAuth) {
        self.client = client
        self.auth = auth
    }
    
    
    func signInAnonymously(
        onCompleted: @escaping (Bool)->Void,
        onError: @escaping (String?)->Void
    ) {
        self.auth.login(withCredential: AnonymousCredential()) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(true)
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
        onCompleted: @escaping (Bool)->Void,
        onError: @escaping (String?)->Void
    ) {
        self.auth.login(
            withCredential: UserPasswordCredential(withUsername: username, withPassword: password)
        ) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(true)
                break
                
            case .failure(let error):
                onError("UsernamePassword Provider Login failed \(error)")
                break
            }
        }
    }
    
    func registerWithEmail(
        email: String,
        password: String,
        onCompleted: @escaping (Bool)->Void,
        onError: @escaping (String?)->Void
    ) {
        
        let emailPassClient = self.auth.providerClient(
            fromFactory: userPasswordClientFactory
        )
        
        emailPassClient.register(withEmail: email, withPassword: password) { result in
            switch result {
            case .success(let user):
                onCompleted(true)
                break
                
            case .failure(let error):
                onError("Error registering new user: \(error)")
                break
            }
        }
    }
    
    func logout(
        onCompleted: @escaping (Bool)->Void,
        onError: @escaping (String?)->Void
    ) {
        self.auth.logout { result in
            switch result {
            case .success(let user):
                onCompleted(true)
                break
                
            case .failure(let error):
                onError("Cannot logout user: \(error)")
                break
            }
        }
        
    }
    
    func getUserId() -> String? {
        return self.auth.currentUser?.id
    }
    
    /// ========================== Database related ========================================== ///
    private func getCollection(databaseName: String?, collectionName: String?) throws
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
        onCompleted: @escaping ()->Void,
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
                    onCompleted()
                case .failure(let error):
                    onError("Failed to insert a document: \(error)")
                }
            }
        }
        catch {
            onError("Failed to insert a document")
        }
    }
    
    ///////////////////////////
 
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
    
    // CHECK
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
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
            
            let task = collection?.find(document, options: nil)

            
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
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
            
            collection?.findOne(document) { result in
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
}
