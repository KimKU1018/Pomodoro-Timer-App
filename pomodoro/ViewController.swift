//
//  ViewController.swift
//  pomodoro
//
//  Created by KU Kim on 2023/01/26.
//

import UIKit
import AVFoundation

enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progreeView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var toggelButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var duration = 60
    var timerStatus: TimerStatus = .end
    var timer: DispatchSourceTimer?
    var currentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTobbleButton()
        
    }
    
    func setTimerInfoViewVisble(isHidden: Bool){
        self.timerLabel.isHidden = isHidden
        self.progreeView.isHidden = isHidden
    }
    
    func configureTobbleButton() {
        self.toggelButton.setTitle("시작", for: .normal)
        self.toggelButton.setTitle("일시정지", for: .selected)
    }
    
    func startTimer() {
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1)
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else {return}
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600
                let minutes = (self.currentSeconds % 3600) / 60
                let second = (self.currentSeconds % 3600) % 60
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, second)
                self.progreeView.progress = Float(self.currentSeconds) / Float(self.duration)
                
                if self.currentSeconds <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    func stopTimer() {
        if self.timerStatus == .pause{
            self.timer?.resume()
        }
        self.timerStatus = .end
        self.cancelButton.isEnabled = false
        self.setTimerInfoViewVisble(isHidden: true)
        self.datePicker.isHidden = false
        self.toggelButton.isSelected = false
        self.timer?.cancel()
        self.timer = nil
    }
    
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        switch self.timerStatus {
        case .start, .pause:
            self.stopTimer()
            
        default:
            break
        }
    }
    
    
    @IBAction func tapToggelButton(_ sender: UIButton) {
        self.duration = Int(self.datePicker.countDownDuration)
        switch self .timerStatus{
        case .end:
            self.currentSeconds = self.duration
            self.timerStatus = .start
            self.setTimerInfoViewVisble(isHidden: false)
            self.datePicker.isHidden = true
            self.toggelButton.isSelected = true
            self.cancelButton.isEnabled = true
            self.startTimer()
            
        case .start:
            self.timerStatus = .pause
            self.toggelButton.isSelected = false
            self.timer?.suspend()
            
        case .pause:
            self.timerStatus = .start
            self.toggelButton.isSelected = true
            self.timer?.resume()
        }
    }
    
}

