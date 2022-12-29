//
//  PostCardView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseStorage

struct PostCardView: View {
    var post: Post
    /// Callbacks
    var onUpdate: (Post)->()
    var onDelete: ()->()
    ///View Properties
    @AppStorage("user_UID") var userUID: String = ""
    @State private var docListner: ListenerRegistration?
    @State private var showLightbox = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
                .foregroundColor(.oxfordBlue)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(post.userName)
                    .foregroundColor(.oxfordBlue)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .foregroundColor(.cgBlue)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(post.text)
                    .foregroundColor(.oxfordBlue)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                
                /// Post Image if any
                if let postImageURL = post.imageURL {
                    GeometryReader {
                        let size = $0.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .foregroundColor(.oxfordBlue)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .onTapGesture {
                                self.showLightbox = true
                            }
                    }
                    .frame(height: 200)
                }
                    
                PostInteraction()
            }
        }
        .sheet(isPresented: $showLightbox) {
            WebImage(url: post.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
                    self.showLightbox = false
                }
        }
        .hAlign(.leading)
        .overlay(alignment: .topTrailing, content: {
            ///Displaying Delete Button (if its author of the post)
            if post.userUID == userUID {
                Menu {
                    Button ("Delete Post", role: .destructive, action: deletePost)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.oxfordBlue)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        })
        .onAppear {
            /// Adding Only Once
            if docListner == nil {
                guard let postID = post.id else {return}
                docListner = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapshot,
                    error in
                    if let snapshot {
                        if snapshot.exists {
                            /// Document Updated
                            /// Fetching Updated Document
                            if let updatedPost = try? snapshot.data(as: Post.self) {
                                onUpdate(updatedPost)
                            }
                        } else {
                            ///Document Deleted
                            onDelete()
                        }
                    }
                })
            }
        }
        .onDisappear {
            if let docListner {
                docListner.remove()
                self.docListner = nil
            }
        }
    }
    
    
    // MARK: Like/Dislike Interaction
    @ViewBuilder
    func PostInteraction()->some View {
        HStack(spacing: 6) {
            Button(action: likePost) {
                Image(systemName: post.likedIDs.contains(userUID) ? "hand.thumbsup.fill" : "hand.thumbsup").foregroundColor(.oxfordBlue)
            }
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: dislikePost) {
                Image(systemName: post.dislikedIDs.contains(userUID) ? "hand.thumbsdown.fill" : "hand.thumbsdown").foregroundColor(.oxfordBlue)
            }
            .padding(.leading, 25)
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.platinum)
        }
        .foregroundColor(.oxfordBlue)
        .padding(.vertical, 8)
    }
    
    ///Liking Post
    func likePost() {
        Task {
            guard let postID = post.id else {return}
            if post.likedIDs.contains(userUID) {
                ///Removing user id from array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                ///Adding User ID to Liked Array and removing our ID from disliked Array (if added in prior)
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID]), "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    ///Disliking a Post
    func dislikePost() {
        Task {
            guard let postID = post.id else {return}
            if post.dislikedIDs.contains(userUID) {
                ///Removing user id from array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                ///Adding User ID to Liked Array and removing our ID from disliked Array (if added in prior)
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayUnion([userUID]), "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    ///Deleting Post
    func deletePost() {
        Task {
            /// Step 1: Delete Image from Firebase Storage if Present
            do {
                if post.imageReferenceID != "" {
                    try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                }
                /// Step 2: Delete Firestore Document
                guard let postID =  post.id else {return}
                try await Firestore.firestore().collection("Posts").document().delete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
