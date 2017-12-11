import UIKit

class Item {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int

    init?(n: String, photo: UIImage?, rating: Int) {
        if n.isEmpty {
            return nil
        }

        self.name = n
        self.photo = photo
        self.rating = rating
    }
}
