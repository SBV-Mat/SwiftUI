
#!/bin/bash

set -eo pipefail

xcodebuild -workspace MyWaySwiftUI.xcworkspace \
            -scheme MyWaySwiftUI\ iOS \
            -destination platform=iOS\ Simulator,OS=18.1,name=iPhone\ 15 \
            clean test | xcpretty
