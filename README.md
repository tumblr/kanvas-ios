<img width="200" align="right" src="https://github.com/tumblr/kanvas-ios/blob/main/images/kanvy-grin.png?raw=true" alt="kanvy">

# Kanvas


[![Build status](https://badge.buildkite.com/7c8558667703d6147550801644af0f394019d6e7b2daed739f.svg?branch=main)](https://buildkite.com/automattic/kanvas-ios)

[![Cocoapods](https://img.shields.io/cocoapods/v/Kanvas)](https://cocoapods.org/pods/Kanvas)

Kanvas is an [open-source](https://github.com/tumblr/kanvas-ios/blob/main/LICENSE) iOS library for adding effects, drawings, text, stickers, and making GIFs from existing media or the camera.

It is used in the [Tumblr iOS app](https://apps.apple.com/us/app/tumblr/id305343404) as a camera, media editor, GIF maker, and media posting tool. 

## Setup

Add this to your `Podfile`:

```ruby
pod 'Kanvas', :git => 'https://github.com/tumblr/kanvas-ios.git'
```

And run:

```bash
pod install
```

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

[`Example`](https://github.com/tumblr/kanvas-ios/tree/main/Example) is an example app showing how to use Kanvas. Try it out!

1. Run `cd Example; bundle exec pod install`
2. Open `Example/KanvasExample.xcworkspace` in Xcode
3. Run the app on a device.

## Bump version

### Steps

1. Open `Kanvas.podspec`
2. Upgrade `spec.version`, please refer `Version naming rules` section below.
3. `cd Example`
4. Run `pod install`
5. `cd ..` and update `CHANGELOG.md`
6. Create a PR from the changes targeting `main` branch

*You can take [this PR](https://github.com/tumblr/kanvas-ios/pull/151) as an example.*

### Version naming rules

(I suggest applying `Semantic Versioning` [technique](https://www.kodeco.com/7076593-cocoapods-tutorial-for-swift-getting-started#toc-anchor-008) from [Kodeco](https://www.kodeco.com/). Beside, [semver](https://semver.org/) should be worthing checking out.)

Many times, you’ll see a version written like this: 1.0.0. Those three numbers are major, minor and patch version numbers.

For example, for the version number 1.0.0, 1 is the major number, the first 0 is the minor number, and the second 0 is the patch number.

*Semantic Versioning Example:* **1.2.3**, where:
```
1: major
2: minor
3: patch
```

If the `major` number increases, it indicates that the version contains non-backward-compatible changes. When you upgrade a pod to the next `major` version, you may need to fix build errors or the pod may behave differently than before.

If the `minor` number increases, it indicates that the version contains new functionality that is backward-compatible. When you decide to upgrade, you may or may not need the new functionality, but it shouldn’t cause any build errors or change existing behavior.

If the `patch` number increases, it means the new version contains bug fixes but no new functionality or behavior changes. In general, you always want to upgrade `patch` versions as soon as possible to have the latest, stable version of the pod.

Finally, when you increase the highest-order number — `major`, then `minor` then `patch` — per the above rules, you must reset any lower-order numbers to zero.

*Here’s an example:*

Consider a pod that has a current version number of 1.2.3.

If you make changes that are not backward-compatible, don’t have new functionality, but fix existing bugs, you’d give it version 2.0.0.