#!/usr/bin/env bash

set -euo pipefail

iterations="${1:?usage: stress-video-metadata-test.sh <iterations> [xcodebuild-log]}"
log="${2:-}"
test_id='KanvasExampleTests/MediaMetadataTests/testWriteAndReadMetadataWithVideo'

if [ -z "$log" ]; then
  xcodebuild -downloadComponent MetalToolchain || true
  install_gems
  restore_swiftpm_cache --package-resolved ExampleSPM/KanvasExample.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

  mkdir -p artifacts
  log="artifacts/stress-${BUILDKITE_PARALLEL_JOB:-0}.log"

  echo "--- :xcode: Running $test_id $iterations times"
  xcodebuild test \
    -project ExampleSPM/KanvasExample.xcodeproj \
    -scheme KanvasExample \
    -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.5' \
    -only-testing:"$test_id" \
    -test-iterations "$iterations" \
    -retry-tests-on-failure NO \
    > "$log" 2>&1 || true
fi

echo "--- :mag: Checking results"
pattern="Test Case '-\[KanvasExampleTests\.MediaMetadataTests testWriteAndReadMetadataWithVideo\]'"
passed=$(grep -cE "$pattern passed" "$log" || true)
failed=$(grep -cE "$pattern failed" "$log" || true)
durations=$(grep -oE "$pattern passed \(([0-9.]+) seconds\)" "$log" | grep -oE '[0-9]+\.[0-9]+' || true)
over_old_wait=$(awk '$1 > 5 { n++ } END { print n + 0 }' <<< "$durations")
slowest=$(sort -rn <<< "$durations" | head -1)

echo "passed=$passed failed=$failed slowest=${slowest:-n/a} runs_over_5s=$over_old_wait"

if [ "$passed" -ne "$iterations" ] || [ "$failed" -ne 0 ]; then
  echo "ASSERTION FAILED: expected $iterations passes and 0 failures"
  exit 1
fi
