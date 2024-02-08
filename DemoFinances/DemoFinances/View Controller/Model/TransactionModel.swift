//
//  TransactionModel.swift
//  DemoFinances
//
//  Created by Sparrow on 2024-02-07.
//

import Foundation
// Transaction.swift
struct TransactionElement: Codable {
    let id, createdAt: Int
    let type: TypeEnum
    let amount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case type, amount
    }
    var date: Date {
        print(Date(timeIntervalSince1970: TimeInterval(createdAt)/1000))
        return Date(timeIntervalSince1970: TimeInterval(createdAt)/1000)
    }
}

enum TypeEnum: String, Codable {
    case expense = "expense"
    case income = "income"
    case income122 = "income122"
    case balance = "balance" // Add this case for the balance type
    
}
struct TransactionInput: Encodable {
    let type: TypeEnum
    let amount: Double
}
typealias Transaction = [TransactionElement]

