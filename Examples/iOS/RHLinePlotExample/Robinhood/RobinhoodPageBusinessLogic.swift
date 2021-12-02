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
    @Published var hourlyResponse: APIResponse?
    @Published var dailyResponse: APIResponse?
    @Published var weeklyResponse: APIResponse?
    @Published var monthlyResponse: APIResponse?
    
    private static let mapTimeSeriesToResponsePath: [AlpacaAPI.TimeSeriesType: ReferenceWritableKeyPath<RobinhoodPageBusinessLogic, APIResponse?>] = [
        .hourly: \.hourlyResponse,
        .daily: \.dailyResponse,
        .weekly: \.weeklyResponse,
        .monthly: \.monthlyResponse
    ]
    
    var storage = Set<AnyCancellable>()
    
    init(symbol: String) {
        self.symbol = symbol
    }
    
    // This function grabs the relevant stock data from the publisher and stores it
    func fetch(timeSeriesType: AlpacaAPI.TimeSeriesType) {
        AlpacaAPI(symbol: symbol, timeSeriesType: timeSeriesType).publisher
            .assign(to: Self.mapTimeSeriesToResponsePath[timeSeriesType]!, on: self)
            .store(in: &storage)
    }
}
