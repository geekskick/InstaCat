//
//  UISwipeFunctions.swift
//  InstaCat
//
//  Created by Patrick Mintram on 27/11/2015.
//  Copyright © 2015 Patrick Mintram. All rights reserved.
//

import UIKit

/// A custom class for the user swipe direction and speed
class UISwipeAction{
    
    /*!
    The different direction options
    */
    enum Direction { case Left, Right, Stationary, ERROR}
    
    /// The previous and latest touch co-ords in order to work out the differentce between them, and therefore the direction
    var previousTouchCoOrds : CGPoint
    var latestTouchCoOrds   : CGPoint
    
    /// A computed variable of the enum typed defines above
    var direction           : Direction{
        get{
            if(latestTouchCoOrds.x > previousTouchCoOrds.x){
                return .Right
            }
            else if(latestTouchCoOrds.x < previousTouchCoOrds.x){
                return .Left
            }
            else if(latestTouchCoOrds.x == previousTouchCoOrds.x){
                return .Stationary
            }
            else{
                return .ERROR
            }
        }
    }
    
    init(){
        self.previousTouchCoOrds = CGPoint(x: 0, y: 0)
        self.latestTouchCoOrds   = CGPoint(x: 0, y: 0)
    }
    
    /*!
    The differecce in the previous and last co-ordinates
    
    - returns: the difference as an (x, y) value
    */
    func differenceInCoOrds() -> CGPoint{
        return CGPoint(x: latestTouchCoOrds.x - previousTouchCoOrds.x , y: latestTouchCoOrds.y - previousTouchCoOrds.y)
    }
}