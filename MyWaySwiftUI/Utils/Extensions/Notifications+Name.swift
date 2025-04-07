//
//  Notifications+Ext.swift
//  MyWaySwiftUI
//
//  Created by Matthias Wüst on 20.03.2025.
//


//
//  NotificationExtension.swift
//  MyWayMockup
//
//  Created by Luciano Butera on 15.02.23.
//  Copyright © 2023 SBV-FSA. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    // IAP Notifications
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
    static let IAPHelperRestoreNotification = Notification.Name("IAPHelperRestoreNotification")
    static let IAPHelperRefreshNotification = Notification.Name("IAPHelperRestoreNotification")
    
    // Speech Notifications
    static let endOfSpeechNotification = Notification.Name("EndOfSpeechNotification")
    
    // GPS Notifications
    static let currentAddressChanged = Notification.Name("currentAddressChanged")
    
    // Navigation Notification
    static let navSetNewPointIndex = Notification.Name("NavSetNewPointIndex")
    static let navUpdateAdvices = Notification.Name("NavUpdateAdvices")
    static let navPointMissed = Notification.Name("NavPointMissed")
    static let navError = Notification.Name("NavigationError")

}
