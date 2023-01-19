//
//  extentions.swift
//  flutter_mongo_stitch
//
//  Created by kfir Matit on 24/05/2020.
//

import Foundation
import StitchCore

import RealmSwift

extension StitchUser{
    func toMap() -> [String:Any] {
        return [
            "id": self.id,
            // "device_id": ,
            "profile": [
                "name": self.profile.name,
                "email": self.profile.email,
                "pictureUrl": self.profile.pictureURL,
                "firstName": self.profile.firstName,
                "lastName": self.profile.lastName,
                "gender": self.profile.gender,
                "birthday": self.profile.birthday,
                "minAge": self.profile.minAge,
                "maxAge": self.profile.maxAge
            ]
        ]
    }
}

extension User{
    func toMap() -> [String:Any] {
        var profile = self.customData;
        return [
            "id": self.id,
            // "device_id": ,
            "profile": [
                "name": "",//self.customData["name"],
                "email": "",//self.profile.email,
                "pictureUrl": "",//self.profile.pictureURL,
                "firstName": "",//self.profile.firstName,
                "lastName": "",//self.profile.lastName,
                "gender": "",//self.profile.gender,
                "birthday": "",//self.profile.birthday,
                "minAge": "",//self.profile.minAge,
                "maxAge": "",//self.profile.maxAge
            ]
        ]
    }
}

class CredentialsExtensions{
    static func fromMap(_ json: Dictionary<String, Any>) throws -> Credentials?{
        enum MyError: Error {
              case cantLink
          }
        
        let type = json["type"] as! String
        switch(type){
        case "anon" :
            throw MyError.cantLink
        case "email_password":
            return Credentials.emailPassword(email: json["email"] as! String, password: json["password"] as! String)
        case "apple":
            return Credentials.apple(idToken: json["idToken"] as! String)
        case "facebook":
            return Credentials.facebook(accessToken: json["accessToken"] as! String)
        //case "google" : return Credentials.google(json["authorizationCode"] as String)
        case "jwt":
            return Credentials.jwt(token: json["jwtToken"] as! String)
        default:
            break
        }
        return nil
    }
    
}
