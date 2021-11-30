//
//  AlpacaAPI.swift
//  RHLinePlotExample
//
//  Created by Andrew Wood on 2021-11-30.
//  Copyright © 2021 Wirawit Rueopas. All rights reserved.
//

import Foundation

struct AlpacaAPI {
    private static let baseURL = URL(string: "https://data.alpaca.markets")!
    
    let symbol: String
    let start: String
    let end: String
    let timeSeriesType: TimeSeriesType
    
    var urlWithBars: String {
        String("\(AlpacaAPI.baseURL)/v2/stocks/\(symbol)/bars")
    }
    
    private var query: String {
        return "?start=\(start)&end=\(end)&timeframe=\(timeSeriesType.timeframe)"
    }
    
    var fullURL: URL {
        URL(string: "\(urlWithBars)\(query)")!
    }
    

    func getBars() {
        var request = URLRequest(url: fullURL)
        request.httpMethod = "GET"
        request.addValue("PK5KK5IJJN3Z1UVFO86F", forHTTPHeaderField: "APCA-API-KEY-ID")
        request.addValue("hnVv9OrxIjrtOiVSCuCFh61bFj1QoNS80h76Hofz", forHTTPHeaderField: "APCA-API-SECRET-KEY")
        
        //Perform request
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            if let safeData = data {
                self.parseJSON(barData: safeData)
            }
        }
        task.resume()
    }
    
    func parseJSON(barData: Data){
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(AlpacaAPIResponse.self, from: barData)
            print(decodedData)
        } catch {
            print(error)
        }
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
                return "1Hour"
            case .daily:
                return "1Day"
            case .weekly:
                return "5Day"
            case .monthly:
                return "20Day"
            }
        }
    }
}
