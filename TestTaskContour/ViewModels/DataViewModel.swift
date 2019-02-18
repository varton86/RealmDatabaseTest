//
//  DataViewModel.swift
//  TestTaskContour
//
//  Created by Oleg Soloviev on 02.02.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import Foundation

protocol DataViewModelDelegate: class {
    func onFetchCompleted()
    func onFetchFailed(with reason: String)
}

final class DataViewModel {
    private weak var delegate: DataViewModelDelegate?
    
    private var page = 1
    private var contacts: [Contact] = []
    private var isFetchInProgress = false

    let client = ContourClient()
    
    init(delegate: DataViewModelDelegate) {
        self.delegate = delegate
    }
    
    var currentPage: Int {
        return page
    }
    
    var currentCount: Int {
        return contacts.count
    }
    
    func contact(at index: Int) -> Contact {
        return contacts[index]
    }
    
    func fetchData() {
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        if page > MAX_PAGE {
            page = 1
            contacts = []
        }

        client.fetchData(with: page) { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    guard let `self` = self else { return }
                    self.page = 1
                    self.contacts = []
                    self.isFetchInProgress = false
                    self.delegate?.onFetchFailed(with: error.reason)
                }
            case .success(let response):
                DispatchQueue.main.async {
                    guard let `self` = self else { return }
                    self.page += 1
                    self.contacts.append(contentsOf: response)
                    print("*** records =", self.contacts.count)
                    
                    self.isFetchInProgress = false
                    self.delegate?.onFetchCompleted()
                }
            }
        }
    }
    
}
