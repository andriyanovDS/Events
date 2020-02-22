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

class UserDetailsViewController: UIViewControllerWithActivityIndicator, UserDetailsViewModelDelegate, UserDetailsView.Delegate {
  var userDetailsView: UserDetailsView!
  let user: User
  var selectedGender: Gender?
  var selectedAvatarUrl: URL?
  private let viewModel: UserDetailsViewModel
  private let disposeBag = DisposeBag()
  
  func loadCustomView() {
    userDetailsView = UserDetailsView()
    userDetailsView.delegate = self
    view = userDetailsView
    
    userDetailsView.closeButton.addTarget(self, action: #selector(closeScreen), for: .touchUpInside)
    userDetailsView.avatarButton.addTarget(self, action: #selector(showSelectImageActionSheet), for: .touchUpInside)
    userDetailsView.submitButton.addTarget(self, action: #selector(submitProfile), for: .touchUpInside)
  }
  
  init(user: User, viewModel: UserDetailsViewModel) {
    self.user = user
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    viewModel.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadCustomView()
    setUserData()

    keyboardAttach$
      .subscribe(onNext: {[weak self] info in
        self?.onKeyboardHeightDidChange(info: info)
      })
      .disposed(by: disposeBag)
  }
  
  @objc func showSelectImageActionSheet() {
    viewModel.showSelectImageActionSheet()
  }
  
  @objc func closeScreen() {
    viewModel.closeScreen()
  }
  
  @objc func selectDate() {
    userDetailsView.dateTextField.text = formatDate(userDetailsView.datePicker.date)
    self.view.endEditing(true)
  }
  
  @objc func endEditing() {
    self.view.endEditing(true)
  }
  
  private func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd LLLL YYYY"
    dateFormatter.locale = Locale(identifier: "ru_RU")
    return dateFormatter.string(from: date)
  }
  
  private func loadImage(url: String, onLoad: @escaping (Data?) -> Void) {
    let url = URL(string: url, relativeTo: nil)
    guard let imageUrl = url else {
      onLoad(nil)
      return
    }
    DispatchQueue.global(qos: .background).async {
      let data = try? Data(contentsOf: imageUrl)
      guard let imageData = data else {
        return
      }
      DispatchQueue.main.async {
        onLoad(imageData)
      }
    }
  }
  
  private func setUserData() {
    userDetailsView.firstNameSection.setChildText(user.firstName)
    user.lastName.foldL(none: {}, some: { name in
      userDetailsView.lastNameSection.setChildText(name)
    })
    user.dateOfBirth.foldL(none: {}, some: { date in
      userDetailsView.datePicker.date = date
    })
    user.dateOfBirth.foldL(none: {}, some: { date in
      userDetailsView.dateTextField.text = formatDate(date)
    })
    user.gender.foldL(none: {}, some: { gender in
      selectedGender = gender
      userDetailsView.genderTextField.text = gender.translateValue()
    })
    user.avatar.foldL(none: {}, some: { externalUrl in
      selectedAvatarUrl = URL(string: externalUrl)
      loadImage(url: externalUrl, onLoad: {[weak self] imageData in
        imageData
          .chain { UIImage(data: $0) }
          .foldL(
            none: {},
            some: {
              self?.userDetailsView.setUserImage($0)
            }
          )
      })
    })
    user.description.foldL(none: {}, some: { description in
      userDetailsView.descriptionSection.setChildText(description)
    })
    user.work.foldL(none: {}, some: { work in
      userDetailsView.workSection.setChildText(work)
    })
  }
  
  @objc func submitProfile() {
    guard let view = userDetailsView else {
      return
    }
    let date = Calendar.current.isDateInToday(view.datePicker.date)
      ? nil
      : view.datePicker.date
    
    let userInfo: [String: Any?] = [
      "firstName": view.firstNameSection.getChildText(),
      "lastName": view.lastNameSection.getChildText(),
      "description": view.descriptionSection.getChildText(),
      "gender": selectedGender,
      "dateOfBirth": date,
      "work": view.workSection.getChildText(),
      "avatar": selectedAvatarUrl
    ]
    self.viewModel.submitProfile(userInfo: userInfo)
  }
  
  private func scrollToActiveTextField(keyboardHeight: CGFloat) {
    guard let view = userDetailsView else {
      return
    }
    let activeField = [
      view.firstNameSection,
      view.lastNameSection,
      view.dateSection,
      view.genderSection,
      view.descriptionSection,
      view.workSection
      ].first { $0.isChildFirstResponder() }
    
    if let activeField = activeField {
      var viewFrame = view.frame
      viewFrame.size.height -= keyboardHeight
      
      if viewFrame.contains(activeField.frame.origin) {
        let scrollPointY = activeField.frame.origin.y - keyboardHeight
        let scrollPoint = CGPoint(x: 0, y: scrollPointY >= 0 ? scrollPointY : 0)
        userDetailsView.scrollView.setContentOffset(scrollPoint, animated: true)
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
    userDetailsView.scrollView.contentInset = inset
    userDetailsView.scrollView.scrollIndicatorInsets = inset
    
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
    userDetailsView.setUserImage(image)
    guard let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL else {
      return
    }
    selectedAvatarUrl = imageUrl
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
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    userDetailsView.genderTextField.text = pickerRowValueToGenderLabel(row)
    selectedGender = pickerRowValueToGender(row)
    view.endEditing(true)
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerRowValueToGenderLabel(row)
  }
}

extension UserDetailsViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.x = 0
  }
}
