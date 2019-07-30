//
//  CalendarViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 06/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, UIGestureRecognizerDelegate {
    let backgroundView = UIView()
    let contentView = UIView()
    let titleLabel = UILabel()
    let clearButton = UIButton()
    let headerView = UIView()
    let weekDaysView = UIStackView()
    let monthsView = UIStackView()
    var days: [DayButton]?
    var viewModel: CalendarViewModel?
    
    var initialSelectedDateFrom: Date?
    var initialSelectedDateTo: Date?
    var onResult: ((SelectedDates) -> Void)?
    var tapOutsideGestureRecognizer: UIGestureRecognizer?
    
    private let titleLabelText = "Веберите даты"
    
    let weekDays: [String] = ["П", "В", "С", "Ч", "П", "С", "В"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapOutsideGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeModal))
        tapOutsideGestureRecognizer?.cancelsTouchesInView = false
        tapOutsideGestureRecognizer?.delegate = self
        
        viewModel = CalendarViewModel(
            onChangeSelectedDate: onChangeSelectedDate,
            selectedDateFrom: initialSelectedDateFrom,
            selectedDateTo: initialSelectedDateTo
        )
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        days?.forEach({ day in
            guard let date = day.selectedDate else {
                return
            }
            day.higlightState = dayDateToButtonHighlightState(date: date)
        })
    }
    
    @objc func selectDay(button: DayButton) {
        guard let selectedDate = button.selectedDate else {
            return
        }
        viewModel?.selectDate(selectedDate: selectedDate)
    }
    
    @objc func clearDates() {
        viewModel?.clearDates()
    }
    
    @objc func closeModal() {
        guard let viewModel = self.viewModel else {
            return
        }
        
        if let onClose = onResult {
            onClose(viewModel.getSelectedDates())
        }
    
        navigationController?.popViewController(animated: false)
        dismiss(animated: false, completion: nil)
    }
    
    func dayDateToButtonHighlightState(date: Date) -> ButtonHiglightState {
        guard let viewModel = self.viewModel else {
            return .notSelected
        }
        
        if viewModel.isSelectedDateSingle {
            return viewModel.isSelectedDateFrom(date: date)
                ? ButtonHiglightState.single
                : ButtonHiglightState.notSelected
        }
        if viewModel.isDateInSelectedRange(date: date) {
            return viewModel.isSelectedDateFrom(date: date)
                ? ButtonHiglightState.from
                : viewModel.isSelectedDateTo(date: date)
                    ? ButtonHiglightState.to
                    : ButtonHiglightState.inRange
        }
        return .notSelected
    }
    
    func onChangeSelectedDate() {
        guard let days = self.days else {
            return 
        }
        
        guard let viewModel = self.viewModel else {
            return
        }
        
        titleLabel.text = viewModel.selectedDatesToTitle() ?? titleLabelText
        
        clearButton.isEnabled = !viewModel.isDatesNotSeleted
        
        days.forEach({ day in
            if let selectedDate = day.selectedDate {
                day.higlightState = dayDateToButtonHighlightState(date: selectedDate)
            } else {
                day.higlightState = .notSelected
            }
        })
    }
    
}

extension CalendarViewController {
    
    func setupView() {
        view.isOpaque = false
        view.backgroundColor = .clear

        setupBackgroundView()
        setupContentView()
    }
    
    func setupBackgroundView() {
        backgroundView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        backgroundView.addGestureRecognizer(tapOutsideGestureRecognizer!)
        view.addSubview(backgroundView)
        setupBackgroundViewConstraints()
    }
    
    func setupContentView() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 5
        shadowStyle(view: contentView, radius: 7, color: .black)
        
        view.addSubview(contentView)
        
        setupContentViewConstraints()
        setupHeaderView()
        setupWeekDays()
        setupCalendarScrollView()
    }
    
    func setupHeaderView() {
        contentView.addSubview(headerView)
        
        setupHeaderConstraints()
        setupTitleLabel()
        setupClearButton()
    }
    
    func setupTitleLabel() {
        headerView.addSubview(titleLabel)
        
        titleLabel.text = viewModel?.selectedDatesToTitle() ?? titleLabelText
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.init(name: "CeraPro-Medium", size: 16)
        
        setupTitleLabelConstraints()
    }
    
    func setupClearButton() {
        clearButton.setTitle("Закрыть", for: .normal)
        clearButton.setTitleColor(UIColor.lightBlue(), for: .normal)
        clearButton.setTitleColor(UIColor.lightBlue(alpha: 0.5), for: .disabled)
        clearButton.contentHorizontalAlignment = .center
        clearButton.contentEdgeInsets = UIEdgeInsets(top: 13, left: 0, bottom: 0, right: 0)
        clearButton.titleLabel?.font = UIFont.init(name: "CeraPro-Medium", size: 14)
        clearButton.isEnabled = !(viewModel?.isDatesNotSeleted ?? false)
        
        clearButton.addTarget(self, action: #selector(clearDates), for: .touchUpInside)
        
        headerView.addSubview(clearButton)
        setupClearButtonConstraint()
    }
    
    func setupWeekDays() {
        weekDays.forEach({ weekday in
            let weekDayLabel = UILabel()
            weekDayLabel.text = weekday
            weekDayLabel.textColor = .black
            weekDayLabel.textAlignment = .center
            weekDayLabel.font = UIFont.init(name: "CeraPro-Bold", size: 11)
            weekDaysView.addArrangedSubview(weekDayLabel)
            weekDayLabel.translatesAutoresizingMaskIntoConstraints = false
        })
        weekDaysView.axis = .horizontal
        weekDaysView.alignment = .fill
        weekDaysView.distribution = .fillEqually
        
        contentView.addSubview(weekDaysView)
        setupWeekDaysViewConstraint()
    
        let bottomBorderView = UIView(frame: weekDaysView.bounds)
        bottomBorderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let borderBottomLayer = CALayer()
        borderBottomLayer.backgroundColor = UIColor.gray400().cgColor
        borderBottomLayer.frame = CGRect(x: 0, y: 30, width: UIScreen.main.bounds.width - 30, height: 1)
        bottomBorderView.layer.addSublayer(borderBottomLayer)
        
        weekDaysView.insertSubview(bottomBorderView, at: 0)
    }
    
    func setupCalendarScrollView() {
        monthsView.axis = .vertical
        monthsView.alignment = .fill
        monthsView.distribution = .fillEqually
        monthsView.spacing = 0
        let calendarScrollView = UIScrollView()
        calendarScrollView.showsVerticalScrollIndicator = false
        calendarScrollView.addSubview(monthsView)
        contentView.addSubview(calendarScrollView)
        
        setupScrollViewConstraints(calendarScrollView: calendarScrollView)
        setupMonthsViewConstraints(calendarScrollView: calendarScrollView)
        guard let days = setupMonthView() else {
            return
        }
        self.days = days
    }
    
    func setupMonthView() -> [DayButton]? {
        return viewModel?.months
            .enumerated()
            .map({ (offset, month) -> [DayButton] in
                let monthView = UIStackView()
                monthView.axis = .vertical
                monthView.alignment = .fill
                monthView.distribution = .equalSpacing
                monthView.spacing = 10
                monthView.translatesAutoresizingMaskIntoConstraints = false
                monthsView.addArrangedSubview(monthView)
                setupMonthTitleLabel(monthView: monthView, monthLabel: month.title)
                
                return month.days
                    .enumerated()
                    .map { setupWeekView(monthView: monthView, days: $1, monthIndex: offset, weekIndex: $0) }
                    .reduce([], +)
            })
            .reduce([], +)
    }
    
    func setupMonthTitleLabel(monthView: UIStackView, monthLabel: String) {
        let titleLabel = UILabel()
        titleLabel.text = monthLabel
        titleLabel.textColor = UIColor.gray900()
        titleLabel.font = UIFont.init(name: "CeraPro-Medium", size: 16)
        monthView.addArrangedSubview(titleLabel)
        setupMonthLabelConstraints(monthView: monthView, label: titleLabel)
    }
    
    func setupWeekView(
        monthView: UIStackView,
        days: [Day?],
        monthIndex: Int,
        weekIndex: Int
    ) -> [DayButton] {
        let weekView = UIStackView()
        weekView.axis = .horizontal
        weekView.alignment = .fill
        weekView.distribution = .fillEqually
        monthView.addArrangedSubview(weekView)
        setupWeekConstraints(monthView: monthView, weekView: weekView)
        
        return days.enumerated().map { setupDayView(
            weekView: weekView,
            day: $1,
            monthIndex: monthIndex,
            weekIndex: weekIndex,
            dayIndex: $0
        ) }
    }
    
    func setupDayView(
        weekView: UIStackView,
        day: Day?,
        monthIndex: Int,
        weekIndex: Int,
        dayIndex: Int
    ) -> DayButton {
        let dayButton = DayButton()
        if let dayOfMonth = day?.dayOfMonth {
             dayButton.setTitle(String(dayOfMonth), for: .normal)
             dayButton.setTitleColor(UIColor.gray600(), for: .normal)
             dayButton.titleLabel?.font = UIFont.init(name: "CeraPro-Medium", size: 14)
        }
        
        if let selectedDate = day?.date {
            dayButton.higlightState = dayDateToButtonHighlightState(date: selectedDate)
            dayButton.selectedDate = selectedDate
        }
        
        dayButton.isToday = day?.isToday ?? false
        
        dayButton.addTarget(self, action: #selector(selectDay(button:)), for: .touchUpInside)
        dayButton.translatesAutoresizingMaskIntoConstraints = false
        weekView.addArrangedSubview(dayButton)
        return dayButton
    }
    
    func setupBackgroundViewConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupContentViewConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            contentView.heightAnchor.constraint(equalToConstant: 360)
        ])
    }
    
    func setupHeaderConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0)
        ])
    }
    
    func setupTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 0),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10)
        ])
    }
    
    func setupClearButtonConstraint() {
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clearButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
            clearButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
            clearButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0)
        ])
    }
    
    func setupWeekDaysViewConstraint() {
        weekDaysView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weekDaysView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            weekDaysView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            weekDaysView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            weekDaysView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setupScrollViewConstraints(calendarScrollView: UIScrollView) {
        calendarScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarScrollView.topAnchor.constraint(equalTo: weekDaysView.bottomAnchor, constant: 10),
            calendarScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            calendarScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            calendarScrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            calendarScrollView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
    
    func setupMonthsViewConstraints(calendarScrollView: UIScrollView) {
        monthsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthsView.topAnchor.constraint(equalTo: calendarScrollView.topAnchor, constant: 0),
            monthsView.leadingAnchor.constraint(equalTo: calendarScrollView.leadingAnchor, constant: 0),
            monthsView.trailingAnchor.constraint(equalTo: calendarScrollView.trailingAnchor, constant: 0),
            monthsView.bottomAnchor.constraint(equalTo: calendarScrollView.bottomAnchor, constant: 0),
            monthsView.widthAnchor.constraint(equalTo: calendarScrollView.widthAnchor)
        ])
    }
    
    func setupMonthLabelConstraints(monthView: UIView, label: UIView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: monthView.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: monthView.leadingAnchor, constant: 15)
        ])
    }
    
    func setupWeekConstraints(monthView: UIView, weekView: UIView) {
        weekView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weekView.leadingAnchor.constraint(equalTo: monthView.leadingAnchor, constant: 5),
            weekView.trailingAnchor.constraint(equalTo: monthView.trailingAnchor, constant: -5),
            weekView.widthAnchor.constraint(equalTo: monthView.widthAnchor),
            weekView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

enum SemicircleDirection {
    case left, right
}

enum ButtonHiglightState {
    case from, to, inRange, single, notSelected
}
