//
//  AlpacaAPI.swift
//  RHLinePlotExample
//
//  Created by Andrew Wood on 2021-11-30.
//  Copyright © 2021 Wirawit Rueopas. All rights reserved.
//

import Foundation
import Combine

struct AlpacaAPI {
    private static let baseURL = URL(string: "https://data.alpaca.markets")!
    static let networkActivity = PassthroughSubject<Bool, Never>()

    let symbol: String
    let timeSeriesType: TimeSeriesType
    
    var start: String {
        let hourlyOffset = -1
        let dailyOffset = -5
        let weeklyOffset = -3
        let monthlyOffset = -5
        switch timeSeriesType.timeframe {
        case "5Min":
            return (Calendar.current.date(byAdding: .day, value: hourlyOffset, to: Date())?.iso8601)!
        case "1Day":
            return (Calendar.current.date(byAdding: .month, value: dailyOffset, to: Date())?.iso8601)!
        case "5Day":
            return (Calendar.current.date(byAdding: .year, value: weeklyOffset, to: Date())?.iso8601)!
        case "21Day":
            return (Calendar.current.date(byAdding: .year, value: monthlyOffset, to: Date())?.iso8601)!
        default:
            return (Calendar.current.date(byAdding: .year, value: monthlyOffset, to: Date())?.iso8601)!
        }
    }
    
    var end: String {
        let dataDelay = -16 // Alpaca free plan delays data by 15 minutes
        return (Calendar.current.date(byAdding: .minute, value: dataDelay, to: Date())?.iso8601)!
    }

    var urlWithBars: String {
        String("\(AlpacaAPI.baseURL)/v2/stocks/\(symbol)/bars")
    }
    
    private var query: String {
        return "?start=\(start)&end=\(end)&timeframe=\(timeSeriesType.timeframe)"
    }
    
    var fullURL: URL {
        URL(string: "\(urlWithBars)\(query)")!
    }
    
    var publisher: AnyPublisher<AlpacaAPIResponse?, Never> {
        let jsonDecoder = JSONDecoder()
        let url = self.fullURL
        print("URL: \(url)")
        var request = URLRequest(url: self.fullURL)
        request.httpMethod = "GET"
        request.addValue("PK5KK5IJJN3Z1UVFO86F", forHTTPHeaderField: "APCA-API-KEY-ID")
        request.addValue("hnVv9OrxIjrtOiVSCuCFh61bFj1QoNS80h76Hofz", forHTTPHeaderField: "APCA-API-SECRET-KEY")
        let publiser = URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { (_) in
                Self.networkActivity.send(true)
            }, receiveCompletion: { (completion) in
                Self.networkActivity.send(false)
            }, receiveCancel: {
                Self.networkActivity.send(false)
            })
            .map(\.data)
            .decode(type: AlpacaAPIResponse?.self, decoder: jsonDecoder)
            .catch { (err) -> Just<AlpacaAPIResponse?> in
                print("Catched Error \(err.localizedDescription)")
                return Just<AlpacaAPIResponse?>(nil)
        }
        .eraseToAnyPublisher()
        return publiser
    }
    
    
}

extension AlpacaAPI {
    enum TimeSeriesType {
        case hourly
        case daily
        case weekly
        case monthly // -> How to implement this properly?
        
        var timeframe: String {
            switch self {
            case .hourly:
                return "5Min"
            case .daily:
                return "1Day"
            case .weekly:
                return "5Day"
            case .monthly:
                return "21Day"
            }
        }
    }
}
