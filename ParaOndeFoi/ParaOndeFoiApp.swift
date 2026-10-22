import SwiftUI
import WebKit

@main
struct ParaOndeFoiApp: App {
    var body: some Scene {
        WindowGroup {
            AppWebView()
                .ignoresSafeArea()
                .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

struct AppWebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()   // mantém o localStorage salvo entre aberturas
        config.userContentController.add(context.coordinator, name: "share")   // botão Salvar backup
        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = .systemGroupedBackground
        web.scrollView.backgroundColor = .systemGroupedBackground
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.allowsLinkPreview = false
        web.navigationDelegate = context.coordinator
        web.uiDelegate = context.coordinator
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        // Recebe o backup do app e abre a folha de compartilhar (Salvar em Arquivos, AirDrop...)
        func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "share",
                  let body = message.body as? [String: Any],
                  let name = body["name"] as? String,
                  let text = body["text"] as? String else { return }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            do { try text.data(using: .utf8)?.write(to: url, options: .atomic) } catch { return }
            DispatchQueue.main.async {
                guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
                      let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController ?? scene.windows.first?.rootViewController
                else { return }
                var top = root
                while let next = top.presentedViewController { top = next }
                let sheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if let pop = sheet.popoverPresentationController {
                    pop.sourceView = top.view
                    pop.sourceRect = CGRect(x: top.view.bounds.midX, y: top.view.bounds.midY, width: 0, height: 0)
                    pop.permittedArrowDirections = []
                }
                top.present(sheet, animated: true)
            }
        }

        // Links externos (preço do Bitcoin, cotação do dólar) abrem no Safari
        func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = action.request.url, let scheme = url.scheme?.lowercased(),
               scheme == "http" || scheme == "https" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = action.request.url { UIApplication.shared.open(url) }
            return nil
        }
    }
}
