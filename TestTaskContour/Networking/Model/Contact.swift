//
//  Contact.swift
//  TestTaskContour
//
//  Created by Oleg Soloviev on 02.02.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import Foundation
import RealmSwift

struct Contact: Decodable {
    let id: String
    let name: String
    let phone: String
    let height: Double
    let biography: String
    let temperament: String
    let educationPeriod: Education
}

struct Education: Decodable {
    let start: String
    let end: String
}

class ContactDB: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var phone = ""
    @objc dynamic var phoneDigits = ""
    @objc dynamic var height = 0.0
    @objc dynamic var biography = ""
    @objc dynamic var temperament = ""
    @objc dynamic var educationPeriod: EducationDB!
}

class EducationDB: Object {
    @objc dynamic var start = ""
    @objc dynamic var end = ""
}
