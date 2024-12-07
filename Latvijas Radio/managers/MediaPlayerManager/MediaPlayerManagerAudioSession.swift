//
//  MediaPlayerManagerAudioSession.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 04/02/2023.
//

import AVFoundation

class MediaPlayerManagerAudioSession: NSObject {
    
    let TAG = String(describing: MediaPlayerManagerAudioSession.self)

    private var mediaPlayerManager: MediaPlayerManager!

    init(_ mediaPlayerManager: MediaPlayerManager) {
        super.init()
        
        self.mediaPlayerManager = mediaPlayerManager
        
        setupAudioSessionNotifications()
    }
    
    func setupAudioSessionNotifications() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main) { [weak self] notification in
                
            if let self = self {
                GeneralUtils.log(self.TAG, AVAudioSession.interruptionNotification)

                guard let userInfo = notification.userInfo,
                    let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                    let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                        return
                }

                switch(type) {

                case .began:
                    GeneralUtils.log(self.TAG, "Interruption began")

                    break
                case .ended:
                    GeneralUtils.log(self.TAG, "Interruption ended")

                    guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        // An interruption ended. Resume playback.
                        GeneralUtils.log(self.TAG, "Resuming if possible...")
                        
                        self.mediaPlayerManager.performActionToggleMediaPlayback()
                    } else {
                        // An interruption ended. Don't resume playback.
                    }

                    break
                default:
                    break
                }
            }
        }
    }
}
