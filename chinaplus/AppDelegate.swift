/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
 import UIKit
 
 @UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let tintColor =  UIColor(red: 242/255, green: 71/255, blue: 63/255, alpha: 1)
  var backgroundSessionCompletionHandler: (() -> Void)?
  
  /*
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
     customizeAppearance()
    
    let directoryURL = URL.documentDirectory
    let audioURL = Bundle.main.url(forResource: "audio", withExtension: "mp3")!
    let audioURL2 = Bundle.main.url(forResource: "test", withExtension: "m4a")!
     let audioURL3 = Bundle.main.url(forResource: "today", withExtension: "m4a")!
    let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")!
    let pdfURL = Bundle.main.url(forResource: "pdf", withExtension: "pdf")!
    let image = UIImage(named: "image.jpg")!
    let imageData = UIImagePNGRepresentation(image)!
    
    
    let firstDirectoryURL = directoryURL.appendingPathComponent("Directory")
    try? FileManager.default.createDirectory(at: firstDirectoryURL, withIntermediateDirectories: true, attributes: [FileAttributeKey: Any]())
    
    let items = [
      (audioURL, "audio.mp3"),
       (audioURL2, "test.m4a"),
        (audioURL3, "today.m4a"),
       (videoURL, "video.mp4"),
      (pdfURL, "pdf.pdf")
    ]
    for (url, filename) in items {
      let destinationURL = firstDirectoryURL.appendingPathComponent(filename)
      try? FileManager.default.copyItem(at: url, to: destinationURL)
    }
    
    let imageURL = firstDirectoryURL.appendingPathComponent("image.png")
    try? imageData.write(to: imageURL)
    
    let subdirectoryURL = firstDirectoryURL.appendingPathComponent("Empty Directory")
    try? FileManager.default.createDirectory(at: subdirectoryURL, withIntermediateDirectories: true, attributes: [FileAttributeKey: Any]())
    
    let secondDirectoryURL = directoryURL.appendingPathComponent("Empty Directory")
    try? FileManager.default.createDirectory(at: secondDirectoryURL, withIntermediateDirectories: true, attributes: [FileAttributeKey: Any]())
    
    return true
  }*/
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    customizeAppearance()
    return true
  }
  
  func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
    backgroundSessionCompletionHandler = completionHandler
  }
  
  // MARK - App Theme Customization
  
  private func customizeAppearance() {
    window?.tintColor = tintColor
    UISearchBar.appearance().barTintColor = tintColor
    UINavigationBar.appearance().barTintColor = tintColor
    UINavigationBar.appearance().tintColor = UIColor.white
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue):UIColor.white]
  }
 }
 
