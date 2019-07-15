//
//  LocationSearchStackView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 14/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class LocationSearchStackView: UIStackView {

    weak var delegate: LocationSearchStackViewDelegate?

    var currentLocation: Geocode? {
        didSet {
            addCurrentLocationItem()
        }
    }

    var predictions: [Prediction]? {
        willSet (nextValue) {
            let predictions = nextValue ?? []

            for view in self.subviews {
                view.removeFromSuperview()
            }

            if predictions.isEmpty {
                addCurrentLocationItem()
                return
            }

            predictions.forEach({ prediction in
                let stackItem = addStackItem(text: prediction.description)
                stackItem.placeId = prediction.place_id
            })
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addCurrentLocationItem() {
        guard let geocode = currentLocation else {
            return
        }
        let stackItem = addStackItem(text: geocode.fullLocationName())
        stackItem.geocode = geocode
    }

    private func addStackItem(text: String) -> LocationItem {
        let stackItem = LocationItem()
        stackItem.text = text
        stackItem.addTarget(delegate!, action: #selector(delegate!.onSelectLocationItem(_:)), for: .touchUpInside)
        self.addArrangedSubview(stackItem)
        return stackItem
    }
}

@objc protocol LocationSearchStackViewDelegate: class {

    @objc func onSelectLocationItem(_ button: LocationItem)
}
