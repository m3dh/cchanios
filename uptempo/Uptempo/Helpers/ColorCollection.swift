import UIKit

class ColorCollection {
    static let White = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    static let Black = UIColor(red: 71/255.0, green: 74/255.0, blue: 82/255.0, alpha: 1)
    static let Cyan = UIColor(red: 126/255.0, green: 188/255.0, blue: 202/255.0, alpha: 1)
    static let LightCyan = UIColor(red: 232/255.0, green: 245/255.0, blue: 249/255.0, alpha: 1)
    static let LightBlue = UIColor(red: 147/255.0, green: 153/255.0, blue: 176/255.0, alpha: 1)
    static let LightGrey = UIColor(red: 182/255.0, green: 189/255.0, blue: 189/255.0, alpha: 1)

    static let NavigationBarBackgroundColor = White
    static let NavigationBarTextColor = Black
    static let NavigationBarUnselectedTextColor = LightBlue
    static let NavigationItemTintColor = Cyan

    static let DisabledButtonBackgroundColor = UIColor.lightGray
    static let EnabledPrimaryButtonBackgroundColor = UIColor(red: 101/255.0, green: 197/255.0, blue: 104/255.0, alpha: 1)
    static let EnabledSecondaryButtonBackgroundColor = UIColor(red: 103/255.0, green: 111/255.0, blue: 135/255.0, alpha: 1)

    static let TextfieldDefaultTintColor = UIColor(white: 0.9, alpha: 1)

    // Group avatar has a, while normal users are in light blue
    static let UserAvatarBorder0 =  UIColor(red: 222/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)

    static let TableViewTimestamp = LightBlue

    // Chat view colors...
    static let ChatViewBackground0 = White

    static let ChatElementViewBackground = LightCyan
    static let ChatSentMessageBackground = UIColor(red: 215/255.0, green: 238/255.0, blue: 241/255.0, alpha: 1)
}
