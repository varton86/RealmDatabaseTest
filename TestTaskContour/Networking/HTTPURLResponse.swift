//
//  HTTPURLResponse.swift
//  TestTaskContour
//
//  Created by Oleg Soloviev on 02.02.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    var hasSuccessStatusCode: Bool {
        return 200...299 ~= statusCode
    }
}
