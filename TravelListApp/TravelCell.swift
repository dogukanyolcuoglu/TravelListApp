//
//  TravelCell.swift
//  TravelListApp
//
//  Created by Dogukan Yolcuoglu on 8.12.2020.
//

import UIKit

class TravelCell: UITableViewCell {

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var cityName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
