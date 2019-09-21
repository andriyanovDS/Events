//
//  PermissionModalScreenViewModel.swift
//  Events
//
//  Created by Сослан Кулумбеков on 28/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//
import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxFlow

class PermissionModalViewModel: Stepper {
  let steps = PublishRelay<Step>()

  let url = URL(string: UIApplication.openSettingsURLString)
  
  func openAppSettings() {
    UIApplication.shared.open(url!, completionHandler: { (success) in
      print("Settings opened: \(success)")
    })
  }

  func onClose() {
    steps.accept(EventStep.permissionModalDidComplete)
  }
}
