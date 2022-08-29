//
//  ThemeName.swift
//  CodeEditor
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

public extension CodeEditor {
  
  @frozen
  struct ThemeName: TypedString {
    
    public let rawValue : String
    
    @inlinable
    public init(rawValue: String) { self.rawValue = rawValue }
  }
}

public extension CodeEditor.ThemeName {

  static var `default` = pojoaque
  
  static var pojoaque  = CodeEditor.ThemeName(rawValue: "pojoaque")
  static var agate     = CodeEditor.ThemeName(rawValue: "agate")
  static var ocean     = CodeEditor.ThemeName(rawValue: "ocean")
  static var xcode     = CodeEditor.ThemeName(rawValue: "xcode")
  static var vs2015     = CodeEditor.ThemeName(rawValue: "vs2015")
  static var foundation = CodeEditor.ThemeName(rawValue: "foundation")
  static var atelierSeasideDark = CodeEditor.ThemeName(rawValue: "atelier-seaside-dark")
  static var atelierSeasideLight = CodeEditor.ThemeName(rawValue: "atelier-seaside-light")
  static var atelierDuneDark    = CodeEditor.ThemeName(rawValue: "atelier-dune-dark")
  static var atelierDuneLight   = CodeEditor.ThemeName(rawValue: "atelier-dune-light")
  static var hybrid = CodeEditor.ThemeName(rawValue: "hybrid")
  static var atelierSavannaLight = CodeEditor.ThemeName(rawValue: "atelier-savanna-light")
  static var atelierSavannaDark  = CodeEditor.ThemeName(rawValue: "atelier-savanna-dark")
}
