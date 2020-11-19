# Kanvas

[![Kanvas Build Status](https://circleci.com/gh/tumblr/kanvas-ios.svg?style=svg)](https://circleci.com/gh/tumblr/kanvas-ios)

<img width="200" align="center" src="https://github.com/tumblr/kanvas-ios/blob/readme/images/kanvy-grin.png?raw=true" alt="kanvy">

Kanvas is an iOS library for adding effects, drawings, text, stickers, and making GIFs from existing media or the camera.

It is used in the Tumblr iOS app as a camera, media editor, GIF maker, and media posting tool. 

## Setup

Add this to your `Podfile`:

```ruby
pod 'KanvasCamera', :git => 'https://github.com/tumblr/kanvas-ios.git'
```

And run:

```bash
pod install
```

## Usage

Kanvas is mainly two parts: the Camera, and the Editor. Both are just view controllers that you present, and have settings and delegates that help you customize their behavior.

To just show the camera:

```swift
let settings = CameraSettings()
let camera = CameraController(settings: settings)
present(camera, animated: true)
```

And to edit an existing video:

```swift
let videoURL = URL(string: "path/to/video.mov")
let settings = CameraSettings()
let editor = EditorViewController.createEditor(for: videoURL, settings: settings)
present(editor, animated: true)
```

Each view controller uses `CameraSettings`, which have numberous flags for enabling or disabling each feature. Each view controller also have a `delegate` property for providing your own handlers to creating media, performing editing operations, logging, or really anything else Kanvas can do.


## Example App

`KanvasCameraExample` is an example app showing how to use Kanvas. To try it out:

1. Run `cd KanvasCameraExample; bundle exec pod install`
2. Open `KanvasCameraExample/KanvasCameraExample.xcworkspace`
3. Run it on a device from Xcode.
