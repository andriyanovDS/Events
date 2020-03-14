//
//  Location.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

enum AddressComponentType: String, Decodable {
  case streetAddress = "street_address"
  case route
  case intersection
  case political
  case country
  case administrativeAreaLevel1 = "administrative_area_level_1"
  case administrativeAreaLevel2 = "administrative_area_level_2"
  case administrativeAreaLevel3 = "administrative_area_level_3"
  case administrativeAreaLevel4 = "administrative_area_level_4"
  case administrativeAreaLevel5 = "administrative_area_level_5"
  case colloquialArea = "colloquial_area"
  case locality
  case sublocality
  case neighborhood
  case premise
  case subpremise
  case postalCode = "postal_code"
  case naturalFeature = "natural_feature"
  case airport
  case park
  case pointOfInterest = "point_of_interest"
}

struct AddressComponent: Decodable {
  let long_name: String
  let short_name: String?
  let types: [String]
}

struct Location: Codable {
  let lng: Double
  let lat: Double
}

struct Viewport: Decodable {
  let northeast: Location
  let southwest: Location
}

struct Geometry: Decodable {
  let location: Location
  let viewport: Viewport
  let location_type: String
}

struct Geocode: Decodable {
  let place_id: String
  let address_components: [AddressComponent]
  let formatted_address: String
  let geometry: Geometry
  let types: [String]

  var country: String {
    let countryComponent = findComponent(for: .country)
    guard let component = countryComponent else {
      return ""
    }
    return componentName(component)
  }

  var state: String? {
    let stateComponent = findComponent(for: .administrativeAreaLevel1)
    guard let component = stateComponent else {
      return nil
    }
    return componentName(component)
  }

  var neighborhood: String? {
    let neighborhoodComponent = findComponent(for: .neighborhood)
    guard let component = neighborhoodComponent else {
      return nil
    }
    return componentName(component)
  }

  var city: String? {
    let cityComponent = findComponent(for: .locality)
    guard let component = cityComponent else {
      return nil
    }
    return componentName(component)
  }

  var nature: String? {
    let natureComponent = findComponent(for: .naturalFeature)
    guard let component = natureComponent else {
      return nil
    }
    return componentName(component)
  }

  func componentName(_ component: AddressComponent) -> String {
    return component.short_name.getOrElse(result: component.long_name)
  }

  func findComponent(for type: AddressComponentType) -> AddressComponent? {
    return address_components.first(where: { $0.types.contains(type.rawValue) })
  }

  func shortLocationName() -> String {
    return neighborhood.getOrElseL({
      city.getOrElseL({
        nature.getOrElseL({
          state.getOrElseL({ country })
        })
      })
    })
  }

  func fullLocationName() -> String {
    let shortName = shortLocationName()
    let country = self.country
    if country == shortName {
      return shortName
    }
    return "\(shortName), \(country)"
  }
}
