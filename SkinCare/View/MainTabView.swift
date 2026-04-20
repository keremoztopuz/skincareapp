//
//  MainTabView.swift
//  SkinCare
//
//  Created by Kerem Öztopuz on 20.04.2026.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView{
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }
            RecentsView()
                .tabItem {
                    Label("Recents", systemImage: "book")
                }
            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis")
                }
        }
        .tint(Color(red: 0.47, green: 0.11, blue: 0.17))
    }
}

#Preview {
    MainTabView()
}
