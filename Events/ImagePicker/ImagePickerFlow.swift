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
	
	deinit {
		rootNavigationController.setNavigationBarHidden(false, animated: true)
	}

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? EventStep else {
      return .none
    }
    switch step {
    case .imagePicker(let selectedAssets, let onComplete):
      return navigateToImagePicker(
        selectedAssets: selectedAssets,
        onComplete: onComplete
      )
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
    case .permissionModal(let type):
      return navigateToPermissionModal(withType: type)
    case .defaultImagePicker(let source, let delegate):
      return navigateToDefaultImagePicker(source: source, delegate: delegate)
    case .imagesPreviewDidComplete,
         .defaultImagePickerDidComplete,
         .permissionModalDidComplete:
      rootNavigationController.dismiss(animated: true, completion: nil)
      return .none
    default:
      return .none
    }
  }

  func navigateToPermissionModal(withType type: PermissionModalType) -> FlowContributors {
    let flow = PermissionModalFlow()
    Flows.whenReady(flow1: flow, block: {
      self.rootNavigationController.present($0, animated: true)
    })
    return .one(flowContributor: .contribute(
      withNextPresentable: flow,
      withNextStepper: OneStepper(withSingleStep: EventStep.permissionModal(withType: type))
      ))
  }

  func navigateToImagePicker(
    selectedAssets: [PHAsset],
    onComplete: @escaping ([PHAsset]) -> Void
  ) -> FlowContributors {
    let viewModel = ImagePickerViewModel(selectedAssets: selectedAssets, onResult: onComplete)
    let viewController = ImagePickerVC.instantiate(with: viewModel)
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
		viewController.modalPresentationStyle = .overFullScreen
    rootNavigationController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
  
  func navigateToDefaultImagePicker(
    source: UIImagePickerController.SourceType,
    delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate
  ) -> FlowContributors {
    if !UIImagePickerController.isSourceTypeAvailable(source) {
      return .none
    }
    let controller = UIImagePickerController()
    controller.delegate = delegate
    controller.sourceType = source
    rootNavigationController.present(controller, animated: true, completion: nil)
    return .none
  }
}
