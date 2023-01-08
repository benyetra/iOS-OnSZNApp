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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss

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
                
                HStack(spacing: 20){
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 25)
                        .padding(.vertical)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.black.opacity(0.05))
                        }
                    }
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
                }
                .padding(.top, 30)
                .font(.callout)
                .vAlign(.bottom)
            }.alert(loginModel.errorMessage, isPresented: $loginModel.showError) {
            }
        }
        .vAlign(.top)
        .padding(15)
    }
}

struct PhoneLoginView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneLoginView()
    }
}
