#!/bin/sh

SRCROOT="$(pwd)"
CONFIGURATION=Release
BUILT_PRODUCTS_DIR="${SRCROOT}/build"

xcodebuild -scheme "StopKit Mac" -destination "generic/platform=OS X" -configuration ${CONFIGURATION} BUILD_LIBRARY_FOR_DISTRIBUTION=YES CONFIGURATION_BUILD_DIR="${BUILT_PRODUCTS_DIR}/${CONFIGURATION}" 1> /dev/null 2>> ./Error.log

xcodebuild -scheme "StopKit iOS" -destination "generic/platform=iOS Simulator" -configuration ${CONFIGURATION} BUILD_LIBRARY_FOR_DISTRIBUTION=YES CONFIGURATION_BUILD_DIR="${BUILT_PRODUCTS_DIR}/${CONFIGURATION}-iphonesimulator" 1> /dev/null 2>> ./Error.log

xcodebuild -scheme "StopKit iOS" -destination "generic/platform=iOS" -configuration ${CONFIGURATION} BUILD_LIBRARY_FOR_DISTRIBUTION=YES CONFIGURATION_BUILD_DIR="${BUILT_PRODUCTS_DIR}/${CONFIGURATION}-iphoneos" 1> /dev/null 2>> ./Error.log

# Clear previous builds
DIST_DIR="${SRCROOT}/Distribution"
rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

function add_framework() {
  local framework_path="$1/StopKit.framework"
  local dysm_path="$1/StopKit.framework.dSYM"
  if [ -d "${framework_path}" ]; then
      XC_FRAMEWORKS+=( -framework "${framework_path}")
  fi
  echo "Looking for dSYM at ${dysm_path}"
  if [ -d "${dysm_path}" ]; then
      echo "Copying dSYM to $2"
      cp -r "${dysm_path}" "$2"
  fi
}

add_framework "${SRCROOT}/build/${CONFIGURATION}" "${DIST_DIR}/StopKit-Mac.dSYM"
for SDK in iphoneos iphonesimulator appletvos appletvsimulator maccatalyst; do
  add_framework "${SRCROOT}/build/${CONFIGURATION}-${SDK}" "${DIST_DIR}/StopKit-${SDK}.dSYM"
done

# Build XCFramework.
xcodebuild -create-xcframework "${XC_FRAMEWORKS[@]}" -output "${DIST_DIR}/StopKit.xcframework"  1> /dev/null 2>> ./Error.log

# Clear temp build files
rm -rf "${SRCROOT}/build"
