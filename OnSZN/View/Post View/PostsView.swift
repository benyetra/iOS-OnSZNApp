//
//  PostsView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//

import SwiftUI

struct PostsView: View {
    @State private var recentPosts: [Post] = []
    @State private var createNewPost: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        NavigationStack {
            ReusablePostsView(posts: $recentPosts)
                .hAlign(.center).vAlign(.center)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .light ? Color.platinum : Color.oxfordBlue)
                            .padding(13)
                            .background(colorScheme == .light ? Color.oxfordBlue : Color.platinum, in: Circle())
                            .overlay(Circle().stroke(colorScheme == .light ? Color.platinum : Color.oxfordBlue,
                            lineWidth: 1))
                    }
                    .padding(15)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SearchUserView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                                .scaleEffect(0.9)
                        }
                    }
                })
                .navigationTitle("Post's")
        }
        .fullScreenCover(isPresented: $createNewPost) {
            CreateNewPost(onPost: { post in
                /// Adding created post at the top of the recent posts
                recentPosts.insert(post, at: 0)
            })
        }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
