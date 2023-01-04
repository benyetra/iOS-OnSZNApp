//
//  SearchUserView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/29/22.
//

import SwiftUI
import FirebaseFirestore

struct SearchUserView: View {
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        List {
            ForEach(fetchedUsers) { user in
                NavigationLink {
                    ReusableProfileContent(user: user)
                } label: {
                    Text(user.username)
                        .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                        .font(.callout)
                        .hAlign(.leading)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search Users")
        .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
        .searchable(text: $searchText)
        .onSubmit(of: .search, {
            Task {await searchUsers()}
        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                fetchedUsers = []
            }
        })
    }
    
    func searchUsers()async {
        do {
            let documents = try await Firestore.firestore().collection("Users").whereField("username", isGreaterThanOrEqualTo: searchText)
                .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            
            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }
            
            /// UI Must Be Updated on Main Thread
            await MainActor.run(body: {
                fetchedUsers = users
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
