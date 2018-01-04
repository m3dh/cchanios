import UIKit

class UnderlineTextField : UITextField {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.borderStyle = .none
        self.tintColor = ColorCollection.TextfieldDefaultTintColor
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.borderStyle = .none
        self.tintColor = ColorCollection.TextfieldDefaultTintColor
    }

    override var tintColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let startingPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let endingPoint = CGPoint(x: rect.maxX, y: rect.maxY)
        let path = UIBezierPath()

        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        path.lineWidth = 2.0
        tintColor.setStroke()
        path.stroke()
    }
}
