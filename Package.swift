// swift-tools-version:5.5

import PackageDescription

let package = Package(
  
  name: "CodeEditor",

  platforms: [
    .macOS(.v12), .iOS(.v15)
  ],

  products: [
    .library(name: "CodeEditor", targets: [ "CodeEditor" ])
  ],
  
  dependencies: [
//    .package(url: "https://github.com/raspu/Highlightr", from: "2.1.2")
    .package(path: "/Users/ilia/Developer/Highlightr"),
  ],
           
  targets: [
    .target(name: "CodeEditor", dependencies: [ "Highlightr" ])
  ]
)
