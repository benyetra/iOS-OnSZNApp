//
//  ReusableTeamPostsView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 1/6/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusableTeamPostsView: View {
    var basedOnTeamTopic: Bool = false
    var teamTopic: String = ""
    @Binding var posts: [Post]
    var teamName: String = ""
    /// - View Properties
    @State private var isFetching: Bool = true
    /// - Paginatino
    @State private var paginationDoc: QueryDocumentSnapshot?
    @Environment(\.colorScheme) private var colorScheme
   
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
                            .foregroundColor(colorScheme == .light ? Color.cgBlue : Color.platinum)
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
            /// - Scroll to refresh
            guard !basedOnTeamTopic else {return}
            isFetching = true
            posts = []
            /// - Resetting Pagination Doc
            paginationDoc = nil
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
            .onAppear {
                /// - When last post appears, load more if there are any
                if post.id == posts.last?.id && paginationDoc != nil {
                    Task {await fetchPosts()}
                }
            }
            
            Divider()
                .padding(.horizontal, -15)
        }
    }
    
    func fetchPosts()async {
        do {
            var query: Query!
            /// - Implementing Pagination
            if let paginationDoc {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
            /// New Query For team topic Based Document Fetch
            /// Filter posts not used by this team topic
            if  basedOnTeamTopic {
                query = query
                    .whereField("teamTopic", isEqualTo: teamName)
            }
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts.append(contentsOf: fetchedPosts)
                paginationDoc = docs.documents.last
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ReusableTeamPostsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
