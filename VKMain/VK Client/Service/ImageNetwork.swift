import UIKit

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data) -> ()) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                completion(data)
            }
        }
    }
}
class ImageNetwork {
    var nonePhoto = "https://vk.com/images/camera_100.png"
    
}

