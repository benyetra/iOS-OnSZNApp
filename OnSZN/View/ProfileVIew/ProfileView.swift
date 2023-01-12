//
//  ProfileView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    // MARK: My Profile Data
    @State private var myProfile: User?
    @AppStorage("log_status") var logStatus: Bool = false
    // MARK: View Properties
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var editAccount: Bool = false
    @State var favoriteTeam: Bool = false
    @State private var selection: String?
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        NavigationStack {
            VStack {
                if let myProfile {
                    ReusableProfileContent(user: myProfile)
                        .refreshable {
                            //MARK: Refresh User Data
                            self.myProfile = nil
                            await fetchUserData()
                        }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("My Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        //MARK: Three Action's
                        //1. Edit Profile
                        //2. Select Team
                        //3. Logout
                        //4. Delete Account
                        Button("Edit Profile") { editAccount.toggle()}
                        Button("Select Favorite Team") { favoriteTeam.toggle()}
                        Button("Logout", action: logOutUser)
                        Button("Delete Account", role: .destructive, action: deleteAccount)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                            .scaleEffect(0.8)
                    }
                }
            }
            .overlay {
                LoadingView(show: $isLoading)
            }
            .alert(errorMessage, isPresented: $showError) {
            }
            .task {
                // This modifier is like onAppear
                // So fetching for the first time only
                if myProfile != nil{return}
                // MARK: Initial Fetch
                await fetchUserData()
            }
        }
        //MARK: Register View via Sheets
        .fullScreenCover(isPresented: $editAccount){
            EditProfileView()
        }
        .sheet(isPresented: $favoriteTeam){
            FavoriteTeamView(selection: $selection)
        }
    }
    
    //MARK: Fetching User Data
    func fetchUserData()async{
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self) else {return}
        await MainActor.run(body: {
            myProfile = user
        })
    }
    
    //MARK: Logging User Out
    func logOutUser() {
        isLoading = true
        try? Auth.auth().signOut()
        logStatus = false
    }
    
    //MARK: Deleting User Entire Account
    func deleteAccount() {
        isLoading = true
        Task {
            do {
                guard let userUID = Auth.auth().currentUser?.uid else{return}
                // Step 1: First Deleteing Profile Image From Storage
                let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
                try await reference.delete()
                // Step 2: Deleteing Diresrore User Document
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                // Final Step: deleting AUth ACcount and Setting Log Status to False
                try await Auth.auth().currentUser?.delete()
                logStatus = false
            }catch {
                await setError(error)
            }
        }
    }
    //MARK: Setting Error
    func setError(_ error: Error)async{
        //MARK: UI Must be run on Main Thread
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
