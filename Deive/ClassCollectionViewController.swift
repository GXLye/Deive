//
//  ClassCollectionViewController.swift
//  Deive
//
//  Created by Lye Guang Xing on 8/16/15.
//  Copyright (c) 2015 Sweatshop. All rights reserved.
//

import UIKit

class ClassCollectionViewController: PFQueryCollectionViewController, RefreshViewDelegate {
   
    @IBOutlet weak var typeButton: UIButton!
    
    var type = 1
    var typeID = ["feudA4UtER", "oulMd3R3j3", "E06QrHpomy", "6QIF7bl0iy"]
    var typeName = ["Swordsman", "Archer", "Wizard", "Cleric"]
    
    required init(coder aDecoder:NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.pullToRefreshEnabled = false
        self.paginationEnabled = false
        
        self.parseClassName = "Class"
        
    }
    
    override func objectsWillLoad() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var query = PFQuery(className: "Class")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        object.pinInBackground()
                    }
                }
            } else {
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }

    }
    
    @IBAction func chooseType(sender: AnyObject) {
        self.performSegueWithIdentifier("pickerView", sender: self)
    }
    
    override func queryForCollection() -> PFQuery {
        var startup = NSUserDefaults.standardUserDefaults().boolForKey("firstTime")
        var query = PFQuery(className: "Class")
        
        if startup {
            query.fromLocalDatastore()
        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstTime")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        query.whereKey("Type", equalTo: type)
        query.whereKey("Rank", notEqualTo: 1)
        query.orderByAscending("Rank")
        query.addAscendingOrder("Category")
        
        return query
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let cell: ClassCollectionReusableView =
        collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Type", forIndexPath: indexPath) as! ClassCollectionReusableView
        
        // Setting Placeholders
        var initialThumbnail = UIImage(named: "Class 1")
        
        switch type {
        case 1:
            initialThumbnail = UIImage(named: "Class 1")
            cell.thumbBackground.image = UIImage(named: "White")
            cell.background.backgroundColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 235/255.0, alpha: 1.0)
            
        case 2:
            initialThumbnail = UIImage(named: "Class 2")
            cell.thumbBackground.image = UIImage(named: "Grey")
            cell.background.backgroundColor = UIColor(red: 213/255.0, green: 214/255.0, blue: 195/255.0, alpha: 1.0)
            
        case 3:
            initialThumbnail = UIImage(named: "Class 3")
            cell.thumbBackground.image = UIImage(named: "White")
            cell.background.backgroundColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 235/255.0, alpha: 1.0)
            
        case 4:
            initialThumbnail = UIImage(named: "Class 4")
            cell.thumbBackground.image = UIImage(named: "Grey")
            cell.background.backgroundColor = UIColor(red: 213/255.0, green: 214/255.0, blue: 195/255.0, alpha: 1.0)
        default:
            println("Invalid type")
        }
        
        cell.thumbnail.image = initialThumbnail
        
        var query = PFQuery(className: "Class")
        query.fromLocalDatastore()
        query.getObjectInBackgroundWithId(typeID[type-1]) {
            (classType: PFObject?, error: NSError?) -> Void in
            if error == nil && classType != nil {
                if let object = classType {
                    cell.name.text = object["Name"] as? String
                    cell.thumbnail.file = object["Thumbnail"] as? PFFile
                    cell.thumbnail.loadInBackground()
                }
            } else {
                var query2 = PFQuery(className: "Class")
                query2.getObjectInBackgroundWithId(self.typeID[self.type-1]) {
                    (classType2: PFObject?, error: NSError?) -> Void in
                    if error == nil && classType2 != nil {
                        if let object = classType2 {
                            cell.name.text = object["Name"] as? String
                            cell.thumbnail.file = object["Thumbnail"] as? PFFile
                            cell.thumbnail.loadInBackground()
                            
                            object.pinInBackground()
                        }
                    } else {
                        println(error)
                    }
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        
        let cell: ClassCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Class", forIndexPath: indexPath) as! ClassCollectionViewCell
        
        // Setting Placeholders
        var initialThumbnail = UIImage(named: "Class")
        cell.thumbnail.image = initialThumbnail
        
        if let classObj = object {
            cell.name.text = classObj["Name"] as? String
            cell.thumbnail.file = classObj["Thumbnail"] as? PFFile
            cell.thumbnail.loadInBackground()
        }
        
        switch type {
        case 1:
            cell.background.backgroundColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 235/255.0, alpha: 1.0)
            
        case 2:
            cell.background.backgroundColor = UIColor(red: 213/255.0, green: 214/255.0, blue: 195/255.0, alpha: 1.0)
            
        case 3:
            cell.background.backgroundColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 235/255.0, alpha: 1.0)
            
        case 4:
            cell.background.backgroundColor = UIColor(red: 213/255.0, green: 214/255.0, blue: 195/255.0, alpha: 1.0)
        default:
            println("Invalid type")
        }
        
        return cell
    }
    
    func updateClass(classType: Int) {
        type = classType
        typeButton.setTitle(typeName[type-1], forState: UIControlState.Normal)
        
        self.clear()
        self.loadObjects()
        self.collectionView?.reloadData()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "pickerView" {
            var pickerScene = segue.destinationViewController as! PickerViewController
            
            pickerScene.type = type
            pickerScene.refreshDelegate = self
        }
    }
}
