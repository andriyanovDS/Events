//
//  APIRequest.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

protocol APIRequest: Encodable {
    associatedtype Response: Decodable
}
