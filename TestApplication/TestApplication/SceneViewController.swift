import UIKit
import os.log

class SceneViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var hTViewYourName: UILabel!
    @IBOutlet weak var hTFieldNameInput: UITextField!
    @IBOutlet weak var hImagePhotoSelect: UIImageView!
    @IBOutlet weak var hRatingSelector: RatingControl!
    @IBOutlet weak var hNavSaveButton: UIBarButtonItem!
    var item: Item? = nil
    var isEdit: Bool = false

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === self.hNavSaveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }

        let name = self.hTFieldNameInput.text ?? ""
        let photo = self.hImagePhotoSelect.image
        let rating = self.hRatingSelector.rating
        self.item = Item(n: name, photo: photo, rating: rating)
    }
    
    @IBAction func acTapGesOnImage(_ sender: UITapGestureRecognizer) {
        // Try to hide the keyboard which is activated by the input.
        self.hTFieldNameInput.resignFirstResponder()
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func acBarCancel(_ sender: UIBarButtonItem) {
        if self.isEdit {
            if let owningNavigationController = self.navigationController {
                owningNavigationController.popViewController(animated: true)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hNavSaveButton.isEnabled = false
        self.hTFieldNameInput.delegate = self
        if let item = self.item {
            if let image = item.photo {
                self.hImagePhotoSelect.image = image
            }
            self.hTFieldNameInput.text = item.name
            self.hRatingSelector.rating = item.rating
            self.textFieldDidEndEditing(self.hTFieldNameInput)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.hTViewYourName.text = "Scene Name : \(self.hTFieldNameInput.text!)"
        if let txt = self.hTFieldNameInput.text, !txt.isEmpty {
            self.hNavSaveButton.isEnabled = true
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        self.hImagePhotoSelect.image = selectedImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
