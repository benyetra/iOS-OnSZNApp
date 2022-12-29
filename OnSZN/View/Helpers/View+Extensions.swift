//
//  View+Extensions.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

//MARK: View Extensions for UI Building
extension View{
    //MARK: Closing ALl Active Keyboards
    func closeKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    //MARK: Disabling with Opacity
    func disableWithOpacity(_ condition: Bool)-> some View{
        self.disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
    
    func hAlign(_ alignment: Alignment)-> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment)-> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    //MARK: Cusstom Border with View Padding
    func border(_ width: CGFloat,_ color: Color)-> some View {
        self
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    //MARK: Custom Fill with View Padding
    func fillView(_ color: Color)-> some View {
        self
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
}
