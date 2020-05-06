//
//  UndoActionCounterView.swift
//  Events
//
//  Created by Dmitry on 31.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class UndoActionCounterView: UIView {
	private let counterLabel = UILabel()
	private let circleView = CounterCircleView()
	private var secondsLeft: Int =
		CreatedEventsViewController.Constants.undoActionTimeoutInSeconds
	private var timer: Timer?
	
	init() {
		super.init(frame: CGRect.zero)
		setupView()
	}
	
	deinit {
		guard let timer = timer else { return }
		timer.invalidate()
		self.timer = nil
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		if window == nil {
			invalidateTimer()
		} else {
			startTimer()
		}
	}
  
  func restartTimer() {
    invalidateTimer()
    startTimer()
  }
	
	private func startTimer() {
		timer = Timer.scheduledTimer(
			timeInterval: 1,
			target: self,
			selector: #selector(decrementSecondsLeft),
			userInfo: nil,
			repeats: true
		)
		circleView.startAnimation()
	}
	
	private func invalidateTimer() {
		if let timer = timer {
			timer.invalidate()
			self.timer = nil
		}
		secondsLeft = CreatedEventsViewController.Constants.undoActionTimeoutInSeconds
		counterLabel.text = String(secondsLeft)
		circleView.stopAnimation()
	}
	
	private func setupView() {
		clipsToBounds = true
		styleText(
			label: counterLabel,
			text: String(secondsLeft),
			size: 14,
			color: .fontLabelInverted,
			style: .medium
		)
		circleView.transform = CGAffineTransform(rotationAngle: -(.pi / 2))
		sv([circleView, counterLabel])
		counterLabel.centerInContainer()
		circleView.fillContainer()
	}

	@objc private func decrementSecondsLeft() {
		if secondsLeft == 0, let timer = timer {
			timer.invalidate()
			self.timer = timer
			return
		}
		counterLabel.transform = CGAffineTransform(translationX: 0, y: -30)
		secondsLeft -= 1
		counterLabel.text = String(secondsLeft)
		UIView.animate(
			withDuration: 0.1,
			delay: 0,
			options: .curveEaseOut,
			animations: {[weak self] in
				self?.counterLabel.transform = .identity
			},
			completion: nil
		)
	}
}
