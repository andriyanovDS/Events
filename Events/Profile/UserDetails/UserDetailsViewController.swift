//
//  UserDetailsViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 16/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Photos
import RxSwift
import FirebaseAuth
import Promises

class UserDetailsViewController: UIViewControllerWithActivityIndicator, ViewModelBased {
  var userDetailsView: UserDetailsView?
  var selectedAvatarPromise: Promise<String>?
	var viewModel: UserDetailsViewModel!
  private let disposeBag = DisposeBag()
	private lazy var auth = Auth.auth()
	
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()

    keyboardAttach$
      .subscribe(onNext: {[weak self] info in
        self?.onKeyboardHeightDidChange(info: info)
      })
      .disposed(by: disposeBag)
  }
	
	func setupView() {
		let view = UserDetailsView(user: viewModel.user)
		self.view = view
		userDetailsView = view
		
		view.genderPicker.dataSource = self
		view.genderPicker.delegate = self
		
		let tapGestureGecognizer = UITapGestureRecognizer(
			target: self,
			action: #selector(openActionSheet)
		)
		view.avatarImageView.isUserInteractionEnabled = true
		view.avatarImageView.addGestureRecognizer(tapGestureGecognizer)
		 
		view.closeButton.rx.tap
			.subscribe(onNext: {[weak self] _ in self?.viewModel.closeScreen()  })
			.disposed(by: disposeBag)
		view.submitButton.rx.tap
			.subscribe(onNext: {[weak self] _ in self?.submitProfile() })
			.disposed(by: disposeBag)
		
		view.firstNameTextField.rx.text.orEmpty
			.subscribe(onNext: {[weak self] text in
				self?.viewModel.user.firstName = text
			})
			.disposed(by: disposeBag)
		
		view.lastNameTextField.rx.text.orEmpty
			.subscribe(onNext: {[weak self] text in
				self?.viewModel.user.lastName = text
			})
			.disposed(by: disposeBag)
		
		view.workTextField.rx.text.orEmpty
			.subscribe(onNext: {[weak self] text in
				self?.viewModel.user.work = text
			})
			.disposed(by: disposeBag)
		
		view.descriptionTextView.rx.text.orEmpty
			.subscribe(onNext: {[weak self] text in
				self?.viewModel.user.description = text
			})
			.disposed(by: disposeBag)
	 }
	
	private func openCamera() {
		 if !UIImagePickerController.isSourceTypeAvailable(.camera) {
			 return
		 }
		 let controller = UIImagePickerController()
		 controller.delegate = self
		 controller.sourceType = .camera
		 present(controller, animated: true, completion: nil)
	 }
	 
	private func openLibrary() {
		 if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			 return
		 }
		 let controller = UIImagePickerController()
		 controller.delegate = self
		 controller.sourceType = .photoLibrary
		 present(controller, animated: true, completion: nil)
	 }
	
	@objc private func openActionSheet() {
		let actionSheetController = UIAlertController(
			title: nil,
			message: nil,
			preferredStyle: .actionSheet
		)
		let actions = [
			UIAlertAction(
				title: NSLocalizedString("Camera", comment: "Select image from: Camera"),
				style: .default,
				handler: {[weak self] _ in
					guard let self = self else { return }
					requestCameraUsagePermission(
						onOpenCamera: self.openCamera,
						openCameraAccessModal: {[weak self] in
							self?.viewModel.openPermissionModal(withType: .camera)
						}
					)
				}
			),
			UIAlertAction(
				title: NSLocalizedString("Gallery", comment: "Select image from: Gallery"),
				style: .default,
				handler: {[weak self] _ in
					guard let self = self else { return }
					requestCameraUsagePermission(
						onOpenCamera: self.openLibrary,
						openCameraAccessModal: {[weak self] in
							self?.viewModel.openPermissionModal(withType: .library)
						}
					)
				}
			),
			UIAlertAction(
				title: NSLocalizedString("Close", comment: "Close select image modal"),
				style: .cancel,
				handler: nil
			)
		]
		actions.forEach { actionSheetController.addAction($0) }
    present(actionSheetController, animated: true, completion: nil)
	}
  
	func submitProfile() {
    guard let view = userDetailsView else { return }

		viewModel.user.dateOfBirth = Calendar.current.isDateInToday(view.datePicker.date)
			? nil
			: view.datePicker.date
		
		guard let promise = selectedAvatarPromise else {
			viewModel.updateUserProfile()
			return
		}
		promise
			.then {[weak self] imageUrl in
				self?.viewModel.user.avatar = imageUrl
				self?.viewModel.updateUserProfile()
			}
			.catch {[weak self] error in
				print(error.localizedDescription)
				self?.viewModel.updateUserProfile()
			}
  }
}

extension UserDetailsViewController {
  private func scrollToActiveTextField(keyboardHeight: CGFloat) {
    guard let view = userDetailsView else {
      return
    }
    let activeField = [
      view.firstNameTextField,
      view.lastNameTextField,
      view.dateTextField,
      view.genderTextField,
      view.descriptionTextView,
      view.workTextField
			].first(where: \.isFirstResponder)
    
    if let activeField = activeField {
      var viewFrame = view.frame
      viewFrame.size.height -= keyboardHeight
      
      if viewFrame.contains(activeField.frame.origin) {
        let scrollPointY = activeField.frame.origin.y - keyboardHeight
        let scrollPoint = CGPoint(x: 0, y: scrollPointY >= 0 ? scrollPointY : 0)
        userDetailsView?.scrollView.setContentOffset(scrollPoint, animated: true)
      }
    }
  }
  
  private func onKeyboardHeightDidChange(info: KeyboardAttachInfo?) {
    let inset = info.foldL(
      none: { UIEdgeInsets.zero },
      some: { info in UIEdgeInsets(
        top: 0,
        left: 0,
        bottom: info.height,
        right: 0
        )}
    )
    userDetailsView?.scrollView.contentInset = inset
    userDetailsView?.scrollView.scrollIndicatorInsets = inset
    
    if inset.bottom > 0 {
      scrollToActiveTextField(keyboardHeight: inset.bottom)
    }
  }
}

extension UserDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
    picker.dismiss(animated: true, completion: nil)
		guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      return
    }
		userDetailsView?.setUserImage(image)
    guard let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL else {
      return
		}
		selectedAvatarPromise = viewModel.uploadAvatar(
			url: imageUrl,
			userId: auth.currentUser!.uid
		)
  }
}

extension UserDetailsViewController: UIPickerViewDataSource {
  
  private func pickerRowValueToGender(_ row: Int) -> Gender? {
    switch row {
    case 0: return .male
    case 1: return .female
    case 2: return .other
    default: return nil
    }
  }
  
  private func pickerRowValueToGenderLabel(_ row: Int) -> String? {
    switch row {
    case 0: return NSLocalizedString("Male", comment: "Select gender: Male")
    case 1: return NSLocalizedString("Female", comment: "Select gender: Female")
    case 2: return NSLocalizedString("Other", comment: "Select gender: Other")
    default: return nil
    }
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 3
  }
}

extension UserDetailsViewController: UIPickerViewDelegate {
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		userDetailsView?.genderTextField.text = pickerRowValueToGenderLabel(row)
		viewModel.user.gender = pickerRowValueToGender(row)
		view.endEditing(true)
	}
		
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerRowValueToGenderLabel(row)
	}
}
