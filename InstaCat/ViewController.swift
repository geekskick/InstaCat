//
//  ViewController.swift
//  InstaCat
//
//  Created by Patrick Mintram on 25/11/2015.
//  Copyright © 2015 Patrick Mintram. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLSessionDelegate, NSURLSessionDataDelegate, UITextViewDelegate {

    @IBOutlet var pictureOfCat  : UIImageView!
    @IBOutlet var getButton     : UIButton!
    @IBOutlet var saveButton    : UIButton!
    @IBOutlet var progress      : UIProgressView!
    @IBOutlet var tView         : UITextView!
    
    
    /// The download data buffer
    var buffer                  :NSMutableData = NSMutableData()
    /// The download session might not happen so its optional
    var session                 :NSURLSession?
    /// The task in the session might not happen so its optional
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
        
        /// Make the links the default colour or text AKA black
        tView.tintColor = UIColor.blackColor()

    }
    
    /*!
    This is called when the textview urls are selected - matches a function name in the TextViewDelegate protocol
    
    - parameter textView:				the UITextView object it's within
    - parameter URL:						the Url pressed
    - parameter characterRange:	the character numbers withing the textview
    
    - returns: true if it's allowed to open safari
    */
    internal func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool{
        return true
    }
    
    /*!
    Here when the xcode started
    */
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
        tView.hidden = true
        
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
        showMessageBox("Saved", internalString: "You pervert", buttonText: "Dismiss")
        
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
    When the download is finished check that an image was recieved and display it, otherwise show an error pop up box detailing what was recieved or the error condition
    
    - parameter session:	The session
    - parameter task:		The task
    - parameter error:		The error message
    */
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
       
        var imageRcd = false    ///Will turn true if the content type of the packet is image/jpeg
        var errMsg = ""         ///For storing the error string in
        
        /*!
        @brief  There was an error message
        */
        if(error != nil){
            /*!
            @brief  Display the error message
            */
            errMsg = error!.localizedDescription
        }
        /*!
        @brief  No error message
        */
        else{
            /// Cast the repsonse as NSNTTPURLRespnonse to acess it's members. I know that the reponse is there at this point as there is no error message
            let nsResp = task.response as! NSHTTPURLResponse
            
            /// If there is a 'content-type' field in the header
            if let nsRespContentType = nsResp.allHeaderFields["Content-Type"] as? String{
                /// The the content type is a jpeg
                if(nsRespContentType == "image/jpeg"){
                    
                    imageRcd = true
                    
                    pictureOfCat.image = UIImage(data: buffer)
                    pictureOfCat.hidden = false
                    saveButton.enabled = true
                    
                    /// There is deffoes a response and a URL at this point so put the url in the textfield on screen
                    tView.text = task.response!.URL!.absoluteString
                    tView.hidden = false
                    
                }
                /// The content type wasn't a jpeg
                else{
                    errMsg = "The content was of type \(nsRespContentType)"
                }
            }
            /// There was no content-type field in the reply
            else{
                errMsg = "No content recieved"
            }
        }
        
        /*!
        @brief  There was no jpeg image recieved at this point so show the erorr pop up box
        */
        if(!imageRcd){
            showMessageBox("Error", internalString: errMsg, buttonText: "OK")
        }
        
        /*!
        @brief  Reanable the button common to both error and non error situation and hide the progress bar
        */
        getButton.enabled = true
        progress.hidden = true
        
        //reset the buffer
        buffer.setData(NSData())
    }
    
    /*!
    Pops up an alter but with one button and no handler on acknowledgement
    
    - parameter titleString:		The main string of the box
    - parameter internalString:	The little text inside it
    - parameter buttonText:			The button text
    */
    internal func showMessageBox(titleString: String, internalString: String, buttonText: String){
        let alertController = UIAlertController(title: titleString, message:
            internalString, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

