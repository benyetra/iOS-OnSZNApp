//
//  Post.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//

import SwiftUI
import FirebaseFirestoreSwift

//MARK: Post Model
struct Post: Identifiable,Codable,Equatable,Hashable {
    @DocumentID var id: String?
    var text: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate: Date = Date()
    var likedIDs: [String] = []
    var dislikedIDs: [String] = []
    //MARK: basic User Info
    var userName: String
    var userUID: String
    var userProfileURL: URL
    var teamTopic: String
    
    enum CodingKeys: CodingKey {
        case id
        case text
        case imageURL
        case imageReferenceID
        case publishedDate
        case likedIDs
        case dislikedIDs
        case userName
        case userUID
        case userProfileURL
        case teamTopic
    }
}
