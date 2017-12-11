import UIKit

class SceneViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var hTViewYourName: UILabel!
    @IBOutlet weak var hTFieldNameInput: UITextField!
    @IBOutlet weak var hImagePhotoSelect: UIImageView!
    @IBOutlet weak var hRatingSelector: RatingControl!
    
    @IBAction func acTapGesOnImage(_ sender: UITapGestureRecognizer) {
        // Try to hide the keyboard which is activated by the input.
        self.hTFieldNameInput.resignFirstResponder()
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hTFieldNameInput.delegate = self
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
        self.hTViewYourName.text = "Your Name : \(self.hTFieldNameInput.text!)"
        self.hTFieldNameInput.text = ""
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
