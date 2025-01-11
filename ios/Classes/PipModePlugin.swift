import Flutter
import UIKit
import AVKit

public class PipModePlugin: NSObject, FlutterPlugin, AVPlayerViewControllerDelegate {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.valueoutput.pip_mode", binaryMessenger: registrar.messenger())
    let instance = PipModePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "enterPipMode" {
      guard let arguments = call.arguments as? [String: Any],
        let videoPath = arguments["videoPath"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Video path missing", details: nil))
          return
        }
        startPiPMode(videoPath: videoPath, result: result)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func startPiPMode(videoPath: String, result: @escaping FlutterResult) {
    guard let controller = UIApplication.shared.keyWindow?.rootViewController else {
      result(FlutterError(code: "UNAVAILABLE", message: "Root view controller unavailable", details: nil))
      return
    }

    let videoURL = URL(fileURLWithPath: videoPath)
    let player = AVPlayer(url: videoURL)
    
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player
    playerViewController.allowsPictureInPicturePlayback = true
    playerViewController.delegate = self

    controller.present(playerViewController, animated: true) {
      player.play()
    }
      
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }

    result(nil)
  }

  public func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
    print("PiP started")
  }

  public func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
    print("PiP stopped")
  }

  public func playerViewController(
    _ playerViewController: AVPlayerViewController,
    failedToStartPictureInPictureWithError error: Error
  ) {
    print("Failed to start PiP: \(error.localizedDescription)")
  }
}
