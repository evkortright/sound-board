//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Enrique V. Kortright on 5/3/17.
//  Copyright © 2017 Enrique V. Kortright. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var soundNameTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    var audioRecorder : AVAudioRecorder? = nil
    var audioPlayer : AVAudioPlayer = AVAudioPlayer()
    var audioURL : URL? = nil
    
    var sound : Sound? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SoundViewController.viewDidLoad")
        if (sound != nil) {
            print("sound is not nil")
            soundNameTextField.text = sound?.name
            playButton.isEnabled = true
            recordButton.isEnabled = false
            addButton.setTitle("Update", for: .normal)
            addButton.isEnabled = true
        } else {
            print("sound is nil")
            playButton.isEnabled = false
            recordButton.isEnabled = true
            addButton.setTitle("Add", for: .normal)
            addButton.isEnabled = false
            setupRecorder()
        }

    }

    func setupRecorder() {
        print("setupRecorder")
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
        } catch let error as NSError {
            print("Error setting up AVSession: \(error)")
        }
        
        let basePath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let pathComponents = [basePath, "audio.mp4"]
        audioURL = NSURL.fileURL(withPathComponents: pathComponents)
        print("audioURL: \(audioURL!)")
        
        var settings : [String:AnyObject] = [:]
        settings[AVFormatIDKey] = kAudioFormatMPEG4AAC as AnyObject
        settings[AVSampleRateKey] = 44100.0 as AnyObject
        settings[AVNumberOfChannelsKey] = 2 as AnyObject
        
        do {
            try audioRecorder = AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder!.prepareToRecord()
        } catch {
            print("Error creating audioRecorder")
        }
    }
    
    @IBAction func recordTapped(_ sender: Any) {
        print("recordTapped")
        if audioRecorder!.isRecording {
            audioRecorder!.stop()
            recordButton.setTitle("Record", for: .normal)
            playButton.isEnabled = true
            addButton.isEnabled = true
        } else {
            audioRecorder!.record()
            recordButton.setTitle("Stop", for: .normal)
        }
    }

    @IBAction func playTapped(_ sender: Any) {
        print("playTapped")
        do {
            if (sound == nil) {
                try audioPlayer = AVAudioPlayer(contentsOf: audioURL!)
            } else {
                try audioPlayer = AVAudioPlayer(data: sound!.audio! as Data)
            }
            audioPlayer.play()
        } catch {
            print("Error playing sound")
        }
    }
    
    @IBAction func addTapped(_ sender: Any) {
        print("addTapped")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if (sound == nil) {
            let context = delegate.persistentContainer.viewContext
            sound = Sound(context: context)
            sound!.audio = NSData(contentsOf: audioURL!)
        }
        sound!.name = soundNameTextField.text
        delegate.saveContext()
        navigationController?.popViewController(animated: true)
    }
    
}
