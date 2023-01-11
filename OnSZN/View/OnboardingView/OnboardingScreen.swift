//
//  OnboardingScreen.swift
//  OnSZN
//
//  Created by Bennett Yetra on 1/11/23.
//

import SwiftUI
import Lottie

struct OnboardingScreen: View {
    @State var onboardingItems: [OnboardingItem] = [
        .init(title: "Request Username",
             subTitle: "To be able to discuss hot NBA topics with friends and other users in the NBA space we need a proper username to give you!",
              lottieView: .init(name: "Username", bundle: .main)),
        .init(title: "Add a Profile Pic",
             subTitle: "Add a face to your name to help you stand out in the conversation.",
              lottieView: .init(name: "Profile Pic", bundle: .main)),
        .init(title: "Add Some Character",
             subTitle: "To help you show who you are best, add a bio, your website, and select your favorite NBA team!",
              lottieView: .init(name: "Bio", bundle: .main))]
    @State var currentIndex: Int = 0
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            HStack(spacing: 0) {
                ForEach($onboardingItems) { $item in
                    let isLastSlide = ( currentIndex == onboardingItems.count - 1)
                    VStack {
                        //MARK: Top Nav Bar
                        HStack {
                            Button("Back") {
                                if currentIndex > 0 {
                                    currentIndex -= 1
                                    playAnimation()
                                }
                                
                            }
                            .opacity(currentIndex > 0 ? 1 : 0)
                            
                            Spacer(minLength: 0)
                            
                            Button("Skip") {
                                currentIndex = onboardingItems.count - 1
                                playAnimation()
                            }
                            .opacity(isLastSlide ? 0 : 1)
                        }
                        .animation(.easeInOut, value: currentIndex)
                        .tint(Color.oxfordBlue)
                        .fontWeight(.bold)
                        
                        //MARK: Moveable Slides
                        VStack(spacing: 15) {
                            let offset = -CGFloat(currentIndex) * size.width
                            //MARK: Resizeable Lottie View
                            ResizeableLottieView(onboardingItem: $item)
                                .frame(height: size.width)
                                .onAppear {
                                    //MARK: Initially playing first slide animation
                                    if currentIndex == indexOf(item) {
                                        item.lottieView.play(toProgress: 0.7)
                                    }
                                }
                                .offset(x: offset)
                                .animation(.easeInOut(duration: 0.5), value: currentIndex)
                            Text(item.title)
                                .font(.title.bold())
                                .offset(x: offset)
                                .animation(.easeInOut(duration: 0.5).delay(0.1), value: currentIndex)
                            Text(item.subTitle)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 15)
                                .foregroundColor(.gray)
                                .offset(x: offset)
                                .animation(.easeInOut(duration: 0.5).delay(0.2), value: currentIndex)
                        }
                        Spacer(minLength: 0)
                        //MARK: Next / Login Button
                        VStack(spacing: 15) {
                            Text(isLastSlide ? "Register" : "Next")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.vertical, isLastSlide ? 13 : 12)
                                .frame(maxWidth: .infinity)
                                .background {
                                    Capsule()
                                        .fill(Color.oxfordBlue)
                                }
                                .padding(.horizontal, isLastSlide ? 30 : 100)
                                .onTapGesture {
                                    //MARK: Updating to next index
                                    if currentIndex < onboardingItems.count - 1 {
                                        let currentProgress = onboardingItems[currentIndex].lottieView.currentProgress
                                        onboardingItems[currentIndex].lottieView.currentProgress = (currentProgress == 0 ? 0.7 : currentProgress)
                                        currentIndex += 1
                                        playAnimation()
                                    }
                                }
                            
                            HStack {
                                Text("Terms of Service")
                                Text("Privacy Policy")
                            }
                            .font(.caption2)
                            .underline(true, color: .primary)
                            .offset(y: 5)
                        }
                    }
                    .animation(.easeInOut, value: isLastSlide)
                    .padding(15)
                    .frame(width: size.width, height: size.height)
                }
            }
            .frame(width: size.width * CGFloat(onboardingItems.count), alignment: .leading)
        }
    }
    func playAnimation() {
        onboardingItems[currentIndex].lottieView.currentProgress = 0
        onboardingItems[currentIndex].lottieView.play(toProgress: 0.7)
    }
    
    func indexOf(_ item: OnboardingItem)-> Int {
        if let index = onboardingItems.firstIndex(of: item) {
            return index
        }
        return 0
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen()
    }
}

//MARK: Resizeable Lottie View Without Background
struct ResizeableLottieView: UIViewRepresentable {
    @Binding var onboardingItem: OnboardingItem
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        setupLottieView(view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
            
    }
    
    func setupLottieView(_ to: UIView) {
        let lottieView = onboardingItem.lottieView
        lottieView.backgroundColor = .clear
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Applying Constraints
        let constraints = [
            lottieView.widthAnchor.constraint(equalTo: to.widthAnchor),
            lottieView.heightAnchor.constraint(equalTo: to.heightAnchor),
        ]
        to.addSubview(lottieView)
        to.addConstraints(constraints)
    }
}
