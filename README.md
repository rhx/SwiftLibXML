# SwiftLibXML
A simple object-oriented Swift API around libxml2

## Prerequisites

### Swift

To build, you need at least Swift 5.2 (Swift 5.3+ should work fine), download from https://swift.org/download/ -- if you are using macOS, make sure you have the command line tools installed as well).  Test that your compiler works using `swift --version`, which should give you something like

	$ swift --version
	Apple Swift version 5.3.2 (swiftlang-1200.0.45 clang-1200.0.32.28)
    Target: x86_64-apple-darwin20.3.0

on macOS, or on Linux you should get something like:

	$ swift --version
	Swift version 5.3.2 (swift-5.3.2-RELEASE)
	Target: x86_64-unknown-linux-gnu

### libxml2

#### Linux

On Ubuntu 16.04, 18.04, or 20.04, you can use the libxml2 that comes with the distribution.  Just install with the `apt` package manager:

	sudo apt update
	sudo apt install libxml2-dev

#### macOS

On macOS, you can install gtk using HomeBrew (for setup instructions, see http://brew.sh).  Once you have a running HomeBrew installation, you can use it to install a native version of gtk:

	brew update
	brew install libxml2
