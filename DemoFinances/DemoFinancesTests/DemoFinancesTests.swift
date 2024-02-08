//
//  DemoFinancesTests.swift
//  DemoFinancesTests
//
//  Created by Sparrow on 2024-02-07.
//

import XCTest
@testable import DemoFinances
@testable import DGCharts


final class DemoFinancesTests: XCTestCase {
    
    var apiService: APIService!
    var viewModel: DashboardViewModel!
    var presenter: DashboardPresenter!
    
    override func setUp() {
        super.setUp()
        
        apiService = APIService.shared
        viewModel = DashboardViewModel()
        presenter = DashboardPresenter()
    }
    
    override func tearDown() {
        apiService = nil
        viewModel = nil
        presenter = nil
        
        super.tearDown()
    }
    
    func testFetchData() {
        let expectation = XCTestExpectation(description: "Fetch data expectation")
        
        apiService.fetchData { transactions in
            XCTAssertNotNil(transactions, "Fetch data failed")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSubmitTransaction() {
        let expectation = XCTestExpectation(description: "Submit transaction expectation")
        
        let transactionInput = TransactionInput(type: .income, amount: 100.0)
        
        apiService.submitTransaction(transactionInput) { success in
            XCTAssertTrue(success, "Submit transaction failed")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFilterTransactions() {
        let allTransactions = [
            TransactionElement(id: 1, createdAt: 1644310800, type: .income, amount: 100),
            TransactionElement(id: 2, createdAt: 1644310810, type: .expense, amount: 50),
            TransactionElement(id: 3, createdAt: 1644310820, type: .balance, amount: 50)
        ]
        
        let filteredIncome = viewModel.filterTransactions(transactions: allTransactions, type: .income)
        XCTAssertEqual(filteredIncome.count, 1, "Filtering income transactions failed")
        
        let filteredExpense = viewModel.filterTransactions(transactions: allTransactions, type: .expense)
        XCTAssertEqual(filteredExpense.count, 1, "Filtering expense transactions failed")
        
        let filteredBalance = viewModel.filterTransactions(transactions: allTransactions, type: .balance)
        XCTAssertEqual(filteredBalance.count, 1, "Filtering balance transactions failed")
    }
    
    func testCalculateBalance() {
        let transactions = [
            TransactionElement(id: 1, createdAt: 1644310800, type: .income, amount: 100),
            TransactionElement(id: 2, createdAt: 1644310810, type: .expense, amount: 50),
            TransactionElement(id: 3, createdAt: 1644310820, type: .expense, amount: 30)
        ]
        
        let balanceTransactions = viewModel.calculateBalance(transactions: transactions)
        
        XCTAssertEqual(balanceTransactions.count, 3, "Calculating balance transactions failed")
        XCTAssertEqual(balanceTransactions[0].amount, 100, "Incorrect balance amount for the first transaction")
        XCTAssertEqual(balanceTransactions[1].amount, 50, "Incorrect balance amount for the second transaction")
        XCTAssertEqual(balanceTransactions[2].amount, 20, "Incorrect balance amount for the third transaction")
    }
    
    
}
