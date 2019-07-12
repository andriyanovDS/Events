//
//  RootScreenViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

class RootScreenViewModel {
    
    private var selectedDateFrom: Date?
    private var selectedDateTo: Date?
    
    func setSelectedDates(dates: SelectedDates) {
        selectedDateFrom = dates.from
        selectedDateTo = dates.to
    }
    
    func selectedDatesToString() -> String? {
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
    
    func getSelectedDates() -> SelectedDates {
        return SelectedDates(from: selectedDateFrom, to: selectedDateTo)
    }
}
