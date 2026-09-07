#!/bin/zsh
set -euo pipefail

project_dir=${0:A:h:h}
simulator_id="0A222F0C-59FA-4584-BE57-241BC9D787AD"
derived_data="/tmp/SkinCareAppStoreScreenshots"
app_path="$derived_data/Build/Products/Debug-iphonesimulator/SkinCare.app"

cd "$project_dir"
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl boot "$simulator_id" 2>/dev/null || true
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl bootstatus "$simulator_id" -b
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
    -project SkinCare.xcodeproj -scheme SkinCare \
    -destination "platform=iOS Simulator,id=$simulator_id" \
    -configuration Debug -derivedDataPath "$derived_data" \
    CODE_SIGNING_ALLOWED=NO build -quiet

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl uninstall "$simulator_id" com.keremoztopuz.SkinCare 2>/dev/null || true
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl install "$simulator_id" "$app_path"
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl status_bar "$simulator_id" override \
    --time 22:45 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4

screens=(home result regions recents compare search)
names=(01-home 02-result 03-regions 04-recents 05-compare 06-search)

for locale in tr en; do
    output="$project_dir/docs/app-store/screenshots/final-$locale"
    mkdir -p "$output"
    if [[ "$locale" == tr ]]; then
        language="(tr)"
        region="tr_TR"
    else
        language="(en)"
        region="en_US"
    fi

    for index in {1..6}; do
        screen=${screens[$index]}
        name=${names[$index]}
        DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl terminate "$simulator_id" com.keremoztopuz.SkinCare 2>/dev/null || true
        DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl launch "$simulator_id" com.keremoztopuz.SkinCare \
            -screenshotScreen "$screen" -AppleLanguages "$language" -AppleLocale "$region"
        sleep 5
        screenshot="$output/$name.jpg"
        DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl io "$simulator_id" screenshot "$screenshot"
    done
done

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl status_bar "$simulator_id" clear
printf 'App Store screenshots written to docs/app-store/screenshots/final-{tr,en}\n'
