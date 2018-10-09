import Foundation
import Docopt // marathon: https://github.com/lf-araujo/docopt.swift.git
import SwiftyJSON // marathon: https://github.com/SwiftyJSON/SwiftyJSON.git

let doc: String = """
Get definitions from the Oxford Dictionary right from the command line.

Usage:
 define WORD [-l LANG] [-as]

Options:
 -l LANG --lang LANG  [default: en]   Language (es, gu, hi, lv, sw, ta)
 -a --antonym                         Get antonyms for WORD
 -s --synonym                         Get synonyms for WORD
 -h --help                            Shows this screen
 --version

"""

// Managing arguments
var args = CommandLine.arguments
args.remove(at: 0)
let argument = Docopt.parse(doc, argv: args, help: true, version: "0.0.1")

let group = DispatchGroup.init()

let appId = "8a7dd147"
let appKey = "7e7d022fbce6d8d4523eac3baa5bd04c"

func definition() {
  let url = URL(string:
  "https://od-api.oxforddictionaries.com/api/v1/entries/\(argument["--lang"]!)/\(argument["WORD"]!)")!
  var request = URLRequest(url: url)
  request.addValue("application/json", forHTTPHeaderField: "Accept")
  request.addValue(appId, forHTTPHeaderField: "app_id")
  request.addValue(appKey, forHTTPHeaderField: "app_key")
  URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
    defer {  // Defer makes all ends of this scope make something, here we want to leave the dispatch.
             // This is executed when the scope ends, even if with exception.
       group.leave() // Manually subtract one from the operation count
    }

    if let response = response,
        let data = data,
        let jsonData = try? JSON(data: data) {
            print(jsonData["results"][0]["word"].string! + " [" +
              jsonData["results"][0]["lexicalEntries"][0]["pronunciations"][0]["phoneticSpelling"].string! +
              "] is " +
              jsonData["results"][0]["lexicalEntries"][0]["entries"][0]["senses"][0]["definitions"][0].string!)

    } else {
        print(error)
        print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
    }
    }).resume()
}

func antonyms() {
  let url = URL(string:
    "https://od-api.oxforddictionaries.com/api/v1/entries/\(argument["--lang"]!)/\(argument["WORD"]!)/antonyms")!
  var request = URLRequest(url: url)
  request.addValue("application/json", forHTTPHeaderField: "Accept")
  request.addValue(appId, forHTTPHeaderField: "app_id")
  request.addValue(appKey, forHTTPHeaderField: "app_key")
  URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
    defer {  // Defer makes all ends of this scope make something, here we want to leave the dispatch.
             // This is executed when the scope ends, even if with exception.
       group.leave() // Manually subtract one from the operation count
    }

    if let response = response,
        let data = data,
        let jsonData = try? JSON(data: data) {
           for (key, subJson): (String, JSON) in jsonData["results"][0]["lexicalEntries"] {
              //print(key)
              print(subJson["entries"][0]["senses"][0]["antonyms"].arrayValue.map({$0["text"].stringValue})
                .map {String($0)} .joined(separator: "\n"))
            }
    } else {
        print(error)
        print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
    }
  }).resume()
}

func synonym() {
    let url = URL(string:
    "https://od-api.oxforddictionaries.com/api/v1/entries/\(argument["--lang"]!)/\(argument["WORD"]!)/synonyms")!
  var request = URLRequest(url: url)
  request.addValue("application/json", forHTTPHeaderField: "Accept")
  request.addValue(appId, forHTTPHeaderField: "app_id")
  request.addValue(appKey, forHTTPHeaderField: "app_key")
  URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
    defer {  // Defer makes all ends of this scope make something, here we want to leave the dispatch.
             // This is executed when the scope ends, even if with exception.
       group.leave() // Manually subtract one from the operation count
    }

    if let response = response,
        let data = data,
        let jsonData = try? JSON(data: data) {
           for (key, subJson): (String, JSON) in jsonData["results"][0]["lexicalEntries"] {
              //print(key)
              print(subJson["entries"][0]["senses"][0]["synonyms"].arrayValue.map({$0["text"].stringValue})
                .map {String($0)} .joined(separator: "\n"))

            }
    } else {
        print(error)
        print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
    }
  }).resume()
}

group.enter() // Use this before making anything that needs to be waited for
              // This manually add one to operation count in the dispatch group

scope: if argument["--antonym"] as! Bool {
  antonyms()
  break scope
} else if argument["--synonym"] as! Bool {
  synonym()
  break scope
} else {
  definition()
}

group.wait()  // Wait for group to end operations.
