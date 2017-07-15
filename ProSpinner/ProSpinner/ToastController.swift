//
//  ToastController.swift
//  ProSpinner
//
//  Created by AlexP on 10.07.2017.
//  Copyright © 2016 Gini-Apps. All rights reserved.
//

import UIKit

enum ToastLocation
{
    case top
    case bottom
}
extension UIView
{
    static func fromNib(_ nibName: String) -> UIView
    {
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}

class ToastController
{
    // MARK: Constants
    static let toastViewHeight     : CGFloat = CGFloat(60)
    static let toastPaddingFromTop : CGFloat = CGFloat(65)
    
    static private let presentationDuration = 0.7
    static private let    dismissalDuration = 0.7
    
    //  MARK: Class members
    var toastMessageView : ToastView!
    var locationOnScreen : ToastLocation
    
    init()
    {
        locationOnScreen = .bottom
    }
    
    //  MARK: Public methods
    func showToast(window: UIWindow?, withText message: String?)
    {
        guard let window = window else { return }
        guard let toastMessageViewNib = UIView.fromNib(String(describing: ToastView.self)) as? ToastView else { return }
        toastMessageView = toastMessageViewNib
        
        let messageToShow = message ?? "Checking for new spinners"
        
        toastMessageView.toastLabel.text = messageToShow
        toastMessageView.frame = ToastController.initialPositionInScreen(from: locationOnScreen)
    
        window.makeKeyAndVisible()
        window.addSubview(toastMessageView)
        window.bringSubview(toFront: toastMessageView)
        
        presentToast(completionBlock:
            {
                self.toastMessageView = nil
        })
    }
    
    //  MARK: Private methods
    private static func initialPositionInScreen(from locationOnScreen: ToastLocation) -> CGRect
    {
        switch locationOnScreen
        {
        case .top   : return CGRect(x: 0, y: -toastPaddingFromTop                         , width: UIScreen.main.bounds.width, height: toastViewHeight)
        case .bottom: return CGRect(x: 0, y: UIScreen.main.bounds.height + toastViewHeight, width: UIScreen.main.bounds.width, height: toastViewHeight)
        }
    }
    
    private static func finalPresentationPositionInScreen(from locationOnScreen: ToastLocation) -> CGRect
    {
        switch locationOnScreen
        {
        case .top   : return CGRect(x: 0, y: 20                                           , width: UIScreen.main.bounds.width, height: toastViewHeight)
        case .bottom: return CGRect(x: 0, y: UIScreen.main.bounds.height - toastViewHeight, width: UIScreen.main.bounds.width, height: toastViewHeight)
        }
    }
    
    private static func finalDismissalPositionInScreen(from locationOnScreen: ToastLocation) -> CGRect
    {
        switch locationOnScreen
        {
        case .top   : return CGRect(x: 0, y: -toastPaddingFromTop       , width: UIScreen.main.bounds.width, height: toastViewHeight)
        case .bottom: return CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: toastViewHeight)
        }
    }
    
    //  MARK: Public Functions
    private func presentToast(completionBlock: @escaping () -> Void)
    {
        let targetFrame = ToastController.finalPresentationPositionInScreen(from: locationOnScreen)
        UIView.animate( withDuration: ToastController.presentationDuration,
                        delay: 0,
                        usingSpringWithDamping: 0.9,
                        initialSpringVelocity: 0.15,
                        options: .curveEaseIn,
                        animations:
            {
                self.toastMessageView?.frame = targetFrame
        },
                        completion: { _ in
                            
                            self.dismissToast(withBlock: completionBlock)
        })
    }
    
    private func dismissToast(withBlock completionBlock: @escaping () -> Void)
    {
        let targetFrame = ToastController.finalDismissalPositionInScreen(from: locationOnScreen)
        
        UIView.animate( withDuration: ToastController.dismissalDuration,
                        delay: ToastController.presentationDuration,
                        usingSpringWithDamping: 0.9,
                        initialSpringVelocity: 0.15,
                        options: .curveEaseIn,
                        animations:
            {
                self.toastMessageView?.frame = targetFrame
        },
                        completion:
            { _ in
                completionBlock()
        })
    }
}
