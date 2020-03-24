//
//  EventLocationView.swift
//  Events
//
//  Created by Dmitry on 25.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import MapKit

class EventLocationView: UIStackView {
	private let location: CLLocation
	private let titleLabel = UILabel()
	private let mapView = MKMapView()
	
	init(location: EventLocation) {
		self.location = CLLocation(
			latitude: location.lat,
			longitude: location.lng
		)
		super.init(frame: CGRect.zero)
		setupView()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupView() {
		styleText(
			label: titleLabel,
			text: NSLocalizedString("Place of meeting", comment: "Event location section title"),
			size: 22,
			color: .black,
			style: .bold
		)
		titleLabel.numberOfLines = 2
		setupMap()
		axis = .vertical
		alignment = .leading
		spacing = 10
		addArrangedSubview(titleLabel)
		addArrangedSubview(mapView)
	}
	
	private func setupMap() {
		let coordinateRegion = MKCoordinateRegion(
			center: location.coordinate,
			latitudinalMeters: 500,
			longitudinalMeters: 500
		)
		mapView.layer.cornerRadius = 6
		mapView.isUserInteractionEnabled = false
		mapView.setRegion(coordinateRegion, animated: false)
		mapView.addAnnotation(Annotation(coordinate: location.coordinate))
		mapView.width(UIScreen.main.bounds.width - 40).height(200)
	}
}

class Annotation: NSObject, MKAnnotation {
	let coordinate: CLLocationCoordinate2D
	
	init(coordinate: CLLocationCoordinate2D) {
		self.coordinate = coordinate
	}
}
