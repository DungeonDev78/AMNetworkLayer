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
 2. **Request model**
 3. **Response model**

Let's see the details of every components.

### Service provider
It needs to confrom the AMServiceProviderProtocol.
```swift
import AMNetworkLayer

class SWAPIServiceProvider: AMServiceProviderProtocol {

    func getHost() -> String {
        "swapi.dev"
    }
    
    func getHTTPScheme() -> AMNetworkManager.SchemeKind {
        .https
    }
    
    func createHTTPHeader() -> [String : String] {
        ["Content-Type" : "application/json"]
    }
    
    func parseAndValidate<U>(
        _ data: Data,
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

### Request model

It needs to confrom the AMBaseRequest and use the phantom type to specify the expected response type of the service.
```swift
import AMNetworkLayer

class SWAPIGetPeopleRequest: AMBaseRequest<SWAPIGetPeopleRsponse> {
    
    init(peopleId: Int) {
        let path = "/api/people/\(peopleId)"
        
        super.init(serviceProvider: SWAPIServiceProvider(), endpoint: path)
    }
}
```

### Response model
It needs to confrom the Codable protocol.
```swift
struct SWAPIGetPeopleRsponse: Codable {
    
    let name: String?
    let height: String?
    let mass: String?
    let gender: String?
    let homeworld: String?
    
    var description: String {
"""
************************************************
* Name: \(name ?? "---")
* Height: \(height ?? "---") cm
* Mass: \(mass ?? "---") kg
* Gender: \(gender?.capitalized ?? "---")
* Homeworld: \(homeworld ?? "---")
************************************************

"""
    }
}
```

## Putting it all together
```swift
import AMNetworkLayer

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = SWAPIGetPeopleRequest(peopleId: 1)
        AMNetworkManager.shared.performRequest(request: request) { (result) in
            switch result {
            case .success(let response):
                print(response?.description ?? "---")
            case .failure(let error):
                print(error.localizedDescription)
                print(error.recoverySuggestion ?? "")
            }
        }
    }
}
```

## Advanced Usage
TBD

## Author

* **Alessandro "DungeonDev78" Manilii**

## License

This project is licensed under the MIT License.
