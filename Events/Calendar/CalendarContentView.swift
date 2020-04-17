//
//  CalendarContentView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 19/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Hero

let calendarSharedElementId = "CALENDAR_SHARED_ID"

class CalendarContentView: UIView {
  let backgroundView = UIView()
  let contentView = UIView()
  let monthsCollectionView: UICollectionView
  let headerView = CalendarHeaderView()
  let footerView = CalendarFooterView()
  
  private struct Constants {
    static let contentPaddingHorizontal: CGFloat = 10.0
    static let collectionViewPaddingHorizontal: CGFloat = 25.0
  }

  init() {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    monthsCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    isOpaque = false
    backgroundColor = .clear
    backgroundView.backgroundColor = UIColor.backgroundInverted.withAlphaComponent(0.6)

    contentView.hero.id = calendarSharedElementId
    monthsCollectionView.showsVerticalScrollIndicator = false
    monthsCollectionView.register(
      CalendarDayCell.self,
      forCellWithReuseIdentifier: CalendarDayCell.reuseIdentifier
    )
    monthsCollectionView.register(
      CalendarSectionTitleView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CalendarSectionTitleView.reusableIdentifier
    )
    monthsCollectionView.backgroundColor = .background
    monthsCollectionView.contentInset = UIEdgeInsets(
      top: 0,
      left: Constants.collectionViewPaddingHorizontal,
      bottom: 0,
      right: Constants.collectionViewPaddingHorizontal
    )
    contentView.style { v in
      v.backgroundColor = .background
      v.layer.cornerRadius = 10
    }

    sv(backgroundView, contentView.sv(headerView, monthsCollectionView, footerView))
    backgroundView.fillContainer()

    contentView
      .top(safeAreaInsets.top + 130)
      .left(Constants.contentPaddingHorizontal)
      .right(Constants.contentPaddingHorizontal)
      .height(50%)
      .layout(
        0,
        |-0-headerView-0-|,
        10,
        |-0-monthsCollectionView-0-|,
        |-footerView-|,
        0
      )
  }
}
