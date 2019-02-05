//
//  String+Extensions.swift
//  TestTaskContour
//
//  Created by Oleg Soloviev on 05.02.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import Foundation

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }
}
