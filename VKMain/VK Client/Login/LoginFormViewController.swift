import UIKit

class LoginFormViewController: UIViewController {
    let fadingCircleView = FadingCircleView()
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnScroll))
        scrollView?.addGestureRecognizer(tapGesture)
        scrollView.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        configure()
        configureFadingCircleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    private func configure() {
    }
    
    private func configureFadingCircleView() {
        view.addSubview(fadingCircleView)
        
        NSLayoutConstraint.activate([
            fadingCircleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fadingCircleView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            fadingCircleView.heightAnchor.constraint(equalToConstant: 40),
            fadingCircleView.widthAnchor.constraint(equalToConstant: 150)])
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let kbSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.size.height, right: 0)
        scrollView.contentInset = insets
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        let insets = UIEdgeInsets.zero
        scrollView.contentInset = insets
    }
    
    @objc func didTapOnScroll() {
        self.scrollView?.endEditing(true)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        fadingCircleView.animate()
    }
}
