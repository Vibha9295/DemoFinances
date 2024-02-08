////
////  Dashboard+Extensions.swift
////  DemoFinances
////
////  Created by Sparrow on 2024-02-07.
////
//
//import Foundation
//import DGCharts
//import UIKit
//import FSCalendar
//
//// MARK: - Chart Setup and Actions
//extension DashBoardVC: ChartViewDelegate, UIGestureRecognizerDelegate {
//    
//    private func setupGestureRecognizers() {
//        setupGestureRecognizer(for: IncomeChartView ?? BarChartView())
//        setupGestureRecognizer(for: BalancechartView ?? BarChartView())
//        setupGestureRecognizer(for: ExpansechartView ?? BarChartView())
//    }
//    
//    private func setupChartViews() {
//        [IncomeChartView, BalancechartView, ExpansechartView].compactMap { $0 }.forEach {
//            $0.delegate = self
//            setupCharts(chartView: $0)
//        }
//    }
//    
//    func setupCharts(chartView: BarChartView){
//        chartView.maxVisibleCount = 7
//        
//        let xAxis = chartView.xAxis
//        xAxis.labelPosition = .bottom
//        xAxis.labelFont = .systemFont(ofSize: 10)
//        xAxis.granularity = 1
//        xAxis.labelCount = 7
//        xAxis.valueFormatter = DayAxisValueFormatter(chart: chartView)
//        xAxis.labelPosition = .bottom
//        
//        let leftAxisFormatter = NumberFormatter()
//        leftAxisFormatter.minimumFractionDigits = 0
//        leftAxisFormatter.maximumFractionDigits = 1
//        leftAxisFormatter.negativeSuffix = " $"
//        leftAxisFormatter.positiveSuffix = " $"
//        
//        let leftAxis = chartView.leftAxis
//        leftAxis.labelFont = .systemFont(ofSize: 10)
//        leftAxis.labelCount = 7
//        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
//        leftAxis.labelPosition = .outsideChart
//        leftAxis.spaceTop = 0.15
//        leftAxis.axisMinimum = 0
//        
//        chartView.chartDescription.enabled = false
//        chartView.dragEnabled = true
//        chartView.setScaleEnabled(true)
//        chartView.pinchZoomEnabled = false
//        chartView.rightAxis.enabled = false
//        
//    }
//    func setupGestureRecognizer(for chartView: BarChartView) {
//        if let gestureRecognizers = chartView.gestureRecognizers {
//            for gestureRecognizer in gestureRecognizers {
//                if gestureRecognizer is UIPanGestureRecognizer {
//                    gestureRecognizer.delegate = self
//                }
//            }
//        }
//    }
//    
//}
//
//// MARK: - UI Actions
//extension DashBoardVC {
//    
//    @IBAction func previousMonthAction(_ sender: UIButton) {
//        presenter.changeMonth(by: -1)
//        
//    }
//    
//    @IBAction func nextMonthAction(_ sender: UIButton) {
//        presenter.changeMonth(by: 1)
//        
//    }
//    
//    @IBAction func btnStartDateAction(_ sender: Any) {
//        presenter.showCalendarView()
//        
//        
//    }
//    @IBAction func btnEndDateAction(_ sender: Any) {
//        presenter.showCalendarView()
//        
//        
//    }
//    @IBAction func btnCancelAct(_ sender: Any) {
//        presenter.hideCalendarView()
//        
//    }
//    
//    @IBAction func confirmAction(_ sender: UIButton) {
//        handleConfirmAction()
//        
//    }
//    @IBAction func btnSubmitEntryAct(_ sender: Any) {
//        presenter.submitEntry(amountText: txtAmountAddEntry.text, typeText: txtTypeEntry.text)
//        
//    }
//    
//    
//}
//// MARK: - Calendar Setup and Actions
//extension DashBoardVC: FSCalendarDelegate, FSCalendarDataSource {
//    private func setupCalendar() {
//        calendar.delegate = self
//        calendar.dataSource = self
//        calendar.locale = Locale(identifier: "en")
//        calendar.allowsMultipleSelection = true
//        calendar.scrollDirection = .vertical
//        calendar.backgroundColor = .white
//        calendar.today = nil
//        calendar.register(CalendarCell.self, forCellReuseIdentifier: "cell")
//        calendar.rowHeight = 25
//        
//        self.calendar.accessibilityIdentifier = "calendar"
//        currentMonth = Date()
//    }
//    
//    private func updateButton() {
//        btnPrevMonth.isEnabled =  self.currentMonth > minimumDate
//        btnNextMonth.isEnabled =  self.currentMonth.difference(from: maximumDate, only: .month) < 0
//    }
//}
//
//extension DashBoardVC {
//    func showCalendarView() {
//        // Show the blur effect view with animation
//        UIView.animate(withDuration: 0.3) {
//            self.scrollView.isUserInteractionEnabled = false
//        }
//        
//        // Reveal the hidden view with animation
//        vwCalender.isHidden = false
//        vwCalender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
//            self.vwCalender.transform = .identity
//        }, completion: nil)
//    }
//    
//    func hideCalendarView() {
//        UIView.animate(withDuration: 0.3, animations: {
//            self.scrollView.isUserInteractionEnabled = true
//            self.vwCalender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//        }) { _ in
//            self.vwCalender.isHidden = true
//            self.vwCalender.transform = .identity
//            
//        }
//    }
//    
//    func showEntryPopup() {
//        
//        // Reveal the hidden view with animation
//        vwAddEntry.isHidden = false
//        self.scrollView.isUserInteractionEnabled = false
//        vwAddEntry.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
//            self.vwAddEntry.transform = .identity
//        }, completion: nil)
//    }
//    
//    func hideEntryPopup() {
//        UIView.animate(withDuration: 0.3, animations: {
//            self.scrollView.isUserInteractionEnabled = true
//            
//            self.vwAddEntry.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//        }) { _ in
//            self.vwAddEntry.isHidden = true
//            self.vwAddEntry.transform = .identity
//        }
//    }
//    
//    
//    func handleConfirmAction() {
//        if selected.count == 1 {
//            range = DateRange(start: selected[0], end: selected[0])
//        } else if selected.count > 1 {
//            range = DateRange(start: selected[0], end: selected[1])
//        }
//        
//        if let firstSelectedDate = selected.first {
//            selectedStartDate = firstSelectedDate
//        }
//        
//        if selected.count > 1, let lastSelectedDate = selected.last {
//            selectedEndDate = lastSelectedDate
//        } else {
//            selectedEndDate = selectedStartDate
//        }
//        
//        hideCalendarView()
//        
//        guard let _range = range else { return }
//        onSelected?(_range)
//        
//        displayConfirmDate(dates: calendar.selectedDates.sorted(by: { $0.compare($1) == .orderedAscending }))
//        // presenter?.handleDateSelection(selectedDate: selectedStartDate ?? Date())
//        presenter.handleDateSelection(startDate: selectedStartDate ?? Date(), endDate: selectedEndDate ?? Date())
//        calendar.select(selectedStartDate, scrollToDate: true)
//        calendar.select(selectedEndDate, scrollToDate: true)
//        btnStartDate.setTitle(selectedStartDate.map { dateFormatter.string(from: $0) }, for: .normal)
//        btnEndDate.setTitle(selectedEndDate.map { dateFormatter.string(from: $0) }, for: .normal)
//    }
//    
//    func changeMonth(by months: Int) {
//        if let newMonth = Calendar.current.date(byAdding: .month, value: months, to: calendar.currentPage) {
//            calendar.setCurrentPage(newMonth, animated: true)
//            displayTitleMonth(date: newMonth)
//            currentMonth = newMonth
//        }
//    }
//}
//
//// MARK: - UIPickerViewDelegate & DataSource
//
//extension DashBoardVC: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return types.count
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return types[row].rawValue.capitalized
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        txtTypeEntry.text = types[row].rawValue.capitalized
//    }
//}
//extension DashBoardVC{
//    
//    func resetCalendar() {
//        calendar.selectedDates.forEach({ calendar.deselect($0) })
//    }
//    
//    func minimumDate(for calendar: FSCalendar) -> Date {
//        return minimumDate
//        //return isEnabledPast ? datePast : tomorrow
//    }
//    
//    func maximumDate(for calendar: FSCalendar) -> Date {
//        return maximumDate
//    }
//    
//    // MARK:- FSCalendarDataSource
//    
//    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
//        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
//        return cell
//    }
//    
//    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
//        self.configure(cell: cell, for: date, at: position)
//    }
//    
//    // MARK:- FSCalendarDelegate
//    
//    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//        if let selected = Calendar.current.date(byAdding: .day, value: 1, to: calendar.currentPage) {
//            self.currentMonth = selected
//            self.monthLabel.text = selected.toString(format: "MMMM")
//        }
//    }
//    
//    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
//        return true
//    }
//    
//    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//        return true
//    }
//    
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        if isFirstSelected {
//            for date in selected {
//                calendar.deselect(date)
//            }
//            isFirstSelected = false
//        }
//        
//        if calendar.selectedDates.count == 3 || maxSelected ?? 0 == 1 {
//            self.resetCalendar()
//            calendar.select(date)
//        }
//        
//        if let max = maxSelected, max > 1, calendar.selectedDates.count == 2 {
//            let more = calendar.selectedDates[0].adding(.day, value: max-1)
//            let less = calendar.selectedDates[0].adding(.day, value: 1-max)
//            if date > more || date < less {
//                calendar.deselect(date)
//                calendar.select(date >= more ? more : less)
//                self.onSelectedOver?()
//            }
//        }
//        
//        self.configureVisibleCells()
//        displayRangeDates(dates: calendar.selectedDates.sorted(by: { $0.compare($1) == .orderedAscending }))
//    }
//    
//    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        displayRangeDates(dates: calendar.selectedDates.sorted(by: { $0.compare($1) == .orderedAscending }))
//        self.configureVisibleCells()
//    }
//    
//    // MARK: - Private functions
//    
//    private func configureVisibleCells() {
//        calendar.visibleCells().forEach { (cell) in
//            let date = calendar.date(for: cell)
//            let position = calendar.monthPosition(for: cell)
//            self.configure(cell: cell, for: date!, at: position)
//        }
//    }
//    
//    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
//        let diyCell = (cell as! CalendarCell)
//        var selectionType = SelectionType.none
//        if calendar.selectedDates.count == 2 {
//            var first = calendar.selectedDates[0]
//            var second = calendar.selectedDates[1]
//            if second <= first {
//                let temp = first
//                first = second
//                second = temp
//            }
//            if date == first {
//                selectionType = .leftBorder
//            } else if date == second {
//                selectionType = .rightBorder
//            } else if date >= first && date <= second {
//                selectionType = .middle
//            }
//        } else {
//            if calendar.selectedDates.contains(date) {
//                if calendar.selectedDates.count == 1 {
//                    selectionType = .single
//                } else {
//                    selectionType = .none
//                }
//            } else {
//                selectionType = .none
//            }
//        }
//        diyCell.selectionColor = #colorLiteral(red: 0.3725490196, green: 0.462745098, blue: 0.8980392157, alpha: 1)
//        diyCell.selectionType = selectionType
//    }
//}
