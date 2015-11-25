//
//  ViewController.swift
//  InstaCat
//
//  Created by Patrick Mintram on 25/11/2015.
//  Copyright © 2015 Patrick Mintram. All rights reserved.
//

import UIKit

class ViewController: UIViewController,NSURLSessionDelegate,NSURLSessionDataDelegate {

    @IBOutlet var pictureOfCat  : UIImageView!
    @IBOutlet var getButton     : UIButton!
    @IBOutlet var saveButton    : UIButton!
    @IBOutlet weak var progress : UIProgressView!
    @IBOutlet var labelURL      : UILabel!
    
    /// The download data buffer
    var buffer                  :NSMutableData = NSMutableData()
    /// The download session
    var session                 :NSURLSession?
    /// The task in the session
    var dataTask                :NSURLSessionDataTask?
    /// How long it's gonna take
    var expectedContentLength   = 0
    
    /*!
    Initialise the view
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.enabled = false
        progress.progress = 0
        progress.hidden = true
        pictureOfCat.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*!
    When the newcat button is pressed
    
    - parameter sender:	The new Cat button
    */
    @IBAction func newCatPressed(sender: AnyObject){
        
        /// Create a reqest to the URL
        let req = NSMutableURLRequest(URL: NSURL(string: "http://thecatapi.com/api/images/get?type=jpg")!)
        
        req.HTTPMethod = "GET";
        
        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        dataTask = session?.dataTaskWithRequest(req)
        
        /*!
        @brief  Hide the objects not needed or relevant
        */
        pictureOfCat.hidden = true
        progress.hidden = false
        getButton.enabled = false
        saveButton.enabled = false
        labelURL.hidden = true
        
        /*!
        Reset progress bar
        */
        progress.progress = 0
        
        /*!
        Unpause the thread
        */
        dataTask?.resume()
    
    }
    
    /*!
    When the user presses the save button
    
    - parameter sender:	The save button
    */
    @IBAction func saveCatPic(sender: AnyObject){
        UIImageWriteToSavedPhotosAlbum(pictureOfCat.image!, nil, nil, nil)
        
        /// Pop Up to say it's saved
        let alertController = UIAlertController(title: "Saved", message:
            "You pervert", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    //--------------
    // http://stackoverflow.com/questions/30543806/get-progress-from-datataskwithurl-in-swift
    //
    // The following are methods defined in the NSURLDataSessionDelegate class/protocal which his view controller inherits from conforms to
    //
    
    /*!
    When something happens to the Session, in this case as it's just when the reponse is recieved all I want to get out of it is the length of data coming too
    
    - parameter session:						Which session it's listening to
    - parameter dataTask:					Which task
    - parameter response:					The header from the GET request
    - parameter completionHandler:	what to do if the download is complete
    */
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        //here you can get full lenth of your content
        expectedContentLength = Int(response.expectedContentLength)
        
        /*!
        Allow the session to call the completetion listener (the one at the bottom of these three)
        */
        completionHandler(NSURLSessionResponseDisposition.Allow)
        
        /*!
        Display the url of the image
        */
        labelURL.text = "\(response.URL!)"
       
    }
    
    /*!
    The session recieved some more data, so add it to the buffer and update the progressbar accordingly
    
    - parameter session:	the session to listen for
    - parameter dataTask:	The task involved
    - parameter data:			the data recieved
    */
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        buffer.appendData(data)
        let percentageDownloaded = Float(buffer.length) / Float(expectedContentLength)
        progress.progress =  percentageDownloaded
    }
    
    /*!
    When the download is finished
    
    - parameter session:	The session
    - parameter task:		The task
    - parameter error:		The error message
    */
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
       
        if(error != nil){
            let alertController = UIAlertController(title: "Error Downloading", message:
                error?.description, preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else{
            /*!
            @brief  Cast the NSData recieved as an image and put it in the image view controller
            
            @param buffer	The NSData buffer
            
            @return The UIImage object
            */
            pictureOfCat.image = UIImage(data: buffer)
            pictureOfCat.hidden = false
            saveButton.enabled = true
            labelURL.hidden = false
            
        }
        
        /*!
        @brief  Reanable the button common to both error and non error situation and hide the progress bar
        */
        getButton.enabled = true
        progress.hidden = true
        
        //reset the buffer
        buffer.setData(NSData())
    }

}

