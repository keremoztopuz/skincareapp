//
//  MainTabView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 20.04.2026.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    var body: some View {
        let tintColor = Color(red:0.47, green: 0.11, blue: 0.17)
        
        TabView(selection: $selectedTab){
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label(NSLocalizedString("tab_home", comment: ""), systemImage: "house")
                }
                .tag(0)
            SearchView()
                .tabItem {
                    Label(NSLocalizedString("tab_search", comment: ""), systemImage: "magnifyingglass")
                }
                .tag(1)
            CameraView()
                .tabItem {
                    Label(NSLocalizedString("tab_camera", comment: ""), systemImage: "camera")
                }
                .tag(2)
            RecentsView(selectedTab: $selectedTab)
                .tabItem {
                    Label(NSLocalizedString("tab_recents", comment: ""), systemImage: "book")
                }
                .tag(3)
            MoreView()
                .tabItem {
                    Label(NSLocalizedString("tab_profile", comment: ""), systemImage: "person")
                }
                .tag(4)
        }
        .tint(Color(tintColor))
    }
}

#Preview {
    MainTabView()
}
