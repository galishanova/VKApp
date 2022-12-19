import UIKit

class MyFriendsCell: UITableViewCell {
    
    
    @IBOutlet weak var friendName: UILabel!

    @IBOutlet weak var onlineStatus: UIImageView!
    
    @IBOutlet weak var friendCity: UILabel!
    
    @IBOutlet  var friendPhotoProfile: UIImageView!
    
    @IBOutlet weak var containerFriendPhoto: UIView!
    
    let instets: CGFloat = 10.0


    static let identifier = "MyFriendsCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "MyFriendsCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        friendName.text = ""
        friendPhotoProfile.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        containerFriendPhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animate)))        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        containerFriendPhoto.clipsToBounds = false
        containerFriendPhoto.layer.shadowColor = UIColor.vkColor.blackColor.cgColor
        containerFriendPhoto.layer.shadowOpacity = 0.5
        containerFriendPhoto.layer.shadowOffset = CGSize.zero
        containerFriendPhoto.layer.shadowRadius = 8
        containerFriendPhoto.layer.shadowPath = UIBezierPath(roundedRect: containerFriendPhoto.bounds, cornerRadius: 10).cgPath
        containerFriendPhoto.layer.cornerRadius = containerFriendPhoto.frame.width / 2

        friendPhotoProfile.clipsToBounds = true
        friendPhotoProfile.layer.cornerRadius = friendPhotoProfile.frame.width / 2

        containerFriendPhoto.addSubview(friendPhotoProfile)
        containerFriendPhoto.addSubview(onlineStatus)
        onlineStatus.layer.shadowColor = UIColor.vkColor.grayColor.cgColor
        onlineStatus.layer.shadowOpacity = 0.5
        onlineStatus.layer.shadowOffset = CGSize.zero
        onlineStatus.layer.shadowRadius = 10
        onlineStatus.layer.shadowPath = UIBezierPath(roundedRect: containerFriendPhoto.bounds, cornerRadius: 10).cgPath
        onlineStatus.layer.cornerRadius = onlineStatus.frame.width / 2

    }

    
    @objc func animate(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            self.containerFriendPhoto.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)

        }) { (_) in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                self.containerFriendPhoto.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
        }
    
    func downLoadImage(from stringURL: String) {
        guard let url = URL(string: stringURL) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let data = data {
                let uiImage = UIImage(data: data)
                DispatchQueue.main.async {
                    self?.friendPhotoProfile.image = uiImage
                }
            }
        }.resume()
    }
    


}
