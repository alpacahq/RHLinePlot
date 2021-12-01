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
    let end = "2015-11-10T0:00:00Z"
    let start = "2020-11-10T0:00:00Z" // Should calculate this later
    
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
        print("URL: \(fullURL)")
        let jsonDecoder = JSONDecoder()
        let publiser = URLSession.shared.dataTaskPublisher(for: fullURL)
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
