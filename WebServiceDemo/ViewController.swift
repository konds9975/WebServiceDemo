//
//  ViewController.swift
//  WebServiceDemo
//
//  Created by Sachin on 1/30/17.
//  Copyright © 2017 bitware. All rights reserved.
//

import UIKit

class ViewController: UIViewController,WebHandlerDelegate
{
    @IBOutlet weak var image: UIImageView!
    var myActivityIndicator : UIActivityIndicatorView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
         myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = true
        view.addSubview(myActivityIndicator)
    }
  
    @IBAction func uploadImage(_ sender: Any)
    {
        print("Up")
           //UploadRequest()
        let temp = WebHandler()
        temp.delegate=self
        let data = ["user_id" : "22"]
       // "http://74.208.12.101/snsapi/save_image.php"
        
        temp.UploadRequest(parameters: data, urlStr: "http://74.208.12.101/snsapi/save_image.php", imageName: "photo_pics", actualImage: image.image!)
        
        
    }
    func imageUploadResponse(_ Response:AnyObject, error : String)
    {
        print(Response)
    }
    @IBAction func getServiceCallBtnClicked(_ sender: Any)
    {
        //Show Indicator
        myActivityIndicator.startAnimating()
        //MARK: - Get Request
        let temp = WebHandler()
        temp.delegate=self
        
        let name = "pqr" as NSString
        let pass = "pass123" as NSString
       
        let url = WebHandler.mainUrl + "user-login?user_name=\(name)&user_password=\(pass)" as NSString
        
        print(url)
        temp.doRequestGet(urlStr:url)

    }
    
    @IBAction func postServiceCallBtnClicked(_ sender: Any)
    {
        //Show Indicato
        myActivityIndicator.startAnimating()
        //MARK: - Get Request
        let temp = WebHandler()
        temp.delegate=self
        
        let name = "pqr" as String
        let pass = "pass123" as String
        
        let url = WebHandler.mainUrl+"user-login" as NSString
        
        print(url)
        
        let parameter = ["user_name":name , "user_password":pass]
        temp.doRequestPost(parameters: parameter as AnyObject, urlStr: url)
        
        
    }
    //MARK:- Get Request Service Resopnse
    func APIResponseArrived(_ Response:AnyObject, error : String)
    {
        if error != "0"
        {
            if Response is Dictionary<String, AnyObject>
            {
                print(Response)
                let Message = Response["Message"] as! NSString
                
                if "success" == Response["Status"] as! String
                {
                    print(Response)
                   //Hide Indicator
                     myActivityIndicator.isHidden = true
                    myActivityIndicator.stopAnimating()
                     myActivityIndicator.isHidden = true
                    WebHandler.showAlertWithTilte(title: WebHandler.projectTitle , message: Message)
                }
                else
                {
                    //Hide Indicator
                     myActivityIndicator.isHidden = true
                     myActivityIndicator.stopAnimating()
                    WebHandler.showAlertWithTilte(title: WebHandler.projectTitle , message: Message)
                }
            }
        }
        else
        {
            //Hide Indicator
            myActivityIndicator.isHidden = true
            myActivityIndicator.stopAnimating()
            WebHandler.showAlertWithTilte(title: WebHandler.projectTitle , message: WebHandler.somthingWrongMsg as NSString)
        }
    }
    
   

}

