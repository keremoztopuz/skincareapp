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
    case ben_Lezyon
    case healthy
    
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
        case .ben_Lezyon:
            return "Mevcut benlerinizdeki asimetri, renk değişimi veya büyüme durumunu gözlemleyin. Şüpheli durumlarda doktora başvurun."
        case .healthy:
            return "Cildiniz sağlıklı görünüyor! Mevcut bariyeri korumak için güneş kremini ihmal etmeyin."
        }
    }
}
