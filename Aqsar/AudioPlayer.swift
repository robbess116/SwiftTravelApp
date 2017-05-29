//
//  AudioPlayer.swift
//  Aqsar
//
//  Created by moayad on 8/15/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

@objc protocol AudioPlayerDelegate {
    @objc optional func audioPlayerWillPlayNextTrack()
    @objc optional func audioPlayerDidPlayNextTrack()
}

class AudioPlayer: NSObject {
    static let sharedInstance = AudioPlayer()
    
    //MARK:- IVars
    var player:AVAudioPlayer?
    fileprivate var currentTrackIndex = 0
    fileprivate var tracks:[String] = [String]()
    
    var delegate: AudioPlayerDelegate?
    
    // traveling data
    var partName: String?
    var titleAndAuthor = ""
    var currentBook = Book()
    var currentPapers = [Paper]()
    var rowToSelectAudioFile = -1
    
    var currentTrackNumber: Int {
        return currentTrackIndex + 1
    }
    
    var tracksNumber: Int {
        return tracks.count
    }
    
    var highlightingTimer = Timer()
    var audioTrackingCurrentSecond = 0
    var currentTimerTracker = 0
    var timers = [String]()
    
    //MARK:- Inits
    override init(){
        tracks = FileReader.readFiles()
        super.init()
        queueTrack()

    }
    
    func queueTrack() {
        if (player != nil) {
            player = nil
        }
        
        let url = URL(fileURLWithPath: tracks[currentTrackIndex] as String)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                print("AVAudioSession Category Playback OK")
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("AVAudioSession is Active")
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            //_ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            
            player?.delegate = self
            player?.prepareToPlay()
        } catch {
            print("\(#file)\nERROR:- \(error)")
        }
    }
    
    func getCurrentTrackName() -> String {
        return tracks[currentTrackIndex]
    }
    
    //MARK:- Main
    func play() {
        player?.delegate = self
        if player?.isPlaying == false {
            player?.play()
        }
    }
    
    func play(_ url: URL,isStreaming : Bool = false) {
        do {
            if isStreaming {

                let soundData = try NSData(contentsOf: url, options: NSData.ReadingOptions())
                self.player = try AVAudioPlayer(data: soundData as Data)

            }else{
                self.player = try AVAudioPlayer(contentsOf: url)
                player!.prepareToPlay()
                //player!.volume = 1.0
                player!.play()
            }
            
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    func stop(){
        if player?.isPlaying == true {
            player?.stop()
            player?.currentTime = 0
        }
    }
    
    func pause(){
        if player?.isPlaying == true{
            player?.pause()
        }
    }
    
    func nextSong(_ songFinishedPlaying:Bool){
        var playerWasPlaying = false
        if player?.isPlaying == true {
            player?.stop()
            playerWasPlaying = true
        }
        
        currentTrackIndex += 1
        if currentTrackIndex >= tracks.count {
            currentTrackIndex = 0
        }
        queueTrack()
        if playerWasPlaying || songFinishedPlaying {
            player?.play()
        }
    }
    
    func previousSong(){
        var playerWasPlaying = false
        if player?.isPlaying == true {
            player?.stop()
            playerWasPlaying = true
        }
        currentTrackIndex -= 1
        if currentTrackIndex < 0 {
            currentTrackIndex = tracks.count - 1
        }
        
        queueTrack()
        if playerWasPlaying {
            player?.play()
        }
    }
    
    //MARK:- Timing
    func getCurrentTimeAsString() -> String {
        var seconds = 0
        var minutes = 0
        if let time = player?.currentTime {
            seconds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    func getProgress()->Float{
        var theCurrentTime = 0.0
        var theCurrentDuration = 0.0
        if let currentTime = player?.currentTime, let duration = player?.duration {
            theCurrentTime = currentTime
            theCurrentDuration = duration
        }
        return Float(theCurrentTime / theCurrentDuration)
    }
    
    //MARK:- Volume
    func setVolume(_ volume:Float){
        player?.volume = volume
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true {
            if let dele = delegate, dele.audioPlayerWillPlayNextTrack != nil {
                dele.audioPlayerWillPlayNextTrack!()
            }

            nextSong(true)
            
            if let dele = delegate, dele.audioPlayerDidPlayNextTrack != nil {
                dele.audioPlayerDidPlayNextTrack!()
            }
        }
    }
}
