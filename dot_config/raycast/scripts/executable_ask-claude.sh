#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Ask Claude
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ../res/claude-icon.png
# @raycast.argument1 { "type": "text", "placeholder": "Question for Claude" }
# @raycast.packageName AI Tools
# @raycast.description Send text directly to Claude desktop app
# @raycast.author DOOduneye
# @raycast.authorURL https://raycast.com/DOOduneye

# Get the input text from Raycast
query="$1"

# AppleScript to launch Claude and send the text
osascript <<EOF
tell application "Claude" to activate
delay 1
tell application "System Events" to keystroke "$query"
tell application "System Events" to keystroke return
EOF
