//
//  SpeechRecognitionViewController.swift
//  Slindir
//
//  Created by Batth on 29/09/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit
import Speech
import AVKit

protocol RecordVideoDelegate {
    func speechText(_ text: String, _ url : URL)
}

class RecordVideoController: UIViewController, SFSpeechRecognizerDelegate, AVCaptureFileOutputRecordingDelegate, UITextViewDelegate {
    
//MARK:-  IBAction Methods, Variables & Constants
    var speechDelegate: RecordVideoDelegate?
    
    private let speechRecognizor = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let avPlayer = AVPlayer()
    
    var captureDevice: AVCaptureDevice?
    var captureAudio :AVCaptureDevice?
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureDeviceAudioFound:Bool = false
    var captureDeviceVideoFound: Bool = false

    @IBOutlet weak var lblPressToRecond: UILabel!
    @IBOutlet weak var lblNice: UILabel!
    @IBOutlet weak var lblThree: UILabel!
    @IBOutlet weak var lblTwo: UILabel!
    @IBOutlet weak var lblOne: UILabel!
    @IBOutlet weak var lblTimer: UILabel!
    
    @IBOutlet weak var txtViewSpeech: UITextView?
    @IBOutlet weak var txtViewPreview: UITextView!
    
    @IBOutlet weak var viewCameraBackround: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet weak var viewIntro: UIView!
    @IBOutlet weak var viewRecord: UIView?
    @IBOutlet weak var viewSlider: UIView!
    @IBOutlet weak var viewRecondCenter: UIView!
    @IBOutlet weak var viewPreview: UIView!
    @IBOutlet weak var viewVideoPreview: UIView!
    @IBOutlet weak var viewTextViewIntroPreview: UIView!
    
    @IBOutlet weak var videoPreviewImage: UIImageView!
    
    @IBOutlet weak var btnFlipCamera: UIButton!
    @IBOutlet weak var btnRecord: UIButton?
    @IBOutlet weak var btnPlayVideoPreview: UIButton!
    @IBOutlet weak var btnUse: UIButton?
    @IBOutlet weak var btnChanges: UIButton?
    
    let mask = CAGradientLayer()
    
    let videoFileOutput = AVCaptureMovieFileOutput()
    var player: AVPlayer?
    let playerController = AVPlayerViewController()
    
    var firstCounting = [3,2,1]
    
    var timerStart = Timer()
    var timer = Timer()
    
    var countNumber: Int = 1
    var videoCounter: Int = 30
    
    var isRecording: Bool = false
    var isVideoPreview: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtViewPreview.delegate = self
        speechRecognizor?.delegate = self
        btnRecord?.isEnabled = false
        lblPressToRecond.alpha = 0
        lblNice.alpha = 0
        viewIntro.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        lblThree.alpha = 0
        lblTwo.alpha = 0
        lblOne.alpha = 0
        lblTimer.alpha = 0
        txtViewSpeech?.isHidden = true
        txtViewSpeech?.isUserInteractionEnabled = false
        viewSlider.isHidden = true
        viewRecondCenter.alpha = 0
        viewTextViewIntroPreview.alpha = 0
        
//TODO:-   UNcomment this for Speech Recogination
        speechPermissions()
        readyTheVideo()
        startAnimations()
        gestures()
    }
    
    override func viewDidLayoutSubviews() {
        viewRecord?.layer.cornerRadius = (viewRecord?.frame.size.width)!/2
        btnRecord?.layer.cornerRadius = (btnRecord?.frame.size.width)!/2
        btnUse?.layer.cornerRadius = (btnUse?.frame.size.height)!/2
        btnChanges?.layer.cornerRadius = (btnChanges?.frame.size.height)!/2
    }
    
//MARK:-  Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
//MARK:-  AVCapture Methods and Delegates
    
    func readyTheVideo(){
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera,AVCaptureDevice.DeviceType.builtInMicrophone], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        for device in deviceDescoverySession.devices {
            if (device.hasMediaType(AVMediaType.video)) {
                if(device.position == AVCaptureDevice.Position.front) {
                    captureDevice = device
                    if captureDevice != nil {
                        print("Capture device found")
                        captureDeviceVideoFound = true;
                    }
                }
            }
            if(device.hasMediaType(AVMediaType.audio)){
                captureAudio = device //initialize audio
                captureDeviceAudioFound = true
            }
        }
        
        
        let deviceDescoverySessionAudio = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInMicrophone], mediaType: AVMediaType.audio, position: AVCaptureDevice.Position.unspecified)
        for device in deviceDescoverySessionAudio.devices {
            if(device.hasMediaType(AVMediaType.audio)){
                captureAudio = device //initialize audio
                captureDeviceAudioFound = true
            }
        }
        
        
        if(captureDeviceAudioFound && captureDeviceVideoFound){
            beginSession()
        }
    }
    
    func beginSession(){
        configureDevice()
        let _: Error? = nil
        do{
            
            if try captureSession.canAddInput(AVCaptureDeviceInput(device: captureDevice!)){
                try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice!))
            }
            if try captureSession.canAddInput(AVCaptureDeviceInput(device: captureAudio!)){
                try captureSession.addInput(AVCaptureDeviceInput(device: captureAudio!))
            }
        }catch let err{
            print(err)
        }
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = UIScreen.main.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        viewCamera.layer.addSublayer(previewLayer!)
        captureSession.startRunning()
    }
    
    func configureDevice(){
        if let device = captureDevice{
            do{
                try device.lockForConfiguration()
            }catch let err{
                print(err)
            }
        }
        if let audio = captureAudio{
            do{
                try audio.lockForConfiguration()
            }catch let err{
                print(err)
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("capture did finish")
        print(outputFileURL);
    }
//MARK:-  Local Methods
    
    func recordVideo(){
        DispatchQueue.main.async {
            self.viewRecord?.isUserInteractionEnabled = false
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            self.countNumber = 1
            UIView.animate(withDuration: 1, animations: {
                self.btnFlipCamera.alpha = 0
                self.btnRecord?.alpha = 0
                self.viewTop.backgroundColor = UIColor(red: 192/255, green: 29/255, blue: 2/255, alpha: 1)
            }) { (completed) in
                
            }
        }
        UIView.animate(withDuration: 1.2, animations: {
            self.lblPressToRecond.alpha = 0
            self.lblNice.alpha = 0
            self.viewIntro.alpha = 0
        }) { (completed) in
            self.timerStart = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.threeTwoOne(_:)), userInfo: nil, repeats: true)
            self.isRecording = true
            DispatchQueue.main.asyncAfter(deadline:.now() + 3.5, execute: {
                self.timerStart.invalidate()
            })
        }
    }
    
    func gestures(){
        let tapGestureRecordVideo = UITapGestureRecognizer(target: self, action: #selector(btnRecordSpeech(_:)))
        viewRecord?.addGestureRecognizer(tapGestureRecordVideo)
    }
    func startAnimations(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.6, animations: {
                self.lblPressToRecond.alpha = 1
            }) { (completed) in
                UIView.animate(withDuration: 0.6, animations: {
                    self.lblNice.alpha = 1
                }, completion: { (completed) in
                    
                })
            }
        }
    }
    
    func startRecording(){
        if recognitionTask != nil{
            recognitionTask?.cancel()
        }
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSession.Category.record, mode:AVAudioSession.Mode.spokenAudio)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }catch let err{
            print(err)
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        
        guard let recogntionRequest = recognitionRequest else {
            fatalError("Audio engine has no input node")
        }
        
        recognitionRequest?.shouldReportPartialResults = true
        recognitionTask = speechRecognizor?.recognitionTask(with: recogntionRequest, resultHandler: { (result, error) in
            var isFinal = true
            
            if result != nil{
                self.txtViewSpeech?.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal{
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.btnRecord?.isEnabled = true
                self.viewRecord?.isUserInteractionEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do{
            try audioEngine.start()
        }catch let err{
            print("Error :- \(err)")
        }
    }
    
    func createPath(){
        videoFileOutput.movieFragmentInterval = CMTime.invalid
        let fileName = "mysavefile.mp4"
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentURL.appendingPathComponent(fileName)
        self.captureSession.addOutput(videoFileOutput)
        let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
        print("video")
        videoFileOutput.startRecording(to: filePath, recordingDelegate: recordingDelegate!)
    }
    
    func videoThumb() -> UIImage?{
        let fileName = "mysavefile.mp4"
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentURL.appendingPathComponent(fileName)
        let asset = AVAsset(url: filePath)
        let assestImageGenerate = AVAssetImageGenerator(asset: asset)
        assestImageGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do{
            let img = try assestImageGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        }catch let err{
            print(err)
        }
        return nil
    }
    
    func checkSpeechPermissions(){
        let speechPermission = SFSpeechRecognizer.authorizationStatus()
        
        switch speechPermission {
        case .authorized:
            self.checkVideoPermissions()
        case .denied:
            self.showSettingAlert("speech")
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization({ (permissions) in
                switch permissions{
                case .authorized:
                    self.checkVideoPermissions()
                case .denied:
                    self.showSettingAlert("speech")
                case .notDetermined:
                    break
                case .restricted:
                    self.showAlertWithOneButton("Restricted!", "Speech recognition restricted on this device", "OK")
                }
            })
        case .restricted:
            self.showAlertWithOneButton("Restricted!", "Speech recognition restricted on this device", "OK")
        }
    }
    
    func checkVideoPermissions(){
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        switch cameraAuthorizationStatus {
        case .authorized:
            self.checkMicrophonePermissions()
        case .denied:
            self.showSettingAlert("camera")
        case .restricted:
            self.showAlertWithOneButton("Alert!", "Camera is not available.", "OK")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: cameraMediaType, completionHandler: { (granted) in
                if granted{
                    self.checkMicrophonePermissions()
                }else{
                    self.showSettingAlert("camera")
                }
            })
        }
    }
    
    func checkMicrophonePermissions(){
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            self.recordVideo()
        case .denied:
            self.showSettingAlert("microphone")
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted{
                    
                }else{
                    self.showSettingAlert("microphone")
                }
            })
        }
    }
    
    private func showSettingAlert(_ message: String){
        let settingAction = action("Settings", .default) { (action) in
            let path = Bundle.main.bundleIdentifier
            let urlString = "\(UIApplication.openSettingsURLString)+\(path!)"
            UIApplication.shared.open(URL(string: urlString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
        let cancelAction = action("Cancel", .cancel) { (action) in
            
        }
        showAlertWithCustomButtons("Slindir does not have access to phone \(message), tap Settings and turn on \(message).", nil, settingAction,cancelAction)
    }
    
    
//MARK:-  Speech Recognizer Methods and Delegates
    
    func speechPermissions(){
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            switch authStatus{
            case .authorized: break
            case .denied:
                self.showAlertWithOneButton("Denied!", "User denied access to speech recognition", "OK")
                print("User denied access to speech recognition")
                
            case .restricted:
                self.showAlertWithOneButton("Restricted!", "Speech recognition restricted on this device", "OK")
                
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                self.showAlertWithOneButton("Not Find!", "Speech recognition not yet authorized", "OK")
                print("Speech recognition not yet authorized")
            }
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btnRecord?.isEnabled = true
            viewRecord?.isUserInteractionEnabled = true
        }
        else{
            btnRecord?.isEnabled = false
            viewRecord?.isUserInteractionEnabled = false
        }
    }
    
//MARK:-  IBAction Methods
    @IBAction func btnRecordSpeech(_ sender: Any?){
        
        if isRecording {
            isRecording = false
            videoCounter = 0
            self.videoTimer(nil)
        }else{
//            self.checkVideoPermissions()
//TODO:-   UNcomment this for Speech Recogination and Comment upper line
            self.checkSpeechPermissions()
        }
    }
    
    
    @objc func threeTwoOne(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.countDown, .mp3)
        UIView.animate(withDuration: 0.5, animations: {
            if self.countNumber == 1{
                self.lblThree.alpha = 1
            }else if self.countNumber == 2{
                self.lblTwo.alpha = 1
            }else if self.countNumber == 3{
                self.lblOne.alpha = 1
            }
        }) { (completed) in
            UIView.animate(withDuration: 0.4, animations: {
                if self.countNumber == 1{
                    self.lblThree.alpha = 0.3
                }else if self.countNumber == 2{
                    self.lblTwo.alpha = 0.3
                }else if self.countNumber == 3{
                    self.lblOne.alpha = 0.3
                }
            }, completion: { (completed) in
                self.countNumber += 1
                CustomClass.sharedInstance.stopAudio()
                if self.countNumber > self.firstCounting.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.lblOne.alpha = 0
                            self.lblTwo.alpha = 0
                            self.lblThree.alpha = 0
                            self.viewRecondCenter.alpha = 1
                            
                        }, completion: { (completed) in
                            self.lblTimer.isHidden = false
                            UIView.animate(withDuration: 0.5, animations: {
                                self.viewTop.backgroundColor = .clear
                                self.lblTimer.alpha = 1
                            }, completion: { (completed) in
                                self.viewRecord?.isUserInteractionEnabled = true
//TODO:-   UNcomment this for Speech Recogination
                                self.startRecordingHere()
                                self.viewSlider.isHidden = false
                                self.animateTitle()
                                self.videoCounter = 30
                                self.lblTimer.text = "\(self.videoCounter)"
                                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.videoTimer(_ :)), userInfo: nil, repeats: true)
                                self.createPath()
                                return
                            })
                        })
                    })
                }
            })
        }
    }
    
    @objc func videoTimer(_ sender: Any?){
        print(videoCounter)
        if videoCounter <= 0{
            timer.invalidate()
            isRecording = false
            self.videoCounter = 0
            self.lblTimer.text = "\(self.videoCounter)"
            txtViewSpeech?.isUserInteractionEnabled = false
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.captureSession.stopRunning()
            videoFileOutput.stopRecording()
            txtViewPreview.text = txtViewSpeech?.text
            txtViewPreview.isEditable = false
            videoPreviewImage.isHidden = false
            videoPreviewImage.image = videoThumb()
            
//            UIView.transition(from: viewCameraBackround, to: viewPreview, duration: 0.5, options: .transitionCrossDissolve, completion: { (completed) in
            viewCameraBackround.alpha = 0
            viewPreview.alpha = 1
                self.btnUse?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                self.btnChanges?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            
            
            UIView.animate(withDuration: 0.3,delay :0, options: .allowUserInteraction, animations: {
                    self.btnUse?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    self.btnChanges?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.3,delay :0, options: .allowUserInteraction, animations: {
                        self.btnUse?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        self.btnChanges?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    }, completion: { (completed) in
                        UIView.animate(withDuration: 0.3,delay :0, options: .allowUserInteraction, animations: {
                            self.btnUse?.transform = .identity
                            self.btnChanges?.transform = .identity
                        }, completion: { (completed) in
                            
                        })
                    })
                })
//            })
            return
        }
        
        UIView.transition(with: self.lblTimer, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.lblTimer.text = "\(self.videoCounter)"
        }) { (completed) in
            self.videoCounter -= 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            self.viewRecord?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (completed) in
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
                self.viewRecord?.transform = .identity
            }, completion: { (completed) in
                
            })
        }
    }
    
    
    func animateTitle(){
        mask.frame = viewTop.bounds
        mask.colors = [UIColor(red: 34/255, green: 145/255, blue: 147/255, alpha: 1
            ).cgColor, UIColor(red: 34/255, green: 145/255, blue: 147/255, alpha: 1
                ).cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        mask.startPoint = CGPoint(x: 0, y: 1)
        mask.endPoint = CGPoint(x: 1, y: 1)
        viewSlider.layer.mask = mask
        fadeIn()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.5, animations: {
            }, completion: { (completed: Bool) in
                self.fadeOut()
            })
        }
    }
    
    func startRecordingHere(){
        if audioEngine.isRunning{
            audioEngine.stop()
            recognitionRequest?.endAudio()
            createPath()
        }else{
            self.txtViewSpeech?.isHidden = false
            startRecording()
        }
    }
    
    @IBAction func btnUse(_ sender: Any?){
//TODO:-   UNcomment this for Speech Recogination and Text Preview
        if isVideoPreview {
            isVideoPreview = false
            player?.pause()
            UIView.animate(withDuration: 0.5, animations: {
                self.btnPlayVideoPreview.alpha = 0
            }, completion: { (completed) in
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.btnUse?.alpha = 0
                    self.btnChanges?.alpha = 0
                    self.viewTextViewIntroPreview.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                }, completion: { (completed) in
                    self.btnUse?.setTitle("USE AS MY INTRO", for: .normal)
                    self.btnChanges?.setTitle("NO, MAKE CHANGES", for: .normal)
                    UIView.animate(withDuration: 0.2, animations: {
                        self.btnUse?.alpha = 1
                        self.btnChanges?.alpha = 1
                        self.viewTextViewIntroPreview.alpha = 1
                    }, completion: { (completed) in
                        
                    })
                })
            })
        }else{
            let transition: CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromTop
            self.view.window!.layer.add(transition, forKey: nil)
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            
            let videoDataPath = documentsDirectory + "/"+"mysavefile.mp4"
            let filePathURL = NSURL.fileURL(withPath: videoDataPath)
            self.speechDelegate?.speechText(self.txtViewPreview.text, filePathURL)
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func btnChanges(_ sender: Any?){
        if isVideoPreview {
            self.captureSession.removeOutput(videoFileOutput)
            do{
                try self.captureSession.removeInput(AVCaptureDeviceInput(device: captureDevice!))
                try self.captureSession.removeInput(AVCaptureDeviceInput(device: captureAudio!))

            }catch{
                print("error")
            }
            txtViewSpeech?.text = ""
            viewCameraBackround.alpha = 1
            viewPreview.alpha = 0
            player?.replaceCurrentItem(with: nil)
            playerController.player = nil
            btnRecord?.isEnabled = false
            self.btnRecord?.alpha = 1
            self.btnFlipCamera.alpha = 1
            viewRecord?.isUserInteractionEnabled = true
            lblPressToRecond.alpha = 1
            lblNice.alpha = 1
            lblTimer.isHidden = true
            self.viewIntro.alpha = 1
            viewIntro.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            lblTimer.alpha = 1
            viewTop.backgroundColor = .black
            txtViewSpeech?.isHidden = true
            txtViewSpeech?.isUserInteractionEnabled = false
            viewSlider.isHidden = true
            viewRecondCenter.alpha = 0
            viewTextViewIntroPreview.alpha = 0
            
//TODO:-   UNcomment this if Speech Recogination

            speechPermissions()
            readyTheVideo()
            startAnimations()
            view.sendSubviewToBack(viewPreview)
            playerController.view.removeFromSuperview()
            self.btnPlayVideoPreview.alpha = 1
        }else{
           txtViewPreview.isEditable = true
            txtViewPreview.becomeFirstResponder()
        }
    }
    
    @IBAction func btnRecordPlay(_ sender: Any?){
        self.btnPlayVideoPreview.alpha = 0
        self.videoPreviewImage.isHidden = true
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        if let documentDirectory: URL = urls.first{
            let videoUrl = documentDirectory.appendingPathComponent("mysavefile.mp4")
            print(videoUrl)
            player = AVPlayer(url: videoUrl)
            player?.play()
            playerController.player = player
            playerController.showsPlaybackControls = false
            viewVideoPreview.addSubview(playerController.view)
            NotificationCenter.default.addObserver(self, selector: #selector(videoAtItsEnd(_ :)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            playerController.view.frame = (viewVideoPreview?.frame)!
        }
    }
    
    @IBAction func btnBack(_ sender: Any?){
        self.dismiss(animated: true, completion: nil)
    }
    
    
//MARK:- Notification Methods
    @objc func videoAtItsEnd(_ notification: Notification){
        self.btnPlayVideoPreview.alpha = 1
    }
    
//MARK:-  UITextView Delegates
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
//MARK:-  Animation Functions
    private func locations(a: Float, b: Float, c: Float, d: Float) -> [Any] {
        return [Float(a), Float(b), Float(c), Float(d)]
    }
    
    func fadeIn() {
        CATransaction.begin()
        CATransaction.setValue(Double(0.0), forKey: kCATransactionAnimationDuration)
        (viewSlider.layer.mask as? CAGradientLayer)?.locations = locations(a: 0, b: 0, c: 0, d: 0) as? [NSNumber]
        CATransaction.commit()
    }
    
    func fadeOut() {
        CATransaction.begin()
        CATransaction.setValue(Double(30), forKey: kCATransactionAnimationDuration)
        let timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        CATransaction.setAnimationTimingFunction(timingFunction)
        (viewSlider.layer.mask as? CAGradientLayer)?.locations = locations(a: 1, b: 1, c: 1, d: 1) as? [NSNumber]
        CATransaction.commit()
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
