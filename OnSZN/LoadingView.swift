//
//  LoadingView.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/28/22.
//

import SwiftUI

struct LoadingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var show: Bool
    var body: some View {
        ZStack {
            if show {
                Group {
                    Rectangle()
                        .fill(colorScheme == .light ? Color.oxfordBlue.opacity(0.25) : Color.platinum.opacity(0.25))
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .padding(15)
                        .background(colorScheme == .light ? Color.platinum : Color.oxfordBlue,in:RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: show)
    }
}
