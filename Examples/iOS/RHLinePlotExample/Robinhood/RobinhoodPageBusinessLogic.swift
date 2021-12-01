//
//  RobinhoodPageBusinessLogic.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/11/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import Combine

class RobinhoodPageBusinessLogic {
    typealias APIResponse = AlpacaAPIResponse
    
    let symbol: String
    @Published var intradayResponse: AlpacaAPIResponse?
    @Published var dailyResponse: AlpacaAPIResponse?
    @Published var weeklyResponse: AlpacaAPIResponse?
    @Published var monthlyResponse: AlpacaAPIResponse?
    
    private static let mapTimeSeriesToResponsePath: [AlpacaAPI.TimeSeriesType: ReferenceWritableKeyPath<RobinhoodPageBusinessLogic, AlpacaAPIResponse?>] = [
        .hourly: \.intradayResponse,
        .daily: \.dailyResponse,
        .weekly: \.weeklyResponse,
        .monthly: \.monthlyResponse
    ]
    
    var storage = Set<AnyCancellable>()
    
    init(symbol: String) {
        self.symbol = symbol
    }
    
    func fetch(timeSeriesType: AlpacaAPI.TimeSeriesType) {
        AlpacaAPI(symbol: symbol, timeSeriesType: timeSeriesType).publisher
            .assign(to: Self.mapTimeSeriesToResponsePath[timeSeriesType]!, on: self)
            .store(in: &storage)
    }
}
