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

## Unreleased

- Added new delegate methods to track appearing and disappearing of camera, preview, and editor screens. [#156]

## 1.4.8

- Replace `DispatchQueue.global` with Swift concurrency to reduce Thread Explosion [#153]
- Fix streched image after taking a shot in GIF mode issue [#155]

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
