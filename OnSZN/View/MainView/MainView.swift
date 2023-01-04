//
//  MainView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        //MARK: TabView With Recent Post's and Profile Tabs
        TabView {
            PostsView()
                .tabItem{
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Post's")
                }
            ContentsView()
                .tabItem{
                    Image(systemName: "basketball.fill")
                    Text("Team News")
                }
            ProfileView()
                .tabItem{
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        //Changing Tab Label Tint to Black
        .tint(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
