//
//  VideoList+Extensions.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 13.02.2022.
//

import Foundation
import CoreData

extension VideoList {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
