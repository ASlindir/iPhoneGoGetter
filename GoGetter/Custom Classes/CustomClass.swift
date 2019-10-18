//
//  CustomClass.swift
//  GoGetter
//
//  Created by Batth on 15/09/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass
import AVFoundation

enum Audios : String{
    case popGreen = "PopGreen"
    case popRed = "PopRed"
    case countDown = "Videocountdow"
    case swipeLeft = "swipeLEFT"
    case swipeRight = "swipeRight"
    case bottomView = "bottomView"
}

enum SongExtnsions: String{
    case mp3 = "mp3"
}


class CustomClass: NSObject {

//Variables and Constants
    
    var audioPlayer: AVAudioPlayer!
    
    var isAudioPlay: Bool! {
        get{
            return checkAudioPlay()
        }
        set{
        }
    }
    
//MARK:-  Make Singleton Class
    static let sharedInstance = CustomClass()
    
    
//MARK:-  Audio Play Pause Methods
    func playAudio(_ fileName:Audios, _ fileExtension: SongExtnsions){
        if LocalStore.store.isSoundOn(){
            let music = Bundle.main.path(forResource: fileName.rawValue, ofType: fileExtension.rawValue)
            do {
/*                if audioPlayer == nil{
                    audioPlayer = AVAudioPlayer?
                }*/
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: music!))
                audioPlayer?.volume = 1
//                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient);
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient, mode:AVAudioSession.Mode.spokenAudio);
                try AVAudioSession.sharedInstance().setActive(true)
                audioPlayer?.play()
            }catch let err{
              print(err)
            }
        }
    }
    
    private func checkAudioPlay() -> Bool!{
        var audioPlay: Bool = false
        if audioPlayer != nil {
            if (audioPlayer?.isPlaying)!{
                audioPlay = true
            }else{
                audioPlay = false
            }
        }else{
            audioPlay = false
        }
        return audioPlay
    }
    
    func stopAudio() {
        audioPlayer?.stop()
    }
    
}

//MARK:-  Custom Pan Gesture
enum PanDirection {
    case vertical
    case horizontal
}

class PanDirectionGestureRecognizer: UIPanGestureRecognizer {
    
    let direction: PanDirection
    
    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if state == .began {
            let vel = velocity(in: view)
            switch direction {
            case .horizontal where abs(vel.y) > abs(vel.x):
                state = .cancelled
            case .vertical where abs(vel.x) > abs(vel.y):
                state = .cancelled
            default:
                break
            }
        }
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
