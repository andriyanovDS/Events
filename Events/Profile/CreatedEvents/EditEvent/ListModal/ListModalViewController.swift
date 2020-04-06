//
//  ListModalViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift

class ListModalViewController: BottomModalViewController<ListModalView>, ViewModelBased {
  var viewModel: ListModalViewModel!
  var modalTitle: String!
  private let disposeBag = DisposeBag()
  private var isPanGestureActive: Bool = false

  private struct Constants {
    static let contentAnimationDuration: TimeInterval = 0.4
    static let animationTranslationYBound: CGFloat = 75.0
  }

  override func setupView() {
		super.setupView()
	
    modalView.listView.register(
      ListModalTableViewCell.self,
      forCellReuseIdentifier: ListModalTableViewCell.reuseIdentifier
    )
    modalView.listView.dataSource = self
    modalView.listView.delegate = self
    modalView.listView.height(min(
      UIScreen.main.bounds.height * 0.6,
      CGFloat(viewModel.buttonLabelTexts.count * 42)
    ))

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeWithoutChanges))
    modalView.backgroundView.addGestureRecognizer(tapRecognizer)

    let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleContentViewPanGesture))
    panRecognizer.maximumNumberOfTouches = 1
    modalView.contentView.addGestureRecognizer(panRecognizer)

    modalView.listView.panGestureRecognizer.addTarget(self, action: #selector(handleTableViewPanGesture))

    modalView.closeButton.rx.tap
      .subscribe(onNext: {[unowned self] in self.closeWithoutChanges() })
      .disposed(by: disposeBag)

    modalView.submitButton.rx.tap
      .subscribe(onNext: {[unowned self] in self.closeWithoutChanges() })
      .disposed(by: disposeBag)
  }

  private func panGestureEnded(translationY: CGFloat) {
    isPanGestureActive = false
    let translationRatio = Double(translationY / modalView.contentView.bounds.height)

    if translationY >= Constants.animationTranslationYBound {
      let animationDuration = (1 - translationRatio) * Constants.contentAnimationDuration
      viewModel.willCloseWithoutChanges()
      UIView.animate(
        withDuration: animationDuration,
        animations: {
					self.modalView.contentView.transform = CGAffineTransform(
            translationX: 0,
            y: UIScreen.main.bounds.height
          )
        }, completion: {[weak self] _ in
          self?.viewModel.onClose()
        }
      )
      return
    }
    let animationDuration = translationRatio * Constants.contentAnimationDuration
    UIView.animate(withDuration: animationDuration, animations: {
			self.modalView.contentView.transform = .identity
    })
  }

  private func closeWithAnimation() {
    animateDisappearance {[weak self] in
      self?.viewModel.onClose()
    }
  }

  @objc private func closeWithoutChanges() {
    viewModel.willCloseWithoutChanges()
    closeWithAnimation()
  }

  @objc private func handleContentViewPanGesture(_ recognizer: UIPanGestureRecognizer) {
    let translationY = recognizer.translation(in: view).y
    switch recognizer.state {
    case .changed:
      if translationY < 0 {
        if isPanGestureActive {
          panGestureEnded(translationY: translationY)
        }
        return
      }
      isPanGestureActive = true
      modalView.contentView.transform = CGAffineTransform(
        translationX: 0,
        y: translationY
      )
      return
    case .ended:
      if !isPanGestureActive { return }
      panGestureEnded(translationY: translationY)
      return
    default:
      return
    }
  }

  @objc private func handleTableViewPanGesture(_ recognizer: UIPanGestureRecognizer) {
		guard modalView.listView.contentOffset.y <= 0 else { return }
    handleContentViewPanGesture(recognizer)
  }
}

extension ListModalViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.buttonLabelTexts.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellOption = tableView.dequeueReusableCell(withIdentifier: ListModalTableViewCell.reuseIdentifier)
    guard let cell = cellOption as? ListModalTableViewCell else {
      fatalError("Unexpected cell")
    }
    cell.label.text = viewModel.buttonLabel(at: indexPath.item)
    return cell
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.bounces = scrollView.contentOffset.y > 20
  }
}

extension ListModalViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.onSelectButton(at: indexPath.item)
    closeWithAnimation()
  }
}
