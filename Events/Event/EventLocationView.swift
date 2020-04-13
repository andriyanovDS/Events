//
//  EventLocationView.swift
//  Events
//
//  Created by Dmitry on 25.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import MapKit.MKMapSnapshotter

class EventLocationView: UIStackView {
	private let location: CLLocation
	private let titleLabel = UILabel()
	private let mapSnapshotImageView = UIImageView()
	
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
	
	private struct Constants {
		static let mapSnapshotSize = CGSize(
			width: UIScreen.main.bounds.width - 40,
			height: 200
		)
	}
	
	private func setupView() {
		styleText(
			label: titleLabel,
			text: NSLocalizedString("Place of meeting", comment: "Event location section title"),
			size: 22,
			color: .fontLabel,
			style: .bold
		)
		titleLabel.numberOfLines = 2
		mapSnapshotImageView.contentMode = .scaleAspectFill
		mapSnapshotImageView.layer.cornerRadius = 6
		mapSnapshotImageView.translatesAutoresizingMaskIntoConstraints = false
		mapSnapshotImageView
			.width(Constants.mapSnapshotSize.width)
			.height(Constants.mapSnapshotSize.height)
		
		setupMapSnapshot()
		axis = .vertical
		alignment = .leading
		spacing = 10
		addArrangedSubview(titleLabel)
		addArrangedSubview(mapSnapshotImageView)
	}
	
	private func setupMapSnapshot() {
		let coordinateRegion = MKCoordinateRegion(
			center: location.coordinate,
			latitudinalMeters: 500,
			longitudinalMeters: 500
		)
		
		let snapshotOptions = MKMapSnapshotter.Options()
		snapshotOptions.region = coordinateRegion
		snapshotOptions.showsBuildings = true
		snapshotOptions.scale = UIScreen.main.scale
		snapshotOptions.size = Constants.mapSnapshotSize
		
		DispatchQueue.global(qos: .userInteractive).async {
			let snapshot = MKMapSnapshotter(options: snapshotOptions)
			
			snapshot.start { snapshot, error in
				guard let snapshot = snapshot, error == nil else {
					print(error ?? "Unknown error")
					return
				}
				
				let image = UIGraphicsImageRenderer(size: Constants.mapSnapshotSize).image {[unowned self] _ in
					snapshot.image.draw(at: .zero)
					
					let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
					let point = snapshot.point(for: self.location.coordinate)
					pinView.image?.draw(at: point)
				}
				
				DispatchQueue.main.async {
					self.mapSnapshotImageView.image = image
				}
			}
		}
	}
}

class Annotation: NSObject, MKAnnotation {
	let coordinate: CLLocationCoordinate2D
	
	init(coordinate: CLLocationCoordinate2D) {
		self.coordinate = coordinate
	}
}
