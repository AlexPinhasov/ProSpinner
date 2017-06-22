//
//  JSSAlertView+Predefined.swift
//  Pods
//
//  Created by Tomas Sykora, jr. on 05/11/2016.
//
//

import UIKit

// MARK: - Predefined styles of JSSAlertView
extension JSSAlertView {
	
    
	/// Info style 💁‍♂️
	///
	/// - Parameters:
	///   - viewController: root view controller
	///   - title: title
	///   - text: text
	///   - buttonText: button text
	///   - cancelButtonText: cancel button text
	///   - delay: delay
	///   - timeLeft: time left Tinder Style
	/// - Returns: Returns Responder
    @discardableResult
	open func info(_ viewController: UIViewController,
	               title: String,
	               text: String? = nil,
	               buttonText: String? = nil,
	               cancelButtonText: String? = nil,
	               delay: Double? = nil,
	               timeLeft: UInt? = nil) -> JSSAlertViewResponder {


		let alertview = show(viewController,
		                     title: title,
		                     text: text,
		                     noButtons: noButtons,
		                     buttonText: buttonText,
		                     cancelButtonText: cancelButtonText,
		                     color: UIColorFromHex(0x1D5788, alpha: 1),
		                     iconImage: iconImage,
		                     delay: delay,
		                     timeLeft: timeLeft)


		alertview.setTextTheme(.light)
		return alertview
	}
    
	/// Success style 🎉
	///
    /// - Parameters:
    ///   - viewController: root view controller
    ///   - title: title
    ///   - text: text
    ///   - buttonText: button text
    ///   - cancelButtonText: cancel button text
    ///   - delay: delay
    ///   - timeLeft: time left Tinder Style
    /// - Returns: Returns Responder
	@discardableResult
	open func success(_ viewController: UIViewController,
	                  title: String,
	                  text: String?=nil,
	                  buttonText: String? = nil,
	                  cancelButtonText: String? = nil,
	                  delay: Double?=nil,
	                  timeLeft: UInt? = nil) -> JSSAlertViewResponder {

		return show(viewController,
		            title: title,
		            text: text,
		            noButtons: noButtons,
		            buttonText: buttonText,
		            cancelButtonText: cancelButtonText,
		            color: UIColorFromHex(0x2ecc71, alpha: 1),
		            iconImage: iconImage,
		            delay: delay,
		            timeLeft: timeLeft)

	}
    
    open func downloadView(_ viewController: UIViewController,
                      title: String,
                      text: String?=nil,
                      buttonText: String? = nil,
                      cancelButtonText: String? = nil,
                      delay: Double?=nil,
                      timeLeft: UInt? = nil) -> JSSAlertViewResponder {
        
        return show(
                    viewController,
                    title: "",
                    noButtons: true,
                    color: UIColorFromHex(0x2ecc71, alpha: 1),
                    loadingSpinner: true)
        
    }
    
	/// Warning style ⚠️
	///
    /// - Parameters:
    ///   - viewController: root view controller
    ///   - title: title
    ///   - text: text
    ///   - buttonText: button text
    ///   - cancelButtonText: cancel button text
    ///   - delay: delay
    ///   - timeLeft: time left Tinder Style
    /// - Returns: Returns Responder	@discardableResult
	open func warning(_ viewController: UIViewController,
	                  title: String,
	                  text: String?=nil,
	                  buttonText: String? = nil,
	                  cancelButtonText: String? = nil,
	                  delay: Double?=nil,
	                  timeLeft: UInt? = nil) -> JSSAlertViewResponder {

		return show(viewController,
		            title: title,
		            text: text,
		            noButtons: noButtons,
		            buttonText: buttonText,
		            cancelButtonText: cancelButtonText,
		            color: UIColorFromHex(0xf1c40f, alpha: 1),
		            iconImage: iconImage,
		            delay: delay,
		            timeLeft: timeLeft)

	}
    
	/// Danger style ☢️
	///
    /// - Parameters:
    ///   - viewController: root view controller
    ///   - title: title
    ///   - text: text
    ///   - buttonText: button text
    ///   - cancelButtonText: cancel button text
    ///   - delay: delay
    ///   - timeLeft: time left Tinder Style
    /// - Returns: Returns Responder
	@discardableResult
	open func danger(_ viewController: UIViewController,
	                 title: String,
	                 text: String?=nil,
	                 buttonText: String? = nil,
	                 cancelButtonText: String?=nil,
	                 delay: Double?=nil,
	                 timeLeft: UInt? = nil) -> JSSAlertViewResponder {


		let alertview = show(viewController,
		                     title: title,
		                     text: text,
		                     noButtons: noButtons,
		                     buttonText: buttonText,
		                     cancelButtonText: cancelButtonText,
		                     color: UIColor(red: 32/255, green: 162/255, blue: 183/255, alpha: 1.0),
		                     iconImage: iconImage,
		                     delay: delay,
		                     timeLeft: timeLeft)
		alertview.setTextTheme(.light)
		return alertview
	}
}
