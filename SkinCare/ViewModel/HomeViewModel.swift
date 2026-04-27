//
//  HomeViewModel.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 20.04.2026.
//

import Foundation
import SwiftUI
import CoreData
internal import Combine

class HomeViewModel: ObservableObject {
    @Published var userName: String = ""
    
    init() {
        fetchNames()
    }
    
    func fetchNames() {
        let profile = LocalPersistenceManager.shared.fetchUserProfile()
        if let profile = profile {
            self.userName = profile.name ?? ""
            print("--- CORE DATA DEBUG ---")
            print("User Name: \(profile.name ?? "No Name")")
            print("Skin Type: \(profile.skinType ?? "No Type")")
            print("Gender: \(profile.gender ?? "No Gender")")
            print("-----------------------")
        } else {
            print("--- CORE DATA DEBUG ---")
            print("No User Profile found in Core Data.")
            print("-----------------------")
        }
    }}
