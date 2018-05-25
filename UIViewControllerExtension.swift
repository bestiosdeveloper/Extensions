//
//  UIViewControllerExtension.swift
//
//  Created by Pramod Kumar on 19/09/17.
//  Copyright © 2017 Pramod Kumar. All rights reserved.
//


import Foundation
import UIKit
import AssetsLibrary
import AVFoundation
import Photos
import PhotosUI

extension UIViewController {
    func hideNavigationItem(isHidden: Bool){
        self.navigationController?.isNavigationBarHidden = isHidden
        Globals.vemeRootNavController?.isNavigationBarHidden = isHidden
    }
}

extension UIViewController{
    
    ///Adds Child View Controller to Parent View Controller
    func add(childViewController:UIViewController){
        
        self.addChildViewController(childViewController)
        let frame = self.view.bounds
//        frame.size.height -= UIDevice.bottomPaddingFromSafeArea
        childViewController.view.frame = frame
        self.view.addSubview(childViewController.view)
        
        childViewController.didMove(toParentViewController: self)
    }
    
    ///Removes Child View Controller From Parent View Controller
    var removeFromParentVC:Void{
        
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    ///Updates navigation bar according to given values
    func updateNavigationBar(withTitle title:String? = nil, leftButton:UIBarButtonItem? = nil, rightButton:UIBarButtonItem? = nil, tintColor:UIColor? = nil, barTintColor:UIColor? = nil, titleTextAttributes: [NSAttributedStringKey : Any]? = nil){
        
        self.navigationController?.isNavigationBarHidden = false
        if let tColor = barTintColor{
            self.navigationController?.navigationBar.barTintColor = tColor
        }
        if let tColor = tintColor{
            self.navigationController?.navigationBar.tintColor = tColor
        }
        if let button = leftButton{
            self.navigationItem.leftBarButtonItem = button;
        }
        if let button = rightButton{
            self.navigationItem.rightBarButtonItem = button;
        }
        if let ttle = title{
            self.title = ttle
        }
        if let ttleTextAttributes = titleTextAttributes{
            self.navigationController?.navigationBar.titleTextAttributes =   ttleTextAttributes
        }
    }
    ///Not using static as it won't be possible to override to provide custom storyboardID then
    class var storyboardID : String {
        
        return "\(self)"
    }
    
    ///function to push the target from navigation Stack
    func pushToController(_ viewController:UIViewController, animated:Bool = true){
        
        var navigationVC:UINavigationController?
        if let navVC = self as? UINavigationController{
            navigationVC = navVC
        }
        else{
            navigationVC = self.navigationController
        }
        navigationVC?.pushViewController(viewController, animated: animated)
    }
    
    ///function to pop the target from navigation Stack
    
    func popToController(_ viewController:UIViewController? = nil, animated:Bool = true) {
        
        var navigationVC:UINavigationController?
        if let navVC = self as? UINavigationController{
            navigationVC = navVC
        }
        else{
            navigationVC = self.navigationController
        }
        
        if let vc = viewController{
            _ = navigationVC?.popToViewController(vc, animated: animated)
        }
        else{
            _ = navigationVC?.popViewController(animated: animated)
        }
    }
    
    func popToController(atIndex index:Int, animated:Bool = true) {
        
        var navigationVC:UINavigationController?
        if let navVC = self as? UINavigationController{
           navigationVC = navVC
        }
        else{
           navigationVC = self.navigationController
        }
        
        if let navVc = navigationVC, navVc.viewControllers.count > index{
            
            _ = navVc.popToViewController(navVc.viewControllers[index], animated: animated)
        }
    }
    
    func popToRootController(animated:Bool = true) {
        
        var navigationVC:UINavigationController?
        if let navVC = self as? UINavigationController{
            navigationVC = navVC
        }
        else{
            navigationVC = self.navigationController
        }
        _ = navigationVC?.popToRootViewController(animated: animated)
    }
    
    // Take image from gallery or Camera
    func captureImage(delegate:(UIImagePickerControllerDelegate & UINavigationControllerDelegate)?,
                      photoGallary:Bool = true,
                      camera:Bool = true,
                      cameraDevice: UIImagePickerControllerCameraDevice = .rear) {
        
        let alertController = UIAlertController(title: "Choose from options", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if photoGallary {
            
            let alertActionGallery = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                self.checkAndOpenLibrary(delegate: delegate)
            }
            alertController.addAction(alertActionGallery)
        }
        
        if camera{
            let alertActionCamera = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                
                !UIDevice.isSimulator ? self.checkAndOpenCamera(delegate: delegate, cameraDevice: cameraDevice):self.checkAndOpenLibrary(delegate: delegate)
            }
            alertController.addAction(alertActionCamera)
        }
        let alertActionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
            
        }
        alertController.addAction(alertActionCancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkAndOpenCamera(delegate:(UIImagePickerControllerDelegate & UINavigationControllerDelegate)?, cameraDevice: UIImagePickerControllerCameraDevice = .rear) {
        
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == AVAuthorizationStatus.authorized {
            let image_picker = UIImagePickerController()
            image_picker.delegate = delegate
            let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera

            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                image_picker.sourceType = sourceType
                if image_picker.sourceType == UIImagePickerControllerSourceType.camera {
                    image_picker.allowsEditing = true
                    image_picker.showsCameraControls = true
                }
                
                if UIImagePickerController.isCameraDeviceAvailable(cameraDevice) {
                    image_picker.cameraDevice = cameraDevice
                }
                else {
                    image_picker.cameraDevice = .rear
                }
                self.present(image_picker, animated: true, completion: nil)
            }
            else if !UIDevice.isSimulator{
                
                self.showAlert(title: "", message: "Camera not available", buttonTitle: "OK", onCompletion: nil)
            }
        }
        else {
            if authStatus == AVAuthorizationStatus.notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {(granted: Bool) in                DispatchQueue.main.async(execute: {                    if granted {
                    let image_picker = UIImagePickerController()
                    image_picker.delegate = delegate
                    let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
                    if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                        image_picker.sourceType = sourceType
                        if image_picker.sourceType == UIImagePickerControllerSourceType.camera {
                            image_picker.allowsEditing = true
                            image_picker.showsCameraControls = true
                        }
                        self.present(image_picker, animated: true, completion: nil)
                    }
                    else if !UIDevice.isSimulator{
                        self.showAlert(title: "", message: "Camera not available", buttonTitle: "OK", onCompletion: nil)
                    }
                    }
                    
                })
                    
                })
            }
            else {
                if authStatus == AVAuthorizationStatus.restricted {
                    
                    let alertController = UIAlertController(title: "", message: "You have been restricted from using the camera on this device Without camera access this feature wont work", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let alertActionSettings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                        UIApplication.openSettingsApp
                    }
                    let alertActionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                    }
                    alertController.addAction(alertActionSettings)
                    alertController.addAction(alertActionCancel)
                    self.present(alertController, animated: true, completion: nil)
                }
                else {
                    
                    let alertController = UIAlertController(title: "", message: "Please change your privacy setting from the Settings app and allow access to camera", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let alertActionSettings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                        UIApplication.openSettingsApp
                    }
                    let alertActionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                    }
                    alertController.addAction(alertActionSettings)
                    alertController.addAction(alertActionCancel)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func checkAndOpenLibrary(delegate:(UIImagePickerControllerDelegate & UINavigationControllerDelegate)?) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            
            let image_picker = UIImagePickerController()
            image_picker.delegate = delegate
            let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
            image_picker.sourceType = sourceType
            image_picker.allowsEditing=true
            self.present(image_picker, animated: true, completion: nil)
            
        //handle authorized status
        case .denied:
            
            let alertController = UIAlertController(title: "", message: "Please change your privacy setting from the Settings app and allow access to library", preferredStyle: UIAlertControllerStyle.alert)
            
            let alertActionSettings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                UIApplication.openSettingsApp
            }
            let alertActionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
            }
            alertController.addAction(alertActionSettings)
            alertController.addAction(alertActionCancel)
            self.present(alertController, animated: true, completion: nil)
            
        case .restricted :
            
            let alertController = UIAlertController(title: "", message: "You have been restricted from using the library on this device Without camera access this feature wont work", preferredStyle: UIAlertControllerStyle.alert)
            
            let alertActionSettings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                UIApplication.openSettingsApp
            }
            let alertActionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
            }
            alertController.addAction(alertActionSettings)
            alertController.addAction(alertActionCancel)
            self.present(alertController, animated: true, completion: nil)
            
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                self.checkAndOpenLibrary(delegate: delegate)
            }
        }
    }
    
    func showAlert(title:String, message: String , successButtonTitle:String, cancelButtonTitle:String , onCompletion completion: @escaping (Bool)->Void){
        
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
        let doneAction = UIAlertAction(title:successButtonTitle, style: .default) { (_) -> Void in
            completion(true)
        }
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .destructive) { (_) in
            completion(false)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil);
    }
    
    func showAlert(title:String, message: String , buttonTitle:String, onCompletion completion: (()->Void)?){
        
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
        let doneAction = UIAlertAction(title:buttonTitle, style: .cancel) { (_) -> Void in
            completion?()
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil);
    }
}

