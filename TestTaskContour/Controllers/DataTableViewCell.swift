//
//  DataTableViewCell.swift
//  TestTaskContour
//
//  Created by Oleg Soloviev on 02.02.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import UIKit

class DataTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var temperamentLabel: UILabel!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        configure(with: .none)
    }
    
    func configure(with contact: ContactDB?) {
        if let contact = contact {
            nameLabel.text = contact.name
            phoneLabel.text = contact.phone
            temperamentLabel.text = contact.temperament.capitalized

            nameLabel.alpha = 1
            phoneLabel.alpha = 1
            temperamentLabel.alpha = 1

            indicatorView.stopAnimating()
        } else {
            nameLabel.alpha = 0
            phoneLabel.alpha = 0
            temperamentLabel.alpha = 0

            indicatorView.startAnimating()
        }
    }
}
