//
//  ObservableType+Nwise.swift
//  Events
//
//  Created by Dmitry on 25.02.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import RxSwift

extension ObservableType {
	public func nwise(_ n: Int) -> Observable<[Element]> {
		self
			.scan([]) { acc, item in Array((acc + [item]).suffix(n)) }
			.filter { $0.count == n }
	}

	public func pairwise() -> Observable<(Element, Element)> {
		nwise(2).map { ($0[0], $0[1]) }
	}
}
