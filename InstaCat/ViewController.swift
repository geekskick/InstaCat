//
//  ViewController.swift
//  InstaCat
//
//  Created by Patrick Mintram on 25/11/2015.
//  Copyright © 2015 Patrick Mintram. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDelegate, URLSessionDataDelegate, UITextViewDelegate {

    @IBOutlet var pictureOfCat  : UIImageView!
    @IBOutlet var getButton     : UIButton!
    @IBOutlet var saveButton    : UIButton!
    @IBOutlet var progress      : UIProgressView!
    @IBOutlet var tView         : UITextView!
    
    /// The original locartion of the cat picture, initialised in viewDidLoad()
    var originalPictureLocation = CGPoint(x: 0, y: 0)
    /// The last location of a touch on the screen
    var previousTouch = CGPoint(x: 0, y: 0)
    /// The difference between the last location of a touch and the current one
    var differenceInCoORds = CGPoint(x: 0, y: 0)
    /// The download data buffer
    var buffer                  :NSMutableData = NSMutableData()
    /// The download session might not happen so its optional
    var session                 :Foundation.URLSession?
    /// The task in the session might not happen so its optional
    var dataTask                :URLSessionDataTask?
    /// How much content is being sent by REST 'GET' request
    var expectedContentLength   = 0
    /// The swiping information
    var swipe                   = UISwipeAction()
    
    
    /*!
    Change the colour of stuff before it's loaded for more efficient loading
    
    - parameter animated:	not used
    */
    override func viewWillAppear(_ animated: Bool) {
        
        // Make the link font colour black in the label
        tView.tintColor = UIColor.black
        
        let nBar = self.navigationController?.navigationBar
		
		// The navbar has three bits (back, title and forward), the titletext has it's information in a dictionary [ datatype : its value ]
        nBar?.titleTextAttributes = [NSForegroundColorAttributeName: getButton.tintColor]
    }
    
    /*!
    Initialise the view with no picture and the save button disabled
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        progress.progress = 0
        progress.isHidden = true
        pictureOfCat.isHidden = true
        
        // Save the original location of the UIImageView for when it's reset
        originalPictureLocation = pictureOfCat.frame.origin
        
        // Show instruction message
        showMessageBox(title: "Welcome to InstaCat", internalString: "Swipe Left to get a New Cat\rSwipe Right to Save the Cat", buttonText: "Go")
        
    }
    
    
    /*!
    This is called when the textview urls are selected - matches a function name in the TextViewDelegate protocol
    
    - parameter textView:				the UITextView object it's within
    - parameter URL:						the Url pressed
    - parameter characterRange:	the character numbers withing the textview
    
    - returns: true if it's allowed to open safari
    */
    internal func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool{
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
    @IBAction func newCatPressed(_ sender: UIButton){
        
        
        /// Create a reqest to the URL
        var req = URLRequest(url: URL(string: "http://thecatapi.com/api/images/get?type=jpg")!)
        
        req.httpMethod = "GET"
        
        session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        dataTask = session?.dataTask(with: req)
		
		// Hide the objects not needed or relevant
        pictureOfCat.isHidden = true
        progress.isHidden = false
        getButton.isEnabled = false
        saveButton.isEnabled = false
        tView.isHidden = true
		
		// Reset progress bar
        progress.progress = 0
		
		// Unpause the thread
        dataTask?.resume()
    
    }
    
    /*!
    When the user presses the save button
    
    - parameter sender:	The save button
    */
    @IBAction func saveCatPic(_ sender: UIButton){
        
        UIImageWriteToSavedPhotosAlbum(pictureOfCat.image!, nil, nil, nil)
        
        /// Pop Up to say it's saved
        showMessageBox(title: "Saved", internalString: "You pervert", buttonText: "Dismiss")
        
    }
    
    //--------------
    // http://stackoverflow.com/questions/30543806/get-progress-from-datataskwithurl-in-swift
    //
    // The following are methods defined in the NSURLDataSessionDelegate class/protocol which his view controller inherits from conforms to
    //
    
    /*!
    When something happens to the Session, in this case as it's just when the reponse is recieved all I want to get out of it is the length of data coming too
    
    - parameter session:						Which session it's listening to
    - parameter dataTask:					Which task
    - parameter response:					The header from the GET request
    - parameter completionHandler:	what to do if the download is complete
    */
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        //here you can get full lenth of your content
        expectedContentLength = Int(response.expectedContentLength)
        
        /*!
        Allow the session to call the completetion listener (the one at the bottom of these three)
        */
        completionHandler(Foundation.URLSession.ResponseDisposition.allow)
        
    }
    
    /*!
    The session recieved some more data, so add it to the buffer and update the progressbar accordingly
    
    - parameter session:	the session to listen for
    - parameter dataTask:	The task involved
    - parameter data:			the data recieved
    */
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        buffer.append(data)
        let percentageDownloaded = Float(buffer.length) / Float(expectedContentLength)
        progress.progress =  percentageDownloaded
    }
    
    /*!
    When the download is finished check that an image was recieved and display it, otherwise show an error pop up box detailing what was recieved or the error condition
    
    - parameter session:	The session
    - parameter task:		The task
    - parameter error:		The error message
    */
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
       
        var imageRcd = false    ///Will turn true if the content type of the packet is image/jpeg
        var errMsg = ""         ///For storing the error string in
	
		//  There was an error message
        if(error != nil){
  
			// Display the error message
            errMsg = error!.localizedDescription
        }
		
			// No error message
        else{
            // Cast the repsonse as NSNTTPURLRespnonse to acess it's members. I know that the reponse is there at this point as there is no error message
            let nsResp = task.response as! HTTPURLResponse
            
            // If there is a 'content-type' field in the header
            if let nsRespContentType = nsResp.allHeaderFields["Content-Type"] as? String{
                // The the content type is a jpeg
                if(nsRespContentType == "image/jpeg"){
                    
                    imageRcd = true
                    
                    pictureOfCat.image = UIImage(data: buffer as Data)
                    pictureOfCat.isHidden = false
                    saveButton.isEnabled = true
                    
                    // There is deffoes a response and a URL at this point so put the url in the textfield on screen
                    tView.text = task.response!.url!.absoluteString
                    tView.isHidden = false
                    
                }
                // The content type wasn't a jpeg
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
            showMessageBox(title: "Error", internalString: errMsg, buttonText: "OK")
        }
        
        /*!
        @brief  Reanable the button common to both error and non error situation and hide the progress bar
        */
        getButton.isEnabled = true
        progress.isHidden = true
        
        //reset the buffer
        buffer.setData(Data())
        
    }
    
    /*!
    Pops up an alter but with one button and no handler on acknowledgement
    
    - parameter titleString:		The main string of the box
    - parameter internalString:	The little text inside it
    - parameter buttonText:			The button text
    */
    internal func showMessageBox(title titleString: String, internalString: String,  buttonText: String){
        
        let alertController = UIAlertController(title: titleString, message:
            internalString, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    
    }
    
    //================================
    // SWIPING LOGIC FOLLOWS
    // If the picture isn't visible then don't do any swiping logic or calculations
    
    /*!
    When the user touches the screen then remember the location
    
    - parameter touches:	The touches on the screen, only the first is used
    - parameter event:		NOt used
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!pictureOfCat.isHidden){
            swipe.previousTouchCoOrds = touches.first!.location(in: self.view)
            swipe.latestTouchCoOrds = swipe.previousTouchCoOrds
        }
    }
    
    /*!
    When the touch press moves calculate the different between the first and last, and update the cat picture to follow the touch horixonatally only
    
    - parameter touches:	The touches on the screen, only the first is used
    - parameter event:		No used
    */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!pictureOfCat.isHidden){
            
            /*!
            The one which was the latests touch is now old news, so put it into the previous touch location and make the latest the one passed into this function
            */
            swipe.previousTouchCoOrds = swipe.latestTouchCoOrds
            swipe.latestTouchCoOrds = touches.first!.location(in: self.view)
        
            
            updatePictureLocation(CGPoint(x: pictureOfCat.frame.origin.x + swipe.differenceInCoOrds().x, y: pictureOfCat.frame.origin.y))
        }
    }
    
    /*!
    When the touches on the screen end update the cat pic, and save it if needed. 
    
    - parameter touches:	a bunch of touched, only 1 when there's one finger on the screen
    - parameter event:		the event type, not used
    */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!pictureOfCat.isHidden){
            
            ///If the picture is to the left of the centre
            if pictureOfCat.center.x > self.view.center.x{
                saveCatPic(UIButton())
            }
            
            ///If the picture is to the right of the centre
            else if pictureOfCat.center.x < self.view.center.x{
                newCatPressed(UIButton())
            }
            
            updatePictureLocation(originalPictureLocation)
            
        }
    }
    
    /*!
    Change the location of the cat picture
    
    - parameter newLoc:	A CGPoint of it's new location
    */
    func updatePictureLocation(_ newLoc: CGPoint){
        pictureOfCat.frame.origin = newLoc
    }

}

