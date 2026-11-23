#!/usr/bin/env bash

set -euo pipefail

log="${1:-}"
test_id='KanvasExampleTests/MediaMetadataTests/testWriteAndReadMetadataWithVideo'

if [ -z "$log" ]; then
  xcodebuild -downloadComponent MetalToolchain || true
  install_gems
  restore_swiftpm_cache --package-resolved ExampleSPM/KanvasExample.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

  mkdir -p artifacts
  log="artifacts/stress-${BUILDKITE_PARALLEL_JOB:-0}.log"

  echo "--- :xcode: Running $test_id"
  xcodebuild test \
    -project ExampleSPM/KanvasExample.xcodeproj \
    -scheme KanvasExample \
    -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.5' \
    -only-testing:"$test_id" \
    > "$log" 2>&1 || true
fi

echo "--- :mag: Checking results"
pattern="Test Case '-\[KanvasExampleTests\.MediaMetadataTests testWriteAndReadMetadataWithVideo\]'"
passed=$(grep -cE "$pattern passed" "$log" || true)
failed=$(grep -cE "$pattern failed" "$log" || true)
duration=$(grep -oE "$pattern (passed|failed) \(([0-9.]+) seconds\)" "$log" | grep -oE '[0-9]+\.[0-9]+' || true)

echo "passed=$passed failed=$failed duration=${duration:-n/a}"

if [ "$passed" -ne 1 ] || [ "$failed" -ne 0 ]; then
  echo "ASSERTION FAILED: expected 1 pass and 0 failures"
  exit 1
fi
