#!/usr/bin/zsh

while [ $# -gt 0 ]; do
    if [[ $1 == "--cold" ]]; then
        hot=false
    fi
    shift
done

if $hot; then
    cd $ANDROID_SDK_ROOT/emulator; emulator -avd $(emulator -list-avds)
else
    cd $ANDROID_SDK_ROOT/emulator; emulator -avd $(emulator -list-avds) -no-snapshot-load
fi