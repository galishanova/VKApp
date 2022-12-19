import UIKit

class FullPhotoViewController: UIViewController {

    @IBOutlet weak var zoomedUserPhoto: UIImageView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var likePhotoButton: UIButton!
    @IBOutlet weak var likePhotoLabel: UILabel!
    @IBOutlet weak var commentPhotoLabel: UILabel!
    @IBOutlet weak var showCommentPhotoButton: UIButton!
    
    var likesCount = Int()
    var commentCount = Int()
    
    var currentIndex: Int = 0
    var userId = Int()
    var photos: [UserPhotos]? = []
    var animator: UIViewPropertyAnimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setDataInContainer()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        let currentPhoto = photos?[currentIndex]
        if let url = currentPhoto?.sizes.last?.url {
            zoomedUserPhoto.load(url: URL(string: url)!)
        }
        zoomedUserPhoto.isUserInteractionEnabled = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(close))
        self.view.addGestureRecognizer(pan)
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    @IBAction func btnLikeClick(_ sender: UIButton) {
        if likePhotoButton.tag == 0 {
            likePhotoButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likePhotoButton.tintColor = .red
            likePhotoButton.tag = 1
            
            setDataInContainer()
        }
        else {
            likePhotoButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likePhotoButton.tintColor = .lightGray
            likePhotoButton.tag = 0
        }
    }
    
    func setDataInContainer () {
        likesCount = (photos?[self.currentIndex].likes ?? 0)
    
        commentCount = (photos?[self.currentIndex].comments ?? 0)
        likePhotoLabel.text = "\(String(describing: likesCount))"
        commentPhotoLabel.text = "\(commentCount)"
    }
    
    private func changeImage(direction: Direction) {
        switch direction {
        case .next:
            if self.currentIndex < self.photos?.count ?? 0 - 1 {
                zoomedUserPhoto.getData(from: URL(string: photos?[currentIndex + 1].sizes.last?.url
                                                    ?? photos?[currentIndex + 1].sizes.last?.url as! String)!) { [weak self] (data) in
                    let imageFromData = UIImage(data: data)
                    
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.animateTransition(view: self.zoomedUserPhoto, toImage: imageFromData!, direction: direction)
                        
                    }
                }
                
            }
            self.currentIndex += 1
            setDataInContainer()
            
        case .previous:
            if currentIndex > 0 {
                zoomedUserPhoto.getData(from: URL(string: photos?[currentIndex - 1].sizes.last?.url
                                                    ?? photos?[currentIndex - 1].sizes.last?.url as! String)!) { [weak self] (data) in
                    let imageFromData = UIImage(data: data)
                    
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.animateTransition(view: self.zoomedUserPhoto, toImage: imageFromData!, direction: direction)
                    }
                }
                self.currentIndex -= 1
                setDataInContainer()
            }
        }
        
    }
    
    private enum Direction {
        case next, previous
    }
    
    private func animateTransition(view: UIImageView, toImage: UIImage, direction: Direction) {
        
        view.image = toImage
        
        var translation = CGAffineTransform()
        var scale = CGAffineTransform()
        switch direction {
        case .next:
            translation = CGAffineTransform(translationX: view.frame.width, y: 0)
            scale = CGAffineTransform(scaleX: 0.4, y: 0.4)
        case .previous:
            translation = CGAffineTransform(translationX: -view.frame.width, y: 0)
            scale = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }
        
        let concatenatedTransform = scale.concatenating(translation)
        view.transform = concatenatedTransform
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        view.transform = .identity
                       },
                       completion: nil)
        
    }
    

    
    @objc func close(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        
        if abs(translation.y) > abs(translation.x) {
            switch recognizer.state {
            case .began:
                animator = UIViewPropertyAnimator(duration: 1, curve: .easeIn, animations: {
                    if translation.y > 0 {
                        self.zoomedUserPhoto.transform = CGAffineTransform(translationX: 0, y: self.zoomedUserPhoto.frame.height)
                        
                    } else if translation.y < 0 {
                        self.zoomedUserPhoto.transform = CGAffineTransform(translationX: 0, y: -self.zoomedUserPhoto.frame.height)
                    }
                })
                animator?.startAnimation()
            case .changed:
                animator.fractionComplete = abs(translation.y / 100)
            case .ended:
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                navigationController?.popViewController(animated: false)
            default:
                break
            }
        }
        
        switch recognizer.state {
        case .began:
            animator = UIViewPropertyAnimator(duration: 1, curve: .easeIn, animations: {
                if translation.x > 0 && self.currentIndex > 0 {
                    self.zoomedUserPhoto.transform = CGAffineTransform(translationX: self.zoomedUserPhoto.frame.width, y: 0)
                } else if translation.x < 0  && self.currentIndex < self.photos?.count ?? 0 - 1 {
                    self.zoomedUserPhoto.transform = CGAffineTransform(translationX: -self.zoomedUserPhoto.frame.width, y: 0)
                }
            })
            
            animator?.startAnimation()
        case .changed:
            animator.fractionComplete = abs(translation.x / 100)
        case .ended:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            if translation.x > 0 {
                changeImage(direction: .previous)
            } else {
                changeImage(direction: .next)
            }
        default:
            break
        }
    }
    
    


    
}
