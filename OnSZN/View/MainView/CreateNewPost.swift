//
//  CreateNewPost.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage

struct CreateNewPost: View {
    /// - Callbacks
    var onPost: (Post)->()
    /// - Post Properties
    @State private var postText: String = ""
    @State private var postImageData: Data?
    @State var teamTopic: String = ""
    @State private var selection: String?
    /// - Stored User Data From UserDefaults(AppStorage)
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    @AppStorage("selected_team") var storedSelectedTeam: String = "NBAWhereAmazingHappens"
    /// - View Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isLoading: Bool = false
    @State private var topicSheetAppear: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    @FocusState private var showKeyboard: Bool

    var body: some View {
        VStack{
            HStack {
                Menu {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                } label: {
                    Text("Cancel")
                        .font(.callout)
                        .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                }
                .hAlign(.leading)
                
                Button(action: createPost) {
                    Text("Post")
                        .font(.callout)
                        .foregroundColor(colorScheme == .light ? Color.platinum : Color.cgBlue)
                        .padding(.horizontal,20)
                        .padding(.vertical,6)
                        .background(colorScheme == .light ? Color.oxfordBlue : Color.platinum,in: Capsule())
                }
                .disableWithOpacity(postText == "")
            }
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background {
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    TextField("What's Happening?", text: $postText, axis: .vertical)
                        .focused($showKeyboard)
                    if let postImageData,let image = UIImage(data: postImageData) {
                        GeometryReader {
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            /// - Delete Button
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            self.postImageData = nil
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .fontWeight(.bold)
                                            .tint(.red)
                                    }
                                    .padding(10)
                                }
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }
                .padding(15)
            }
            Text("#\(storedSelectedTeam)")
                .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                .hAlign(.trailingFirstTextBaseline)
                .font(.callout)
                .fontWeight(.semibold)
            
            Divider()
            
            HStack {
                Button {
                    showImagePicker.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                        .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                }
                .hAlign(.leading)
                
                Button("Team Topic") {
                    showKeyboard = false
                    topicSheetAppear.toggle()
                }.sheet(isPresented: $topicSheetAppear) {
                    SelectTeamTopicView(selection: $selection)
                    Text("Swipe Down to Dismiss")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                }
            }
            .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
            .padding(.horizontal, 15)
            .padding(.vertical,10)
        }
        .vAlign(.top)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            if let newValue {
                Task {
                    if let rawImageData = try? await newValue.loadTransferable(type: Data.self), let image = UIImage(data: rawImageData), let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                        /// UI Must be done on Main Thread
                        await MainActor.run(body: {
                            postImageData = compressedImageData
                            photoItem = nil
                        })
                    }
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
        /// - Loading View
        .overlay{
            LoadingView(show: $isLoading)
        }
    }
    
    // MARK: Post Content To Firebase
    func createPost() {
        isLoading = true
        showKeyboard = false
        Task {
            do {
                guard let profileURL = profileURL else {return}
                    ///Step 1: Uploading Image If
                let imageReferenceID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imageReferenceID)
                if let postImageData {
                    let _ = try await storageRef.putDataAsync(postImageData)
                    let downloadURL = try await storageRef.downloadURL()
                    /// Step 3: Create post object with image ID and URL
                    let post = Post(text: postText, imageURL: downloadURL, imageReferenceID: imageReferenceID, userName: userName, userUID: userUID, userProfileURL: profileURL, teamTopic: storedSelectedTeam)
                    try await createDocumentAtFirebase(post)
                } else {
                    ///Step 2:  Directly Post Text Data to Firebase (Since there is no images present)
                    let post = Post(text: postText, userName: userName, userUID: userUID, userProfileURL: profileURL, teamTopic:storedSelectedTeam)
                    try await createDocumentAtFirebase(post)
                }
            } catch {
                await setError(error)
            }
        }
    }
    
    func createDocumentAtFirebase(_ post: Post)async throws {
        /// - Writing Document to Firebase Firestore
        let _ = try Firestore.firestore().collection("Posts").addDocument(from: post, completion: { error in
            if error == nil {
                /// Post successfully  stored at Firebase
                isLoading = false
                onPost(post)
                dismiss()
            }
        })
    }
    
    //MARK: Displaying Errors as Alert
    func setError(_ error: Error)async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct Teams: Hashable {
    let name: String
    let icon: String
}

let teams = [
        Teams(name: "Toronto Raptors", icon: "Raptors"),
        Teams(name: "Boston Celtics", icon: "Celtics"),
        Teams(name: "Brooklyn Nets", icon: "Nets"),
        Teams(name: "New York Knicks", icon: "Knicks"),
        Teams(name: "Philadelphia 76ers", icon: "Sixers"),
        Teams(name: "Milwaukee Bucks", icon: "Bucks"),
        Teams(name: "Indiana Pacers", icon: "Pacers"),
        Teams(name: "Chicago Bulls", icon: "Bulls"),
        Teams(name: "Detroit Pistons", icon: "Pistons"),
        Teams(name: "Cleveland Cavaliers", icon: "Cavaliers"),
        Teams(name: "Miami Heat", icon: "Heat"),
        Teams(name: "Orlando Magic", icon: "Magic"),
        Teams(name: "Charlotte Hornets", icon: "Hornets"),
        Teams(name: "Washington Wizards", icon: "Wizards"),
        Teams(name: "Atlanta Hawks", icon: "Hawks"),
        Teams(name: "Denver Nuggets", icon: "Nuggets"),
        Teams(name: "Oklahmoma City Thunder", icon: "Thunder"),
        Teams(name: "Utah Jazz", icon: "Jazz"),
        Teams(name: "Portland Trail Blazers", icon: "Blazers"),
        Teams(name: "Minnesota Timberwolves", icon: "Timberwolves"),
        Teams(name: "Los Angeles Lakers", icon: "Lakers"),
        Teams(name: "Los Angeles Clippers", icon: "Clippers"),
        Teams(name: "Phoenix Suns", icon: "Suns"),
        Teams(name: "Sacramento Kings", icon: "Kings"),
        Teams(name: "Golden State Warriors", icon: "Warriors"),
        Teams(name: "Houston Rockets", icon: "Rockets"),
        Teams(name: "Dallas Mavericks", icon: "Mavericks"),
        Teams(name: "Memphis Grizzlies", icon: "Grizzlies"),
        Teams(name: "San Antonio Spurs", icon: "Spurs"),
        Teams(name: "New Orleans Pelicans", icon: "Pelicans")
]


struct SelectTeamTopicView: View {
    @Binding var selection: String?
    @State private var selectedTeam: Teams?
    @State var teamTopic: String = ""
    @AppStorage("selected_team") private var storedSelectedTeam: String = "NBAWhereAmazingHappens"


    var body: some View {
        VStack {
            HStack {
                Text("Select The NBA Topic:")
                    .font(.body)
                Spacer()
            }
            .padding(EdgeInsets(top: 20, leading: 21, bottom: 0, trailing: 21))
            List {
                ForEach(teams, id: \.self) { teams in
                    Button(action: {
                        self.selectedTeam = teams
                        storedSelectedTeam = self.selectedTeam?.name ?? "NBAWhereAmazingHappens"
                    }) {
                        HStack {
                            Image(teams.icon)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)
                                .opacity(self.selectedTeam == teams ? 1 : 0.5)
                            Text(teams.name)
                                .font(.body)
                                .foregroundColor(self.selectedTeam == teams ? Color.cgBlue : Color.gray)
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            Spacer()
        }
    }
}
