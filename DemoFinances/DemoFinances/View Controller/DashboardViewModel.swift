//
//  DashboardViewModel.swift
//  DemoFinances
//
//  Created by Sparrow on 2024-02-08.
//

import Foundation
// DashboardViewModel.swift
class DashboardViewModel {
    var allTransactions: [TransactionElement] = []
    
    func fetchData(completion: @escaping ([TransactionElement]?) -> Void) {
        APIService.shared.fetchData { transactions in
            if let transactions = transactions {
                self.allTransactions = transactions
                completion(transactions)
            } else {
                completion(nil)
            }
        }
    }
    
    func filterTransactionsForSelectedRange(startDate: Date, endDate: Date) -> [TransactionElement] {
        return allTransactions.filter { transaction in
            return transaction.date >= startDate && transaction.date <= endDate
        }
    }
    
    func filterTransactions(transactions: [TransactionElement], type: TypeEnum) -> [TransactionElement] {
        return transactions.filter { $0.type == type }
    }
    
    func calculateBalance(transactions: [TransactionElement]) -> [TransactionElement] {
        var balanceTransactions: [TransactionElement] = []
        var runningBalance: Double = 0
        
        for transaction in transactions {
            let incomeAmount = transaction.type == .income ? transaction.amount : 0
            let expenseAmount = transaction.type == .expense ? transaction.amount : 0
            runningBalance = Double(incomeAmount - expenseAmount)
            
            let balanceTransaction = TransactionElement(
                id: Int(UUID().uuid.0),
                createdAt: transaction.createdAt,
                type: .balance,
                amount: Int(runningBalance)
            )
            
            balanceTransactions.append(balanceTransaction)
        }
        
        return balanceTransactions
    }
}
