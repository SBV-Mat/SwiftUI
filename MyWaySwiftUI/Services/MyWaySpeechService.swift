//
//  MyWaySpeechService.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//


//
//  SoundUtil.swift
//  MyWayMockup
//
//  Created by Erkan Kuzucular on 29.11.18.
//  Copyright © 2018 SBV-FSA. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox
import AVFoundation

/// Zentrale Klasse für die Steuerung der Sprachausgabe. Setzen von Audio-Session damit Ausgabe im Sperrbildschirm funktioniert etc. Singleton-Pattern
class MyWaySpeechService: NSObject {
    
    // MARK: Declaration
    public static var sharedInstance = MyWaySpeechService()
    private let avSpeechSynthesizer = AVSpeechSynthesizer()
    private var myWayRate = MyWayConstants.AVSpeechConstants.AVSpeechRate
    private var myWaySpeechVoice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
    private var currentSpeechLanguageCode = "de"
    private var lastCaller = MyWaySpeechMode.Unknown
    
    // Prevent clients from creating another instance of this Singleton.
    private override init() {
        super.init();
        avSpeechSynthesizer.delegate = self
    }
    
    // MARK: Class-Methods
    
    /// Konfigurieren der Audio-Session, damit die Sprachausgabe auch im Hintegrund (App minimiert oder Sperrbildschirm) läuft. Wird in der Routennavigation und HomeScreen verwendet
    internal func setAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            
            //Damit die Audio-Ausgabe auch im Hintergrund-Funktioniert!!
            //Hier mussten wir auf PlayAndRecord umstellen. Obwohl wir nix aufnehmen. Aber damit auf Bluetooth-kopfhörer die Ausgabe funktioniert musste wir auch unter options die einstellungen einstellen. Mit dieser EInstellung wird der Sperrbildschirm auch nicht aktiv bei einer Ausgabe
            //Früher: multiRoute: Damit Sprachausgabe und Speech im Hintegrund funktioniert
            //Früher: .playback funktioniert auch. Beim Sprechen im Hintergrund wird aber Sperrbildschirm wieder aktiv und die Zeit wird vorgelesen
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode(rawValue: convertFromAVAudioSessionMode(AVAudioSession.Mode.default)), options: [.mixWithOthers, .allowAirPlay, .allowBluetoothA2DP,.defaultToSpeaker]);
            try audioSession.setActive(true);
        } catch {
            GeneralUtil.displayAlert(alertTitle: "AVAudioSessionCategoryPlayback-Error", alertMessage: "Error Loading AVAudioSessionCategoryPlayback, Error: \(error.localizedDescription)", animated: true, viewController: nil)
        }
    }
    
    /// Deaktivieren der AV-AudioSession. Wird deaktiviert wenn Views disappearen, damit Ressourcen freigegeben werden (In Routennavigation zB).
    internal func deactivateAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            GeneralUtil.displayAlert(alertTitle: "AVAudioSessionCategoryPlayback-Error", alertMessage: "Error Deactivating AVAudioSessionCategoryPlayback, Error: \(error.localizedDescription)", animated: true, viewController: nil)
        }
    }
    
    /// Beenden der Sprachausgabe
    /// - Parameter speechBoundary: Soll Ausgabe sofort (.immediate) oder nach einem Wort (.word) beendet werden? Alle Ausgaben in der Queue werden geleert
    func stopSpeechSyntesizer(speechBoundary: AVSpeechBoundary) {
        if lastCaller == .PoiObservation {
            self.avSpeechSynthesizer.stopSpeaking(at: speechBoundary);
        }
    }
    
    func setCurrentSpeechLanguageCode(currLangCode: String) {
        self.currentSpeechLanguageCode = currLangCode;
    }
    
    func getCurrentSpeechLanguageCode() -> String {
        return self.currentSpeechLanguageCode;
    }
    
    func setSpeechRate(speechRate: Float ) {
        myWayRate = min(speechRate, AVSpeechUtteranceMaximumSpeechRate);
        myWayRate = max(speechRate, AVSpeechUtteranceMinimumSpeechRate);
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromAVAudioSessionMode(_ input: AVAudioSession.Mode) -> String {
        return input.rawValue
    }
    
    func getSpeechRate() -> Float {
        return myWayRate;
    }
    
    /// Observer Obj-C Methode, welche signalisiert das der Nutzer in den Einstellungen Stimme geändert hat
    /// - Parameter notification: Notification
    @objc(speechVoiceDidChange:)
    func speechVoiceDidChange (_ notification : Notification?) {
        if let voice = SpeechSettingsTableViewController.selectedVoiceForLanguageCode(LanguageCode(rawValue: getCurrentSpeechLanguageCode())!) {
            self.myWaySpeechVoice = voice;
        }
    }
    
    /// Observer Obj-C Methode, welche signalisiert das der Nutzer in den Einstellungen Rate der Stimme geändert hat
    /// - Parameter notification: Notification
    @objc(speechRateDidChange:)
    func speechRateDidChange (_ notification : Notification?) {
        if let myWayRateLoc = SpeechSettingsTableViewController.selectedSpeechRateForLanguageCode(LanguageCode(rawValue: getCurrentSpeechLanguageCode())!) {
            
            setSpeechRate(speechRate: myWayRateLoc);
        }
    }
    
    /// Setzen von Variablen für den Synthesizer. Werte wie Geschwindigkeit der Sprachausgabe und Stimme werden hier gesetzt. (Ausgehend aus den eingestellten Parametern aus MyWay-Einstellungen)
    func setVariablesForAvSpeechSynth() {
        NotificationCenter.default.addObserver(self, selector: #selector(MyWaySpeechService.speechRateDidChange(_:)), name: NSNotification.Name(rawValue: SpeechRateDidChangeNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyWaySpeechService.speechVoiceDidChange(_:)), name: NSNotification.Name(rawValue: SpeechVoiceDidChangeNotification), object: nil)
        
        if let currSpeechLang = Locale.current.languageCode {
            setCurrentSpeechLanguageCode(currLangCode: currSpeechLang);
        }
        
        if let myWayRateLoc = SpeechSettingsTableViewController.selectedSpeechRateForLanguageCode(LanguageCode(rawValue: getCurrentSpeechLanguageCode())!) {
            
            setSpeechRate(speechRate: myWayRateLoc);
        } else {
            setSpeechRate(speechRate: MyWayConstants.AVSpeechConstants.AVSpeechRate);
        }
        
        //Voice-Stimme ist nicht gleich Stimme bei gesprochenen Inhalte. Diese Stimme hier (Background-Modus) ist eine andere. Das hier ist nämlich die Stimme der gesprochenen inhalte: Bildschirm vorlesen:
        // Bedienungshilfen / Gesprochene INhalte / Stimme / Deutsch
        if let voice = SpeechSettingsTableViewController.selectedVoiceForLanguageCode(LanguageCode(rawValue: getCurrentSpeechLanguageCode())!) {
            
            self.myWaySpeechVoice = voice;
        } else {
            self.myWaySpeechVoice =  AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode());
        }
    }
    
    /// Ausgabe einer Sprachausgabe. Stimme und Geschwindigkeit wird aus MyWayPro/Einstellungen gelesen
    /// - Parameters:
    ///   - textToSpeech: Text, welcher gesprochen werden soll
    ///   - routeDirectionPointObserving: Nutzer hat Funktion Punkte-Überwachen in Navigation ausgewählt
    ///   - pointObservingPointChange: Punktwechsel ist erfolgt während Routennavigation
    ///   - caller: Aufrufer dieser Methode
    func speechOutput(textToSpeech: String, caller: MyWaySpeechMode) {
        lastCaller = caller
        let utterance = AVSpeechUtterance(string: textToSpeech);
        utterance.pitchMultiplier = MyWayConstants.AVSpeechConstants.AVSpeechPitch;
        
        //Wir haben volume auskommentiert. Wenn andere Applikation wie zB Komoot im Hintergrund läuft und hier volume definiert ist, erfolgt die Ausgabe in MyWay in einer geringeren Lautstärke, daher auskommentiert damit default-lautstärke (das was grad eingestellt) genommen wird
        //utterance.volume = MyWayConstants.AVSpeechConstants.AVSpeechVolume;
        utterance.rate = myWayRate;
        utterance.voice = myWaySpeechVoice;
        
        if(caller == .PoiObservation && !avSpeechSynthesizer.isSpeaking) {
            //Nutzer ist in der Home-Maske. Alle bisherigen Ausgaben stoppen, Neuen Text ausgeben und Ausstieg.
            avSpeechSynthesizer.stopSpeaking(at: .immediate)
            avSpeechSynthesizer.speak(utterance);
            return;
        }
        
        if(caller == .PoiObservation || caller == .Unknown) {
            return
        }
        
        if avSpeechSynthesizer.isSpeaking {
            if caller == .UnsortedNavigation {
                //Da er im Hintergrund viel redet wenn Punkte überwachen, wird das was er am sagen ist beendet, damit der neue Text gesprochen werden kann
                //Cache leeren
                avSpeechSynthesizer.stopSpeaking(at: .immediate);
                avSpeechSynthesizer.speak(utterance);
                avSpeechSynthesizer.continueSpeaking();
            } else {
                avSpeechSynthesizer.pauseSpeaking(at: .word)
                avSpeechSynthesizer.speak(utterance);
                avSpeechSynthesizer.continueSpeaking();
            }
        } else {
            self.avSpeechSynthesizer.speak(utterance);
        }
    }
    
    func speakText(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.pitchMultiplier = MyWayConstants.AVSpeechConstants.AVSpeechPitch;
        
        //Wir haben volume auskommentiert. Wenn andere Applikation wie zB Komoot im Hintergrund läuft und hier volume definiert ist, erfolgt die Ausgabe in MyWay in einer geringeren Lautstärke, daher auskommentiert damit default-lautstärke (das was grad eingestellt) genommen wird
        //utterance.volume = MyWayConstants.AVSpeechConstants.AVSpeechVolume;
        utterance.rate = myWayRate;
        utterance.voice = myWaySpeechVoice;
        avSpeechSynthesizer.speak(utterance);
    }
    
    /// Abspielen eines Systemton
    /// - Parameter systemSoundId: Die SystemId des Tons. Bsp: 1000: Mail Received Ton / 1001: Zischgeräusch.
    func playSystemSound(systemSoundId: SystemSoundID) {
        let systemSoundId: SystemSoundID = systemSoundId;
        AudioServicesPlaySystemSound(systemSoundId)
    }
    
    func vibrateDevice(includeHapticFeedback: Bool = false) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        if(includeHapticFeedback) {
            //Zusätzlich noch haptisch, wenn Punkt erreicht wird
            AudioServicesPlaySystemSound(1520);
        }
    }
    
    func isSpeaking() -> Bool {
        return avSpeechSynthesizer.isSpeaking
    }
    
}

enum MyWaySpeechMode {
    case PoiObservation, SortedNavigation, UnsortedNavigation, Unknown
}

extension MyWaySpeechService: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        NotificationCenter.default.post(name: .endOfSpeechNotification, object: self)
    }
}
