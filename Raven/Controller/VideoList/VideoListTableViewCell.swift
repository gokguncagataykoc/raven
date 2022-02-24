//
//  VideoListTableViewCell.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 12.02.2022.
//

import UIKit

class VideoListTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var channelTitle: UILabel!
    
    @IBOutlet weak var publishTime: UILabel!
    
    @IBOutlet weak var imgActivityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
