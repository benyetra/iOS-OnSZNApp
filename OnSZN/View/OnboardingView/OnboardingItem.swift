//
//  OnboardingItem.swift
//  OnSZN
//
//  Created by Bennett Yetra on 1/11/23.
//

import SwiftUI
import Lottie
 
//MARK: Onboarding Item Model
struct OnboardingItem: Identifiable, Equatable {
    var id: UUID = .init()
    var title: String
    var subTitle: String
    var lottieView: LottieAnimationView = .init()
}
