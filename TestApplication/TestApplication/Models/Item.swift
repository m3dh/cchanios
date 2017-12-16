import UIKit
import os.log

class Item: NSObject, NSCoding {

    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
    }

    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("scene_items")


    init?(n: String, photo: UIImage?, rating: Int) {
        if n.isEmpty {
            return nil
        }

        self.name = n
        self.photo = photo
        self.rating = rating
    }

    static func saveItemList(list: [Item]) {
        if NSKeyedArchiver.archiveRootObject(list, toFile: ArchiveURL.path) {
            os_log("list save succeeded", log: .default, type: .debug)
        } else {
            os_log("list save failed", log: .default, type: .error)
        }
    }

    static func loadItemList() -> [Item]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? [Item]
    }

    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        // Encode the properties in.
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        // Decode the properties out.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            return nil
        }

        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage

        self.init(n: name, photo: photo, rating: rating)
    }
}
