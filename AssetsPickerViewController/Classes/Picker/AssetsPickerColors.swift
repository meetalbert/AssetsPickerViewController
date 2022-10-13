//
//  AssetsPickerColors.swift
//  
//
//  Created by Paolo Rau on 10/12/22.
//
import UIKit

/// Class to hold color values for Picker elements.
/// Note: it provides default values and use semantic values for iOS13+.
public struct AssetsPickerColors {
  var defaultCheckmark: UIColor
  var label: UIColor
  var secondaryLabel: UIColor
  var background: UIColor
  var cellBackground: UIColor
  
  public init(
    defaultCheckmark: UIColor? = nil,
    label: UIColor? = nil,
    secondaryLabel: UIColor? = nil,
    background: UIColor? = nil,
    cellBackground: UIColor? = nil
  ) {
    self.defaultCheckmark = defaultCheckmark ?? DefaultColors.defaultCheckmark
    self.label = label ?? DefaultColors.label
    self.secondaryLabel = secondaryLabel ?? DefaultColors.secondaryLabel
    self.background = background ?? DefaultColors.background
    self.cellBackground = cellBackground ?? DefaultColors.cellBackground
  }
  
  struct DefaultColors {
    static var defaultCheckmark : UIColor {
      UIColor(red: 0.078, green: 0.435, blue: 0.875, alpha: 1)
    }
    
    static var label: UIColor {
      guard #available(iOS 13.0, *) else {
          return .black
      }
      return .label
    }
    
    static var secondaryLabel: UIColor {
      guard #available(iOS 13.0, *) else {
        return UIColor(rgbHex: 0x8C8C91)
      }
      return .secondaryLabel
    }
    
    static var background: UIColor {
      guard #available(iOS 13.0, *) else {
        return .white
      }
      return .systemBackground
    }
    
    static var cellBackground: UIColor {
      guard #available(iOS 13.0, *) else {
        return UIColor(rgbHex: 0xF0F0F0)
      }
      return .secondarySystemBackground
    }
  }
}
