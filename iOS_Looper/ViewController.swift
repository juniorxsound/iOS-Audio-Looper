//
//  ViewController.swift
//  iOS_Looper
//
//  Created by ITP on 11/15/17.
//  Copyright © 2017 Or Fleisher. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    //Collection of sliders
    @IBOutlet var sliders: [UISlider]!
    //Collection of toggls
    @IBOutlet var toggles: [UISwitch]!
    
    
    @IBAction func slided(_ sender: UISlider) {
        print("Slider number \(sender.tag) changed to value \(sender.value)")
        
        //This is the master so we treat it sepretly
        if(sender.tag == 6){
            self.engine.mainMixerNode.outputVolume = sender.value
        } else {
            //Let's handle all the other sliders since the tags match the players array indices
            self.players[sender.tag].volume = sender.value
        }
        
    }
    
    @IBAction func switched(_ sender: UISwitch) {
        
        print("Toggle number \(sender.tag) changed to \(sender.state.rawValue)")
        
        //Handle the master since
        if(sender.tag == 6){
            
            //Iterate over the slider array and find a match based on tag
            for slider in self.sliders{
                //We found a match
                if(slider.tag == sender.tag){
                    if(!sender.isOn){
                        slider.setValue(0.0, animated: true)
                        slider.isEnabled = false
                        self.engine.mainMixerNode.outputVolume = 0.0
                    } else {
                        slider.setValue(1.0, animated: true)
                        slider.isEnabled = true
                        self.engine.mainMixerNode.outputVolume = 1.0
                    }
                }
                
            }
        } else {
            
            //Iterate over the slider array and find a match based on tag
            for slider in self.sliders{
                //We found a match
                if(slider.tag == sender.tag){
                    if(!sender.isOn){
                        slider.setValue(0.0, animated: true)
                        slider.isEnabled = false
                        self.players[sender.tag].volume = 0.0
                    } else {
                        slider.setValue(1.0, animated: true)
                        slider.isEnabled = true
                        self.players[sender.tag].volume = 1.0
                    }
                }
                
            }
        }
        
    }
    
    
    //AV Audio Engine
    let engine: AVAudioEngine = AVAudioEngine()
    
    //AV Audio player instances
    var players : [AVAudioPlayerNode] = []
    
    //File names
    let fileNames: [String] = [
        "bass1", "bass2", "beats1", "beats2", "synth1", "synth2"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load all the buffers
        for file in self.fileNames{
            if let buffer = loadAudioBuffer(file){
                
                //Sanity check
                //print(buffer)
                
                //Create a player node and lower the volume
                let player = AVAudioPlayerNode()
                player.volume = 0.0
                
                //Push it back to the players array
                self.players.append(player)
                
                //Attach the player to the engine and connect it to the main mixer
                self.engine.attach(player)
                self.engine.connect(player,
                                    to: self.engine.mainMixerNode,
                                    format: buffer.format)
                
                //Scheduale it now
                player.scheduleBuffer(buffer,
                                      at: nil,
                                      options: AVAudioPlayerNodeBufferOptions.loops,
                                      completionHandler: nil)
                
            } else {
                //Send an error to the queue
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Sorry", message: "Could not read buffer", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alertController, animated: true, completion: nil)
                }
            }

        }
        
        //Start the engine
        try? self.engine.start()
        
        //Play everything
        for player in self.players{
            player.play()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadAudioBuffer(_ name: String) -> AVAudioPCMBuffer?{
        
        //The path to file into an optional URL
        if let url = Bundle.main.url(forResource: name, withExtension: "wav"){
            print(url)
            //Load the audio file
            let audioFile = try! AVAudioFile(forReading: url)
            
            //Create the buffer
            if let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length)){
                try! audioFile.read(into: buffer)
                
                return buffer
            }
    
        }
        //Return the nil
        return nil
    }
    
}

