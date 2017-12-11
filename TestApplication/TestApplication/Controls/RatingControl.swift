import UIKit

@IBDesignable
class RatingControl: UIStackView {
    
    private var ratingButtons = [UIButton]()
    var rating = 0 {
        didSet {
            for (idx, button) in self.ratingButtons.enumerated() {
                button.isSelected = idx < rating
            }
        }
    }
    
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            self.setupButtons()
        }
    }

    @IBInspectable var starCount: Int = 5 {
        didSet {
            self.setupButtons()
        }
    }

    var setAllowed: Bool = true

    // initialize from view hierarchy
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.setupButtons()
    }
    
    // initialize programmatically
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupButtons()
    }

    private func setupButtons() {
        if self.ratingButtons.count > 0 {
            for b in self.ratingButtons {
                b.removeFromSuperview()
                self.removeArrangedSubview(b)
            }
            
            self.ratingButtons.removeAll()
        }
        
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "Filled", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named:"Empty", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named:"Highlight", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0..<self.starCount {
            let button = UIButton()
            button.backgroundColor = .red
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: self.starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: self.starSize.width).isActive = true
            button.setImage(emptyStar, for: .normal)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected]) // highlighted & selected
            button.setImage(filledStar, for: .selected)
            
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped), for: .touchUpInside)

            self.ratingButtons.append(button)
            self.addArrangedSubview(button)
        }
    }
    
    @objc func ratingButtonTapped(_ button: UIButton, _ event: UIEvent) {
        if let index = self.ratingButtons.index(of: button) {
            if self.setAllowed {
                self.rating = index + 1
            }
        }
    }
}
