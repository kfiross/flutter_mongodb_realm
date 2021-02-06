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
