import Cocoa
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var webView: WKWebView!
    var gatewayProcess: Process?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        startGateway()
        let rect = NSRect(x: 0, y: 0, width: 1200, height: 800)
        window = NSWindow(contentRect: rect, styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "CapatiClaw"
        window.center()
        window.makeKeyAndOrderFront(nil)
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: rect, configuration: config)
        window.contentView = webView
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let url = URL(string: "http://127.0.0.1:18789/") {
                self.webView.load(URLRequest(url: url))
            }
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func startGateway() {
        let resources = Bundle.main.resourcePath ?? ""
        let nodePath = resources + "/node/node"
        let scriptPath = resources + "/capaticlaw.mjs"
        let process = Process()
        let node = FileManager.default.fileExists(atPath: nodePath) ? nodePath : "/usr/local/bin/node"
        process.executableURL = URL(fileURLWithPath: node)
        process.arguments = [scriptPath, "gateway", "--port", "18789"]
        try? process.run()
        gatewayProcess = process
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
    func applicationWillTerminate(_ notification: Notification) { gatewayProcess?.terminate() }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
