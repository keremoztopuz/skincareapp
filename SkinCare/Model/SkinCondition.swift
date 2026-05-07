//
//  SkinCondition.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation

// MARK: Skin Classes
enum SkinCondition: String, Codable, CaseIterable, Identifiable{
    case acne
    case eczema
    case psoriasis
    case wrinkles
    case eyebags
    
    
    var id : String { self.rawValue }
    
// MARK: Descriptions for testing
    var recommendation: String {
        switch self {
        case .acne:
            return "Salisilik asit içeren temizleyiciler kullanın. Gözenekleri tıkamayan (non-comedogenic) nemlendiriciler tercih edin."
        case .eczema:
            return "Cilt bariyerini güçlendiren seramidli kremler kullanın. Sıcak sudan ve parfümlü ürünlerden kaçının."
        case .psoriasis:
            return "Yoğun nemlendiriciler ve pullanma karşıtı içerikler kullanın. Mutlaka uzman bir dermatoloğa danışın."
        case .wrinkles:
            return "Retinol ve peptid içerikli ürünler kullanın. Cildinizi güneşten koruyun ve bol su tüketin."
        case .eyebags:
            return "Soğuk kompres uygulayın ve kafein içeren göz altı kremleri tercih edin. Uyku düzeninize dikkat edin."
        }
    }
}
