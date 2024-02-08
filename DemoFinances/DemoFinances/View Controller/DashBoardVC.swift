//
//  DashBoardVC.swift
//  DemoFinances
//
//  Created by Sparrow on 2024-02-07.
//

import Foundation
import UIKit
import FSCalendar
import Charts
import DGCharts
typealias DateRange = (start: Date, end: Date)
class DashBoardVC: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var txtAmountAddEntry: UITextField!
    @IBOutlet weak var txtTypeEntry: UITextField!
    
    @IBOutlet weak var btnStartDate: UIButton!
    @IBOutlet weak var btnEndDate: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnNextMonth: UIButton!
    @IBOutlet weak var btnPrevMonth: UIButton!
    
    // MARK: - Pop-up Views
    
    @IBOutlet weak var vwAddEntry: UIView!
    @IBOutlet weak var vwIncome: UIView!
    @IBOutlet weak var vwExpenses: UIView!
    @IBOutlet weak var vwBalance: UIView!
    @IBOutlet weak var vwCalender: UIView!
    
    // MARK: - Labels
    
    @IBOutlet weak var lblIncomeTotal: UILabel!
    @IBOutlet weak var lblTotalExpenses: UILabel!
    @IBOutlet weak var lblTotalBalance: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    // MARK: - Chart Outlets
    
    @IBOutlet var IncomeChartView: BarChartView?
    @IBOutlet var ExpansechartView: BarChartView?
    @IBOutlet var BalancechartView: BarChartView?
    // MARK: - Properties
    
    var onSelected: ((_ range: DateRange)->())?
    var onSelectedOver: (()->())?
    var range: DateRange?
    var selected = [Date]()
    var isFirstSelected = false
    var isEnabledPast = true
    var currentMonth = Date() {
        didSet {
            updateButton()
        }
    }
    var maxSelected: Int?
    var minimumDate = Date().adding(.month, value: -3)
    var maximumDate = Date().adding(.year, value: 1)
    
    var calendarCurrentMonth = Date() {
        didSet {
            updateButton()
        }
    }
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    var typePickerView: UIPickerView!
    let types: [TypeEnum] = [.income, .expense]
    
    // MARK: - Presenter
    
    var presenter: DashboardPresenter!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dashboard"
        setupUI()
        setupPresenters()
        setUpPickerView()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        setupGestureRecognizers()
        setupCalendarView()
        setupChartViews()
        setupDateRange()
    }
    
    private func setUpPickerView(){
        // Set up the type dropdown
        typePickerView = UIPickerView()
        typePickerView.delegate = self
        typePickerView.dataSource = self
        txtTypeEntry.inputView = typePickerView
        txtTypeEntry.text = types[0].rawValue.capitalized
        // Add a "Done" button to the type picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        txtTypeEntry.inputAccessoryView = toolbar
    }
    
    private func setupCalendarView() {
        setupCalendar()
        updateButton()
        updateCalendar()
        displayTitleMonth(date: Date())
    }
    
    private func setupDateRange() {
        selectedStartDate = Date().adding(.day, value: -15)
        selectedEndDate = Date()
        updateDateButtonsText()
        calendar.select(selectedStartDate, scrollToDate: true)
        calendar.select(selectedEndDate, scrollToDate: true)
    }
    
    private func setupPresenters() {
        presenter = DashboardPresenter()
        presenter.view = self
        presenter.fetchData()
    }
    
    
    // Function to update text fields with formatted dates
    func updateDateButtonsText() {
        btnStartDate.setTitle(selectedStartDate.map { dateFormatter.string(from: $0) }, for: .normal)
        btnEndDate.setTitle(selectedEndDate.map { dateFormatter.string(from: $0) }, for: .normal)
        
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == scrollView.panGestureRecognizer {
            return true
        }
        
        return false
    }
    func filterTransactions(transactions: [TransactionElement], startDate: Date, endDate: Date, type: TypeEnum) -> [TransactionElement] {
        return transactions.filter { transaction in
            return transaction.date >= startDate
            && transaction.date <= endDate
            && transaction.type == type
        }
    }
    
    @objc func doneButtonTapped() {
        txtTypeEntry.resignFirstResponder()
    }
    
    func setDataCount(chartView: BarChartView, transactions: [TransactionElement]) {
        DispatchQueue.main.async {
            var entries: [BarChartDataEntry] = []
            
            for (index, transaction) in transactions.enumerated() {
                let entry = BarChartDataEntry(x: Double(index), y: Double(transaction.amount))
                entries.append(entry)
            }
            
            var set1: BarChartDataSet! = nil
            if let set = chartView.data?.first as? BarChartDataSet {
                set1 = set
                set1.replaceEntries(entries)
                chartView.data?.notifyDataChanged()
                chartView.notifyDataSetChanged()
            } else {
                set1 = BarChartDataSet(entries: entries, label: "Transaction Amount")
                set1.colors = ChartColorTemplates.material()
                set1.drawValuesEnabled = true
                
                let data = BarChartData(dataSet: set1)
                data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
                data.barWidth = 0.9
                chartView.data = data
            }
        }
    }
    
    func showInitialChartData(incomeTransactions: [TransactionElement], expenseTransactions: [TransactionElement], balanceEntries: [TransactionElement]) {
        // Show all transactions initially
        
        let allTransactions = incomeTransactions + expenseTransactions + balanceEntries
        let allStartDate = allTransactions.min(by: { $0.date < $1.date })?.date ?? Date()
        let allEndDate = allTransactions.max(by: { $0.date < $1.date })?.date ?? Date()
        DispatchQueue.main.async {
            self.btnStartDate.setTitle(allStartDate.toString(format: "MMM dd, yyyy"), for: .normal)
            self.btnEndDate.setTitle(allEndDate.toString(format: "MMM dd, yyyy"), for: .normal)
            print("Transaction - \(incomeTransactions), \(allStartDate),\(allEndDate)")
            
            // Show chart with all transactions
            self.updateChart(chartView: self.IncomeChartView ?? BarChartView(), transactions: incomeTransactions, type: .income, startDate: allStartDate, endDate: allEndDate)
            self.updateChart(chartView: self.ExpansechartView ?? BarChartView(), transactions: expenseTransactions, type: .expense, startDate: allStartDate, endDate: allEndDate)
            self.updateChart(chartView: self.BalancechartView ?? BarChartView(), transactions: balanceEntries, type: .balance, startDate: allStartDate, endDate: allEndDate)
        }
    }
    
    func showChartData(incomeTransactions: [TransactionElement], expenseTransactions: [TransactionElement], balanceEntries: [TransactionElement]) {
        updateChart(chartView: IncomeChartView ?? BarChartView(), transactions: incomeTransactions, type: .income, startDate: selectedStartDate ?? Date(), endDate: selectedEndDate ?? Date())
        updateChart(chartView: ExpansechartView ?? BarChartView(), transactions: expenseTransactions, type: .expense, startDate: selectedStartDate ?? Date(), endDate: selectedEndDate ?? Date())
        updateChart(chartView: BalancechartView ?? BarChartView(), transactions: balanceEntries, type: .balance, startDate: selectedStartDate ?? Date(), endDate: selectedEndDate ?? Date())
    }
    
    func generateEntries(transactions: [TransactionElement]) -> [BarChartDataEntry] {
        var entries: [BarChartDataEntry] = []
        
        for (index, transaction) in transactions.enumerated() {
            let entry = BarChartDataEntry(x: Double(index), y: Double(transaction.amount))
            entries.append(entry)
        }
        
        return entries
    }
    
    
    func updateTotalLabels(filteredTransactions: [TransactionElement], type: TypeEnum) {
        switch type {
        case .balance:
            let totalBalance = filteredTransactions.reduce(0) { $0 + ($1.type == .balance ? $1.amount : 0) }
            lblTotalBalance.text = formatAmount(Double(totalBalance))
        case .income, .income122:
            let totalIncome = filteredTransactions.reduce(0) { $0 + ($1.type == .income ? $1.amount : 0) }
            print("Total Income: \(totalIncome)")
            lblIncomeTotal.text = formatAmount(Double(totalIncome))
        case .expense:
            let totalExpense = filteredTransactions.reduce(0) { $0 + ($1.type == .expense ? $1.amount : 0) }
            print("Total Expense: \(totalExpense)")
            lblTotalExpenses.text = formatAmount(Double(totalExpense))
        }
    }
    func updateChart(chartView: BarChartView, transactions: [TransactionElement], type: TypeEnum, startDate: Date, endDate: Date) {
        DispatchQueue.main.async {
            // Filter transactions by type and date range
            let filteredTransactions = transactions.filter { $0.type == type && $0.date >= startDate && $0.date <= endDate }
            self.updateTotalLabels(filteredTransactions: filteredTransactions, type: type)
            
            // Extract entries and X-axis labels
            let entries = filteredTransactions.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: Double($0.element.amount)) }
            let xAxisLabels = filteredTransactions.map { $0.date.toString(format: "MMM dd") }
            
            // Create or update dataset
            let dataSet: BarChartDataSet
            if let existingDataSet = chartView.data?.first as? BarChartDataSet {
                dataSet = existingDataSet
                dataSet.replaceEntries(entries)
                chartView.data?.notifyDataChanged()
                chartView.notifyDataSetChanged()
            } else {
                dataSet = BarChartDataSet(entries: entries, label: "")
                let barColor: UIColor = {
                    switch type {
                    case .balance: return UIColor(hex: "#748AFB") // Blue
                    case .income, .income122: return UIColor(hex: "#FF539B") // System Pink
                    case .expense: return UIColor(hex: "#FFB661") // System Green
                    }
                }()
                dataSet.colors = [barColor]
                dataSet.drawValuesEnabled = false // Set to true if you want to display values on bars
                
                let data = BarChartData(dataSet: dataSet)
                data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
                data.barWidth = 0.9
                
                chartView.data = data
            }
            
            // Configure X-axis
            let xAxis = chartView.xAxis
            // self.configureAxis(xAxis, withLabels: xAxisLabels, count: min(filteredTransactions.count, 7))
            
            self.configureAxis(xAxis, withLabels: xAxisLabels, count: 6)
            
            // Configure left axis
            let leftAxis = chartView.leftAxis
            let maxAmount = filteredTransactions.map { $0.amount }.max() ?? 0
            self.configureLeftAxis(leftAxis, maxAmount: Double(maxAmount))
            
            // Disable chart legend
            chartView.legend.enabled = false
            
            // Notify chart view of changes
            chartView.notifyDataSetChanged()
        }
    }
    
    func configureAxis(_ axis: XAxis, withLabels labels: [String], count: Int) {
        axis.labelPosition = .bottom
        axis.labelFont = .systemFont(ofSize: 10)
        axis.granularity = 1
        axis.labelCount = 6
        axis.valueFormatter = IndexAxisValueFormatter(values: labels)
        axis.drawGridLinesEnabled = false
    }
    
    func configureLeftAxis(_ axis: YAxis, maxAmount: Double) {
        axis.labelFont = .systemFont(ofSize: 10)
        axis.labelCount = 6
        axis.axisMinimum = 0
        axis.axisMaximum = maxAmount + 10
    }
    
    func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return formattedAmount
    }
    
    func setup(barLineChartView chartView: BarLineChartViewBase) {
        chartView.chartDescription.enabled = false
        
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        
        chartView.rightAxis.enabled = false
    }
    
    
    func updateCalendar() {
        if !selected.isEmpty {
            selected.forEach { (date) in
                calendar.select(date)
            }
            displayRangeDates(dates: selected.sorted(by: { $0.compare($1) == .orderedAscending }))
            displayTitleMonth(date: selected[0])
        }
    }
    
    
    func displayConfirmDate(dates: [Date]) {
        selected.removeAll()
        for date in dates {
            selected.append(date)
            
        }
        
        if dates.count == 0 {
            print("-")
        } else {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "d MMMM yyyy"
            dateFormatter1.locale = Locale(identifier: "en")
            
            if dates.count == 1  {
                print(dateFormatter1.string(from: dates[0]))
            } else if dates.count == 2  {
                if dates[0].hasSame(.year, as: dates[1]) {
                    dateFormatter1.dateFormat = "d MMMM"
                }
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "d MMMM yyyy"
                dateFormatter2.locale = Locale(identifier: "en")
                print(dateFormatter1.string(from: dates[0]) + " to " + dateFormatter2.string(from: dates[1]))
            }
        }
        
    }
    
    func displayRangeDates(dates: [Date]) {
        
        selected.removeAll()
        for date in dates {
            selected.append(date)
        }
        
        if dates.count == 0 {
            print("-")
        } else {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "d MMMM yyyy"
            dateFormatter1.locale = Locale(identifier: "en")
            
            if dates.count == 1  {
                print(dateFormatter1.string(from: dates[0]))
            } else if dates.count == 2  {
                if dates[0].hasSame(.year, as: dates[1]) {
                    dateFormatter1.dateFormat = "d MMMM"
                }
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "d MMMM yyyy"
                dateFormatter2.locale = Locale(identifier: "en")
                print(dateFormatter1.string(from: dates[0]) + " to " + dateFormatter2.string(from: dates[1]))
            }
        }
    }
    
    func displayTitleMonth(date: Date) {
        let formatterSubTitle = DateFormatter()
        formatterSubTitle.dateFormat = "MMMM yyyy"
        formatterSubTitle.locale = Locale(identifier: "en")
        monthLabel.text = formatterSubTitle.string(from: date)
    }
    // MARK: - UI Actions
    
    @IBAction func btnNeverMindAct(_ sender: Any) {
        hideEntryPopup()
    }
    
    @IBAction func btnAddEntryAct(_ sender: Any) {
        showEntryPopup()
    }
}
//
//  Dashboard+Extensions.swift
//  DemoFinances
//
//  Created by Sparrow on 2024-02-07.
//

import Foundation
import DGCharts
import UIKit
import FSCalendar

// MARK: - Chart Setup and Actions
extension DashBoardVC: ChartViewDelegate, UIGestureRecognizerDelegate {
    
    private func setupGestureRecognizers() {
        setupGestureRecognizer(for: IncomeChartView ?? BarChartView())
        setupGestureRecognizer(for: BalancechartView ?? BarChartView())
        setupGestureRecognizer(for: ExpansechartView ?? BarChartView())
    }
    
    private func setupChartViews() {
        [IncomeChartView, BalancechartView, ExpansechartView].compactMap { $0 }.forEach {
            $0.delegate = self
            setupCharts(chartView: $0)
        }
    }
    
    func setupCharts(chartView: BarChartView){
        chartView.maxVisibleCount = 7
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = DayAxisValueFormatter(chart: chartView)
        xAxis.labelPosition = .bottom
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = " $"
        leftAxisFormatter.positiveSuffix = " $"
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 7
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        
        chartView.chartDescription.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        chartView.rightAxis.enabled = false
        
    }
    func setupGestureRecognizer(for chartView: BarChartView) {
        if let gestureRecognizers = chartView.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                if gestureRecognizer is UIPanGestureRecognizer {
                    gestureRecognizer.delegate = self
                }
            }
        }
    }
    
}

// MARK: - UI Actions
extension DashBoardVC {
    
    @IBAction func previousMonthAction(_ sender: UIButton) {
        presenter.changeMonth(by: -1)
        
    }
    
    @IBAction func nextMonthAction(_ sender: UIButton) {
        presenter.changeMonth(by: 1)
        
    }
    
    @IBAction func btnStartDateAction(_ sender: Any) {
        presenter.showCalendarView()
        
        
    }
    @IBAction func btnEndDateAction(_ sender: Any) {
        presenter.showCalendarView()
        
        
    }
    @IBAction func btnCancelAct(_ sender: Any) {
        presenter.hideCalendarView()
        
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        handleConfirmAction()
        
    }
    @IBAction func btnSubmitEntryAct(_ sender: Any) {
        presenter.submitEntry(amountText: txtAmountAddEntry.text, typeText: txtTypeEntry.text)
        
    }
    
    
}
// MARK: - Calendar Setup and Actions
extension DashBoardVC: FSCalendarDelegate, FSCalendarDataSource {
    private func setupCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.locale = Locale(identifier: "en")
        calendar.allowsMultipleSelection = true
        calendar.scrollDirection = .vertical
        calendar.backgroundColor = .white
        calendar.today = nil
        calendar.register(CalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.rowHeight = 25
        
        self.calendar.accessibilityIdentifier = "calendar"
        currentMonth = Date()
    }
    
    private func updateButton() {
        btnPrevMonth.isEnabled =  self.currentMonth > minimumDate
        btnNextMonth.isEnabled =  self.currentMonth.difference(from: maximumDate, only: .month) < 0
    }
}

extension DashBoardVC {
    func showCalendarView() {
        // Show the blur effect view with animation
        UIView.animate(withDuration: 0.3) {
            self.scrollView.isUserInteractionEnabled = false
        }
        
        // Reveal the hidden view with animation
        vwCalender.isHidden = false
        vwCalender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.vwCalender.transform = .identity
        }, completion: nil)
    }
    
    func hideCalendarView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.isUserInteractionEnabled = true
            self.vwCalender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { _ in
            self.vwCalender.isHidden = true
            self.vwCalender.transform = .identity
            
        }
    }
    
    func showEntryPopup() {
        
        // Reveal the hidden view with animation
        vwAddEntry.isHidden = false
        self.scrollView.isUserInteractionEnabled = false
        vwAddEntry.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.vwAddEntry.transform = .identity
        }, completion: nil)
    }
    
    func hideEntryPopup() {
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.isUserInteractionEnabled = true
                
                self.vwAddEntry.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { _ in
                self.vwAddEntry.isHidden = true
                self.vwAddEntry.transform = .identity
            }
        }
    }
    
    
    func handleConfirmAction() {
        if selected.count == 1 {
            range = DateRange(start: selected[0], end: selected[0])
        } else if selected.count > 1 {
            range = DateRange(start: selected[0], end: selected[1])
        }
        
        if let firstSelectedDate = selected.first {
            selectedStartDate = firstSelectedDate
        }
        
        if selected.count > 1, let lastSelectedDate = selected.last {
            selectedEndDate = lastSelectedDate
        } else {
            selectedEndDate = selectedStartDate
        }
        
        hideCalendarView()
        
        guard let _range = range else { return }
        onSelected?(_range)
        
        displayConfirmDate(dates: calendar.selectedDates.sorted(by: { $0.compare($1) == .orderedAscending }))
        // presenter?.handleDateSelection(selectedDate: selectedStartDate ?? Date())
        presenter.handleDateSelection(startDate: selectedStartDate ?? Date(), endDate: selectedEndDate ?? Date())
        calendar.select(selectedStartDate, scrollToDate: true)
        calendar.select(selectedEndDate, scrollToDate: true)
        btnStartDate.setTitle(selectedStartDate.map { dateFormatter.string(from: $0) }, for: .normal)
        btnEndDate.setTitle(selectedEndDate.map { dateFormatter.string(from: $0) }, for: .normal)
    }
    
    func changeMonth(by months: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: months, to: calendar.currentPage) {
            calendar.setCurrentPage(newMonth, animated: true)
            displayTitleMonth(date: newMonth)
            currentMonth = newMonth
        }
    }
}

// MARK: - UIPickerViewDelegate & DataSource

extension DashBoardVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row].rawValue.capitalized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtTypeEntry.text = types[row].rawValue.capitalized
    }
}
extension DashBoardVC{
    
    func resetCalendar() {
        calendar.selectedDates.forEach({ calendar.deselect($0) })
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return minimumDate
        //return isEnabledPast ? datePast : tomorrow
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return maximumDate
    }
    
    // MARK:- FSCalendarDataSource
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: position)
    }
    
    // MARK:- FSCalendarDelegate
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        if let selected = Calendar.current.date(byAdding: .day, value: 1, to: calendar.currentPage) {
            self.currentMonth = selected
            self.monthLabel.text = selected.toString(format: "MMMM")
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
        return true
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return true
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if isFirstSelected {
            for date in selected {
                calendar.deselect(date)
            }
            isFirstSelected = false
        }
        
        if calendar.selectedDates.count == 3 || maxSelected ?? 0 == 1 {
            self.resetCalendar()
            calendar.select(date)
        }
        
        if let max = maxSelected, max > 1, calendar.selectedDates.count == 2 {
            let more = calendar.selectedDates[0].adding(.day, value: max-1)
            let less = calendar.selectedDates[0].adding(.day, value: 1-max)
            if date > more || date < less {
                calendar.deselect(date)
                calendar.select(date >= more ? more : less)
                self.onSelectedOver?()
            }
        }
        
        self.configureVisibleCells()
        displayRangeDates(dates: calendar.selectedDates.sorted(by: { $0.compare($1) == .orderedAscending }))
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        displayRangeDates(dates: calendar.selectedDates.sorted(by: { $0.compare($1) == .orderedAscending }))
        self.configureVisibleCells()
    }
    
    // MARK: - Private functions
    
    private func configureVisibleCells() {
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let diyCell = (cell as! CalendarCell)
        var selectionType = SelectionType.none
        if calendar.selectedDates.count == 2 {
            var first = calendar.selectedDates[0]
            var second = calendar.selectedDates[1]
            if second <= first {
                let temp = first
                first = second
                second = temp
            }
            if date == first {
                selectionType = .leftBorder
            } else if date == second {
                selectionType = .rightBorder
            } else if date >= first && date <= second {
                selectionType = .middle
            }
        } else {
            if calendar.selectedDates.contains(date) {
                if calendar.selectedDates.count == 1 {
                    selectionType = .single
                } else {
                    selectionType = .none
                }
            } else {
                selectionType = .none
            }
        }
        diyCell.selectionColor = #colorLiteral(red: 0.3725490196, green: 0.462745098, blue: 0.8980392157, alpha: 1)
        diyCell.selectionType = selectionType
    }
}
