//
//  HomeView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 23.03.2026.
//

import Foundation
import SwiftUI
internal import Combine

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    
    var body: some View {
        Text(vm.userName)
            
    }
}
