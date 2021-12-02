//
//  AlpacaAPIResponse.swift
//  RHLinePlotExample
//
//  Created by Andrew Wood on 2021-11-30.
//  Copyright © 2021 Wirawit Rueopas. All rights reserved.
//

import Foundation

struct AlpacaAPIResponse: Codable {
    let bars: [Bar]?
}

struct Bar: Codable {
    var t: String
    var o: Float
    var h: Float
    var l: Float
    var c: Float
    var v: Float
}
