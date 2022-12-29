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
            .navigationTitle("My Profile").foregroundColor(.oxfordBlue)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        //MARK: Two Action's
                        //1. Logout
                        //2. Delete Account
                        Button("Logout", action: logOutUser)
                        Button("Delete Account", role: .destructive, action: deleteAccount)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.oxfordBlue)
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
                let reference = Storage.storage().reference().child("Profile_Image").child(userUID)
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
