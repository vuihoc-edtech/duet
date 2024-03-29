import Flutter
import UIKit

enum DuetType: String {
    case recordDuet  = "RECORD_DUET"
    case pauseDuet   = "PAUSE_DUET"
    case resumeDuet  = "RESUME_DUET"
    case recordAudio = "RECORD_AUDIO"
    case pauseAudio  = "PAUSE_AUDIO"
    case playSound  = "PLAY_SOUND"
    case playAudioFromUrl  = "PLAY_AUDIO_FROM_URL"
    case stopAudioPlayer  = "STOP_AUDIO_PLAYER"
    case reset = "RESET"
    case retryMerge = "RETRY_MERGE"
}

@available(iOS 10.0, *)
public class SwiftDuetPlugin: NSObject, FlutterPlugin {
    static var channel: FlutterMethodChannel?
    static var registrar: FlutterPluginRegistrar?

    public static func register(with registrar: FlutterPluginRegistrar) {

        let factory = FLNativeViewFactory(messenger: registrar.messenger())

        registrar.register(factory, withId: "<platform-view-type>")

        self.channel = FlutterMethodChannel(name: "duet", binaryMessenger: registrar.messenger())
        self.registrar = registrar
        registrar.addMethodCallDelegate(SwiftDuetPlugin(), channel: channel!)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print(call.method)
        switch(call.method){
        case DuetType.recordDuet.rawValue:
            FLNativeView.controller?.startRecording()
            result("")
        case DuetType.pauseDuet.rawValue:
            FLNativeView.controller?.pauseRecording()
            result("")
        case DuetType.resumeDuet.rawValue:
            FLNativeView.controller?.resumeRecording()
            result("")
        case DuetType.recordAudio.rawValue:
            FLNativeView.controller?.startRecordingAudio()
            result("")
        case DuetType.pauseAudio.rawValue:
            FLNativeView.controller?.pauseRecordingAudio()
            result("")
        case DuetType.playSound.rawValue:
            let url = (call.arguments as? String) ?? ""
            FLNativeView.controller?.playSound(url: url, result: result)
        case DuetType.playAudioFromUrl.rawValue:
            let path = (call.arguments as? String) ?? ""
            FLNativeView.controller?.playAudioFromUrl(path: path, result: result)
        case DuetType.stopAudioPlayer.rawValue:
            FLNativeView.controller?.stopAudioPlayer(result: result)
        case DuetType.reset.rawValue:
            FLNativeView.controller?.resetData(result: result)
        case DuetType.retryMerge.rawValue:
            let url = (call.arguments as? String) ?? ""
            FLNativeView.controller?.retryMergeVideo(cameraUrl: url, result: result)
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }

    public static func notifyFlutter(event: EventType, arguments: Any?) {
        SwiftDuetPlugin.channel?.invokeMethod(event.rawValue, arguments: arguments)
    }
}

public enum EventType: String {
    case AUDIO_RESULT
    case VIDEO_RECORDED
    case VIDEO_MERGED
    case VIDEO_TIMER
    case VIDEO_ERROR
    case WILL_ENTER_FOREGROUND
    case ALERT
    case AUDIO_FINISH
}
