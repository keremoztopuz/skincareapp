//
//  MoreViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 6.05.2026.
//

import Foundation
import SwiftUI
internal import Combine
internal import CoreData

class MoreViewModel: ObservableObject {
    @Published var userName: String = "Sarah Johnson"
    @Published var userAge: String = "28"
    @Published var userGender: String = "Female"
    @Published var userSkinType: String = "Combination"
    @AppStorage("isPremium") var isPremium: Bool = false
}
