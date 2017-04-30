import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    @IBOutlet weak var imageTake: UIImageView!
    var imagePicker: UIImagePickerController!
    let session = URLSession.shared
    var googleAPIKey = "NOT_THE_API_KEY_YOU'RE_LOOKING_FOR"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Capture image
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
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        // Reduce image size b/c Google has a small limit
        let smallerImage = image?.resized(withPercentage: 0.1)
        
        print("Got Image ***" + smallerImage.debugDescription)
        let imageData:NSData = UIImagePNGRepresentation(smallerImage!)! as NSData
        let strBase64 = imageData.base64EncodedString()
        
        // Extract text using Google Vision
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": strBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ],
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 100000
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
         print("Calling Google Vision...")
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
    }
    
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
            let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            self.analyzeResults(data)
        }
        
        task.resume()
    }
    
    // Parse response from Google Vision
    func analyzeResults(_ dataToParse: Data) {
        print("analyzeResults")
        
        do {
            let json = try JSON(data: dataToParse)
            print(json)

        } catch {
            print(error)
        }
        
    }
    
}

// Helper to reduce size of the taken image to meet Google's size limitation
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
