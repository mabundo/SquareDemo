/*
 * Copyright 2013 shrtlist.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import CoreData
import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?

    // MARK: Core Data stack
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
        
        if let mom = self.managedObjectModel {
            _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
            
            let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("UniversalDemo.sqlite")
            
            do {
                try _persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            }
            catch {
                print(error)
                
                do {
                    // In case of an error, delete the existing store and create a new one.
                    try NSFileManager.defaultManager().removeItemAtURL(storeURL)
                    
                    _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
                    
                    do {
                        try _persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL: storeURL, options: nil)
                    }
                    catch {
                        print(error)
                    }
                }
                catch {
                    print(error)
                }
            }
        }
        
        return _persistentStoreCoordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return moc
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel? = {
        var mom: NSManagedObjectModel?
        if let modelURL = NSBundle.mainBundle().URLForResource("UniversalDemo", withExtension: "momd") {
            mom = NSManagedObjectModel(contentsOfURL: modelURL)
        }
        
        return mom
    }()

    // MARK: UIApplicationDelegate protocol conformance
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let splitViewController = window?.rootViewController as! UISplitViewController
        splitViewController.delegate = self
        
        let masterNavigationController = splitViewController.viewControllers.first as! UINavigationController
        let masterViewController = masterNavigationController.topViewController as! MasterViewController
        masterViewController.managedObjectContext = managedObjectContext
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
            let detailNavigationController = splitViewController.viewControllers.last as! UINavigationController
            detailNavigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        }
        
        return true
    }

    // MARK: Application's Documents directory

    private var applicationDocumentsDirectory: NSURL {
        get {
            return NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last!
        }
    }
    
    // MARK: UISplitViewControllerDelegate protocol conformance
    
    func targetDisplayModeForActionInSplitViewController(svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
        if (svc.displayMode == UISplitViewControllerDisplayMode.PrimaryOverlay || svc.displayMode == UISplitViewControllerDisplayMode.PrimaryHidden) {
            return UISplitViewControllerDisplayMode.AllVisible
        }
        
        return UISplitViewControllerDisplayMode.PrimaryHidden
    }

}
