//
//  LoginView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct LoginView: View {
    //MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    //MARK: View Properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    //MARK: User Defaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    var body: some View {
        VStack(spacing:10) {
            Text("Lets sign you in!")
                .font(.largeTitle.bold())
                .foregroundColor(.oxfordBlue)
                .hAlign(.leading)
            
            Text("Welcome back, \nYou have been missed!")
                .font(.title3)
                .foregroundColor(.oxfordBlue)
                .hAlign(.leading)
            
            VStack(spacing:12){
                TextField("Email", text: $emailID)
                    .textContentType(.emailAddress)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .autocorrectionDisabled()
                    .border(1, .cgBlue.opacity(0.5))
                    .padding(.top, 25)

                
                SecureField("Password", text:$password)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .border(1, .cgBlue.opacity(0.5))
                
                Button("Reset Password?", action:resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.cgBlue)
                    .hAlign(.trailing)
                
                Button(action: loginUser) {
                    //MARK: Login Button
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.oxfordBlue)
                }
                .padding(.top,10)
            }
            
            //MARK: Register Button
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                Button("Register Now") {
                    createAccount.toggle()
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
        //MARK: Register View via Sheets
        .fullScreenCover(isPresented: $createAccount){
            RegisterView()
        }
        //MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    
    func loginUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    // MARK: If User if Found then Fetching User Data From Firestore
    func fetchUser()async throws {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        //MARK: UI Upodating Must be Run on Main Thread
        await MainActor.run(body: {
            //Setting UserDefaults data and Chaing App's Auth Status
            userUID = userID
            userNameStored = user.username
            profileURL = user.userProfileURL
            logStatus = true
        })
    }
    
    func resetPassword() {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            } catch {
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error)async{
        //MARK: UI Must Be UYpdated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


