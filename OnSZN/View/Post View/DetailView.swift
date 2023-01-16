//
//  DetailView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 1/16/23.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct DetailView: View {
    var post: Post
    var body: some View {
        VStack {
            Text(post.text)
            WebImage(url: post.imageURL)
            Text(post.userName)
            Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
        }
    }
}
