//
//  ReusableProfileContent.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//


import SwiftUI
import SDWebImageSwiftUI

struct ReusableProfileContent: View {
    var user: User
    @State private var fetchedPosts: [Post] = []
    @Environment(\.colorScheme) private var colorScheme
    @State private var showLightbox = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                HStack(spacing: 12){
                    VStack() {
                        WebImage(url: user.userProfileURL).placeholder {
                            // MARK: Placeholder Image
                            Image("NullProfile")
                                .resizable()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(colorScheme == .light ? Color.cgBlue : Color.platinum, lineWidth: 1))
                        .overlay(
                            Image("\(user.favoriteTeam)")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(colorScheme == .light ? Color.platinum : Color.platinum, lineWidth: 1))
                                .position(x: 85, y: 85)
                        )
                        .onTapGesture {
                            self.showLightbox = true
                        }
                        .sheet(isPresented: $showLightbox) {
                            WebImage(url: self.user.userProfileURL)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                self.showLightbox = false
                                }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        
                        // MARK: Displaying Bio Link, If Given While Signing Up Profile Page
                        if let bioLink = URL(string: user.userBioLink){
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                    }
                    .hAlign(.leading)
                }
                
                Text("Post's")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .hAlign(.leading)
                    .padding(.vertical,15)
                
                ReusablePostsView(basedOnUID: true, uid: user.userUID, posts: $fetchedPosts)
            }
            .padding(15)
        }
    }
}
