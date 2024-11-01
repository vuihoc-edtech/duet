//
//  URL+Extension .swift
//  duet
//
//  Created by DucManh on 27/04/2023.
//

import Foundation
import AVFoundation
import AVKit
import Photos

@available(iOS 13.0, *)
extension URL {

    func gridMergeVideos(duetViewArgs: DuetViewArgs,
                         urlVideo: URL,
                         cGSize: CGSize) {
        DPVideoMerger().gridMergeVideos(
            duetViewArgs: duetViewArgs,
            videoFileURLs: [urlVideo, self],
            videoResolution: cGSize,
            completion: { mergedVideoFile, error in

                if let error = error {
                    SwiftDuetPlugin.notifyFlutter(event: .VIDEO_ERROR, arguments: "\(error)")
                }

                guard let mergedVideoFile = mergedVideoFile else {
                    return
                }
                SwiftDuetPlugin.notifyFlutter(event: .VIDEO_MERGED, arguments: mergedVideoFile.path)
            }
        )
    }

    func saveVideoToAlbum(result: @escaping FlutterResult) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self)
        }) { (success, _) in
            result(success)
        }
    }

       static var documents: URL {
        return FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func presentShareActivity(viewController: UIViewController) {
        let player = AVPlayer(url: self)
        DispatchQueue.main.async {
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            viewController.present(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
        }
    }

}
