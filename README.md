![GeoConfess Logo](Logo.png)

# GeoConfess

GeoConfess iOS app, an Uber style app for linking *believers* and *priests*.

## Development Tools

The recommended Xcode version is **7.3**. All app code is based on **Swift 2.2**. 

All dependencies are managed by [CocoaPods](https://cocoapods.org), version **0.39.0**.
The downloaded frameworks are stored in the `Pods` directory and *not* tracked by Git.
As such, you must run `pod install` after cloning the repo (or pulling in new code).

### Backend API Documentation

Our backend API is documented [here](http://geoconfess.herokuapp.com/apidoc/V1.html).

Some useful scripts are available in the `bin` directory 
for playing with the backend (eg, `bin/show-user`).

### Swift Coding Conventions

Please configure your Xcode to the following settings: 

* Page guide at column: **90** 
* Prefer indent using: **Tabs**
* Tab width: **4**
* Automatically trim trailing whitespaces: **on**

All settings above are available at: *Xcode* > *Preferences...* > *Text Editing*.

## Test Accounts

Some useful accounts for testing:

	admin@example.com
	1q2w3e4r
	
	user@example.com
	123456
	
	priest@example.com
	123456

For instance, for getting more info about one of these 
accounts, just type `bin/show-user <username> <password>`.
