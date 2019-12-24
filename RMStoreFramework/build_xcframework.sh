#!/bin/bash

#—————————————————————————————————————————————————————————————————————————————————————————
# Setup
#—————————————————————————————————————————————————————————————————————————————————————————

set -euo pipefail

#
# Determine script directory and go to working directory.
#
SCRIPTDIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
SRCROOT=${SRCROOT:-"$SCRIPTDIR/.."}
cd "$SRCROOT"

# NOTES temp
# -destination 'platform=macOS,variant=Mac Catalyst'.
# ARCHS="x86_64h"

#
# This table details what we're going to build. The correct architecture will be used according
# to the SDK; as of this writing, no fat binaries should be build because the minimum SDK
# versions are all 64 bit, and no legacy architectures need be built.
#
# BUILD_SCHEME           ; BUILD_SDK
MANIFEST=$(cat <<HEREDOC
RMStoreFramework (iOS)   ; iphoneos
RMStoreFramework (iOS)   ; iphonesimulator
RMStoreFramework (tvOS)  ; appletvos
RMStoreFramework (tvOS)  ; appletvsimulator
RMStoreFramework (macOS) ; macosx
HEREDOC
)


#—————————————————————————————————————————————————————————————————————————————————————————
# Help
#—————————————————————————————————————————————————————————————————————————————————————————
echo_help()
{
# Build a list of things that we're going to build.
local BUILD_LIST=
    while IFS=';' read -ra KVP; do
        BUILD_LIST="$BUILD_LIST, $(echo ${KVP[3]} | xargs)"
    done <<< "$MANIFEST"
   
    cat <<HEREDOC
Usage: $0 [-h|--help]

This script builds individual RMStore frameworks for targeted platforms and 
assembles them into a single, cross-compatible xcframework. 

Output destination will be according the the Xcode project configuration, and
will be announced to stdout as each scheme is built.

Frameworks for each of the following device targets will be built:
   ${BUILD_LIST:1}
HEREDOC
}


#—————————————————————————————————————————————————————————————————————————————————————————
# Spinner for lengthy operations
#—————————————————————————————————————————————————————————————————————————————————————————
spinner()
{
  [ -o xtrace ]
  local _XTRACE=$?
  if [[ $_XTRACE -eq 0 ]]; then { set +x; } 2>/dev/null; fi
  
  local pid=$!
  local delay=0.75
  local spinstr='|/-\' #\'' (<- fix for some syntax highlighters)
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf "  [%c]" "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b"
  done

  wait $pid
  if [[ $_XTRACE -eq 0 ]]; then set -x; fi
  return $?
}


#—————————————————————————————————————————————————————————————————————————————————————————
# Main
#—————————————————————————————————————————————————————————————————————————————————————————

#
# Process command line arguments
#
while [[ $# -gt 0 ]]; do
    i="$1"
    case $i in
      -h|--help)
        echo_help
        exit
        ;;
      *)
        echo "Unknown argument: ${i}"
        echo "Use -h or --help for help. Hint: this script takes no arguments."
        exit 1
    ;;
    esac
done


#
# Remember the successful framework builds in order to assemble them into xcframework later.
#
FRAMEWORKS=()
 

#
# Build Loop
#
while IFS=';' read -ra KVP; do

    BUILD_SCHEME=$(echo "${KVP[0]}" | xargs) 
    BUILD_SDK=$(echo "${KVP[1]}" | xargs)

    # Capture Xcode's build settings for this scheme.  
    BUILD_SETTINGS=$(xcodebuild \
        archive \
        -scheme "$BUILD_SCHEME" \
        -sdk "$BUILD_SDK" \
        -showBuildSettings \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    )

    # From those, we can get paths to show to the user.
    BUILD_DIR=$(echo "$BUILD_SETTINGS" | grep [[:space:]]BUILD_DIR | sed 's/^.*= //')
    BUILT_DIR=$(echo "$BUILD_SETTINGS" | grep [[:space:]]BUILT_PRODUCTS_DIR | sed 's/^.*= //')
  
    # We'll capture stdout to a logfile.
    BUILD_LOG="$BUILT_DIR/${BUILD_SDK}.log"
    
    cat <<HEREDOC
     Scheme: $BUILD_SCHEME 
        SDK: $BUILD_SDK
 Build Root: $BUILD_DIR
  Build Log: $BUILD_LOG
HEREDOC

    printf "     Status:"    

    set +e
    
    mkdir -p "$BUILT_DIR"
    echo "$BUILD_SETTINGS" > "$BUILD_LOG"
    (xcodebuild \
        archive \
        -scheme "$BUILD_SCHEME" \
        -sdk "$BUILD_SDK" \
        -archivePath "${BUILT_DIR}/${BUILD_SDK}.xcarchive" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        >> "$BUILD_LOG"
    ) & spinner
  
    RESULT=$?
    if [ "${RESULT}" != 0 ]; then
      printf " Problem during xcodebuild; please check ${BUILD_LOG}\n\n"
      exit $RESULT
    else
      printf " complete\n\n"
      FRAMEWORKS+=("-framework ${BUILT_DIR}/${BUILD_SDK}.xcarchive/Products/Library/Frameworks/RMStoreFramework.framework ")
    fi

done <<< "$MANIFEST"


#
# Make an xcframework.
#

XCFRAMEWORK="$BUILD_DIR/RMStoreFramework.xcframework"
rm -R "$XCFRAMEWORK"
xcodebuild -create-xcframework ${FRAMEWORKS[*]} -output "$XCFRAMEWORK"
RESULT=$?
if [[ "${RESULT}" != 0 ]]; then
  echo "Something went wrong building the XCFramework."
  exit $RESULT
fi
                

#
# Done
#

cd "$SCRIPTDIR"
