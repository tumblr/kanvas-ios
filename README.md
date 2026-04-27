<img width="200" align="right" src="https://github.com/tumblr/kanvas-ios/blob/main/images/kanvy-grin.png?raw=true" alt="kanvy">

# Kanvas


[![Build status](https://badge.buildkite.com/7c8558667703d6147550801644af0f394019d6e7b2daed739f.svg?branch=main)](https://buildkite.com/automattic/kanvas-ios)

Kanvas is an [open-source](https://github.com/tumblr/kanvas-ios/blob/main/LICENSE) iOS library for adding effects, drawings, text, stickers, and making GIFs from existing media or the camera.

It is used in the [Tumblr iOS app](https://apps.apple.com/us/app/tumblr/id305343404) as a camera, media editor, GIF maker, and media posting tool.

## Setup

Add Kanvas as a Swift Package dependency:

```swift
dependencies: [
    .package(url: "https://github.com/tumblr/kanvas-ios.git", from: "1.6.2")
]
```

Or in Xcode: **File → Add Package Dependencies…** and enter the repository URL.

## Usage

Kanvas is mainly two parts: [the Camera](https://github.com/tumblr/kanvas-ios/blob/main/Classes/Camera/CameraController.swift), and [the Editor](https://github.com/tumblr/kanvas-ios/blob/main/Classes/Editor/EditorViewController.swift). Both are just view controllers that you present, and have settings and delegates that help you customize their behavior.

To show the camera:

```swift
let settings = CameraSettings()
let camera = CameraController(settings: settings)
present(camera, animated: true)
```

And to edit existing media, like a video:

```swift
let videoURL = URL(string: "path/to/video.mov")
let settings = CameraSettings()
let editor = EditorViewController.createEditor(for: videoURL, settings: settings)
present(editor, animated: true)
```

Each view controller accepts a [`CameraSettings`](https://github.com/tumblr/kanvas-ios/blob/main/Classes/Settings/CameraSettings.swift) object, which provides fine-grained settings and feature togges. Each view controller also has a `delegate` property for providing your own handlers to creating media, performing editing operations, logging, or really anything else Kanvas can do.

Documentation is lacking at the moment, but contributions are welcome!

## Example App

[`ExampleSPM`](https://github.com/tumblr/kanvas-ios/tree/main/ExampleSPM) is an example app showing how to use Kanvas. Try it out!

1. Open `ExampleSPM/KanvasExample.xcodeproj` in Xcode
2. Run the app on a device or simulator.
