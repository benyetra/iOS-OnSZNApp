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
                VStack {
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
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search Users")
        .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
        .searchable(text: $searchText)
        .textInputAutocapitalization(.never)
        .textCase(.lowercase)
        .onSubmit(of: .search, {
            searchUsers()
        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                fetchedUsers = []
            }
        })
    }
    
    func searchUsers() {
        Firestore.firestore().collection("Users")
            .whereField("username", isGreaterThanOrEqualTo: searchText)
            .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
            .getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let snapshot = querySnapshot {
                    let users = snapshot.documents.compactMap { doc -> User? in
                        try? doc.data(as: User.self)
                    }
                    DispatchQueue.main.async {
                        self.fetchedUsers = users
                    }
                }
        }
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
