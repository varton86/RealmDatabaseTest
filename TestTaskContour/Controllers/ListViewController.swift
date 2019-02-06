//
//  ViewController.swift
//  TestTaskContour
//
//  Created by Oleg Soloviev on 02.02.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import UIKit
import RealmSwift

let MAX_PAGE = 3

class ListViewController: UIViewController {
    
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var errorView: UIView!
    
    private enum CellIdentifiers {
        static let list = "List"
    }
    private var viewModel: DataViewModel!
    private var refreshControl: UIRefreshControl!
    private var timer: Timer!
    private var searchController: UISearchController!
    
    private var contacts: Results<ContactDB>!
    private var searchResults: Results<ContactDB>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorView.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        timer = Timer.scheduledTimer(timeInterval: 61, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)
        setupRefreshControl()
        setupSearchController()
        
        do {
            let realm = try Realm()
            contacts = realm.objects(ContactDB.self)
        } catch {
            fatalRealmDataError(error)
        }
        if contacts.count > 0 {
            tableView.isHidden = false
            indicatorView.stopAnimating()
        } else {
            contacts = nil
        }
        
        errorView.layer.cornerRadius = 6
        errorView.layer.masksToBounds = true
        
        viewModel = DataViewModel(delegate: self)        
        viewModel.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Contacts"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = ""
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let detailViewController = segue.destination as! DetailViewController
                let contact = searchController.isActive ? searchResults[indexPath.row] : contacts[indexPath.row]
                detailViewController.contact = contact
            }
        }
    }
    
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? (searchResults == nil ? 0 : searchResults.count) : (contacts == nil ? 0 : contacts.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.list, for: indexPath) as! DataTableViewCell
        let contact = searchController.isActive ? searchResults[indexPath.row] : contacts[indexPath.row]
        if isLoadingCell(for: indexPath) {
            cell.configure(with: .none)
        } else {
            cell.configure(with: contact)
        }
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if !isLoadingCell(for: indexPath) {
            performSegue(withIdentifier: "ShowDetail", sender: tableView.cellForRow(at: indexPath))
        }
    }
}

extension ListViewController: DataViewModelDelegate {
    func onFetchCompleted() {
        errorView.isHidden = true
        if viewModel.currentPage <= MAX_PAGE {
            viewModel.fetchData()
        } else {
            updateData()
        }
    }
    
    func onFetchFailed(with reason: String) {
        tableView.isHidden = false
        indicatorView.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        errorLabel.text = reason
        errorView.isHidden = false
    }
}

extension ListViewController:  UISearchBarDelegate {
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text!
        filterResultsWithSearchString(searchString: searchString)
        tableView.reloadData()
    }
}


private extension ListViewController {
    func setupRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        refreshControl = tableView.refreshControl!
        refreshControl.attributedTitle = NSAttributedString(string: "Потяните для обновления")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Поиск: имя или телефон"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= (searchController.isActive ? searchResults.count : contacts.count)
    }
    
    @objc func refreshData() {
        refreshControl.endRefreshing()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        viewModel.fetchData()
    }
    
    func fatalRealmDataError(_ error: Error) {
        print("*** Fatal error: \(error)")
    }
    
    func filterResultsWithSearchString(searchString: String) {
        let predicate = NSPredicate(format: "name CONTAINS[c] %@ || phoneDigits CONTAINS %@", searchString, searchString)
        do {
            let realm = try Realm()
            searchResults = realm.objects(ContactDB.self).filter(predicate)
        } catch {
            fatalRealmDataError(error)
        }
    }
    
    func updateData() {
        print("*** delete records")
        DispatchQueue(label: "background").async { [weak self] in
            autoreleasepool {
                do {
                    let realm = try Realm()
                    realm.beginWrite()
                    realm.deleteAll()
                    let maxIteration = self?.viewModel.currentCount ?? 0
                    for i in 0..<maxIteration {
                        if let contact = self?.viewModel.contact(at: i) {
                            let contactDB = ContactDB()
                            contactDB.id = contact.id
                            contactDB.name = contact.name
                            contactDB.phone = contact.phone
                            contactDB.phoneDigits = contact.phone.digits
                            contactDB.height = contact.height
                            contactDB.biography = contact.biography
                            contactDB.temperament = contact.temperament
                            contactDB.educationPeriod = EducationDB()
                            contactDB.educationPeriod.start = contact.educationPeriod.start
                            contactDB.educationPeriod.end = contact.educationPeriod.end
                            realm.add(contactDB)
                        }
                    }
                    try realm.commitWrite()
                } catch {
                    self?.fatalRealmDataError(error)
                }
                DispatchQueue.main.async { [weak self] in
                    if self?.contacts == nil {
                        do {
                            let realm = try Realm()
                            self?.contacts = realm.objects(ContactDB.self)
                        } catch {
                            self?.fatalRealmDataError(error)
                        }
                    }
                    print("*** add records")
                    self?.tableView.reloadData()
                    self?.tableView.isHidden = false
                    self?.indicatorView.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
    }
    
}

