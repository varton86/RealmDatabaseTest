//
//  ResponseError.swift
//  TestTaskContour
//
//  Created by Oleg Soloviev on 02.02.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import Foundation

enum ResponseError: Error {
    case network
    case decoding

    var reason: String {
        switch self {
        case .network:
            return "Нет подключения к сети"
        case .decoding:
            return "Ошибка в данных"
        }
    }
}
