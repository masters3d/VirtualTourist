This project uses the flickr API to get pictures around a location. 

My API key is not included in this repo. 

```swift
 static var flickrAPIKey:String {
    
    guard let path = Bundle.main.path(forResource: "SecretAPIKeys", ofType: "plist"),
        let nsarray = NSArray(contentsOfFile: path),
        let array = nsarray as? Array<String>,
        let key = array.first
        else { fatalError(" Flickr API not included. Please overide the APIConstants.flickrAPIKey with your API key")}
    return key
    
    }
```

Replace the above code with 

```swift
 static var flickrAPIKey = "YOUR KEY HERE"
 ```
 
 Alternatively, you can add a file called `SecretAPIKeys.plist` to the project. Or you can create this with xcode. 

``` xmls
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
	<string>YOUR API KEY HERE</string>
</array>
</plist>
```