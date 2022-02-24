//
//  VideoSearchTableViewCell.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 18.02.2022.
//

import UIKit

class VideoSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var channelTitle: UILabel!
    
    @IBOutlet weak var publishTime: UILabel!
    
    @IBOutlet weak var videoId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
