//
//  CustomColors.swift
//  OnSZN
//
//  Created by Bennett Yetra on 12/29/22.
//

import SwiftUI


struct ColorView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
        }
        .background(Color.platinum)
        .padding(15)
        VStack {
            Color.cgBlue
        }
        .background(Color.customSecondaryColor)
        .padding(15)
        ZStack {
            Color.customTertiaryColor
            VStack {
                Text("Hello, World!")
            }
        }
    }
}

func hexStringToUIColor (hex:String, alpha: CGFloat) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: alpha
    )
}


extension Color {
    static let customPrimaryColor = Color(UIColor(red: 0.16, green: 0.38, blue: 0.54, alpha: 1.0))
    static let customSecondaryColor = Color(UIColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 1.0))
    static let customTertiaryColor = Color(UIColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 1.0))
    static let platinum = Color(hexStringToUIColor(hex: "#dce0d9", alpha: 1.0))
    static let bigDipOruby = Color(hexStringToUIColor(hex: "#9c0d38", alpha: 1.0))
    static let oxfordBlue = Color(hexStringToUIColor(hex: "#03254e", alpha: 1.0))
    static let cgBlue = Color(hexStringToUIColor(hex: "#247ba0", alpha: 1.0))
    static let vividBurgundy = Color(hexStringToUIColor(hex: "#a3333d", alpha: 1.0))
}

struct CustomColors_Previews: PreviewProvider {
    static var previews: some View {
        ColorView()
    }
}
