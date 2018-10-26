/*
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
