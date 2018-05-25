//
//  UITableViewExtension.swift
//
//  Created by Pramod Kumar on 04/04/18.
//  Copyright © 2018 Pramod Kumar. All rights reserved.
//

import Foundation
//MARK:- UITableView Extension
extension UITableView {
    
    
    func registerCell(nibName:String, bundle:Bundle? = nil, forCellWithReuseIdentifier:String? = nil){
        
        let cellWithReuseIdentifier = forCellWithReuseIdentifier ?? nibName
        self.register(UINib(nibName: nibName , bundle: bundle), forCellReuseIdentifier: cellWithReuseIdentifier)
    }
    
    func cell(forItem: AnyObject) -> UITableViewCell? {
        if let indexPath = self.indexPath(forItem: forItem) {
            return self.cellForRow(at: indexPath)
        }
        return nil
    }
    
    func indexPath(forItem: AnyObject) -> IndexPath? {
        let itemPosition: CGPoint = forItem.convert(CGPoint.zero, to: self)
        return self.indexPathForRow(at: itemPosition)
    }
    
    func isRowPresentAt(index: IndexPath) -> Bool {
        if index.section < self.numberOfSections {
            if index.row < self.numberOfRows(inSection: index.section) {
                return true
            }
        }
        return false
    }
    func isSectionPresentAt(section: Int) -> Bool {
        if section < self.numberOfSections {
            return true
        }
        return false
    }
    
    func reloadSection(section: Int, with: UITableViewRowAnimation) {
        if self.isSectionPresentAt(section: section) {
            self.reloadSections(IndexSet(integer: section), with: with)
        }
        else {
            self.reloadData()
        }
    }
    
    func reloadRow(at: IndexPath, with: UITableViewRowAnimation) {
        if self.isRowPresentAt(index: at) {
            self.reloadRows(at: [at], with: with)
        }
        else {
            self.reloadData()
        }
    }
    
    ///pull to refresh
    public func enablePullToRefresh(tintColor: UIColor, target: UIViewController, selector: Selector){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(target, action: selector, for: UIControlEvents.valueChanged)
        refreshControl.tintColor = tintColor
        self.addSubview(refreshControl)
    }
}
