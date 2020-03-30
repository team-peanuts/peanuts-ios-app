//
//  OrderModel.swift
//  CodeVsCovid19
//
//  Created by Jochen Zehnder on 29.03.20.
//  Copyright © 2020 Team Peanuts. All rights reserved.
//

import Foundation

struct Order: Codable {
    var shoppingCartId: String
    var shoppingCartCustomer: Customer
    var shoppingCartItems: [OrderItem]
    var orderDate: Int
    var expectedDeliveryDate: Int
    var orderStatus: String
    var friendlyNeighbourName: String?

    enum CodingKeys: String, CodingKey {case shoppingCartId, shoppingCartCustomer, shoppingCartItems, orderDate, expectedDeliveryDate, orderStatus, friendlyNeighbourName}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.shoppingCartId = try container.decode(String.self, forKey: .shoppingCartId)
        self.shoppingCartCustomer = try container.decode(Customer.self, forKey: .shoppingCartCustomer)
        self.shoppingCartItems = try container.decode([OrderItem].self, forKey: .shoppingCartItems)
        self.orderDate = try container.decode(Int.self, forKey: .orderDate)
        self.expectedDeliveryDate = try container.decode(Int.self, forKey: .expectedDeliveryDate)
        self.orderStatus = try container.decode(String.self, forKey: .orderStatus)
        self.friendlyNeighbourName = try container.decode(String?.self, forKey: .friendlyNeighbourName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(shoppingCartId, forKey: .shoppingCartId)
        try container.encode(shoppingCartCustomer, forKey: .shoppingCartCustomer)
        try container.encode(shoppingCartItems, forKey: .shoppingCartItems)
        try container.encode(orderDate, forKey: .orderDate)
        try container.encode(expectedDeliveryDate, forKey: .expectedDeliveryDate)
        try container.encode(orderStatus, forKey: .orderStatus)
        try container.encode(friendlyNeighbourName, forKey: .friendlyNeighbourName)
    }
}

struct Customer: Codable {
    var customerName: String?
    var callerId: String?
    var customerAddress: String?
    var customerPhoneNumber: String?
    
    enum CodingKeys: String, CodingKey {case customerName, callerId, customerAddress, customerPhoneNumber}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.customerName = try container.decode(String?.self, forKey: .customerName)
        self.callerId = try container.decode(String?.self, forKey: .callerId)
        self.customerAddress = try container.decode(String?.self, forKey: .customerAddress)
        self.customerPhoneNumber = try container.decode(String?.self, forKey: .customerPhoneNumber)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(customerName, forKey: .customerName)
        try container.encode(callerId, forKey: .callerId)
        try container.encode(customerAddress, forKey: .customerAddress)
        try container.encode(customerPhoneNumber, forKey: .customerPhoneNumber)
    }
}

struct OrderItem: Codable {
    var itemId: String
    var itemName: String
    var itemQuantity: Int
    
    enum CodingKeys: String, CodingKey {case itemId, itemName, itemQuantity}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.itemId = try container.decode(String.self, forKey: .itemId)
        self.itemName = try container.decode(String.self, forKey: .itemName)
        self.itemQuantity = try container.decode(Int.self, forKey: .itemQuantity)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(itemId, forKey: .itemId)
        try container.encode(itemName, forKey: .itemName)
        try container.encode(itemQuantity, forKey: .itemQuantity)
    }
}

func getOrderText(order: Order) -> String {
    var res = "n/a"
    
    if let n = order.shoppingCartCustomer.customerName {
        res = n
    }
    
    return res
}
