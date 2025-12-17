import SwiftUI
import Combine
import WebKit

struct MisterChickenPlayfield: UIViewRepresentable {
    let entryPoint: URL
    let realm: MisterChickenRealm
    let orientation: CoopOrientationManager
    let onReady: () -> Void

    func makeCoordinator() -> Keeper {
        Keeper(
            entryPoint: entryPoint,
            realm: realm,
            orientation: orientation,
            onReady: onReady
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)

        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator

        view.allowsBackForwardNavigationGestures = true
        view.scrollView.bounces = true
        view.scrollView.showsVerticalScrollIndicator = false
        view.scrollView.showsHorizontalScrollIndicator = false
        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.backgroundColor = .black

        let refresh = UIRefreshControl()
        refresh.addTarget(
            context.coordinator,
            action: #selector(Keeper.handleRefresh(_:)),
            for: .valueChanged
        )
        view.scrollView.refreshControl = refresh

        context.coordinator.attach(view)
        context.coordinator.begin()

        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) { }

    final class Keeper: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let entryPoint: URL
        private let realm: MisterChickenRealm
        private let orientation: CoopOrientationManager
        private let onReady: () -> Void

        weak var mainView: WKWebView?
        weak var popupView: WKWebView?

        private var baseHost: String?
        private var marksTimer: Timer?

        private var didScheduleSave = false

        init(entryPoint: URL,
             realm: MisterChickenRealm,
             orientation: CoopOrientationManager,
             onReady: @escaping () -> Void) {
            self.entryPoint = entryPoint
            self.realm = realm
            self.orientation = orientation
            self.onReady = onReady
            self.baseHost = realm.entryPoint.host?.lowercased()
        }

        func attach(_ view: WKWebView) {
            mainView = view
        }

        func begin() {
            orientation.setActiveValue(entryPoint)
            mainView?.load(URLRequest(url: entryPoint))
        }

        @objc func handleRefresh(_ sender: UIRefreshControl) {
            mainView?.reload()
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            if webView === popupView {
                if let main = mainView,
                   let next = navigationAction.request.url {
                    orientation.setActiveValue(next)
                    main.load(URLRequest(url: next))
                }
                decisionHandler(.cancel)
                return
            }

            guard let next = navigationAction.request.url,
                  let proto = next.scheme?.lowercased()
            else {
                decisionHandler(.cancel)
                return
            }

            orientation.setActiveValue(next)

            let allowed = proto == "http" || proto == "https" || proto == "about"
            guard allowed else {
                decisionHandler(.cancel)
                return
            }

            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView,
                     didStartProvisionalNavigation navigation: WKNavigation!) {
            stopMarksJob()
            orientation.setActiveValue(webView.url)
        }

        func webView(_ webView: WKWebView,
                     didFinish navigation: WKNavigation!) {
            handleFinish(in: webView)
        }

        func webView(_ webView: WKWebView,
                     didFail navigation: WKNavigation!,
                     withError error: Error) {
            handleFailure(in: webView)
        }

        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {
            handleFailure(in: webView)
        }

        private func handleFinish(in view: WKWebView) {
            onReady()
            view.scrollView.refreshControl?.endRefreshing()

            scheduleSaveIfNeeded()

            guard let current = view.url else {
                orientation.setActiveValue(nil)
                stopMarksJob()
                return
            }

            orientation.setActiveValue(current)

            let nowHost = current.host?.lowercased()
            let isBase: Bool
            if let base = baseHost, let now = nowHost, now == base {
                isBase = true
            } else {
                isBase = false
            }

            if isBase {
                stopMarksJob()
            } else {
                runMarksJob(for: current, in: view)
            }
        }

        private func handleFailure(in view: WKWebView) {
            onReady()
            view.scrollView.refreshControl?.endRefreshing()
            orientation.setActiveValue(view.url)
            stopMarksJob()
        }

        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {

            let popup = WKWebView(frame: .zero, configuration: configuration)
            popup.navigationDelegate = self
            popup.uiDelegate = self
            popupView = popup
            return popup
        }

        private func scheduleSaveIfNeeded() {
            guard didScheduleSave == false else { return }
            didScheduleSave = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                guard let self else { return }
                guard let active = self.mainView?.url else { return }

                let base = self.realm.entryPoint.absoluteString
                let now = active.absoluteString
                guard now != base else { return }

                self.realm.saveIfNeeded(active)
            }
        }

        private func runMarksJob(for value: URL, in board: WKWebView) {
            stopMarksJob()

            let mask = (value.host ?? "").lowercased()

            marksTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) {
                [weak board, weak realm] _ in
                guard let view = board, let store = realm else { return }

                view.configuration.websiteDataStore.httpCookieStore.getAllCookies { list in
                    let filtered = list.filter { cookie in
                        guard !mask.isEmpty else { return true }
                        return cookie.domain.lowercased().contains(mask)
                    }

                    let packed: [[String: Any]] = filtered.map { c in
                        var map: [String: Any] = [
                            "name": c.name,
                            "value": c.value,
                            "domain": c.domain,
                            "path": c.path,
                            "secure": c.isSecure,
                            "httpOnly": c.isHTTPOnly
                        ]
                        if let exp = c.expiresDate {
                            map["expires"] = exp.timeIntervalSince1970
                        }
                        if #available(iOS 13.0, *), let s = c.sameSitePolicy {
                            map["sameSite"] = s.rawValue
                        }
                        return map
                    }

                    store.saveMarks(packed)
                }
            }

            if let job = marksTimer {
                RunLoop.main.add(job, forMode: .common)
            }
        }

        private func stopMarksJob() {
            marksTimer?.invalidate()
            marksTimer = nil
        }
    }
}
