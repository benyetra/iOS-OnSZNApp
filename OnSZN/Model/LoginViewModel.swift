//
//  LoginViewModel.swift
//  OnSZN
//
//  Created by Bennett Yetra on 1/7/23.
//

import SwiftUI
import Firebase
import CryptoKit
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

class LoginViewModel: ObservableObject {
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    //MARK: Error Properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var nonce: String = ""
    @AppStorage("log_status") var logStatus: Bool = false
    
    func authenticate(credential: ASAuthorizationAppleIDCredential) {
        guard let token = credential.identityToken else {
            print("error with firebase")
            return
        }
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("error with token")
            return
        }
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        Auth.auth().signIn(with: firebaseCredential) { (result, err) in
            if let error = err {
                print(error.localizedDescription)
                return
            }
            print("Logged In Succesfully")
            withAnimation(.easeInOut) {
                self.logStatus = true
            }
        }
    }
    
    //MARK: Firebase APIs
    func getOTPCode() {
        UIApplication.shared.closeKeyboard()
        Task {
            do {
                //MARK: Disable it when testing with a real device
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                let code = try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(mobileNo)", uiDelegate: nil)
                await MainActor.run(body: {
                    CLIENT_CODE = code
                    //MARK: Enabling OTP Field when its a success
                    withAnimation(.easeInOut){showOTPField = true}
                })
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func verifyOTPCode() {
        UIApplication.shared.closeKeyboard()
        Task {
            do {
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_CODE, verificationCode: otpCode)
                
                try await Auth.auth().signIn(with: credential)
                print("Success!")
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func logGoogleUser(user: GIDSignInResult) {
        Task {
            do {
                guard let idToken = user.user.idToken else {return}
                let accessToken = user.user.accessToken
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                
                try await Auth.auth().signIn(with:credential)
                print("Success Google!")
                
                await MainActor.run(body: {
                    withAnimation(.easeInOut){logStatus = true}
                })
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    //MARK: Handle Error
    func handleError(error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
    //MARK: Helpers for Apple Sign in with Firebase
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func rootController()->UIViewController {
        guard let window = connectedScenes.first as? UIWindowScene else {return .init()}
        guard let viewController = window.windows.last?.rootViewController else {return .init()}
        return viewController
    }
}
