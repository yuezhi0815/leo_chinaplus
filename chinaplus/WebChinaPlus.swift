
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
class WebChinaPlus {
  
  
  var columns: [String] = ["Today", "Horizons", "The Beijing Hour", "Round Table"];
  var max=3;
  var items = [String: [String]]()
  
  
  typealias JSONDictionary = [String: Any]
  typealias QueryResult = ([Track]?, String) -> ()
  
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
    if var urlComponents = URLComponents(string: "http://chinaplus.cri.cn/radio/index.html") {
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
          self.parse(input: output)
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
  
  func isFileExisted(column: String, name: String) -> Bool{
    
    let urlDocument = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let filename = name.replacingOccurrences(of: " ", with: "_")
    let urlFile=urlDocument.appendingPathComponent(column+"/"+filename+".mp3")
    return FileManager.default.fileExists(atPath: urlFile.path)
    
  }
  
  func parse(input: String){
    do {
      //let html: String = "<p>An <a href='http://example.com/'><b>example</b></a> link.</p>";
      let html: String = input
      let doc: Document = try! SwiftSoup.parse(html)
      // let names: Elements = try! doc.getElementsByClass("title text-black");//.select("div");
      //   let urls: Elements = try! doc.getel.select("a");
      let table: Elements = try! doc.getElementsByAttributeValue("class", "js-proGrams-name")
        let names: Elements = try! table.first()!.getElementsByAttributeValueMatching("class", "js-proGrams-name-li.*");
     // let names: Elements = try! table.first()!.getElementsByAttributeValue("class", "js-proGrams-name-li");
      
       let sources: Elements = try! table.first()!.getElementsByAttributeValue("class", "js-proGrams-list");
      var index=0;
     
      for j in 0..<names.size() {
        //print( try url.className())
       
          let name: Element = try! names.get(j).select("strong").first()!
          print(try name.html());
         // print( try name.attr("href"));//..html());
          
         loop:
          for column in columns {
            
            if(try name.html().contains(column) ) {
              let srcs: Elements = try! sources.get(j).getElementsByTag("source");//.first()?.attr("src");
              let details: Elements = try! sources.get(j).getElementsByTag("p");
              
              for i in 0..<srcs.size(){
                if i > 3 {
                  break loop;
                }else{
                  
                  
                  if !self.isFileExisted(column: column, name: try details.get(i).text()){
                    tracks.append(Track(name: column, artist: try details.get(i).text(), previewURL: URL(string: try srcs.get(i).attr("src"))!, index: index))
                    index+=1
                  }
                  
                  
                 
                  
                }
                /*
                if !items.keys.contains(column){
                 // let item: [String]=[try srcs.get(i).attr("src")]
                 // items[column] = item;
                  tracks.append(Track(name: column, artist: try details.get(i).text(), previewURL: URL(string: try srcs.get(i).attr("src"))!, index: index))
                  
                  
                }else{
                 
                 // var item=items[column]
                  tracks.append(Track(name: column, artist: try details.get(i).text(), previewURL: URL(string: try srcs.get(i).attr("src"))!, index: index))
                   index+=1
                  /*
                  if item!.count > max {
                    break loop
                  }
                  item?.append(try srcs.get(i).attr("src"))
                  items[column] = item;*/
                }*/
               
              }
              
              
              
              break ;
            }
            
            
          }
          
          
          
        
       // index+=1;
        
        
        
        
      }
      
      
      
    } catch {
      print("error")
    }
    
    
    /*
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
      
      
    }*/
    
    
    
    
  }
 
  
  
}

