//
//  ContentView.swift
//  CodeVsCovid19
//
//  Created by Jochen Zehnder on 29.03.20.
//  Copyright © 2020 Team Peanuts. All rights reserved.
//

import SwiftUI

struct VStackStyle: ViewModifier {
    func body(content: Content) -> some View {
        return content.padding(.horizontal, 20.0).frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
    }
}

struct TitleStyle: ViewModifier {
    let font = Font.system(.title).weight(.semibold)
    func body(content: Content) -> some View {
        return content.font(font)
    }
}

struct HeadlineStyle: ViewModifier {
    let font = Font.system(.headline).weight(.semibold)
    func body(content: Content) -> some View {
        return content.font(font).padding(.vertical)
    }
}

struct OrderView: View {
    let order: Order
    var body: some View {
        NavigationView {
            VStack {
                CustomerDetailsView(order: order)
                OrderDetailsView(order: order)
                OrderItemsView(order: order)
                ShoppingDoneView(order: order)
            }
            .navigationBarTitle(getOrderText(order: order))
            .frame(minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct OrderDetailsView: View {
    var order: Order?

    var body: some View {
        var orderDate = -1
        var status = "n/a"
        var deliveryDate = -1

        if let o = order {
            orderDate = o.orderDate
            status = o.orderStatus
            deliveryDate = o.expectedDeliveryDate
        }

        return VStack(alignment: .leading) {
            Text("Order details").modifier(HeadlineStyle())
//            Text("Order date: \(orderDate)")
            Text("Order status: \(status)")
//            Text("Delivery Date: \(deliveryDate)")
        }.modifier(VStackStyle())
    }
    
    
}

struct CustomerDetailsView: View {
    var order: Order?

    var body: some View {
        var name = "n/a"
        var phone = "n/a"
        var address = "n/a"
        if let o = order {
            if let n = o.shoppingCartCustomer.customerName {
                name = n
            }
            if let i = o.shoppingCartCustomer.customerPhoneNumber {
                phone = i
            }
            if let a = o.shoppingCartCustomer.customerAddress {
                address = a
            }
        }

        return VStack(alignment: .leading) {
            Text("Customer details").modifier(HeadlineStyle())
            Text("Name: \(name)")
            Text("Phone Number: \(phone)")
            Text("Address: \(address)")
        }.modifier(VStackStyle())
    }
}

struct OrderItemsView: View {
    var order: Order?

    var body: some View {
        var items: [OrderItem] = []
        var status = "NO"
        if let order = order {
            items = order.shoppingCartItems
            status = order.orderStatus
        }

        return VStack(alignment: .leading) {
            Text("Items").modifier(HeadlineStyle())
            List(items, id: \.itemName) { item in
                OrderItemView(item: item, status: status)
            }.onAppear {
                UITableView.appearance().separatorStyle = .none
            }.onDisappear {
                UITableView.appearance().separatorStyle = .singleLine
            }
        }.modifier(VStackStyle())
    }
}

struct OrderItemView: View {
    var item: OrderItem
    var status: String
    @State var active = true

    var body: some View {
        var disabled = true
        if status == "ORDER_STARTED" {
            disabled = false
        }

        var color = Color.gray
        if active {
            color = Color.black
        }

        return Toggle(isOn: $active) {
            Text("\(item.itemQuantity)x \(item.itemName)").foregroundColor(color)
        }.disabled(disabled)
    }
}

struct ShoppingDoneView: View {
    var order: Order?

    var body: some View {
        let newStatus: String
        let text: String
        switch order?.orderStatus {
        case "ORDER_INITIATED", "ORDER_CREATED":
            newStatus = "ORDER_STARTED"
            text = "Take order"
        case "ORDER_STARTED":
            newStatus = "ORDER_WILL_BE_DELIVERED_SOON"
            text = "Shopping Completed"
        case "ORDER_WILL_BE_DELIVERED_SOON":
            newStatus = "ORDER_DELIVERED"
            text = "Order delivered"
        default:
            newStatus = "NONE"
            text = "NONE"
        }
        
        
        return Button(action: {
            self.updateOrder(order: self.order, status: newStatus)
        }) {
            HStack {
                Image(systemName: "checkmark.circle")
                    .font(.title)
                Text(text)
                    .modifier(TitleStyle())
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(30)
        }
    }

    func updateOrder(order: Order?, status: String) {
        if var o = order {
            o.orderStatus = status
            print(o)

            let jsonData: Data
            do {
                jsonData = try JSONEncoder().encode(o)
            } catch let error {
                print(error)
                return
            }
            
            var callerId = ""
            if let id = o.shoppingCartCustomer.callerId {
                callerId = id.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                print("Do nothing")
            }

            let urlString = "http://peanuts-voice-api.westus.azurecontainer.io:8080/shopping-cart/\(callerId)"
            print(urlString)
            if let url = URL(string: urlString) {
                var req = URLRequest(url: url)
                req.httpMethod = "PUT"
                req.httpBody = jsonData
                req.addValue("application/json", forHTTPHeaderField: "Content-Type")
                req.addValue("application/json", forHTTPHeaderField: "Accept")

                print("\(req.httpMethod ?? "") \(req.url)")
                let str = String(decoding: req.httpBody!, as: UTF8.self)
                print("BODY \n \(str)")
                print("HEADERS \n \(req.allHTTPHeaderFields)")
                
                URLSession.shared.dataTask(with: req) { data, _, error in
                    print("do put")
                    print("ERROR: \(error)")
                    
                    if let d = data {
                        print("DATA: " + String(decoding: d, as: UTF8.self))
                    }
                    
                    guard let data = data, error == nil else {
                        print("error")
                        print(error?.localizedDescription ?? "No data")
                        return
                    }

                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    print(responseJSON)
                    if let responseJSON = responseJSON as? [String: Any] {
                        print(responseJSON)
                    }
                }.resume()
            }
        }
    }
}



//struct OrderView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Create dummy order
//        let customer = Customer(customerName: "Dominik", callerId: "ABCCallerId", customerAddress: "Dummy Address, Zurich, Switzerland", customerPhoneNumber: "+41 79 540 52 52")
//        var items: [OrderItem] = []
//        items.append(OrderItem(itemId: "0", itemName: "Chocolate", itemQuantity: 1))
//        items.append(OrderItem(itemId: "1", itemName: "Toilet Paper", itemQuantity: 1))
//        items.append(OrderItem(itemId: "2", itemName: "BBQ Source", itemQuantity: 2))
//        let order = try Order(from: <#Decoder#>)
//
//        return OrderView(order: order)
//    }
//}
