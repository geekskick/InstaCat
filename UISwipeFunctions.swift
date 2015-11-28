//
//  UISwipeFunctions.swift
//  InstaCat
//
//  Created by Patrick Mintram on 27/11/2015.
//  Copyright © 2015 Patrick Mintram. All rights reserved.
//

import UIKit

class UISwipeAction{
    enum Direction { case Left, Right, Stationary, ERROR}
    
    //var differenceInCoOrds  : CGPoint
    var previousTouchCoOrds : CGPoint
    var latestTouchCoOrds   : CGPoint
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
    
    func differenceInCoOrds() -> CGPoint{
        return CGPoint(x: latestTouchCoOrds.x - previousTouchCoOrds.x , y: latestTouchCoOrds.y - previousTouchCoOrds.y)
    }
}