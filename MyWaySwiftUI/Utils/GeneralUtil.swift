//
//  GeneralUtil.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//


//
//  GeneralUtil.swift
//  MyWayMockup
//
//  Created by Erkan Kuzucular on 02.05.18.
//  Copyright © 2018 SBV-FSA. All rights reserved.
//

import Foundation
import UIKit

/// Klasse zur Bereitstellung von generellen Helper-Methoden wie z.B. Selektion des Tagesdatums. Static-Methoden, um Aufruf überal aus Projekt zu ermöglichen
class GeneralUtil {
    
    // MARK: Declaration
    /// Setzen eines Status-Text zur Anzeige in Alerts im ganzen Projekt und übergreifenden Masken
    static var statusText: String = "Hallo, wie geht es dir?";
    
    
    // MARK: Class-Methods
    
    /// Gibt das aktuelle Tagesdatum und Uhrzeit in einem bestimmten Format zurück
    /// - Returns: Tagesdatum im Format 10. Juli 2019 15:07:04
    class func getSysdate() -> String {
        
        let sysdate = Date();
        let dateFormat = DateFormatter();
        //Damit er das Datum richtig liest in der Routenuebersicht, haben wir das Format gewechselt
        dateFormat.dateFormat = "d. MMMM yyyy H:mm:ss"; //10. Juli 2019 15:07:04
        dateFormat.locale = Locale(identifier: "de_CH");
        let dateString =  dateFormat.string(from: sysdate as Date);
        
        return dateString;
        
    }
    
    
    static func getStatusText() -> String {
    
        return self.statusText;
        
    }
    
    
    static func setStatusText(statusText: String)  {
        
        self.statusText = statusText;
        
    }
    

    
    /// Anzeige eines Alerts. Kann im ganzen Projekt verwendet werden, da unabhängig der aufrufenden View
    /// - Parameters:
    ///   - alertTitle: Title des Alert-Fenster
    ///   - alertMessage: Meldung des Alert-Fensters
    ///   - animated: Soll das Fenster animiert sein oder nicht?
    ///   - viewController: Die Aufrufende View. Nil, wenn keine View, dann wird programmatisch bestimmt, welche View aktuell angezeigt wird
    static func displayAlert(alertTitle: String, alertMessage: String, animated: Bool, viewController: UIViewController?) {
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            
            //Sicherstellen das es auch zu geht
            alertController.dismiss(animated: false, completion: nil);
            
            
        })
        
        alertController.addAction(okAction);
        
        //Wenn der Aufrufer keine View ist, da nicht bekannt, dann wird einfach die Rootview gesucht.
        if(viewController == nil) {
            if let viewControllerRoot = UIApplication.shared.keyWindow?.rootViewController {
                viewControllerRoot.present(alertController, animated: animated, completion: nil);
            }
        } else {
            
            //View ist bekannt, daher auf dieser View den Alert presentieren
            viewController!.present(alertController, animated: animated, completion: nil);
        }
    }
    
    /// Anzeige eines Alerts, welche nach bestimmter Anzahl Sekunden wieder automatisch disappeared
    /// - Parameters:
    ///   - alertTitle: Title des Alerts
    ///   - alertMessage: Meldung des Alerts
    ///   - animated: Soll der Alert animiert sein?
    ///   - viewController: Die Aufrufende View. Wenn keine View, dann mitgabe von NIL. Dann wird programmatisch bestimmt, welche Root-View es ist
    static func displayDismissAlert(alertTitle: String, alertMessage: String, animated: Bool, viewController: UIViewController?) {
        
        let alertAutoDismiss  = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert);
        
        if(viewController == nil) {
            
            
            if let viewControllerRoot = UIApplication.shared.keyWindow?.rootViewController {
                
                
                viewControllerRoot.present(alertAutoDismiss, animated: animated, completion: nil);
                
            }
            
        }
            
        else {
            
            
            viewController!.present(alertAutoDismiss, animated: animated, completion: nil);
            
        }
        
        
        // Die View bleibt 2 Sekunden aufgepoppt, anschliessend wird diese dismissed
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            
            alertAutoDismiss.dismiss(animated: true, completion: nil)
        }
        
        
        
    }
    
    
    //Wird momentan nicht aufgerufen
    @objc func alertControllerBackgroundTapped(viewController: UIViewController)
    {
        
        viewController.dismiss(animated: true, completion: nil);
        
        
    }
    
}

