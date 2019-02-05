//
//  ContourClient.swift
//  TestTaskContour
//
//  Created by Oleg Soloviev on 02.02.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import Foundation

final class ContourClient {
    private lazy var baseURL: URL = {
        return URL(string: "https://raw.githubusercontent.com/SkbkonturMobile/mobile-test-ios/master/json")!
    }()

    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchData(with page: Int, completion: @escaping (Result<[Contact], ResponseError>) -> Void) {
        print("*** page =", page)
        let pageNumber = "generated-0\(page).json"
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(pageNumber))
        urlRequest.timeoutInterval = 15

        session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.hasSuccessStatusCode, let data = data else {
                completion(Result.failure(ResponseError.network))
                return
            }
            guard let decodedResponse = try? JSONDecoder().decode([Contact].self, from: data) else {
                completion(Result.failure(ResponseError.decoding))
                return
            }
            completion(Result.success(decodedResponse))
        }).resume()
    }
}
