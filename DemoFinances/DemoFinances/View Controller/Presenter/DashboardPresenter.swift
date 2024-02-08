//
//  DashboardPresenter.swift
//  DemoFinances
//
//  Created by Sparrow on 2024-02-07.
//

import Foundation
class DashboardPresenter {
    weak var view: DashBoardVC?
    let viewModel = DashboardViewModel()
    
    func fetchData() {
        viewModel.fetchData { [weak self] transactions in
            guard let self = self, let transactions = transactions else { return }
            self.view?.showInitialChartData(
                incomeTransactions: self.viewModel.filterTransactions(transactions: transactions, type: .income),
                expenseTransactions: self.viewModel.filterTransactions(transactions: transactions, type: .expense),
                balanceEntries: self.viewModel.calculateBalance(transactions: transactions)
            )
        }
    }
    func submitTransaction(_ transactionInput: TransactionInput, completion: @escaping (Bool) -> Void) {
        // Use your API service to submit the transaction
        APIService.shared.submitTransaction(transactionInput) { success in
            completion(success)
        }
    }
    func handleDateSelection(startDate: Date, endDate: Date) {
        let filteredTransactions = viewModel.filterTransactionsForSelectedRange(startDate: startDate, endDate: endDate)
        view?.showChartData(
            incomeTransactions: viewModel.filterTransactions(transactions: filteredTransactions, type: .income),
            expenseTransactions: viewModel.filterTransactions(transactions: filteredTransactions, type: .expense),
            balanceEntries: viewModel.calculateBalance(transactions: filteredTransactions)
        )
    }
    func showCalendarView() {
        view?.showCalendarView()
    }
    
    func hideCalendarView() {
        view?.hideCalendarView()
    }
    func showEntryPopup() {
        view?.showEntryPopup()
    }
    func hideEntryPopup() {
        view?.hideEntryPopup()
    }
    
    func changeMonth(by months: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: months, to: view?.currentMonth ?? Date()) else { return }
        view?.calendar.setCurrentPage(newMonth, animated: true)
        view?.displayTitleMonth(date: newMonth)
        view?.currentMonth = newMonth
    }
    
    func submitEntry(amountText: String?, typeText: String?) {
        guard let amountText = amountText, let typeText = typeText, let amount = Double(amountText), let type = TypeEnum(rawValue: typeText.lowercased()) else {
            // Handle invalid input
            return
        }
        
        let transactionInput = TransactionInput(type: type, amount: amount)
        
        submitTransaction(transactionInput) { success in
            if success {
                // Reload or update your data after a successful transaction
                self.fetchData()
                self.hideEntryPopup()
            } else {
                // Handle API error
                print("Failed to submit transaction")
            }
        }
        self.view?.txtAmountAddEntry.text = nil
        
        
    }
    
}
