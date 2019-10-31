import UIKit
import Foundation

let argc = CommandLine.argc
let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: Int(CommandLine.argc))
let app = UIApplicationMain(argc, argv, nil, NSStringFromClass(AppDelegate.self))
