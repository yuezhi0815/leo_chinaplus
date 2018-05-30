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

import Foundation
import UIKit

extension SearchViewController: URLSessionDownloadDelegate {

  // Stores downloaded file
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

    let fileManager = FileManager.default
    guard let sourceURL = downloadTask.originalRequest?.url else { return }
    let download = downloadService.activeDownloads[sourceURL];
    downloadService.activeDownloads[sourceURL] = nil

    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    if let down = download{
      let urlFile = documentsPath.appendingPathComponent((down.track.name))
      print("destinationURL: "+urlFile.path)
      
      if !fileManager.fileExists(atPath: urlFile.path) {
        do {
          try fileManager.createDirectory(atPath: urlFile.path, withIntermediateDirectories: true, attributes: nil)
          
        }catch let error as NSError {
          print("Ooops! Something went wrong: \(error)")
        }
        
      }
      
      let filename = down.track.artist.replacingOccurrences(of: " ", with: "_")
      let fileURL=urlFile.appendingPathComponent(filename+".mp3")
      print(fileURL)
      // 3
    
      try? fileManager.removeItem(at: fileURL)
      do {
        try fileManager.copyItem(at: location, to: fileURL)
        download?.track.downloaded = true
      } catch let error {
        print("Could not copy file to disk: \(error.localizedDescription)")
      }
    }
   
    
   
    // 4
    if let index = download?.track.index {
      DispatchQueue.main.async {
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
      }
    }
  }

  // Updates progress info
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
    totalBytesExpectedToWrite: Int64) {
    // 1
    guard let url = downloadTask.originalRequest?.url,
      let download = downloadService.activeDownloads[url]  else { return }
    // 2
    download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    // 3
    let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite,
      countStyle: .file)
    // 4
    DispatchQueue.main.async {
      if let trackCell = self.tableView.cellForRow(at: IndexPath(row: download.track.index,
        section: 0)) as? TrackCell {
        trackCell.updateDisplay(progress: download.progress, totalSize: totalSize)
      }
    }
  }

}

// MARK: - URLSessionDelegate

extension SearchViewController: URLSessionDelegate {

  // Standard background session handler
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    DispatchQueue.main.async {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let completionHandler = appDelegate.backgroundSessionCompletionHandler {
        appDelegate.backgroundSessionCompletionHandler = nil
        completionHandler()
      }
    }
  }

}
