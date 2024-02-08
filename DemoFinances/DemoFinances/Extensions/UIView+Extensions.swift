//
//  UIView+Extensions.swift
//  DemoFinances
//
//  Created by Sparrow on 2024-02-07.
//
import UIKit
import Foundation
@IBDesignable
extension UIView {
    
    @IBInspectable var shadowColor: UIColor {
        get { return UIColor(cgColor: layer.shadowColor ?? UIColor.clear.cgColor) }
        set { layer.shadowColor = newValue.cgColor }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {return layer.shadowOpacity}
        set {layer.shadowOpacity = newValue}
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    @IBInspectable var masksToBounds: Bool {
        get { return layer.masksToBounds }
        set { layer.masksToBounds = newValue }
    }
    @IBInspectable
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius}
        set { layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0}
    }
}
