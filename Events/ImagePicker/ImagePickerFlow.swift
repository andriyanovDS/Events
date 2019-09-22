//
//  ImagePickerFlow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow
import UIKit

class ImagePickerFlow: Flow {
  var root: Presentable {
    return rootNavigationController
  }

  private lazy var rootNavigationController: UINavigationController = {
    let controller = UINavigationController()
    controller.setNavigationBarHidden(true, animated: true)
    return controller
  }()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? EventStep else {
      return .none
    }
    switch step {
    case .imagePicker(let onComplete):
      return navigateToImagePicker(onComplete: onComplete)
    case .imagePickerDidComplete:
      rootNavigationController.popViewController(animated: false)
      return .end(forwardToParentFlowWithStep: EventStep.imagePickerDidComplete)
    case .imagesPreview(let images, let startAt, let onResult):
      return navigateToImagesPreview(images: images, startAt: startAt, onResult: onResult)
    case .imagesPreviewDidComplete:
      rootNavigationController.dismiss(animated: true, completion: nil)
      return .none
    default:
      return .none
    }
  }

  func navigateToImagePicker(onComplete: @escaping ([UIImage]) -> Void) -> FlowContributors {
     let viewModel = ImagePickerViewModel(onResult: onComplete)
     let viewController = ImagePickerVC(viewModel: viewModel)
     viewController.modalTransitionStyle = .coverVertical
     viewController.modalPresentationStyle = .overCurrentContext
     rootNavigationController.pushViewController(viewController, animated: true)
     return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
   }

  func navigateToImagesPreview(
    images: [UIImage],
    startAt: Int,
    onResult: @escaping ([UIImage]) -> Void
  ) -> FlowContributors {
    let viewModel = ImagesPreviewViewModel()
    let viewController = ImagesPreviewVC(
      viewModel: viewModel,
      images: images,
      startAt: startAt,
      onResult: onResult
    )
    viewController.hero.isEnabled = true
    viewController.modalPresentationStyle = .overCurrentContext
    rootNavigationController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
}
