//
//  EventCellView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Promises
import Hero
import SwiftIconFont
import UIKit
import func AVFoundation.AVMakeRect

class EventCellView: UITableViewCell, ReuseIdentifiable {
  var id: String?
  let cardView = EventCardView()
  let shadowView = UIView()
  private let roundedView = UIView()
	private var isEventImageLoaded: Bool = false
  
  override var frame: CGRect {
    didSet {
      frameDidSet(to: frame, from: oldValue)
    }
  }
  
  static let reuseIdentifier = String(describing: EventCellView.self)
  
  struct Constants {
    static let cellPaddingHorizontal: CGFloat = 15
    static var eventImageSize: CGSize = CGSize(
			width: UIScreen.main.bounds.width - (Constants.cellPaddingHorizontal * 2.0),
			height: 250.0
		)
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    id = nil
    cardView.categoryLabel.text = ""
    cardView.imageView.image = nil
    cardView.titleLabel.text = ""
    cardView.locationLabel.text = ""
  }
  
  private func frameDidSet(to frame: CGRect, from oldFrame: CGRect) {
    guard frame.width != oldFrame.width || frame.height != oldFrame.height else {
      return
    }
    shadowView.layer.shadowPath = UIBezierPath(
      roundedRect: CGRect(
        x: bounds.minX,
        y: bounds.minY,
        width: bounds.width,
        height: bounds.height - 30
      ),
      cornerRadius: 15
    ).cgPath
  }
  
  private func setupView() {
    clipsToBounds = false
    selectionStyle = .none
    shadowView.layer.shadowRadius = 7
    shadowView.layer.shadowOpacity = 0.3
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.shadowOffset = .zero
    shadowView.clipsToBounds = false
    shadowView.backgroundColor = .clear
    
    roundedView.layer.cornerRadius = 15
    roundedView.clipsToBounds = true
    roundedView.backgroundColor = .background
    
    roundedView.sv(cardView)
    shadowView.sv(roundedView)
    sv(shadowView)
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    cardView.imageView.height(Constants.eventImageSize.height)
    shadowView.left(0).right(0).top(0).bottom(30)
    roundedView.fillContainer()
    cardView.fillContainer()
  }
}
