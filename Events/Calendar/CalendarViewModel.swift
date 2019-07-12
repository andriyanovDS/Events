//
//  CalendarViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 07/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

func splitDaysByWeeks(days: [Day]) -> [[Day?]] {
    let weeks: [[Day]] = days.reduce([], { (acc, day) in
        var accumulated = acc
        if day.dayOfWeek == 1 {
            accumulated.append([day])
            return accumulated
        }
        let last = accumulated.reversed().last
        if last != nil {
            accumulated[accumulated.count - 1].append(day)
            return accumulated
        }
        return [[day]]
    })
    return weeks
        .enumerated()
        .map({ (weekOffset, week) -> [Day?] in
            let daysInWeek = 7
            let daysDifference = daysInWeek - week.count
            let finalWeek = Array.init(repeating: 0, count: daysInWeek)
                .enumerated()
                .map({ (offset, _) -> Day? in
                    if weekOffset == 0 {
                        let index = offset - daysDifference
                        if index < 0 {
                            return nil
                        }
                        return week[index]
                    }
                    if offset < week.count {
                        return week[offset]
                    }
                    return nil
                })
            return finalWeek
        })
}

func generateMonths(monthsToDisplay: Int) -> [Month] {
    let dateFormatter = DateFormatter()
    let startOfCurrentMonth = Date().startOfMonth()
    dateFormatter.dateFormat = "MMMM"
    return Array
        .init(repeating: 0, count: monthsToDisplay)
        .enumerated()
        .map({ (offset, _) -> Month in
            var dateComponents = DateComponents()
            dateComponents.month = offset
            let month = Calendar.current.date(byAdding: dateComponents, to: startOfCurrentMonth)!
            let daysRange = Calendar.current.range(of: .day, in: .month, for: month)!
            let startOfMonth = month.startOfMonth()
            let days = daysRange.map({ dayOfMonth -> Day in
                dateComponents.day = dayOfMonth - 1
                dateComponents.month = 0
                let day = Calendar.current.date(byAdding: dateComponents, to: startOfMonth)!
                return Day(
                    dayOfMonth: dayOfMonth,
                    dayOfWeek: day.dayNumberOfWeek()!,
                    isToday: Calendar.current.isDateInToday(day),
                    date: day
                )
            })
            let title = dateFormatter.string(from: month)
            let weeks = splitDaysByWeeks(days: days)
            return Month(title: title, days: weeks)
        })
}

class CalendarViewModel {
    var months: [Month]
    private var selectedDateFrom: Date?
    private var selectedDateTo: Date?
    private let monthsToDisplay = 6
    private let onChangeSelectedDate: () -> Void
    var isSelectedDateSingle: Bool {
        return selectedDateFrom != nil && selectedDateTo == nil
    }
    
    var isDatesNotSeleted: Bool {
        return selectedDateFrom == nil && selectedDateTo == nil
    }
    
    init(onChangeSelectedDate: @escaping () -> Void, selectedDateFrom: Date?, selectedDateTo: Date?) {
        months = generateMonths(monthsToDisplay: monthsToDisplay)
        self.onChangeSelectedDate = onChangeSelectedDate
        self.selectedDateTo = selectedDateTo
        self.selectedDateFrom = selectedDateFrom
    }
    
    func getSelectedDates() -> SelectedDates {
        return SelectedDates(from: selectedDateFrom, to: selectedDateTo)
    }
    
    func selectDate(selectedDate: Date) {
        if let dateFrom = selectedDateFrom {
            
            if dateFrom == selectedDate {
                return
            }
            
            if selectedDateTo != nil {
                selectedDateFrom = selectedDate
                selectedDateTo = nil
            } else {
                if dateFrom > selectedDate {
                    selectedDateFrom = selectedDate
                } else {
                    selectedDateTo = selectedDate
                }
            }
            onChangeSelectedDate()
            return
        }
        
        selectedDateFrom = selectedDate
        onChangeSelectedDate()
    }
    
    func clearDates() {
        selectedDateTo = nil
        selectedDateFrom = nil
        onChangeSelectedDate()
    }
    
    func isSelectedDateFrom(date: Date) -> Bool {
        if let dateFrom = selectedDateFrom {
            return Calendar.current.isDate(dateFrom, equalTo: date, toGranularity: .day)
        }
        return false
    }
    
    func isSelectedDateTo(date: Date) -> Bool {
        if let dateTo = selectedDateTo {
            return Calendar.current.isDate(dateTo, equalTo: date, toGranularity: .day)
        }
        return false
    }
    
    func isDateInSelectedRange(date: Date) -> Bool {
        guard let dateFrom = selectedDateFrom else {
            return false
        }
        guard let dateTo = selectedDateTo else {
            return dateFrom == date
        }
        return date.isBetween(dateFrom, and: dateTo)
    }
    
    func selectedDatesToTitle() -> String? {
        guard let dateFrom = selectedDateFrom else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        
        let dateFromFormatted = dateFormatter.string(from: dateFrom)
        
        guard let dateTo = selectedDateTo else {
            return dateFromFormatted
        }
        return "\(dateFromFormatted) - \(dateFormatter.string(from: dateTo))"
    }
}

struct SelectedDates {
    let from: Date?
    let to: Date?
}

extension Date {
    
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(
            from: Calendar.current.dateComponents(
                [.year, .month],
                from: Calendar.current.startOfDay(for: self))
            )!
    }
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)) ~= self
    }
}
