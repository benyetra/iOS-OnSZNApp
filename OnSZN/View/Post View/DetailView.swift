//
//  DetailView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 1/16/23.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import FirebaseStorage

struct DetailView: View {
    var post: Post
    /// Callbacks
//    var onUpdate: (Post)->()
//    var onDelete: ()->()
    ///View Properties
//    @AppStorage("user_UID") var userUID: String = ""
    @State private var userUID: String = ""
    @State private var docListner: ListenerRegistration?
    @State private var showLightbox = false
    var basedOnUID: Bool = false
    var uid: String = ""
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
                .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("@\(post.userName)")
                    .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .foregroundColor(colorScheme == .light ? Color.cgBlue : Color.platinum)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(post.text)
                    .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                
                /// Post Image if any
                if let postImageURL = post.imageURL {
                    GeometryReader {
                        let size = $0.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .onTapGesture {
                                self.showLightbox = true
                            }
                    }
                    .frame(height: 200)
                }
                Text(post.teamTopic)
                    .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                    .hAlign(.trailingFirstTextBaseline)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                PostInteraction()
            }
        }
        .vAlign(.topLeading)
        .padding(.horizontal, 10)
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
                    Image(systemName: "trash")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        })
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
                    Image(systemName: post.likedIDs.contains(userUID) ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                }
                Text("\(post.likedIDs.count)")
                    .font(.caption)
                    .foregroundColor(colorScheme == .light ? Color.gray : Color.gray)

                Button(action: dislikePost) {
                    Image(systemName: post.dislikedIDs.contains(userUID) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                }
                .padding(.leading, 25)
                Text("\(post.dislikedIDs.count)")
                    .font(.caption)
                    .foregroundColor(colorScheme == .light ? Color.gray : Color.gray)
            }
            .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
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
        
        //Deleting Post
        func deletePost() {
            Task {
                /// Step 1: Delete Image from Firebase Storage if Present
                do {
                    if post.imageReferenceID != "" {
                        try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                    }
                    /// Step 2: Delete Firestore Document
                    guard let postID =  post.id else {return}
                    try await Firestore.firestore().collection("Posts").document(postID).delete()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

