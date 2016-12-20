//
//  HelperProtocol.swift
//  CasperSplash
//
//  Created by Morgan, Tyler on 12/19/16.
//  Copyright © 2016 François Levaux-Tiffreau. All rights reserved.
//

import Foundation

struct HelperConstants {
    static let machServiceName = "io.fti.CasperSplash.helper"
}

@objc(HelperProtocol)
protocol HelperProtocol {
    func getVersion(reply: (String) -> Void)
    //  Edit: Add Helper's functions here
    func setAssetTag(asset_tag: String,reply: @escaping (NSNumber) -> Void)
}
