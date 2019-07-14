//
//  SearchBarDelegate.swift
//  Events
//
//  Created by Дмитрий Андриянов on 14/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

protocol SearchBarDelegate: NSObject {

    func searchBarDidActivate()

    func searchBarDidCancel()
}

extension SearchBarDelegate {

    func searchBarDidActivate() {
        print("SearchBar did activate")
    }

    func searchBarDidCancel() {
        print("SearchBar did cancel")
    }
}
