import UIKit

class ColorfulButton : UIButton {
    var isPrimary: Bool = false

    override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                if self.isPrimary {
                    self.backgroundColor = ColorCollection.EnabledPrimaryButtonBackgroundColor
                } else {

                }
            } else {
                self.backgroundColor = ColorCollection.DisabledButtonBackgroundColor
            }
        }
    }
}
