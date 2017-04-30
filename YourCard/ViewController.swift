import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    @IBOutlet weak var imageTake: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Take image
    @IBAction func takePhoto(_ sender: UIButton) {
        print("takePhoto")
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    // Process image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("imagePickerController")
        imagePicker.dismiss(animated: true, completion: nil)
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        print("Got Image ***" + pickedImage.debugDescription)
        let imageData:NSData = UIImagePNGRepresentation(pickedImage!)! as NSData
        let strBase64 = imageData.base64EncodedString()
    }
    
}
