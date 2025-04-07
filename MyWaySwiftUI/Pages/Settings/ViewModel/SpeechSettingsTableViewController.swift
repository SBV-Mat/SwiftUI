//
//  SpeechSettingsTableViewController.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//


//
//  SpeechSettingsTableViewController.swift
//  MyWayMockup
//
//  Created by anwender on 21.03.20.
//  Copyright © 2020 SBV-FSA. All rights reserved.
//


import UIKit
import AVFoundation

let SpeechSettingsCellIdentifier = "SpeechSettingsCellIdentifier"
let SpeechRateDidChangeNotification = "SpeechRateDidChangeNotification"
let SpeechVoiceDidChangeNotification = "SpeechVoiceDidChangeNotification"
let SpeechSettingsLanguageKey = "SpeechSettingsLanguageKey"
let SpeechSettingsRateKey = "SpeechSettingsRateKey"
let SpeechSettingsVoiceKey = "SpeechSettingsVoiceKey"
let UDKeySpeechSettingsVoicesDict = "UDKeySpeechSettingsLanguagesDict"
let UDKeySpeechSettingsRatesDict = "UDKeySpeechSettingsRatesDict"

class SpeechSettingsTableViewController: UITableViewController {
    
    var voices = [AVSpeechSynthesisVoice]()
    var rateValueAtStart:Float = 0.5;
    
    //MARK: - UI Properties
    lazy var doneButton : UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SpeechSettingsTableViewController.doneButtonAction(_:)))
        return item
    }()
    
    lazy var speechRateSlider : UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(SpeechSettingsTableViewController.speechRateSliderDidChangeValue(_:)), for: .valueChanged)
        return slider
    }()
    
    var languageCode = LanguageCode.None {
        didSet {
            // setup view controller title
            switch self.languageCode {
           case .German: self.title = NSLocalizedString("Deutsch", comment: "Titel der deutschen Vorlese-Einstellungen.")
            case .English: self.title = NSLocalizedString("Englisch", comment: "Titel der englischen Vorlese-Einstellungen.")
            case .French: self.title = NSLocalizedString("Französisch", comment: "Titel der französischen Vorlese-Einstellungen.")
           
            case .Italian: self.title = NSLocalizedString("Italienisch", comment: "Titel der italienischen Vorlese-Einstellungen.")
            case .None: self.title = NSLocalizedString("Sprache", comment: "Titel der Vorlese-einstellungen ohne konkrete Sprache.")
            
            }
            
            // setup speech rate slider value
            var rate = AVSpeechUtteranceDefaultSpeechRate
            if let rateDict = UserDefaults.standard.dictionary(forKey: UDKeySpeechSettingsRatesDict) {
                if let rateNumber = rateDict[self.languageCode.rawValue] as? NSNumber {
                    rate = rateNumber.floatValue
                }
            }
            let range = AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceMinimumSpeechRate
            let value = (rate - AVSpeechUtteranceMinimumSpeechRate) / range
            self.speechRateSlider.value = value
            
            // get available voices:
            self.voices = SpeechSettingsTableViewController.voicesForLanguageCode(self.languageCode)
            
            // reload table view:
            self.tableView.reloadData()
        }
    }
        
    //MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.doneButton
        
        // configure the table view
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: SpeechSettingsCellIdentifier)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.rateValueAtStart = self.speechRateSlider.value;
        print("der aktuelle wert des Sliders ist: \(self.speechRateSlider.value)");
    
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 0
        if self.languageCode != .None {
            sections = 2
        }
        return sections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch section {
        case 0: rows = self.voices.count
        case 1: rows = 1
        default: break
        }
        
        return rows
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title : String?
        
        switch section {
        case 0: title = NSLocalizedString("Vorlese-Stimme", comment: "Zwischenüberschrift in Vorlese-einstellungen.")
        case 1: title = NSLocalizedString("Geschwindigkeit", comment: "Überschrift in Stimmen-Einstellungen.")
        default: break
        }
        
        return title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpeechSettingsCellIdentifier, for: indexPath)
        
        // Configure the cell...
        switch indexPath.section {
        case 0:
            if let voice = self.voiceForIndexPath(indexPath) {
                let name : String
                if #available(iOS 9, *) {
                    name = voice.name
                } else {
                    name = voice.language
                }
                
                cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
                cell.textLabel?.text = name
                
                if let selectedVoice = SpeechSettingsTableViewController.selectedVoiceForLanguageCode(self.languageCode) {
                    if voice == selectedVoice {
                        cell.accessoryType = .checkmark
                        cell.accessibilityTraits = UIAccessibilityTraits(rawValue: UIAccessibilityTraits.button.rawValue | UIAccessibilityTraits.selected.rawValue)
                    } else {
                        cell.accessoryType = .none
                        cell.accessibilityTraits = UIAccessibilityTraits.button
                    }
                }
            }
        case 1:
            cell.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0)
            cell.addSubview(self.speechRateSlider)
            self.speechRateSlider.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44.0)
        default:
            break
        }
        
        return cell
    }
    
    func voiceForIndexPath (_ indexPath : IndexPath) -> AVSpeechSynthesisVoice? {
        if indexPath.section != 0 { return nil }
        
        var voice : AVSpeechSynthesisVoice? = nil
        let row = indexPath.row
        if row < self.voices.count {
            voice = self.voices[row]
        }
        
        return voice
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let voice = self.voiceForIndexPath(indexPath) else { return }
        
        // Save selection to user defaults:
        let name : String
        if #available(iOS 9, *) {
            name = voice.identifier
        } else {
            name = voice.language
        }
        
        var voiceDict : [String : AnyObject]
        if let dict = UserDefaults.standard.dictionary(forKey: UDKeySpeechSettingsVoicesDict) {
            voiceDict = dict as [String : AnyObject]
            voiceDict[self.languageCode.rawValue] = name as AnyObject?
        } else {
            voiceDict = [self.languageCode.rawValue : name as AnyObject]
        }
        
        UserDefaults.standard.set(voiceDict, forKey: UDKeySpeechSettingsVoicesDict)
        UserDefaults.standard.synchronize()
        
        // reload table view data:
        tableView.reloadData()
        
        // post notification:
        let info = [SpeechSettingsLanguageKey : self.languageCode.rawValue, SpeechSettingsVoiceKey: name]
        NotificationCenter.default.post(name: Notification.Name(rawValue: SpeechVoiceDidChangeNotification), object: self, userInfo: info)
    }
    
    //MARK: - Button Actions
    override func accessibilityPerformEscape () -> Bool {
        self.doneButtonAction(nil)

        return true
    }
    
    @objc func doneButtonAction (_ sender : AnyObject?) {
        if(rateValueAtStart != self.speechRateSlider.value) {
            //Slider wurde angepasst
             NotificationCenter.default.post(name: Notification.Name(rawValue: SpeechRateDidChangeNotification), object: self, userInfo: nil)
        }
        
        if let controller = self.navigationController?.presentingViewController {
            controller.dismiss(animated: true, completion: {})
        }
        else if let controller = self.presentingViewController {
            controller.dismiss(animated: true, completion: {})
        }
    }
    
    @objc func speechRateSliderDidChangeValue (_ sender : AnyObject?) {
        let value = self.speechRateSlider.value
        let range = AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceMinimumSpeechRate
        let rate = value * range + AVSpeechUtteranceMinimumSpeechRate
        let rateNumber = NSNumber(value: rate as Float)
        
        if var rateDict = UserDefaults.standard.dictionary(forKey: UDKeySpeechSettingsRatesDict) {
            rateDict[self.languageCode.rawValue] = rateNumber
            UserDefaults.standard.set(rateDict, forKey: UDKeySpeechSettingsRatesDict)
        } else {
            let rateDict = [self.languageCode.rawValue : rateNumber]
            UserDefaults.standard.set(rateDict, forKey: UDKeySpeechSettingsRatesDict)
        }
        UserDefaults.standard.synchronize()
        
        //let info = [SpeechSettingsLanguageKey : self.languageCode.rawValue, SpeechSettingsRateKey : rateNumber] as [String : Any]
       // NotificationCenter.default.post(name: Notification.Name(rawValue: SpeechRateDidChangeNotification), object: self, userInfo: info)
    }
    
    //MARK: - Class Methods
    static func selectedSpeechRateForLanguageCode (_ languageCode : LanguageCode) -> Float? {
        var rate = MyWayConstants.AVSpeechConstants.AVSpeechRate
        if let rateDict = UserDefaults.standard.dictionary(forKey: UDKeySpeechSettingsRatesDict) {
            if let rateNumber = rateDict[languageCode.rawValue] as? NSNumber {
                rate = rateNumber.floatValue
            }
        }
        
        return rate
    }
    
    static func selectedVoiceForLanguageCode (_ languageCode : LanguageCode) -> AVSpeechSynthesisVoice? {
        var voice : AVSpeechSynthesisVoice? = nil
        if let voiceDict = UserDefaults.standard.dictionary(forKey: UDKeySpeechSettingsVoicesDict) {
            if let code = voiceDict[languageCode.rawValue] as? String {
                print("Wir haben hier den code: \(code)");
                if #available(iOS 9, *) { voice = AVSpeechSynthesisVoice(identifier: code) }
                else { voice = AVSpeechSynthesisVoice(language: code) }
            }
        }
        
        /*
        if voice == nil {
            let voices = SpeechSettingsTableViewController.voicesForLanguageCode(languageCode)
            voice = voices.first
        }
        */
        
        return voice
    }
    
    static func voicesForLanguageCode (_ languageCode : LanguageCode) -> [AVSpeechSynthesisVoice] {
        var voices = [AVSpeechSynthesisVoice]()
        if languageCode == .None { return voices }
        
        let id = languageCode.rawValue
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            let language : String = voice.language
            let startIndex = language.startIndex
            let endIndex = language.index(startIndex, offsetBy: 1)
            let code = language[startIndex ... endIndex]
            if id == code {
                voices.append(voice)
            }
        }
        
        return voices
    }
    
}
