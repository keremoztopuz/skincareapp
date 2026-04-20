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
        self.userName = profile?.name ?? ""
        
    }
}
