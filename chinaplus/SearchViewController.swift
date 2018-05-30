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
import AVKit
import AVFoundation
import SwiftSoup
import FileExplorer

class SearchViewController: UIViewController {
  
    let columns: [String] = ["Today", "Horizons", "The Beijing Hour", "Round Table"];
    //var days=3;
    var items = [String: [String]]()
    
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  lazy var tapRecognizer: UITapGestureRecognizer = {
    var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
    return recognizer
  }()
  
  var searchResults: [Track] = []
 // let queryService = ListService()
   let queryService = WebChinaPlus()
  let downloadService = DownloadService()
  // Create downloadsSession here, to set self as delegate
  lazy var downloadsSession: URLSession = {
//    let configuration = URLSessionConfiguration.default
    let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
    return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
  }()

  // Get local file path: download task stores tune here; AV player plays it.
  let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  func localFilePath(for url: URL) -> URL {
    return documentsPath.appendingPathComponent(url.lastPathComponent)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
      print("Playback OK")
      try AVAudioSession.sharedInstance().setActive(true)
      print("Session is Active")
    } catch {
      print(error)
    }
    
    
    tableView.tableFooterView = UIView()
    downloadService.downloadsSession = downloadsSession
    //self.showList()
  }

   @IBAction func showList(){
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    queryService.getSearchResults(searchTerm: "") { results, errorMessage in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      if let results = results {
        self.searchResults = results
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
      }
      if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
    }
    
    
    
  }
    
    @IBAction func downloadAll(_ sender: Any) {
      
      let fileManager = FileManager.default
  

      let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      
      for column in columns{
        let urlColumn = documentsPath.appendingPathComponent(column)
        print("destinationURL: "+urlColumn.path)
        // fileManager.changeCurrentDirectoryPath(destinationURL.path)
        // print("Current: " + fileManager.currentDirectoryPath)
        
        if !fileManager.fileExists(atPath: urlColumn.path) {
          do {
            try fileManager.createDirectory(atPath: urlColumn.path, withIntermediateDirectories: true, attributes: nil)
            //print(fileManager.currentDirectoryPath)
          }catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
          }
          
        }else{
          do {
           
            let fileNames = try fileManager.contentsOfDirectory(atPath: urlColumn.path)
              print("all files in cache: \(fileNames)")
              for fileName in fileNames {
                 let filePath = urlColumn.path+"/\(fileName)"
                do {
                  
                  let attributes = try fileManager.attributesOfItem(atPath: filePath)
                  let dateFile = attributes[FileAttributeKey.creationDate]
                  //print(dateFile.debugDescription)
                  
                  let dateOld = Date().addingTimeInterval(-3*24*60*60)
                  
                  if dateOld > dateFile as! Date {
                    try fileManager.removeItem(atPath: filePath)
                  }
                  
                }catch let error as NSError {
                  print("Ooops! Something went wrong: \(error)")
                }
                /*
                if (fileName.hasSuffix(".m4a") || fileName.hasSuffix(".mp3")){
                  //let filePathName = urlColumn.path+"/\(fileName)"
                 
                }*/
                
              }
              
          //  let files = try fileManager.contentsOfDirectory(atPath: urlColumn.path)
            //  print("all files in cache after deleting images: \(files)")
            
            
          } catch {
            print("Could not clear temp folder: \(error)")
          }
          
        }
        
      }
      
     
      
      
      
      let totalSection = tableView.numberOfSections
      for section in 0..<totalSection
      {
        print("section \(section)")
        let totalRows = tableView.numberOfRows(inSection: section)
        
        for row in 0..<totalRows
        {
          print("row \(row)")
          let cell = tableView.cellForRow(at: IndexPath(row: row, section: section))
          if let btnDownload = cell?.viewWithTag(77) as? UIButton
          {
            btnDownload.sendActions(for: .touchUpInside)
          }
        }
      }
        
        
        
    }
    

  
  func playDownload(_ track: Track) {
    let playerViewController = AVPlayerViewController()
    if #available(iOS 11.0, *) {
      playerViewController.entersFullScreenWhenPlaybackBegins = true
    } else {
      // Fallback on earlier versions
    }
    if #available(iOS 11.0, *) {
      playerViewController.exitsFullScreenWhenPlaybackEnds = true
    } else {
      // Fallback on earlier versions
    }
    present(playerViewController, animated: true, completion: nil)
    let url = localFilePath(for: track.previewURL)
    let player = AVPlayer(url: url)
    playerViewController.player = player
    player.play()
  }
  
}

// MARK: - UITableView

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: TrackCell = tableView.dequeueReusableCell(for: indexPath)

    // Delegate cell button tap events to this view controller
    cell.delegate = self

    let track = searchResults[indexPath.row]
    cell.configure(track: track, downloaded: track.downloaded, download: downloadService.activeDownloads[track.previewURL])

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 62.0
  }

  // When user taps cell, play the local file, if it's downloaded
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let track = searchResults[indexPath.row]
    if track.downloaded {
      playDownload(track)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - TrackCellDelegate
// Called by track cell to identify track for index path row,
// then pass this to download service method.
extension SearchViewController: TrackCellDelegate {

  func downloadTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.startDownload(track)
      reload(indexPath.row)
    }
  }

  func pauseTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.pauseDownload(track)
      reload(indexPath.row)
    }
  }
  
  func resumeTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.resumeDownload(track)
      reload(indexPath.row)
    }
  }
  
  func cancelTapped(_ cell: TrackCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let track = searchResults[indexPath.row]
      downloadService.cancelDownload(track)
      reload(indexPath.row)
    }
  }

  // Update track cell's buttons
  func reload(_ row: Int) {
    tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
  }

}
