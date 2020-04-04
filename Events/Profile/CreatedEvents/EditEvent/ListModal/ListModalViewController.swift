//
//  ListModalViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift

class ListModalViewController: UIViewController, ViewModelBased {
  var viewModel: ListModalViewModel!
  var modalTitle: String!
  var listModalView: ListModalView?
  private let disposeBag = DisposeBag()
  private var isPanGestureActive: Bool = false

  private struct Constants {
    static let contentAnimationDuration: TimeInterval = 0.4
    static let animationTranslationYBound: CGFloat = 75.0
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  private func setupView() {
    let view = ListModalView(titleText: modalTitle)
    let screenHeight = UIScreen.main.bounds.height
    view.contentView.transform = CGAffineTransform(
      translationX: 0,
      y: screenHeight
    )
    view.listView.register(
      ListModalTableViewCell.self,
      forCellReuseIdentifier: ListModalTableViewCell.reuseIdentifier
    )
    view.listView.dataSource = self
    view.listView.delegate = self
    view.listView.height(min(
      screenHeight * 0.6,
      CGFloat(viewModel.buttonLabelTexts.count * 42)
    ))

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeWithoutChanges))
    view.backgroundView.addGestureRecognizer(tapRecognizer)

    let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleContentViewPanGesture))
    panRecognizer.maximumNumberOfTouches = 1
    view.contentView.addGestureRecognizer(panRecognizer)

    view.listView.panGestureRecognizer.addTarget(self, action: #selector(handleTableViewPanGesture))

    view.closeButton.rx.tap
      .subscribe(onNext: {[unowned self] in self.closeWithoutChanges() })
      .disposed(by: disposeBag)

    view.submitButton.rx.tap
      .subscribe(onNext: {[unowned self] in self.closeWithoutChanges() })
      .disposed(by: disposeBag)

    self.view = view
    listModalView = view
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animateAppearance()
  }

  private func animateAppearance() {
    guard let modalView = listModalView else { return }
    UIView.animate(
      withDuration: Constants.contentAnimationDuration,
      delay: 0,
      usingSpringWithDamping: 0.9,
      initialSpringVelocity: 1,
      options: .curveEaseInOut,
      animations: {
        modalView.contentView.transform = .identity
      },
      completion: nil
    )
  }

  private func animateDisappearance(completion: @escaping () -> Void) {
    guard let modalView = listModalView else { return }
    UIView.animate(
      withDuration: Constants.contentAnimationDuration,
      animations: {
        modalView.contentView.transform = CGAffineTransform(
          translationX: 0,
          y: UIScreen.main.bounds.height
        )
      },
      completion: { _ in completion() }
    )
  }

  private func panGestureEnded(translationY: CGFloat) {
    guard let view = listModalView else { return }
    isPanGestureActive = false
    let translationRatio = Double(translationY / view.contentView.bounds.height)

    if translationY >= Constants.animationTranslationYBound {
      let animationDuration = (1 - translationRatio) * Constants.contentAnimationDuration
      viewModel.willCloseWithoutChanges()
      UIView.animate(
        withDuration: animationDuration,
        animations: {
          view.contentView.transform = CGAffineTransform(
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
      view.contentView.transform = .identity
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
    guard let view = listModalView else { return }
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
      view.contentView.transform = CGAffineTransform(
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
    guard let tableView = listModalView?.listView else { return }
    guard tableView.contentOffset.y <= 0 else { return }
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
