//
//  ViewController.swift
//  CustomCamera
//
//  Created by DucManh on 27/04/2023.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var cameraPreviewContainer: UIView!
    @IBOutlet private weak var togglePauseResumeButton : UIButton?
    @IBOutlet private weak var toggleRecordingButton : UIButton?
    @IBOutlet weak var heightContraintCamera: NSLayoutConstraint!
    @IBOutlet weak var heightContraintVideo: NSLayoutConstraint!
    private var player: AVPlayer?
    var viewArgs: DuetViewArgs?
    private var videoURL: URL?

    // private ivars
    lazy var captureStack = CVRecorder(delegate: self)
    private var isObjectDetectionEnabled = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initVideo()
    }

    private func initVideo() {

        //2. Create AVPlayer object
        var asset: AVAsset
//        if let url = viewArgs?.url {
//            asset = AVAsset(url: url)
//            videoURL = url
//        } else {
            guard let path = Bundle.main.path(forResource: "manhdz", ofType:"mp4") else {
                print("video.m4v not found")
                return
            }
            asset = AVAsset(url: URL(fileURLWithPath: path))
            videoURL = URL(fileURLWithPath: path)
//        }
        //2. Create AVPlayer object
        let videoSize = asset.videoSize
        let ratio = videoSize.height / videoSize.width
        self.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        let playerLayer = AVPlayerLayer(player: player)
        let width = UIScreen.main.bounds.width / 2
        let height = width * ratio
        heightContraintCamera.constant = height
        heightContraintVideo.constant = height
        playerLayer.frame = CGRect(x: 0, y: 0,
                                   width: width,
                                   height: height)
        self.videoView.layer.addSublayer(playerLayer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup()
    }

    private func saveInPhotoLibrary(with fileURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        }) { saved, error in
            if saved {
                let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                print(error.debugDescription)
            }
        }
    }
}

extension CameraViewController {

    private func updatePauseResumeControl(_ currentRecorderState: RecorderState) {
        switch currentRecorderState {
        case .Paused:
            togglePauseResumeButton?.isUserInteractionEnabled = true
            togglePauseResumeButton?.backgroundColor = .green
            togglePauseResumeButton?.setTitle("Resume", for: .normal)
        case .Recording:
            togglePauseResumeButton?.isUserInteractionEnabled = true
            togglePauseResumeButton?.backgroundColor = .green
            togglePauseResumeButton?.setTitle("Pause", for: .normal)
        case .Stopped:
            fallthrough
        case .NotReady:
            togglePauseResumeButton?.isUserInteractionEnabled = false
            togglePauseResumeButton?.backgroundColor = .gray
            togglePauseResumeButton?.setTitle("Pause", for: .normal)
        }
    }

    private func updateToggleRecordingControl(_ currentRecorderState: RecorderState) {
        switch currentRecorderState {
        case .Paused:
            fallthrough
        case .Recording:
            toggleRecordingButton?.isUserInteractionEnabled = true
            toggleRecordingButton?.backgroundColor = .green
            toggleRecordingButton?.setTitle("Stop", for: .normal)
        case .Stopped:
            toggleRecordingButton?.isUserInteractionEnabled = true
            toggleRecordingButton?.backgroundColor = .green
            toggleRecordingButton?.setTitle("Start", for: .normal)
        case .NotReady:
            toggleRecordingButton?.isUserInteractionEnabled = false
            toggleRecordingButton?.backgroundColor = .gray
            toggleRecordingButton?.setTitle("Not Ready", for: .normal)
        }
    }

    private func changeControlStates(_ currentRecorderState: RecorderState) {
        updatePauseResumeControl(currentRecorderState)
        updateToggleRecordingControl(currentRecorderState)
    }

    private func setup(){
        setupCaptureStack()
    }

    private func setupCaptureStack() {
        let width = UIScreen.main.bounds.width
        let height = heightContraintCamera.constant
        let cgSize = CGSize(width: width, height: height)
        captureStack.loadCaptureStack(parentViewForPreview: cameraPreviewContainer,
                                      videoUrl: videoURL,
                                      cgSize: cgSize)
        print(cameraPreviewContainer.frame.width)
        print(cameraPreviewContainer.frame.height)
    }
}

extension CameraViewController {
    @IBAction func pausePressed() {
        captureStack.togglePauseResumeRecording()
        switch captureStack.recorderState {
        case .Stopped:
            player?.pause()
        case .Recording:
            player?.play()
        case .Paused:
            player?.pause()
        case .NotReady:
            break
        }
    }

    @IBAction func toggleRecording() {
        captureStack.toggleRecording()
        switch captureStack.recorderState {
            case .Stopped:
                player?.pause()
            case .Recording:
                player?.play()
            case .Paused:
                player?.pause()
            case .NotReady:
                break
        }
    }

}

extension CameraViewController: CVRecorderDelegate {
    func didChangedCamera(_ currentCameraPosition: AVCaptureDevice.Position) {
        switch currentCameraPosition {
        case .unspecified:
            print("------- Changed to back unspecified")
        case .back:
            print("------- Changed to back camera")
        case .front:
            print("------- Changed to front camera")
        @unknown default:
            print("------- Changed to unknown default")
        }
    }

    func didChangedRecorderState(_ currentRecorderState:  RecorderState) {
        print("<<<<<< changed state -- \(currentRecorderState)")
        changeControlStates(currentRecorderState)
    }
}
