import Flutter
import UIKit
import ActivityKit
import flutter_foreground_task

// Mirrors ReadingSessionLAAttributes in snippetWidgetLiveActivity.swift — keep in sync.
struct ReadingSessionLAAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var timerReferenceEpoch: Double  // epoch-seconds of "virtual zero" for .timer style
        var isPaused: Bool
        var pausedElapsedSeconds: Int
    }
    var bookTitle: String
    var coverUrl: String
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    private var _currentActivity: Any?  // Any? avoids @available on stored property

    @available(iOS 16.2, *)
    private var currentActivity: Activity<ReadingSessionLAAttributes>? {
        get { _currentActivity as? Activity<ReadingSessionLAAttributes> }
        set { _currentActivity = newValue }
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ReadingLiveActivity") else { return }
        let channel = FlutterMethodChannel(
            name: "com.gowoobro.snippet/liveActivity",
            binaryMessenger: registrar.messenger()
        )
        channel.setMethodCallHandler { [weak self] call, result in
            guard #available(iOS 16.2, *) else { result(nil); return }
            let args = call.arguments as? [String: Any] ?? [:]
            switch call.method {
            case "start":
                Task { await self?.startActivity(args) }
                result(nil)
            case "update":
                Task { await self?.updateActivity(args) }
                result(nil)
            case "end":
                Task { await self?.endActivity() }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - Live Activity lifecycle

    @available(iOS 16.2, *)
    private func startActivity(_ args: [String: Any]) async {
        await endActivity()
        let title    = args["title"]    as? String ?? "독서 중"
        let coverUrl = args["coverUrl"] as? String ?? ""
        let refEpoch = args["timerReferenceEpoch"] as? Double ?? Date().timeIntervalSince1970

        if let url = URL(string: coverUrl) { await saveCoverImage(from: url) }

        let attributes = ReadingSessionLAAttributes(bookTitle: title, coverUrl: coverUrl)
        let state = ReadingSessionLAAttributes.ContentState(
            timerReferenceEpoch: refEpoch, isPaused: false, pausedElapsedSeconds: 0
        )
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil)
            )
        } catch {
            print("[LiveActivity] start error: \(error)")
        }
    }

    @available(iOS 16.2, *)
    private func updateActivity(_ args: [String: Any]) async {
        guard let activity = currentActivity else { return }
        let refEpoch      = args["timerReferenceEpoch"]  as? Double ?? Date().timeIntervalSince1970
        let isPaused       = args["isPaused"]              as? Bool   ?? false
        let pausedElapsed  = args["pausedElapsedSeconds"]  as? Int    ?? 0
        let newState = ReadingSessionLAAttributes.ContentState(
            timerReferenceEpoch: refEpoch, isPaused: isPaused, pausedElapsedSeconds: pausedElapsed
        )
        await activity.update(ActivityContent(state: newState, staleDate: nil))
    }

    @available(iOS 16.2, *)
    private func endActivity() async {
        guard let activity = currentActivity else { return }
        let finalState = activity.content.state
        await activity.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
        currentActivity = nil
    }

    private func saveCoverImage(from url: URL) async {
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let container = FileManager.default.containerURL(
                  forSecurityApplicationGroupIdentifier: "group.com.gowoobro.snippet"
              ) else { return }
        try? data.write(to: container.appendingPathComponent("current_book_cover.jpg"))
    }
}
