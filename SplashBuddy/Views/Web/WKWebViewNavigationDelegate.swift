//
//  Copyright © 2018 Amaris Technologies GmbH. All rights reserved.
//

import Cocoa
import WebKit

extension MainViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Log.write(string: error.localizedDescription, cat: "WebView", level: .error)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url

        if url?.description.range(of: "formdone://") != nil {
            Log.write(string: "Enter key pressed, attempting to run formEnterKey function.", cat: "UserInput", level: .debug)
            decisionHandler(.cancel)
            self.formEnterKey()
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
}
