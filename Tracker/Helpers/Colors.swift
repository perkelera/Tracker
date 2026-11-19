import Foundation
import UIKit

final class Colors {
    var viewBackgroundColor: UIColor = UIColor { (traits) -> UIColor in
        let isDarkMode = traits.userInterfaceStyle == .dark
        return isDarkMode ? UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0) : .white
    }

    var primaryTextColor: UIColor = UIColor { (traits) -> UIColor in
        let isDarkMode = traits.userInterfaceStyle == .dark
        return isDarkMode ? .white : UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
    }

    var secondaryBackgroundColor: UIColor = UIColor { (traits) -> UIColor in
        let isDarkMode = traits.userInterfaceStyle == .dark
        return isDarkMode
            ? UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 0.85)
            : UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.30)
    }

    var tabBarSeparatorColor: UIColor = UIColor { (traits) -> UIColor in
        let isDarkMode = traits.userInterfaceStyle == .dark
        return isDarkMode ? .black : UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    var buttonBackgroundColor: UIColor = UIColor { (traits) -> UIColor in
        traits.userInterfaceStyle == .dark ? .white : UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
    }

    var buttonTextColor: UIColor = UIColor { (traits) -> UIColor in
        traits.userInterfaceStyle == .dark ? UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0) : .white
    }
}
