//
//  CustomTextField.swift
//  OnSZN
//
//  Created by Bennett Yetra on 1/7/23.
//

import SwiftUI

struct CustomTextField: View {
    var hint: String
    @Binding var text: String
    @Environment(\.colorScheme) private var colorScheme
    
    @FocusState var isEnabled: Bool
    var contentType: UITextContentType = .telephoneNumber
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField(hint, text: $text)
                .keyboardType(.numberPad)
                .textContentType(contentType)
                .focused($isEnabled)
                .foregroundColor(colorScheme == .light ? Color.gray : Color.platinum)
                .textContentType(.telephoneNumber)
                .border(1, colorScheme == .light ? Color.cgBlue : Color.platinum.opacity(0.5))
                .padding(.top, 25)
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.black.opacity(0.2))
               
                Rectangle()
                    .fill(.black)
                    .frame(width: isEnabled ? nil :0, alignment: .leading)
                    .animation(.easeInOut(duration: 0.3), value: isEnabled)
            }
            .frame(height:2)
        }
    }
}
