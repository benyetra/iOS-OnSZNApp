//
//  PhoneLoginView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 1/7/23.
//

import SwiftUI

struct PhoneLoginView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    @StateObject var loginModel: LoginViewModel = .init()

    var body: some View {
        
        VStack(spacing:12){
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
        .alert(loginModel.errorMessage, isPresented: $loginModel.showError) {
        }
    }
}

struct PhoneLoginView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneLoginView()
    }
}
