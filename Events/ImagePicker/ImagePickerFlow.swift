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
import Photos

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
    case .imagesPreview(let assets, let sharedImage, let selectedImageIndices, let onImageDidSelected):
      return navigateToImagesPreview(
        assets: assets,
				sharedImage: sharedImage,
        selectedImageIndices: selectedImageIndices,
        onImageDidSelected: onImageDidSelected
      )
    case .imagesPreviewDidComplete:
      rootNavigationController.dismiss(animated: true, completion: nil)
      return .none
    default:
      return .none
    }
  }

  func navigateToImagePicker(onComplete: @escaping ([PHAsset]) -> Void) -> FlowContributors {
     let viewModel = ImagePickerViewModel(onResult: onComplete)
     let viewController = ImagePickerVC(viewModel: viewModel)
     viewController.modalTransitionStyle = .coverVertical
     viewController.modalPresentationStyle = .overCurrentContext
     rootNavigationController.pushViewController(viewController, animated: true)
     return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
   }

  func navigateToImagesPreview(
    assets: PHFetchResult<PHAsset>,
    sharedImage: SharedImage,
    selectedImageIndices: [Int],
    onImageDidSelected: @escaping (Int) -> Void
  ) -> FlowContributors {
    let viewModel = ImagesPreviewViewModel(assets: assets)
    let viewController = ImagesPreviewVC(
      viewModel: viewModel,
			sharedImage: sharedImage,
      selectedImageIndices: selectedImageIndices,
      onImageDidSelected: onImageDidSelected
    )
    viewController.hero.isEnabled = true
    viewController.modalPresentationStyle = .overCurrentContext
    rootNavigationController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
}
