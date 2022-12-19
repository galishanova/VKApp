import UIKit
import WebKit

class VKLoginViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            webView.navigationDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.vk.com"
        components.path = "/authorize"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: "7812244"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"), //переход на страницу после авторизации
            URLQueryItem(name: "display", value: "mobile"), //авторизация для моб устройств
            URLQueryItem(name: "scope", value: "270342"), //битовая маска: друзья, группы, фотографии, стена,
//            URLQueryItem(name: "scope", value: "offline"), //срок действия токена
            URLQueryItem(name: "response_type", value: "token"),//тип ответа кот необх получить
            URLQueryItem(name: "v", value: "5.92") //версия апи
        ]
    
        guard let url = components.url else { return }
        let request = URLRequest(url: url)
        webView.load(request)

    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
extension VKLoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url,
              url.path == "/blank.html",
              let fragment = url.fragment else {
            decisionHandler(.allow)
            return
        }
        
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                
                return dict
            }
        
        print(params)
        
        guard let token = params["access_token"],
              let userIdString = params["user_id"],
              let _ = Int(userIdString) else {
            decisionHandler(.allow)
            return
        }
        
        Session.network.token = token
        Session.network.userID = Int(userIdString) ?? 0

        performSegue(withIdentifier: "toMainTabBar", sender: self)
        decisionHandler(.cancel)
        
    }
}
