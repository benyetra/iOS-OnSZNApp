//
//  EditProfileView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/29/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct EditProfileView: View {
    //MARK: User Properties
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    //MARK: View Properties
    @Environment(\.dismiss) var dismiss
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    // MARK: User Defaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    var body: some View {
        VStack(spacing:10) {
            Text("Edit your profile")
                .font(.largeTitle.bold())
                .foregroundColor(.oxfordBlue)
                .hAlign(.leading)
            
            Text("Update your profile information")
                .font(.title3)
                .foregroundColor(.oxfordBlue)
                .hAlign(.leading)
            
            //MARK: Optimize Size
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                HelperView()
            }
            //MARK: Cancel Button
            HStack {
                Text("Want to revisit this later?")
                    .foregroundColor(.gray)
                Button("Cancel") {
                    dismiss ()
                }
                .fontWeight(.bold)
                .foregroundColor(.cgBlue)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            //MARK: Extracting UIImage From PhotoItem
            Task {
                do {
                    guard let imageData = try await newValue?.loadTransferable(type: Data.self) else {return}
                    //MARK: UI Must Be Updated on Main Thread
                    await MainActor.run(body: {
                        userProfilePicData = imageData
                    })
                }catch{}
            }
        }
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    func updateUserInfo() {
        // Get Firestore instance and user's uid
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid

        // Update user's data in Firebase Firestore
        db.collection("users").document(uid ?? "").updateData([
            "email": self.emailID,
            "password": self.password,
            "username": self.userName,
            "bio": self.userBio,
            "bio_link": self.userBioLink,
            "profile_pic_data": self.userProfilePicData
        ]) { (error) in
            if let error = error {
                // Show error message
                self.errorMessage = error.localizedDescription
                self.showError = true
            } else {
                // Update user's data in UserDefaults
                self.userNameStored = self.userName
                self.profileURL = URL(string: self.userBioLink)
                self.logStatus = true
                // Dismiss view
                self.dismiss()
            }
        }
    }
    
    @ViewBuilder
    func HelperView() -> some View {
        VStack(spacing:12) {
            ZStack {
                if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("NullProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.cgBlue, lineWidth: 1))
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top, 20)
            
            Text("Edit Profile Picture")
                .font(.title3)
                .foregroundColor(.oxfordBlue)
                .hAlign(.center)
            Text("Tap on the image to change it")
                .font(.subheadline)
                .foregroundColor(.gray)
                .hAlign(.center)
            VStack(spacing:15) {
                TextField("Username",text: $userName)
                TextField("Email", text: $emailID)
                SecureField("Password", text: $password)
                TextField("About You", text: $userBio)
                TextField("Bio Link (Optional)", text: $userBioLink)
                Button(action: updateUserInfo) {
                    //MARK: Login Button
                    Text("Save Changes")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.oxfordBlue)
                }
                .disableWithOpacity(userName == "" || userBio == "" || emailID == "" || password == "" || userProfilePicData == nil)
                .padding(.top,10)
            }
            }
        }
    }

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
