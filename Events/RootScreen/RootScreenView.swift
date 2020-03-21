//
//  RootScreenView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 26/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import AsyncDisplayKit
import Stevia

class RootScreenNode: ASDisplayNode {
  let eventTableNode: ASTableNode
  let defaultDatesButtonLabel = NSLocalizedString(
     "Dates",
     comment: "Select calendar dates label"
   )

  override init() {
    eventTableNode = ASTableNode(style: .plain)
    super.init()
    addSubnode(eventTableNode)
  }

  override func didLoad() {
    super.didLoad()
    eventTableNode.view.separatorStyle = .none
    eventTableNode.clipsToBounds = false

    let headerView = UIView()
    let titleLabel = UILabel()
    styleText(
      label: titleLabel,
      text: NSLocalizedString("Choose your next experience", comment: "Home screen title"),
      size: 24,
      color: .black,
      style: .bold
    )
    titleLabel.numberOfLines = 0
    headerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.sv(titleLabel)
    eventTableNode.view.tableHeaderView = headerView
    eventTableNode.view.showsVerticalScrollIndicator = false
    headerView.left(0).right(0).height(100).Width == eventTableNode.view.Width
    titleLabel.left(10).right(0).top(30)
  }

  override func layout() {
    super.layout()
    backgroundColor = .white
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let padding = EventCellNode.Constants.cellPaddingHorizontal
    let insetLayoutSpec = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: 30, left: padding, bottom: 0, right: padding),
      child: eventTableNode
    )
    return ASWrapperLayoutSpec(layoutElement: insetLayoutSpec)
  }
}
