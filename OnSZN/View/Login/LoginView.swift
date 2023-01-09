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
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var loginModel: LoginViewModel = .init()
    @StateObject var loginData = LoginViewModel()
    
    //MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    //MARK: View Properties
    @State var createAccount: Bool = false
    @State var phoneLogin: Bool = false
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
                .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                .hAlign(.leading)
            
            Text("Welcome back, \nYou have been missed!")
                .font(.title3)
                .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.platinum)
                .hAlign(.leading)
            
            VStack(spacing:12){
                TextField("Email", text: $emailID)
                    .foregroundColor(colorScheme == .light ? Color.gray : Color.platinum)
                    .textContentType(.emailAddress)
                    .autocapitalization(UITextAutocapitalizationType.none)
                    .autocorrectionDisabled()
                    .border(1, colorScheme == .light ? Color.cgBlue : Color.platinum.opacity(0.5))
                    .padding(.top, 25)
                
                SecureField("Password", text:$password)
                    .foregroundColor(colorScheme == .light ? Color.gray : Color.platinum)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .border(1, colorScheme == .light ? Color.cgBlue : Color.platinum.opacity(0.5))
                
                Button("Reset Password?", action:resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.cgBlue)
                    .hAlign(.trailing)
                
                Button(action: loginUser) {
                    //MARK: Login Button
                    Text("Sign in")
                        .foregroundColor(colorScheme == .light ? Color.platinum : Color.oxfordBlue)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .frame(height:55)
                        .padding(.horizontal, 40)
                        .background {
                            Capsule(style: .continuous)
                                .fill(colorScheme == .light ? Color.oxfordBlue : Color.platinum.opacity(0.05))
                        }
                        .hAlign(.center)
                }
                .padding(.top,10)
                
                VStack(spacing: 10) {
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            CustomButton()
                                .overlay {
                                    //MARK: Apple Sign In
                                    SignInWithAppleButton { (request) in
                                        loginData.nonce = LoginViewModel.randomNonceString()
                                        request.requestedScopes = [.email, .fullName]
                                        request.nonce = LoginViewModel.sha256(loginData.nonce)
                                    } onCompletion: { (result) in
                                        switch result {
                                        case .success(let user):
                                            print("Success")
                                            guard let credential = user.credential as?
                                                    ASAuthorizationAppleIDCredential else {
                                                print("error with firebase")
                                                return
                                            }
                                            loginData.authenticate(credential: credential)
                                        case .failure(let error):
                                            print(error.localizedDescription)
                                        }
                                    }
                                    .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                                    .frame(height:55)
                                    .blendMode(.overlay)
                                }
                                .clipped()
                            
                            //MARK: Google Sign In Button
                             CustomButton(isGoogle: true)
                                .overlay {
                                    if let clientID = FirebaseApp.app()?.options.clientID {
                                        GoogleSignInButton {
                                            GIDSignIn.sharedInstance.signIn(with: .init(clientID: clientID), presenting: UIApplication.shared.rootController()) { user, error in
                                                if let error = error {
                                                    print(error.localizedDescription)
                                                    return
                                                }
                                                if let user {
                                                    loginModel.logGoogleUser(user: user)
                                                }
                                            }
                                        }
                                        .blendMode(.overlay)
                                    }
                                }
                                .clipped()
                        }
                        .padding(.leading, -60)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    
                    Button {
                        phoneLogin.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Sign In With Phone")
                        }
                    }
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .frame(height:55)
                    .padding(.horizontal, 40)
                    .font(.title3)
                    .foregroundColor(colorScheme == .light ? Color.oxfordBlue : Color.oxfordBlue)
                    .background(colorScheme == .light ? Color.platinum : Color.platinum, in: Capsule())
                    .fullScreenCover(isPresented: $phoneLogin){
                        PhoneLoginView()
                    }
                }
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
            //Setting UserDefaults data and Change App's Auth Status
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
    
    @ViewBuilder
    func CustomButton(isGoogle: Bool = false) -> some View {
        HStack{
            Group {
                if isGoogle {
                    Image(systemName: "google")
                        .resizable()
                        .renderingMode(.template)
                } else {
                    Image(systemName: "applelogo")
                        .resizable()
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .frame(height: 45)
            
            Text("\(isGoogle ? "Google" : "Apple") Sign In")
                .font(.callout)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 15)
        .background{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


