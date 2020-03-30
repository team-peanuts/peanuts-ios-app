//
//  OrdersView.swift
//  CodeVsCovid19
//
//  Created by Jochen Zehnder on 29.03.20.
//  Copyright © 2020 Team Peanuts. All rights reserved.
//

import SwiftUI

struct OrdersView: View {
//    @ObservedObject var orders = InitOrdersModel()
    @State var orders: [Order] = []

    var body: some View {
        reload()
        
        let started = filterOrders(orders: orders, filter0: "ORDER_STARTED", filter1: "ORDER_WILL_BE_DELIVERED_SOON")
        let created = filterOrders(orders: orders, filter0: "ORDER_CREATED", filter1: "ORDER_INITIATED")
        let delivered = filterOrders(orders: orders, filter0: "ORDER_DELIVERED")
        
        return NavigationView {
            return VStack {
                Text("Pending Orders").modifier(TitleStyle())
                
                List(started, id: \.shoppingCartId) { order in
                        NavigationLink(destination: OrderView(order: order)) {
                            Text(getOrderText(order: order))
                        }
                }
                
                Text("New Orders").modifier(TitleStyle())
                List(created, id: \.shoppingCartId) { order in
                        NavigationLink(destination: OrderView(order: order)) {
                            Text(getOrderText(order: order))
                        }
                }
                
                Text("Delivered Orders").modifier(TitleStyle())
                List(delivered, id: \.shoppingCartId) { order in
                        NavigationLink(destination: OrderView(order: order)) {
                            Text(getOrderText(order: order))
                        }
                }
            }.navigationBarTitle(Text("Orders"))
            
        }
    }
    
    func filterOrders(orders: [Order], filter0: String, filter1: String = "") -> [Order] {
        var res: [Order] = []
        
        for o in orders {
            if o.orderStatus == filter0 || o.orderStatus == filter1{
                res.append(o)
            }
        }
        
        return res
    }
    
    func reload() {
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

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
    }
}
