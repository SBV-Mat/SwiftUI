
#!/bin/bash

set -eo pipefail

cd MyWaySwiftUI; swift test --parallel; cd ..
