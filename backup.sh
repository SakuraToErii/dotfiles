#!/bin/bash
set -e

echo "Starting Backup."

ICLOUD_DOCS="$HOME/Library/Mobile Documents/com~apple~CloudDocs"

APP_PREFS_DIR="$ICLOUD_DOCS/Backup/AppPreferences"
mkdir -p "$APP_PREFS_DIR"

defaults export com.tencent.xinWeChat "$APP_PREFS_DIR/wechat.plist"
defaults export cn.better365.iShotPro "$APP_PREFS_DIR/ishot.plist"
defaults export com.microsoft.Excel "$APP_PREFS_DIR/excel.plist"
defaults export com.microsoft.Word "$APP_PREFS_DIR/word.plist"
defaults export com.microsoft.Powerpoint "$APP_PREFS_DIR/ppt.plist"

echo "Backup Complete."
