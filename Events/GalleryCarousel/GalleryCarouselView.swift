//
//  GalleryCarouselView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Hero

class GalleryCarouselView: UIView {
  let closeButton = UIButtonScaleOnPress()
  let backButton = UIButtonScaleOnPress()
	let selectButton: SelectImageButton
  let collectionView: UICollectionView
  private let actionsStackView = UIStackView()

  init() {
    let layout = ImagePickerCollectionViewLayout(
      cellSize: UIScreen.main.bounds.size
    )
    layout.scrollDirection = .horizontal
    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    selectButton = SelectImageButton(size: Constants.selectionButtonSize)
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupActions<T: GalleryCarouselViewAction>(actions: [T], actionHandler: @escaping (T) -> Void) {
    for action in actions {
      let button = GenericButton(value: action)
      button.setTitle(String.fontMaterialIcon(action.icon), for: .normal)
      button.titleLabel?.font = UIFont.icon(from: .materialIcon, ofSize: 35)
      button.setTitleColor(.fontLabelInverted, for: .normal)
      button.size(44)
      button.onTouch = actionHandler
      actionsStackView.addArrangedSubview(button)
    }
  }
  
  func changeAccessoryViewsVisibility(isHidden: Bool) {
    let alpha: CGFloat = isHidden ? 0 : 1
    UIView.animate(withDuration: 0.2, animations: {
      self.actionsStackView.alpha = alpha
      self.selectButton.alpha = alpha
    })
  }

  private func setupView() {
    isOpaque = false
    backgroundColor = .backgroundInverted
    collectionView.showsVerticalScrollIndicator = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.backgroundColor = .clear
    sv(collectionView, selectButton)
    collectionView.fillContainer().centerInContainer()
    selectButton.right(20)
    
    addShadow(view: selectButton, radius: 3)
    selectButton.Top == safeAreaLayoutGuide.Top + 20
    setupFooter()
  }

  private func setupFooter() {
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor.backgroundInverted.withAlphaComponent(0.7)
    actionsStackView.axis = .horizontal
    actionsStackView.alignment = .center
    actionsStackView.distribution = .equalSpacing
    actionsStackView.spacing = 10
    
    let icon = Icon(material: "chevron.left", sfSymbol: "arrow.left.circle")
    backButton.setIcon(icon, size: 35, color: .fontLabelInverted)
    backButton.size(44)
    actionsStackView.addArrangedSubview(backButton)
    
    backgroundView.sv(actionsStackView)
    sv(backgroundView)
    
    backgroundView.left(0).right(0).bottom(0)
    let safeAreaInsetBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
    actionsStackView.left(20).bottom(safeAreaInsetBottom + 10).top(10)
  }
}

extension GalleryCarouselView {
  struct Constants {
    static let selectionButtonSize = CGSize(width: 35, height: 35)
  }
}

protocol GalleryCarouselViewAction {
  var icon: String { get }
}
