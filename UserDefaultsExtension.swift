//
//  UserDefaultsExtension.swift
//
//  Created by Pramod Kumar on 19/09/17.
//  Copyright © 2017 Pramod Kumar. All rights reserved.
//


import Foundation
import UIKit

//MARK:-
extension UserDefaults {
    
    ///Saves the given object with given key in the 'UserDefaults'
    class func setObject(_ object:Any?, forKey key:String?){
        
        guard let ky = key, let objct = object else { return }
        UserDefaults.standard.set(objct, forKey: ky)
        self.standard.synchronize()
    }
    
    ///Gets value ( if any ) from user defaults
    class func getObject(forKey key:String?)-> Any?{
        
        guard let ky = key else { return nil}
        return self.standard.object(forKey: ky)
    }
    ///Removes object ( if any ) from user defaults
    class func removeObject(forKey key:String?){
        
        guard let ky = key else { return }
        UserDefaults.standard.removeObject(forKey: ky)
        self.standard.synchronize()
    }
    
    ///Saves the given color with given key in the 'UserDefaults'
    class func setColor(_ color: UIColor?, forKey key: String?) {
        
        guard let ky = key, let clr = color else { return }
        self.standard.set(NSKeyedArchiver.archivedData(withRootObject: clr), forKey: ky)
        self.standard.synchronize()
    }
    
    ///Gets color ( if any ) from user defaults
    class func getColor(forKey key: String?) -> UIColor? {
        guard let ky = key, let data = self.standard.data(forKey: ky) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
    }
    class func clear() {
        
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize()
    }
}

