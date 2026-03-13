# Changelog

The format of this document is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- This is a comment, you won't see it when GitHub renders the Markdown file.

When releasing a new version:

1. Remove any empty section (those with `_None._`)
2. Update the `## Unreleased` header to `## [<version_number>](https://github.com/tumblr/Kanvas-iOS/releases/tag/<version_number>)`
3. Add a new "Unreleased" section for the next iteration, by copy/pasting the following template:

## Unreleased

### Breaking Changes

_None._

### New Features

_None._

### Bug Fixes

_None._

### Internal Changes

_None._

-->

## 1.5.2

- Updates localized strings to be compatible with genstrings tool. [#168]

## 1.5.1

- Fixes a crash on iOS 18. [#167]

## 1.5.0

- Adds support for Swift Package Manager [#166]

## 1.4.9

- Force any video to encode as a gif when taken with the gif camera [#159]

## 1.4.8

- Replace `DispatchQueue.global` with Swift concurrency to reduce Thread Explosion [#153]
- Fix streched image after taking a shot in GIF mode issue [#155]
- Add new delegate methods to track appearing and disappearing of camera, preview, and editor screens. [#156]

## 1.4.7

- The crop box starts to swap its dimensions depending on portrait or landscape sized images. [#152]

## 1.4.6

- Fixes issues with files missing imports. [#149]
- Adds Crop & Rotate capabilities to the editor. [#150]

## Unreleased

### Breaking Changes

_None._

### New Features

_None._

### Bug Fixes

_None._

### Internal Changes

- Add this changelog file. [#148]
