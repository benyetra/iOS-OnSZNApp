//
//  ReusablePostsView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusablePostsView: View {
    @Binding var posts: [Post]
    /// - View Properties
    @State var isFetching: Bool = true
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                if isFetching {
                    ProgressView()
                        .padding(.top, 30)
                } else {
                    if posts.isEmpty {
                        ///No Post's found on firestore
                        Text("No Post's Found")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    } else {
                        /// - Displaying Post's
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            /// - Scroll to regresh
            isFetching = true
            posts = []
            await fetchPosts()
        }
        .task {
            /// Fetching For One Time
            guard posts.isEmpty else{return}
            await fetchPosts()
        }
    }
    
    ///Displaying fetched Posts
    @ViewBuilder
    func Posts() ->some View {
        ForEach(posts) { post in
            PostCardView(post: post) { updatedPost in
                ///Updating post in the array
                if let index = posts.firstIndex(where: {post in
                    post.id == updatedPost.id
                }){
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                ///Removing Post form the array
                withAnimation(.easeInOut(duration: 0.25)) {
                    posts.removeAll{post.id == $0.id}
                }
            }
            
            Divider()
                .padding(.horizontal, -15)
        }
    }
    
    func fetchPosts()async {
        do {
            var query: Query!
            query = Firestore.firestore().collection("Posts")
                .order(by: "publishedDate", descending: true)
                .limit(to: 20)
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts = fetchedPosts
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ReusablePostsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
