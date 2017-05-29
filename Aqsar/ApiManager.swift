//
//  ApiManager.swift
//  Aqsar
//
//  Created by moayad on 8/24/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import RealmSwift
import UIKit

protocol APIManagerDelegate {
    func APIManagerDelegateDidDownload()
}

class ApiManager {
    static let sharedInstance = ApiManager()
    
    fileprivate lazy  var backgroundLoadingView: UIView = {
        [unowned self] in
        let backgroundLoadingView = UIView(frame: UIScreen.main.bounds)
        backgroundLoadingView.backgroundColor = UIColor.black
        backgroundLoadingView.alpha = 0.0
        
        return backgroundLoadingView
    }()
    
    fileprivate lazy var loadingView:UIView = {
        [unowned self] in
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        loadingView.center = centerOfScreen
        loadingView.layer.cornerRadius = 4
        loadingView.backgroundColor = UIColor.white
        loadingView.alpha = 0.0
        
        return loadingView
    }()
    
    fileprivate lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.color = darkGreen
        indicator.center = centerOfScreen
        indicator.alpha = 0.0
        indicator.startAnimating()
        
        return indicator
    }()
    
    var delegate: APIManagerDelegate?
    
    typealias defaultSuccess = (_ mapped: AnyObject?) -> ()
    typealias defaultFailure = (_ error: NSError) -> ()
    
    fileprivate let apisProtocol = "http://"
    fileprivate let apisDomainName = "data.www.aqssar.com.barberry.arvixe.com/"

    
    //MARK:- Main Verbs (Methods)
    fileprivate func GET<T:Mappable>(_ url: String, type: T.Type, parameters: [String : AnyObject]?, onSuccess: @escaping defaultSuccess, onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        
        if let lvc = loadingViewController {
            //dispatch_async(dispatch_get_main_queue()) {
            //lvc.showLoadingIndicator()
            //}
            
            window?.addSubview(backgroundLoadingView)
            window?.addSubview(loadingView)
            window?.addSubview(indicator)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.backgroundLoadingView.alpha = 0.8
                self.loadingView.alpha = 1.0
                self.indicator.alpha = 1.0
            })
        }
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(_):
                func handleSuccessResponse() {
                    let returnedType = response.result.value
                    
                    if let unwrappedType = returnedType {
                        onSuccess(unwrappedType as? AnyObject)
                    } else {
                        onSuccess(nil)
                    }
                }
                
                if let lvc = loadingViewController {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.backgroundLoadingView.alpha = 0.0
                        self.loadingView.alpha = 0.0
                        self.indicator.alpha = 0.0
                        }, completion: { _ in
                            self.backgroundLoadingView.removeFromSuperview()
                            self.loadingView.removeFromSuperview()
                            self.indicator.removeFromSuperview()
                    })
                    
                    handleSuccessResponse()
                    
//                    lvc.hideLoadingIndicator({
//                        handleSuccessResponse()
//                    })
                } else {
                    handleSuccessResponse()
                }
            case .failure(_):
                if let lvc = loadingViewController {
                    self.backgroundLoadingView.removeFromSuperview()
                    self.loadingView.removeFromSuperview()//
                    self.indicator.removeFromSuperview()
                    
                    onFailure(response.result.error as! NSError)
                    
//                    lvc.hideLoadingIndicator({
//                        onFailure(error: error)
//                    })
                } else {
                    onFailure(response.result.error as! NSError)
                }
            }
        }
    }
    
    fileprivate func GETDefaultSuccess<T:Mappable>(_ url: String, type: T.Type, parameters: [String : AnyObject]?, onSuccess: @escaping defaultSuccess, onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        
        if let lvc = loadingViewController {
            //dispatch_async(dispatch_get_main_queue()) {
            //lvc.showLoadingIndicator()
            //}
            
            window?.addSubview(backgroundLoadingView)
            window?.addSubview(loadingView)
            window?.addSubview(indicator)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.backgroundLoadingView.alpha = 0.8
                self.loadingView.alpha = 1.0
                self.indicator.alpha = 1.0
            })
        }
        
         Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
        //Alamofire.request(.GET, url, parameters: parameters).responseObject { (response: Response<T, NSError>) in
            print(url)
            switch response.result {
            case .success(_):
                func handleSuccessResponse() {
                    let returnedType = response.result.value
                    
                    if let unwrappedType = returnedType {
                        onSuccess(unwrappedType as? AnyObject)
                    } else {
                        onSuccess(nil)
                    }
                }
                
                if let lvc = loadingViewController {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.backgroundLoadingView.alpha = 0.0
                        self.loadingView.alpha = 0.0
                        self.indicator.alpha = 0.0
                        }, completion: { _ in
                            self.backgroundLoadingView.removeFromSuperview()
                            self.loadingView.removeFromSuperview()
                            self.indicator.removeFromSuperview()
                    })
                    
                    handleSuccessResponse()
                    
//                    lvc.hideLoadingIndicator({
//                        handleSuccessResponse()
//                    })
                } else {
                    handleSuccessResponse()
                }
            case .failure(_):
                if let lvc = loadingViewController {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.backgroundLoadingView.alpha = 0.0
                        self.loadingView.alpha = 0.0
                        self.indicator.alpha = 0.0
                        }, completion: { _ in
                            self.backgroundLoadingView.removeFromSuperview()
                            self.loadingView.removeFromSuperview()
                            self.indicator.removeFromSuperview()
                    })
                    
                    onFailure(response.result.error as! NSError)
                    
//                    lvc.hideLoadingIndicator({
//                        onFailure(error: error)
//                    })
                } else {
                    onFailure(response.result.error as! NSError)
                }
            }
        }
    }
    
    fileprivate func POST<T:Mappable>(_ url: String, type: T.Type, parameters: [String : AnyObject]?, onSuccess: @escaping defaultSuccess, onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        
        if let lvc = loadingViewController {
            //dispatch_async(dispatch_get_main_queue()) {
            lvc.showLoadingIndicator()
            //}
        }
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in

        //Alamofire.request(.POST, url, parameters: parameters).responseObject { (response: Response<T, NSError>) in
            switch response.result {
            case .success(_):
                func handleSuccessResponse() {
                    let returnedType = response.result.value
                    
                    if let unwrappedType = returnedType {
                        onSuccess(unwrappedType as? AnyObject)
                    } else {
                        onSuccess(nil)
                    }
                }
                
                if let lvc = loadingViewController {
                    lvc.hideLoadingIndicator({
                        handleSuccessResponse()
                    })
                } else {
                    handleSuccessResponse()
                }
            case .failure(_):
                if let lvc = loadingViewController {
                    lvc.hideLoadingIndicator({
                        onFailure(response.result.error as! NSError)
                    })
                } else {
                    onFailure(response.result.error as! NSError)
                }
            }
        }
    }
    
    //MARK:- User & Authentication
    func loginPOST(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: LoggedInUserDataTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        
        POST(apisProtocol + apisDomainName + "api/SitesApis/login", type: LoggedInUserDataTable.self, parameters: parameters, onSuccess: { mapped in
            
            let mapper = Mapper<LoggedInUserDataTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func loginGET(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: LoggedInUserDataTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        
        GET(apisProtocol + apisDomainName + "api/SitesApis/login", type: LoggedInUserDataTable.self, parameters: parameters, onSuccess: { mapped in
            
            let mapper = Mapper<LoggedInUserDataTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                if let userDataObject = unwrappedMapped.table?.first {
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(userDataObject)
                    }
                }
                
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    
    func loginGET(_ username: String, password: String, onSuccess: @escaping (_ array: LoggedInUserDataTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        
        let parameters = ["UserName": username, "Password": password, "DeviceID": UIDevice.current.identifierForVendor!.uuidString]
        
        print(UIDevice.current.identifierForVendor!.uuidString)
        
        
        GET(apisProtocol + apisDomainName + "api/SitesApis/login", type: LoggedInUserDataTable.self, parameters: parameters as [String : AnyObject]?, onSuccess: { mapped in
            print("mappedCategories reg \(mapped)")
           
            let mapper = Mapper<LoggedInUserDataTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                
                if let userDataObject = unwrappedMapped.table?.first {
                    if userDataObject.erorr.trimmingCharacters(in: CharacterSet.whitespaces) == "" {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(userDataObject)
                            onSuccess(unwrappedMapped)
                        }
                    }else{
                        onSuccess(unwrappedMapped)

                    }
                }
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func registerGET(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: RegisterSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GET(apisProtocol + apisDomainName + "api/SitesApis/Register", type: RegisterSuccessTable.self, parameters: parameters, onSuccess :{ mappedCategories in

            let mapper = Mapper<RegisterSuccessTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func changeUserEmail(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/UpdateUserEmail", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func logout(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "/api/SitesApis/LogOut", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func forgotDevice(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "/api/SitesApis/ForgetDevice", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    // MARK:- Categories
    func getCategories(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: CategoriesTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GET(apisProtocol + apisDomainName + "api/SitesApis/GetAllCategories", type: CategoriesTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<CategoriesTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }

            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func setUserCategories(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/SetUserCategories", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    //MARK:- Books
    func getBooksToChoose(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: BooksTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GET(apisProtocol + apisDomainName + "api/SitesApis/GetBooksByCategories", type: BooksTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<BooksTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func setUserBooks(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/SetUserBooks", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func getUserLibrary(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: BooksTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        // (books are returned orderd by their ProgressColomn (0:unread , 1:InProgress , 2:finished)
        GET(apisProtocol + apisDomainName + "api/SitesApis/GetUserLibrary", type: BooksTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            //
            let mapper = Mapper<BooksTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func getBooksByFilter(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: BooksTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        // (books are returned orderd by their filter (0:added date , 1:title , 2:read counts)
        GET(apisProtocol + apisDomainName + "api/SitesApis/GetUserLibrary", type: BooksTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<BooksTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
        }, onFailure: onFailure, loadingViewController: loadingViewController)
    }

    
    func setBookStatus(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/SetBookStatus", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func addBookToFavorites(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/AddBookToFav", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func removeBookFromFavorites(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/RemoveBookFromFav", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func getUserFavoriteBooks(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: BooksTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GET(apisProtocol + apisDomainName + "api/SitesApis/GetAllfav", type: BooksTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<BooksTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func getSearchBooks(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: BooksTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GET(apisProtocol + apisDomainName + "api/SitesApis/SearchBooks", type: BooksTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<BooksTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }

    func finishBook(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/FinishABook", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    //MARK:- Quotes
    func getUserQuotes(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: QuotesTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        // (books are returned orderd by their ProgressColomn (0:unread , 1:InProgress , 2:finished)
        GET(apisProtocol + apisDomainName + "api/SitesApis/GetAllQuotes", type: QuotesTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<QuotesTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func getTextQuotes(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: QuotesTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        // (books are returned orderd by their ProgressColomn (0:unread , 1:InProgress , 2:finished)
        GET(apisProtocol + apisDomainName + "api/SitesApis/GetAllBookTextQuotes", type: QuotesTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<QuotesTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func getAudioQuotes(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: QuotesTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        // (books are returned orderd by their ProgressColomn (0:unread , 1:InProgress , 2:finished)
        GET(apisProtocol + apisDomainName + "api/SitesApis/GetAllBookAudioQuotes", type: QuotesTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<QuotesTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func AddQuoteToFavorites(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/AddTextQuoteToFav", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func AddAudioQuoteToFavorites(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/AddAudioQuoteToFav", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func removeQuote(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "/api/SitesApis/RemoveBookQuotesFromFav", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    //MARK:- Discover
    func getDiscoverLatestBooks(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: BooksTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GET(apisProtocol + apisDomainName + "api/SitesApis/DiscoverLatestBooks", type: BooksTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<BooksTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func getDiscoverMostRedBooks(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: BooksTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GET(apisProtocol + apisDomainName + "api/SitesApis/DiscoverMostReadBooks", type: BooksTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<BooksTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func getDiscoverHeaderBook(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: BooksTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GET(apisProtocol + apisDomainName + "api/SitesApis/GetDiscoverMainBook", type: BooksTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<BooksTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    //MARK:- Paper
    func getPapers(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: PapersTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GET(apisProtocol + apisDomainName + "api/SitesApis/GetBookPapersById", type: PapersTable.self, parameters: parameters, onSuccess :{ mappedCategories in
            
            let mapper = Mapper<PapersTable>().map(JSONObject: mappedCategories)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    func setBookCuurrentPage(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/SetBookCuurrentPage", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    //MARK:- My Performance
    func getPerformanceChartData(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: MyPerformanceChartDataTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/GetFinishedBooksByYear", type: MyPerformanceChartDataTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<MyPerformanceChartDataTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    //MARK:- My Account
    func getMyAccountCounts(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: MyAccountCountsTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/GetMyProgressCounts", type: MyAccountCountsTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<MyAccountCountsTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    //MARK:- Audio
    func downloadAudio(_ audioID: String, progressHandler: @escaping ((Progress) -> Void), completion: @escaping (_ success : Bool) -> ()) {
        // check if empty GUID
        if audioID == "00000000-0000-0000-0000-000000000000" {
            completion(false)
            return
        }
        // check if file exists
        let currentFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: currentFilePath.appendingPathComponent(audioID).path) {

            var directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            directoryURL = directoryURL.appendingPathComponent(audioID)
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (directoryURL, [.createIntermediateDirectories, .removePreviousFile])
            }
            
            Alamofire.download("http://www.aqssar.com/Home/download?PaperId=\(audioID)", method: .get, to: destination)
                .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    print("Progress: \(progress.fractionCompleted)")
                    print("Progress: \(progress.totalUnitCount), \(progress.completedUnitCount)")
                    //print(progress.totalByteRead)

                    progressHandler(progress)
                }
                .validate { request, response, temporaryURL, destinationURL in
                    // Custom evaluation closure now includes file URLs (allows you to parse out error messages if necessary)
                    return .success
                }
                .responseJSON { response in
                    debugPrint(response)
                    print(response.temporaryURL ?? "")
                    print(response.destinationURL ?? "")
                    completion(true)
            }
            
            /*
            Alamofire.download(.get,
                "http://www.aqssar.com/Home/download?PaperId=\(audioID)",
                destination: { (temporaryURL, response) in
                    let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                    //let pathComponent = response.suggestedFilename
                    
                    localPath = directoryURL.URLByAppendingPathComponent(audioID)
                    return localPath!
            })
                .response { (request, response, _, error) in
                    print(response)
                    if let unwarappedlocalPath = localPath {
                        print("Downloaded file to \(unwarappedlocalPath)")
                    }
                    
                    
                    self.delegate?.APIManagerDelegateDidDownload()
                    
                    completion()
            }
        */
        } else {
            print("file is already downloaded")
        }
        
    }
    
    //MARK:- Payment
    func purchase(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: PaymentDataTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/InsertUserLibrary", type: PaymentDataTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<PaymentDataTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    //MARK:- Contact Us
    func contactUs(_ parameters: [String : AnyObject]?, onSuccess: @escaping (_ array: DefaultSuccessTable?) -> (), onFailure: @escaping defaultFailure, loadingViewController: UIViewController?) {
        GETDefaultSuccess(apisProtocol + apisDomainName + "api/SitesApis/ContactUs", type: DefaultSuccessTable.self, parameters: parameters, onSuccess: { (mapped) in
            
            let mapper = Mapper<DefaultSuccessTable>().map(JSONObject: mapped)
            if let unwrappedMapped = mapper {
                onSuccess(unwrappedMapped)
            } else {
                onSuccess(nil)
            }
            }, onFailure: onFailure, loadingViewController: loadingViewController)
    }
    
    //MARK:-
}

// MARK:- Meta (Base URL)
//protocol Meta {
//    static var apiPath: String { get set }
//    static func apiUrl()->String
//}
//
//extension Meta {
//    static func apiUrl()->String {
//        let apisProtocol = "http://"
//        let apisDomainName = "data.www.aqssar.com.barberry.arvixe.com/"
//        return apisProtocol + apisDomainName + apiPath
//    }
//}



//MARK:- Loggedin User
class LoggedInUserDataTable: Mappable {
    var table: [LoggedInUserData]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        table <- map["Table"]
    }
}

class LoggedInUserData: Object, Mappable{
    dynamic var userID: String = ""
    dynamic var userName: String = ""
    dynamic var firstName: String = ""
    dynamic var midName: String = ""
    dynamic var lastName: String = ""
    dynamic var email: String = ""
    dynamic var phoneNumber: String = ""
    dynamic var isActive: Bool = false
    dynamic var isFree: Bool = false
    dynamic var isPaid: Bool = false
    dynamic var booksCount: Int = 0
    dynamic var subscriptionEndDate = ""
    dynamic var erorr = ""
    
    let categories = List<Categories>()
    let booksUnread = List<Book>()
    let booksInProgress = List<Book>()
    let booksFinished = List<Book>()
    let booksFavorites = List<Book>()
    let quotes = List<Quote>()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "userID"
    }
    
    func mapping(map: Map) {
        userID <- map["UserID"]
        userName <- map["UserName"]
        firstName <- map["FirstName"]
        midName <- map["MidName"]
        lastName <- map["LastName"]
        email <- map["Email"]
        phoneNumber <- map["PhoneNumber"]
        isActive <- map["IsAvtive"]
        isFree <- map["IsFree"]
        isPaid <- map["isPaid"]
        booksCount <- map["BookCount"]
        subscriptionEndDate <- map["SubscriptionEndDate"]
        
        erorr <- map["Erorr"]
    }
    
    
}

// MARK:- Categories
class CategoriesTable: Mappable {
    var table: [Categories]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        table <- map["Table"]
    }
}

class Categories: Object,  Mappable {
    dynamic var categoryID: String = ""
    dynamic var title: String = ""
    dynamic var imageURL: String = ""
    dynamic var imageID: String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "categoryID"
    }
    
    func mapping(map: Map) {
        categoryID <- map["CategoryID"]
        title <- map["Title"]
        imageURL <- map["ImageURL"]
        imageID <- map["ImageID"]
    }
}

// MARK:- Categories
class BooksTable: Mappable {
    var table: [Book]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        table <- map["Table"]
    }
}

class Book: Object, Mappable {
    dynamic var bookID: String = ""
    dynamic var title: String = ""
    dynamic var summary: String = ""
    dynamic var descriptionText: String = ""
    dynamic var imageURL: String = ""
    dynamic var imageID:String = ""
    dynamic var category1: String = ""
    dynamic var category2: String = ""
    dynamic var category3: String = ""
    dynamic var papers: String = ""
    dynamic var titleEN: String = ""
    dynamic var author: String = ""
    dynamic var hasAudio: String = ""
    dynamic var totalCount: Int = 0
    dynamic var progress: Int = 0
    dynamic var userCurrentPage = 1
    dynamic var totalPages = 0
    dynamic var status = -1
    //To check is finished all audio dwonload
    dynamic var isAudioDownload : Bool = false
    //To check if there any audio in progress.
    dynamic var thereIsLoad : Bool = false


    let papersList = List<Paper>()

    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "bookID"
    }
    
    func mapping(map: Map) {
        bookID <- map["BookID"]
        title <- map["Title"]
        summary <- map["Summary"]
        descriptionText <- map["Description"]
        imageURL <- map["ImageURL"]
        category1 <- map["Category"]
        category2 <- map["Category2"]
        category3 <- map["Category3"]
        imageID <- map["ImageID"]
        papers <- map["Papers"]
        titleEN <- map["TitleEN"]
        author <- map["Author"]
        hasAudio <- map["HaveAudio"]
        status <- map["BookStatus"]
        totalCount <- map["TotalCount"]
        progress <- map["bookProgress"]
        userCurrentPage <- map["bookProgress"]
        totalPages <- map["TotalPages"]
    }
    
    //"Title": " ادب 33",
    //"Summary": "literature Book Summary",
    //"BookID": "f40e55d2-0740-40a9-a8c9-88ee643cb3f8",
    //"RelationId": "03f0b14f-52bd-4f77-bfe2-dfdf4ff321ae",
    //"ImageId": "716140fb-bc7a-4757-8048-9d09f03c7157"
}

//MARK:- Papers
class PapersTable: Mappable {
    var table: [Paper]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        table <- map["Table"]
    }
}

class Paper: Object, Mappable {
    dynamic var paperID: String = ""
    dynamic var title: String = ""
    dynamic var body: String = ""
    dynamic var audioID: String = ""
    dynamic var audioURL : String = ""
    
    dynamic var data : NSData {
        
        do {
            let url = URL(string: self.audioURL)
            return try NSData(contentsOf: url!, options: NSData.ReadingOptions())
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        return NSData()
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    //override class func ignoredProperties() -> [String] {
    //    return ["data"]
    //}
//    override static func primaryKey() -> String? {
//        return "paperID"
//    }
    
    func mapping(map: Map) {
        paperID <- map["PaperID"]
        title <- map["Title"]
        body <- map["Body"]
        audioID <- map["AudioID"]
        audioURL <- map["AudioURL"]
        
    }
}

//MARK:- Quote
class QuotesTable: Mappable {
    var table: [Quote]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        table <- map["Table"]
    }
}

class Quote: Object, Mappable {
    dynamic var bookID: String = ""
    dynamic var quote: String = ""
    dynamic var title: String = ""
    dynamic var authorName:String = ""
    dynamic var textQuotesCount: Int = 0
    dynamic var audioQuotesCount: Int = 0
    dynamic var rID: String = ""

    dynamic var quoteID: String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        bookID <- map["BookID"]
        quote <- map["Quote"]
        title <- map["Title"]
        authorName <- map["AuthorName"]
        textQuotesCount <- map["TextQuotesCount"]
        textQuotesCount <- map["AudioQuotesCount"]
        quoteID <- map["QuoteID"]
        rID <- map["RID"]
        
        
//        "NeverMind": 1,
//        "BookID": "926825d1-2688-4c26-8005-46a84cc52bdf",
//        "Title": "المفتاح",
//        "AuthorName": "Rahma Majed",
//        "TextQuotesCount": 1,
//        "AudioQuotesCount": 0,
//        "RID": 1
        
//        "QuoteID": "1c831fb3-3670-4668-aea5-d998173690d6",
//        "UserID": "a4f3d8e2-fcc3-4203-a07a-505f47e4c609",
//        "Quote": "إلى أن يجد الوسيلة التي تساعده على تجاوز هذه العقبة. يسلب مرتين، يعمل في متجر للبلور",
//        "BookID": "20f94959-ae1b-47be-a082-b27c040a1f74",
//        "Title": " تحقيقات في جريمة ازدراء العقل زمعاداة الانسان",
//        "RID": 1,
//        "TotalCount": 3
    }
}


// MARK:- Default Success
class DefaultSuccessTable: Mappable {
    var table: [DefaultSuccess]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        table <- map["Table"]
    }
}

class DefaultSuccess: Mappable {
    var categoryID: String = ""
    var title: String = ""
    var imageURL: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        categoryID <- map["CategoryID"]
        title <- map["Title"]
        imageURL <- map["ImageURL"]
    }
}


// MARK:- Registration Success
class RegisterSuccessTable: Mappable {
    var table: [RegisterSuccess]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        table <- map["Table"]
    }
}

class RegisterSuccess: Mappable {
    var column1: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        column1 <- map["Column1"]
    }
}

//MARK:- My Performance
class MyPerformanceChartDataTable: Mappable {
    var table: [MyPerformanceChartData]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        table <- map["Table"]
    }
}

class MyPerformanceChartData: Mappable {
    var bookCount = 0
    var finishedMonth = 0
    
    init(bookCount: Int, finishedMonth: Int) {
        self.bookCount = bookCount
        self.finishedMonth = finishedMonth
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        bookCount <- map["BookCount"]
        finishedMonth <- map["FinishedMonth"]
    }
}

//MARK:- My Account
class MyAccountCountsTable: Mappable {
    var table: [MyAccountCounts]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        table <- map["Table"]
    }
}

class MyAccountCounts: Mappable {
    var favoriteCount = 0
    var quotesCount = 0
    var finishedCount = 0
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        favoriteCount <- map["FavCount"]
        quotesCount <- map["QuotesCount"]
        finishedCount <- map["BooksCount"]
    }
}

class PaymentDataTable: Mappable {
    var table: [PaymentData]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        table <- map["Table"]
    }
}

class PaymentData: Mappable {
    var endSubscriptionDate = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        endSubscriptionDate <- map["SubscriptionEndDate"]
    }
}
