//
//  DetailViewController.swift
//  TestTaskContour
//
//  Created by Oleg Soloviev on 02.02.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    private let temperamentCellNumber = 2
    private let phoneCellNumber = 3
    
    private var nameField = ""
    private var educationPeriodField = ""
    private var temperamentField = ""
    private var phoneField = ""
    private var biographyField = ""
    private var formatedPhoneNumber = ""

    var contact: ContactDB? {
        didSet {
            if let contact = contact {
                nameField = contact.name
                educationPeriodField = formatDate(contact.educationPeriod.start, contact.educationPeriod.end)
                temperamentField = contact.temperament.capitalized
                phoneField = "☏ \(contact.phone)"
                biographyField = contact.biography
                formatedPhoneNumber = "+\(contact.phoneDigits)"
            }
        }
    }

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var educationPeriodLabel: UILabel!
    @IBOutlet var temperamentLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var biographyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = nameField
        educationPeriodLabel.text = educationPeriodField
        temperamentLabel.text = temperamentField
        phoneLabel.text = phoneField
        biographyLabel.text = biographyField

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == phoneCellNumber, let url = URL(string: "tel://\(formatedPhoneNumber)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case temperamentCellNumber, phoneCellNumber:
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        default:
            cell.separatorInset = UIEdgeInsets(top: 0, left: CGFloat.greatestFiniteMagnitude, bottom: 0, right: 0)
        }
    }
    
    private func formatDate(_ startDate: String, _ endDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let date1 = dateFormatter.date(from: startDate)
        let date2 = dateFormatter.date(from: endDate)
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if let date1 = date1, let date2 = date2 {
            if date1 < date2 {
                return "\(dateFormatter.string(from: date1)) - \(dateFormatter.string(from: date2))"
            } else {
                return "\(dateFormatter.string(from: date2)) - \(dateFormatter.string(from: date1))"
            }
        } else {
            return "\(dateFormatter.string(from: Date())) - \(dateFormatter.string(from: Date()))"
        }
    }
}
