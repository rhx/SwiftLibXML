# SwiftLibXML
A simple object-oriented Swift API around libxml2

![macOS](https://github.com/rhx/SwiftLibXML/actions/workflows/macOS.yml/badge.svg?branch=main)
![Linux](https://github.com/rhx/SwiftLibXML/actions/workflows/Linux.yml/badge.svg?branch=main)

## Prerequisites

### Swift

To build, you need at least Swift 5.2 (Swift 5.5+ should work fine), download from https://swift.org/download/ -- if you are using macOS, make sure you have the command line tools installed as well).  Test that your compiler works using `swift --version`, which should give you something like

	$ swift --version
	swift-driver version: 1.127.15 Apple Swift version 6.2.4 (swiftlang-6.2.4.1.4 clang-1700.6.4.2)
	Target: arm64-apple-macosx26.0

on macOS, or on Linux you should get something like:

	$ swift --version
	Swift version 6.1 (swift-6.1-RELEASE)
	Target: x86_64-unknown-linux-gnu

### libxml2

#### Linux

On Ubuntu 16.04, 18.04, 20.04, 22.04, and 24.04, you can use the libxml2 that comes with the distribution.  Just install with the `apt` package manager:

	sudo apt update
	sudo apt install libxml2-dev

#### macOS

On macOS, you can install gtk using HomeBrew (for setup instructions, see http://brew.sh).  Once you have a running HomeBrew installation, you can use it to install a native version of gtk:

	brew update
	brew install libxml2
