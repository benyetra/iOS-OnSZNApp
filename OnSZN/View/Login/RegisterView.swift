//
//  RegisterView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

//MARK: Register View
struct RegisterView: View {
    @State var croppedImage: UIImage?
    //MARK: User Properties
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    //MARK: View Properties
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
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
    var body:some View {
        VStack(spacing:10) {
            Text("Lets register your \naccount")
                .font(.largeTitle.bold())
                .environment(\.colorScheme, colorScheme)
                .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                .hAlign(.leading)
            
            Text("Welcome to the league!")
                .font(.title3)
                .environment(\.colorScheme, colorScheme)
                .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                .hAlign(.leading)
            
            //MARK: Optimize Size
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                HelperView()
            }
            
            //MARK: Register Button
            HStack {
                Text("Already have an account?")
                    .environment(\.colorScheme, colorScheme)
                    .foregroundColor(colorScheme == .light ? Color.gray : Color.platinum)
                Button("Login Now") {
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
            .padding(.top,25)
            
            Text("Edit Profile Picture")
                .font(.title3)
                .environment(\.colorScheme, colorScheme)
                .foregroundColor(colorScheme == .light ? Color.cgBlue : Color.platinum)
                .hAlign(.center)
            
            Text("Tap on the image to change it")
                .font(.subheadline)
                .environment(\.colorScheme, colorScheme)
                .foregroundColor(colorScheme == .light ? Color.gray : Color.platinum)
                .hAlign(.center)
                .padding(-10)
            
            Spacer(minLength: 5)
            
            TextField("Username", text:$userName)
                .environment(\.colorScheme, colorScheme)
                .foregroundColor(colorScheme == .light ? Color.gray : Color.platinum)
                .textContentType(.nickname)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .border(1, colorScheme == .light ? Color.cgBlue : Color.platinum.opacity(0.5))
            
            TextField("Email", text:$emailID)
                .environment(\.colorScheme, colorScheme)
                .foregroundColor(colorScheme == .light ? Color.gray : Color.platinum)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .border(1, colorScheme == .light ? Color.cgBlue : Color.platinum.opacity(0.5))

            SecureField("Password", text:$password)
                .environment(\.colorScheme, colorScheme)
                .foregroundColor(colorScheme == .light ? Color.gray : Color.platinum)
                .textContentType(.password)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .border(1, colorScheme == .light ? Color.cgBlue : Color.platinum.opacity(0.5))

            TextField("About You", text:$userBio, axis: .vertical)
                .environment(\.colorScheme, colorScheme)
                .foregroundColor(colorScheme == .light ? Color.gray : Color.platinum)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.nickname)
                .border(1, colorScheme == .light ? Color.cgBlue : Color.platinum.opacity(0.5))

            TextField("Bio Link (Optional)", text:$userBioLink)
                .environment(\.colorScheme, colorScheme)
                .foregroundColor(colorScheme == .light ? Color.gray : Color.platinum)
                .textContentType(.URL)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .border(1, colorScheme == .light ? Color.cgBlue : Color.platinum.opacity(0.5))

            Button(action: registerUser) {
                //MARK: Login Button
                Text("Sign up")
                    .environment(\.colorScheme, colorScheme)
                    .foregroundColor(colorScheme == .light ? Color.white : Color.platinum)
                    .hAlign(.center)
                    .fillView(.oxfordBlue)
            }
            .disableWithOpacity(userName == "" || userBio == "" || emailID == "" || password == "" || userProfilePicData == nil)
            .padding(.top,10)
        }
    }
    
    func registerUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                //Step 1: Creating Firebase Account
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                //Step 2: Uploading Profile Photo into Firebase Storage
                guard let userUID = Auth.auth().currentUser?.uid else {return}
                guard let imageData = userProfilePicData else {return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                //Step 3: Downloading Photo URL
                let downloadURL = try await storageRef.downloadURL()
                //Step 4: Creating a User Firestore Object
                let user = User(username: userName, userBio: userBio, userBioLink: userBioLink, userUID: userUID, userEmail: emailID, userProfileURL: downloadURL)
                //Step 5: Saving User DOc into Firestore Databaase
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: {
                    error in
                    if error == nil {
                        //MARK: Print Saved Successfully
                        print("Saved Succesfully")
                        userNameStored = userName
                        self.userUID = userUID
                        profileURL = downloadURL
                        logStatus = true
                    }
                })
            } catch {
                // MARK: Deleting Created Account In Case of Failure
                try await Auth.auth().currentUser?.delete()
                await setError(error)
            }
        }
    }
    
    //MARK: Displaying Errors Via Alert
    func setError(_ error: Error)async{
        //MARK: UI Must Be UYpdated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
