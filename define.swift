import Foundation
import Docopt // marathon: https://github.com/lf-araujo/docopt.swift.git
import SwiftyJSON // marathon: https://github.com/SwiftyJSON/SwiftyJSON.git

let doc: String = """
Get definitions from the Oxford Dictionary right from the command line.

Usage:
 define WORD [-l LANG]

Options:
 -l LANG --lang LANG  [default: en]
 -h --help            Shows this screen
 --version

"""

// Managing arguments
var args = CommandLine.arguments
args.remove(at: 0)
let argument = Docopt.parse(doc, argv: args, help: true, version: "0.0.1")

let group = DispatchGroup.init()

let appId = "8a7dd147"
let appKey = "7e7d022fbce6d8d4523eac3baa5bd04c"

let word = "Ace"
let url = URL(string: "https://od-api.oxforddictionaries.com/api/v1/entries/\(argument["--lang"]!)/\(argument["WORD"]!)")!
var request = URLRequest(url: url)
request.addValue("application/json", forHTTPHeaderField: "Accept")
request.addValue(appId, forHTTPHeaderField: "app_id")
request.addValue(appKey, forHTTPHeaderField: "app_key")

group.enter() // Use this before making anything that needs to be waited for
              // This manually add one to operation count in the dispatch group
URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
    defer {  // Defer makes all ends of this scope make something, here we want to leave the dispatch.
             // This is executed when the scope ends, even if with exception.

       group.leave() // Manually subtract one from the operation count
    }

    if let response = response,
        let data = data,
        let jsonData = try? JSON(data: data){
            print(jsonData["results"][0]["word"].string! + 
              jsonData["results"][0]["lexicalEntries"][0]["pronunciations"][0]["phoneticSpelling"].string! +
              " is " + jsonData["results"][0]["lexicalEntries"][0]["entries"][0]["senses"][0]["definitions"][0].string!)

    } else {
        print(error)
        print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
    }
}).resume()

group.wait()  // Wait for group to end operations.