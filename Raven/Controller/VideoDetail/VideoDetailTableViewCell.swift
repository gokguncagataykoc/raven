//
//  VideoDetailTableViewCell.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 21.02.2022.
//

import UIKit

class VideoDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var viewCountsLabel: UILabel!
    
    @IBOutlet weak var likeCountsLabel: UILabel!
    
    @IBOutlet weak var creationDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
