# AMNetworkLayer
A lightweight REST network layer in Swift based on URLSession.

## Installation
Requirements:
 - .iOS(.v10)


### Swift Package Manager 
1. In Xcode, open your project and navigate to File → Swift Packages → Add Package Dependency.
2. Paste the repository URL (https://github.com/DungeonDev78/AMNetworkLayer.git) and click Next.
3. For Rules, select version.
4. Click Finish.

### Swift Package
```swift
.package(url: "https://github.com/DungeonDev78/AMNetworkLayer.git", .upToNextMajor(from: "0.2.0"))
```

## Usage
**Guide in development...**

In order to perform a REST service, all you have to do is create the three main components needed by this library:
 1. **Service Provider**
 2. **Request Class**
 3. **Response Object**

Let's see the details of every components.

### Service Provider
The first piece of the puzzle is the Service Provider. It describes all the "behaviour" of the backend that we are going to contact.
Every server has its own rules for the creation of the Http Headers, parsing and response validation, url to contact, etc... so you will have to create an object that conforms to the **AMServiceProviderProtocol**:
```swift
public protocol AMServiceProviderProtocol: Codable {
    
    /// It's the url host of the service provider. Could be different according to different environments for example.
    /// If nededed implement an enum with the possible options using a computed var for host
    var host: String { get }
    
    /// It's the  HTTP Scheme of the service provider. Could be different according to different environments for example.
    /// If nededed implement an enum with the possible options using a computed var for httpScheme
    var httpScheme: AMNetworkManager.SchemeKind { get }
    
    /// Create the HTTP Headers of the service provider according to the rules of the server
    func createHTTPHeaders() -> [String: String]
    
    /// Perform a parse and a validation of the response according to the rules of the server
    /// - Parameters:
    ///   - data: the raw data of the response
    ///   - responseType: the generic of the response
    ///   - error: the possible general error of the given service
    ///   - completion: the completion handler
    func parseAndValidate<U: Codable>(_ data: Data,
                                      responseType: U.Type,
                                      error: AMError?,
                                      completion: @escaping AMNetworkCompletionHandler<U>)
}
```

With this approach your App will be able to request datas from different servers. Just create the provider, give it to the request (see later) and it's done!


### Request Class
The second piece of the puzzle is the Request Class.
It needs to inherit from the AMBaseRequest and use the phantom type to specify the expected response type of the service.
```swift
/// Create a request class inherited from this object.
/// Must use the Phantom Type to specify the type of the response.
open class AMBaseRequest<Response> {
    // MARK: - Properties
    public var endpoint: String
    public var params = [String: Any]()
    public var additionalHeaders = [String: String]()
    public var timeout = 60.0
    public var httpMethod: AMNetworkManager.HTTPMethodKind = .get
    
    // Hold the infos of the contacted server
    public var serviceProvider: AMServiceProviderProtocol
    
    // Filename of the json mocked response
    public var mockedResponseFilename = "*** PLEASE INSERT FILENAME ***"
    
    // MARK: - Initialization
    public init(serviceProvider: AMServiceProviderProtocol, endpoint: String) {
        self.serviceProvider = serviceProvider
        self.endpoint = endpoint
    }
}
```
As you can see the *params*, *additionalHeaders*, *timeout* and *httpMethod* have already a default standard value.

Sometimes you will need to add specific headers for a request; well it's needless to say that you could use the property *additionalHeaders* of the request. The dictionary of this variable will be added alongside the one provided in the *Service Provider* object.

If you plan to use the *mock mode* of the library, you have to specify the *mockedResponseFilename* of the json file of the response.

### Response Object
It is an object that needs only to conform the **Codable** protocol.

## Putting it all together
Let's create a small example to download musif info from iTunes Database

**Service Provider**
```swift
import Foundation
import AMNetworkLayer

class ITunesServiceProvider: AMServiceProviderProtocol {
    
    var host = "itunes.apple.com"
    var httpScheme: AMNetworkManager.SchemeKind = .https
    
    func createHTTPHeaders() -> [String : String] {
        ["Content-Type" : "application/json"]
    }
    
    func parseAndValidate<U>(_ data: Data,
                             responseType: U.Type,
                             error: AMError?,
                             completion: @escaping AMNetworkCompletionHandler<U>) where U : Codable {
                             
        if let error = error {
            completion(.failure(error))
            return
        }
        
        if let parsedObject = try? JSONDecoder().decode(U.self, from: data) {
            completion(.success(parsedObject))
            return
        }
        
        completion(.failure(.serialization))
    }
}
```

**Request Class**
```swift
import Foundation
import AMNetworkLayer

class ITunesSearchRequest: AMBaseRequest<ITunesSearchResponse> {
    
    init(artist: String, limit: Int) {
        super.init(serviceProvider: ITunesServiceProvider(), endpoint: "/search")
        params = ["term": artist,
                  "limit": limit]
        mockedResponseFilename = "ITunesSearchMockedResponse"
    }
}
```
**Response Object**
```swift
import Foundation

struct ITunesSearchResponse: Codable {
    let resultCount: Int?
    let results: [ITunesArtistResult]?
}

struct ITunesArtistResult: Codable {
    let artistName: String?
    let collectionName: String?
    let collectionPrice: Double?
    let isStreamable: Bool?
}
```

**Mocked Json**
```json
{
    "resultCount": 3,
    "results": [{
            "collectionPrice": 9.9900000000000002,
            "collectionName": "Octavarium",
            "artistName": "Dream Theater",
            "isStreamable": true
        },
        {
            "collectionPrice": 9.9900000000000002,
            "collectionName": "Images and Words",
            "artistName": "Dream Theater",
            "isStreamable": true
        },
        {
            "collectionPrice": 9.9900000000000002,
            "collectionName": "Octavarium",
            "artistName": "Dream Theater",
            "isStreamable": true
        }
    ]
}
```

**ViewController**
```swift
import UIKit
import AMNetworkLayer

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = ITunesSearchRequest(artist: "Dream Theater", limit: 3)
        AMNet.performRequest(request: request) { (result) in
            switch result {
            case .success(let response):
                print(response?.resultCount ?? 0)
            case .failure(let error):
                print(error.localizedDescription)
                print(error.recoverySuggestion ?? "")
            }
        }
    }
}
```

## Advanced Usage
In this section wou will find additional info for an andavced use of the AMNetworkLayer library.

**Note**: if you have red the documentation and you have already tried some services, you'll have noticed that you can use indifferently the two forms **AMNetworkManager.shared** or the shortest **AMNet**.

### Logs
In the development phase of an app it's always a good thing to have all the logs under control. Of course the AMNetworkLayer is already *log-enabled*.
In the release phase of an app it's always a good thing to disable all the logs. Needless to say that the AMNetworkLayer is already *log-disabled-ready*.

Tho disable/enable the logs in any moment, just use:
```swift
AMNet.isVerbose = false // Disable all logs
AMNet.isVerbose = true  // Enable all logs
```

By default this value is set to **true**.

### Mock Mode
TBD

### Certificate Pinning
TBD

## Tips'n'Tricks
TBD

## Author

* **Alessandro "DungeonDev78" Manilii**

## License

This project is licensed under the MIT License.
