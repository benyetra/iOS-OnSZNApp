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

struct LoginView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var loginModel: LoginViewModel = .init()
    @StateObject var loginData = LoginViewModel()
    
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

                //MARK: PHONE LOGIN
                CustomTextField(hint: "+1 6505551234", text: $loginModel.mobileNo)
                    .disabled(loginModel.showOTPField)
                    .opacity(loginModel.showOTPField ? 0.4 : 1)
                    .overlay(alignment: .trailing, content: {
                        Button("Change") {
                            withAnimation(.easeInOut) {
                                loginModel.showOTPField = false
                                loginModel.otpCode = ""
                                loginModel.CLIENT_CODE = ""
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.indigo)
                        .opacity(loginModel.showOTPField ? 1 : 0)
                        .padding(.trailing, 15)
                    })
                    .padding(.top, 50)
                
                CustomTextField(hint: "OTP Code", text: $loginModel.otpCode)
                    .disabled(!loginModel.showOTPField)
                    .opacity(!loginModel.showOTPField ? 0.4 : 1)
                    .padding(.top, 20)

                Button(action: loginModel.showOTPField ? loginModel.verifyOTPCode
                       : loginModel.getOTPCode) {
                    HStack(spacing: 15) {
                        Text(loginModel.showOTPField ? "Verify Code" : "Get Code")
                            .fontWeight(.semibold)
                            .contentTransition(.identity)
                            
                            Image(systemName: "line.diagonal.arrow")
                                .font(.title3)
                                .rotationEffect(.init(degrees: 45))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 25)
                        .padding(.vertical)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.black.opacity(0.05))
                        }
                    }
                    .padding(.top, 30)
                }
                    
                
                Button("Reset Password?", action:resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.cgBlue)
                    .hAlign(.trailing)
                
                Button(action: loginUser) {
                    //MARK: Login Button
                    Text("Sign in")
                        .foregroundColor(colorScheme == .light ? Color.white : Color.platinum)
                        .hAlign(.center)
                        .fillView(.oxfordBlue)
                }
                .padding(.top,10)
            
            //MARK: Apple Sign In
            SignInWithAppleButton { (request) in
                loginData.nonce = randomNonceString()
                request.requestedScopes = [.email, .fullName]
                request.nonce = sha256(loginData.nonce)
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
            .signInWithAppleButtonStyle(.white)
            .frame(height:55)
            .clipShape(Capsule())
            .padding(.horizontal, 40)
            .offset(y: -70)
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
//        .alert(loginModel.errorMessage, isPresented: $loginModel.showError) {
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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


