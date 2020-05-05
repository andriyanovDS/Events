//
//  RootScreenView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 26/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class RootScreenView: UIView {
  let eventTableView = UITableView()
  let defaultDatesButtonLabel = NSLocalizedString(
     "Dates",
     comment: "Select calendar dates label"
   )

  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    backgroundColor = .background
    eventTableView.separatorStyle = .none
    eventTableView.clipsToBounds = false
    eventTableView.showsVerticalScrollIndicator = false
    eventTableView.isDirectionalLockEnabled = true
    
    eventTableView.contentInset = UIEdgeInsets(
      top: 30,
      left: 0,
      bottom: 0,
      right: 0
    )
    
    sv(eventTableView)
    eventTableView.top(0).right(15).left(15).bottom(0)
    setupHeaderView()
  }
  
  private func setupHeaderView() {
    let headerView = UIView()
    let titleLabel = UILabel()
    styleText(
      label: titleLabel,
      text: NSLocalizedString("Choose your next experience", comment: "Home screen title"),
      size: 24,
      color: .fontLabel,
      style: .bold
    )
    titleLabel.numberOfLines = 0
    headerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.sv(titleLabel)
    eventTableView.tableHeaderView = headerView
    
    headerView.left(0).right(0).height(100).Width == eventTableView.Width
    titleLabel.left(10).right(0).top(30)
  }
}
