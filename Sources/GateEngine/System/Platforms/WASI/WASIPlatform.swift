/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_WASI_IDE_SUPPORT
import Foundation
import DOM
import JavaScriptKit
import JavaScriptEventLoop

class WASIPlatform: InternalPlatform {
    func saveState(_ state: Game.State) throws {
        let window: DOM.Window = globalThis
        window.localStorage["SaveState.data"] = try JSONEncoder().encode(state).base64EncodedString()
    }
    
    func loadState() -> Game.State {
        let window: DOM.Window = globalThis
        if let base64 = window.localStorage["SaveState.data"], let data = Data(base64Encoded: base64) {
            do {
                return try JSONDecoder().decode(Game.State.self, from: data)
            }catch{
                print(error.localizedDescription)
            }
        }
        return Game.State()
    }
    
    lazy var searchPaths: [Foundation.URL] = {
        func getGameModuleName(_ delegate: AnyObject) -> String {
            let ref = String(reflecting: type(of: delegate))
            return String(ref.split(separator: ".")[0])
        }
        let gameModule = getGameModuleName(Game.shared.delegate)
        let engineModule = getGameModuleName(self)
        return [
            // Engine reseources.
            // - First so projects with delegate defined paths are the most efficient
            Foundation.URL(string: "\(engineModule)_\(engineModule).resources")!,
            // Assume the package and target share a name for convenience
            Foundation.URL(string: "\(gameModule)_\(gameModule).resources")!,
            // Enables the included Demo executable to function without delegate search paths.
            // - Last so it's never called unless a resource is missing
            Foundation.URL(string: "\(engineModule)_\(gameModule).resources")!,
        ]
    }()
    
    var pathCache: [String:String] = [:]
    
    func locateResource(from path: String) async -> String? {
        if let existing = pathCache[path] {
            #if DEBUG
            print("[GateEngine] Located Resource: \"\(path)\" at \"\(existing)\"")
            #endif
            return existing
        }
        let delegatePaths = Game.shared.delegate.resourceSearchPaths()
        #if DEBUG
        do {
            let delegatePaths = Set(delegatePaths)
            let builtInPaths = Set(searchPaths)
            let dups = delegatePaths.intersection(builtInPaths)
            if dups.isEmpty == false {
                print("[GateEngine] Warning: The following search paths are duplicates:\(dups.map({"\n- \($0)"}).joined(separator: "\n- "))\n")
            }
        }
        #endif
        let searchPaths = (delegatePaths + searchPaths)
        for searchPath in searchPaths {
            let newPath = searchPath.appendingPathComponent(path).path
            if let object = try? await fetch(newPath, ["method": "HEAD"]).object {
                if Response(from: object)?.ok == true {
                    pathCache[path] = newPath
                    
                    #if DEBUG
                    print("[GateEngine] Located Resource: \"\(path)\" at \"\(newPath)\"")
                    #endif
                    
                    return newPath
                }
            }
        }
        #if DEBUG
        print("[GateEngine] Failed to located Resource: \"\(path)\"")
        #endif
        return nil
    }
    
    func loadResource(from path: String) async throws -> ArrayBuffer {
        if let path = await locateResource(from: path) {
            #if DEBUG
            print("[GateEngine] Loading Resource: \"\(path)\"")
            #endif
            if let object = try? await fetch(path).object {
                if let response = Response(from: object) {
                    return try await response.arrayBuffer()
                }
            }
        }
       
        throw "[GateEngine] Error: Failed to load resource " + path + "."
    }
    
    func loadResource(from path: String) async throws -> Data {
        let arrayBuffer: ArrayBuffer = try await loadResource(from: path)
        return Data(arrayBuffer)
    }
    
    func fetch(_ url: String, _ options: [String: JSValue] = [:]) async throws -> JSValue {
        let jsFetch = JSObject.global.fetch.function!
        return try await JSPromise(jsFetch(url, options).object!)!.value
    }

    func systemTime() -> Double {
        #if os(WASI)
        var time = timespec()
        let CLOCK_MONOTONIC = clockid_t(bitPattern: 1)
        if clock_gettime(CLOCK_MONOTONIC, &time) != 0 {
            return -1
        }
        return Double(time.tv_sec) + (Double(time.tv_nsec) / 1e+9)
        #else
        return Date().timeIntervalSinceReferenceDate
        #endif
    }
    
    func setupDocument() {
        globalThis.onbeforeunload = { event -> String? in
            Game.shared.willTerminate()
            return nil
        }
        let document: Document = globalThis.document

        if let ele = document.head?.children.namedItem(name: "viewport") {
            if let meta = HTMLMetaElement(from: ele) {
                meta.content += ", viewport-fit=cover"
            }
        }

        if let style = HTMLStyleElement(from: document.createElement(localName: "style")) {
            style.innerText = """
html, body, canvas {
    margin: 0 !important; padding: 0 !important; height: 100%; overflow: hidden;
    width: 100%;
    width: -moz-available;          /* WebKit-based browsers will ignore this. */
    width: -webkit-fill-available;  /* Mozilla-based browsers will ignore this. */
    width: fill-available;
}
:root {
    --sat: env(safe-area-inset-top);
    --sar: env(safe-area-inset-right);
    --sab: env(safe-area-inset-bottom);
    --sal: env(safe-area-inset-left);
}
"""
            _ = document.body?.appendChild(node: style)
        }
    }
}

extension WASIPlatform {
    @MainActor func main() {
        JavaScriptEventLoop.installGlobalExecutor()
        setupDocument()
        Game.shared.didFinishLaunching()
    }
}

extension DOM.Navigator {
    enum Browser {
        case safari
        case chrome
        case fireFox
        case opera
        case unknown
    }
    var browser: Browser {
        let string: String = globalThis.navigator.userAgent
//        let vendor = globalThis.navigator.vendor
//        let version = globalThis.navigator.appVersion
        if string.contains("Chrome") {
            return .chrome
        }
        if string.contains("Safari") {
            return .safari
        }
        if string.contains("FireFox") {
            return .fireFox
        }
        if string.contains("Opera") {
            return .opera
        }
        return .unknown
    }
}

#endif
