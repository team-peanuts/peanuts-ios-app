//
//  RestResource.swift
//  CodeVsCovid19
//
//  Created by Jochen Zehnder on 30.03.20.
//  Copyright © 2020 Team Peanuts. All rights reserved.
//

import Foundation

class InitOrdersModel: ObservableObject {
    @Published var orders: [Order] = []

    init() {
        let urlString = "http://peanuts-voice-api.westus.azurecontainer.io:8080/shopping-cart/"

        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    print("hey")
                    print(String(decoding: data, as: UTF8.self))

                    do {
                        let orders = try JSONDecoder().decode([Order].self, from: data)
                        print(orders)
                        
                        var filtered: [Order] = []
                        for o in orders {
                            if o.shoppingCartCustomer.callerId != nil {
                                filtered.append(o)
                            }
                        }
                        
                        self.orders = filtered
                    } catch {
                        print("ERROR")
                        print(error.localizedDescription)
                    }
                }
            }.resume()
        }
    }
}
