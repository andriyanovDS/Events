//
//  ImagePickerActionsView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 26/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Hero

class ImagePickerActionsView: UIView {
  typealias ActionHandler = (ImagePickerAction) -> Void

  private let actionHandler: ActionHandler
  private let actionsStackView = UIStackView()
  private var actions: [ImagePickerAction] = []

  init(actionHandler: @escaping ActionHandler) {
    self.actionHandler = actionHandler
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func changeFirstAction(to nextAction: ImagePickerAction) {
    guard let button = actionsStackView.arrangedSubviews.first as? UIButton else {
      return
    }
    actions[0] = nextAction
    button.setTitle(nextAction.localizedTitle, for: .normal)
  }

  func setupActions(actions: [ImagePickerAction]) {
    self.actions = actions
    for index in 0..<actions.endIndex {
      let button = UIButton()
      styleText(
        button: button,
        text: actions[index].localizedTitle,
        size: 20,
        color: .blueButtonBackground,
        style: .medium
      )
      button.tag = index
      button.backgroundColor = .background
      button.height(ImagePickerView.Constants.actionButtonHeight)
      button.addTarget(self, action: #selector(onActionDidSelected), for: .touchUpInside)
      actionsStackView.addArrangedSubview(button)
    }
  }

  @objc private func onActionDidSelected(_ button: UIButton) {
    actionHandler(actions[button.tag])
  }

  private func setupView() {
    actionsStackView.style { v in
      v.axis = .vertical
      v.alignment = .fill
      v.distribution = .fillProportionally
    }
    sv(actionsStackView)
    actionsStackView.fillContainer()
  }
}

extension ImagePickerActionsView {
  enum ImagePickerAction {
    case openCamera
    case openLibrary
    case selectImages(count: Int)

    static func makeActionByImageSource(_ source: ImageSource) -> Self {
      switch source {
      case .camera:
        return .openCamera
      case .library:
        return .openLibrary
      }
    }

    var localizedTitle: String {
      switch self {
      case .openCamera: return NSLocalizedString(
        "Camera",
        comment: "Image picker: open camera"
      )
      case .openLibrary: return NSLocalizedString(
        "Gallery",
        comment: "Image picker: open gallery"
      )
      case .selectImages(let count):
        let formatString = NSLocalizedString("image count", comment: "Image picker: select image")
        return NSLocalizedString("Select", comment: "Select images")
          + " "
          + String.localizedStringWithFormat(formatString, count)
      }
    }
  }
}
