
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
import SwiftSoup

// Runs query data task, and stores results in array of Tracks
class ListService {
  
  
  var columns: [String] = ["Today", "Horizons", "The Beijing Hour", "RoundTable"];
  var days=3;
  var items = [String: [String]]()
  
  
  typealias JSONDictionary = [String: Any]
  typealias QueryResult = ([Track]?, String) -> ()
  //
  // 1
  let defaultSession = URLSession(configuration: .default)
  // 2
  var dataTask: URLSessionDataTask?
  var tracks: [Track] = []
  var errorMessage = ""
  
  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
    // 1
    dataTask?.cancel()
    // 2
    if var urlComponents = URLComponents(string: "https://m.qingting.fm/channels/4584/date/20180520") {
      //urlComponents.query = "media=music&entity=song&term=\(searchTerm)"
      // 3
      guard let url = urlComponents.url else { return }
      // 4
      dataTask = defaultSession.dataTask(with: url) { data, response, error in
        defer { self.dataTask = nil }
        // 5
        if let error = error {
          self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
        } else if let data = data,
          let response = response as? HTTPURLResponse,
          response.statusCode == 200 {
          //self.updateSearchResults(data)
          let output=String(data: data, encoding: .utf8)!
          self.parse(input: output, date: "20180520")
          // 6
          DispatchQueue.main.async {
            completion(self.tracks, self.errorMessage)
          }
        }
      }
      // 7
      dataTask?.resume()
    }
  }
  
  fileprivate func updateSearchResults(_ data: Data) {
    var response: JSONDictionary?
    tracks.removeAll()
    
    do {
      response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
    } catch let parseError as NSError {
      errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
      return
    }
    
    guard let array = response!["results"] as? [Any] else {
      errorMessage += "Dictionary does not contain results key\n"
      return
    }
    var index = 0
    for trackDictionary in array {
      if let trackDictionary = trackDictionary as? JSONDictionary,
        let previewURLString = trackDictionary["previewUrl"] as? String,
        let previewURL = URL(string: previewURLString),
        let name = trackDictionary["trackName"] as? String,
        let artist = trackDictionary["artistName"] as? String {
       // data.append(Track(name: name, artist: artist, previewURL: previewURL, index: index))
        index += 1
      } else {
        errorMessage += "Problem parsing trackDictionary\n"
      }
    }
  }
  
  func parse(input: String, date: String){
    do {
      //let html: String = "<p>An <a href='http://example.com/'><b>example</b></a> link.</p>";
      let html: String = input
      let doc: Document = try! SwiftSoup.parse(html)
      // let names: Elements = try! doc.getElementsByClass("title text-black");//.select("div");
      //   let urls: Elements = try! doc.getel.select("a");
      let table: Element = try! doc.getElementById("program-list")!
      let urls: Elements = try! table.select("a");
      
      
      for url in urls {
        //print( try url.className())
        if try url.className() == "audio-list-item hr" {
          let name: Element = try! url.getElementsByClass("title text-black").first()!
          print(try name.html());
          print( try url.attr("href"));//..html());
          
          
          if(try name.html().contains("重播") || !(try name.html().contains("回听"))) {
            
            continue;
          }
          let start=try url.attr("data-start").components(separatedBy: "_")[1];
          let end=try url.attr("data-end").components(separatedBy: "_")[1];
          
          for column in columns {
            
            if(try name.html().contains(column) ) {
              let source="http://lcache.qingting.fm/cache/"+date+"/4584/4584_"+date+"_"+start+"_"+end+"_24_0.m4a";
              
              if !items.keys.contains(column){
                let item: [String]=[source]
                items[column] = item;
              }else{
                var item=items[column]
                item?.append(source)
                items[column] = item;
              }
              
              break ;
            }
            
            
          }
          
          
          
        }
        
        
        
        
        
      }
      
      
      
    } catch {
      print("error")
    }
    
    var index = 0
    for item in items {
      for source in item.value{
      //  if let trackDictionary = trackDictionary as? JSONDictionary,
          //let previewURLString = trackDictionary["previewUrl"] as? String,
          let previewURL = URL(string: source)
          let name = item.key
          let artist = "20180520"
          tracks.append(Track(name: name, artist: artist, previewURL: previewURL!, index: index))
          index += 1
       
        
        
      
      }
      
      
    }
   
    
    
    
  }
  func getList() -> String{
    //let url = URL(string: "http://www.baidu.com")!
    let url = URL(string: "https://m.qingting.fm/channels/4584/date/20180515")!
    // url += "/channels/4584/date/20180515";
    // var output:String? ;
    let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
      if let localURL = localURL {
        if let output = try? String(contentsOf: localURL) {
          //print(output)
          //return output
          self.parse(input: output, date: "20180515")
          //self.downloadFile()
        }
      }
    }
    
    task.resume()
    
    
    return "";
  }
  
  
}
