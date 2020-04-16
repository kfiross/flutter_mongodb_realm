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
    
    init(client: RemoteMongoClient) {
        self.client = client
    }
    
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
        onError: @escaping ()->Void
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
                    print("Failed to insert item: \(error)");
                    onError()
                }
            }
        }
        catch {
            onError()
        }
    }
    
    ///////////////////////////
    // DONE!
    func deleteDocument(
        databaseName: String?,
        collectionName: String?,
        filter: Dictionary<String, Any>?,
        onCompleted: @escaping ()->Void,
        onError: @escaping ()->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var documentFilter = Document()
//            for (key) in data!.keys{
//                let value = data![key]
//
//                if (value != nil){
//                    documentFilter[key] = BsonExtractor.getValue(of: value!)
//                }
//            }
//
            
            
            collection?.deleteOne(documentFilter) { result in
                switch result {
                case .success(let result):
                    onCompleted()
                case .failure(let error):
                    onError()
                }
            }
        }
        catch {
            onError()
        }
    }
    
    // DONE!
    func findDocuments(
        databaseName: String?,
        collectionName: String?,
        filter: Dictionary<String, Any>?,
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping ()->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
//            for (key) in data!.keys{
//                let value = data![key]
//
//                if (value != nil){
//                    document[key] = BsonExtractor.getValue(of: value!)
//                }
//            }
            
            
            let task = collection?.find(document, options: nil)

            task!.toArray(){result in
                switch result {
                case .success(let results):
                    let queryResults =  results.map({ $0.extendedJSON })
                    onCompleted(queryResults)
                case .failure(let error):
                    print("Failed to insert item: \(error)");
                    onError()
                }
            }
        }
        catch {
            onError()
        }
    }
    
    // DONE!
    func findDocument(
        databaseName: String?,
        collectionName: String?,
        filter: Dictionary<String, Any>?,
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping ()->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
//            for (key) in data!.keys{
//                let value = data![key]
//
//                if (value != nil){
//                    document[key] = BsonExtractor.getValue(of: value!)
//                }
//            }
            
            
            collection?.findOne(document) { result in
                switch result {
                case .success(let result):
                    onCompleted(result?.extendedJSON)
                case .failure(let error):
                    print("Failed to insert item: \(error)");
                    onError()
                }
            }
        }
        catch {
            onError()
        }
    }
    
    // DONE!
    func countDocuments(
        databaseName: String?,
        collectionName: String?,
        filter: Dictionary<String, Any>?,
        onCompleted: @escaping (Any)->Void,
        onError: @escaping ()->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
//            for (key) in filter!.keys{
//                let value = data![key]
//
//                if (value != nil){
//                    document[key] = BsonExtractor.getValue(of: value!)
//                }
//            }
            
            
            collection?.count(document) { result in
                switch result {
                case .success(let result):
                    onCompleted(result)
                case .failure(let error):
                    print("Failed with error: \(error)");
                    onError()
                }
            }
        
        }
        catch {
            onError()
        }
    }
}
