cask "zoom" do
  arch arm: "arm64/"

  version "5.15.6.21146"
  sha256 arm:   "d87f2d1280630b7a74bc2e8b4297476af852bf482feeb538b300237426a42977",
         intel: "cf65f6e42bd8e3316114c2274c97c48cf01dadef980d8bfd34e880c54e63d013"

  url "https://cdn.zoom.us/prod/#{version}/#{arch}Zoom.pkg"
  name "Zoom.us"
  desc "Video communication and virtual meeting platform"
  homepage "https://www.zoom.us/"

  livecheck do
    url "https://zoom.us/client/latest/Zoom.pkg"
    strategy :header_match
  end

  auto_updates true
  conflicts_with cask: "zoom-for-it-admins"

  pkg "Zoom.pkg"

  postflight do
    # Description: Ensure console variant of postinstall is non-interactive.
    # This is because `open "$APP_PATH"&` is called from the postinstall
    # script of the package and we don't want any user intervention there.
    retries ||= 3
    ohai "The Zoom package postinstall script launches the Zoom app" if retries >= 3
    ohai "Attempting to close zoom.us.app to avoid unwanted user intervention" if retries >= 3
    return unless system_command "/usr/bin/pkill", args: ["-f", "/Applications/zoom.us.app"]

  rescue RuntimeError
    sleep 1
    retry unless (retries -= 1).zero?
    opoo "Unable to forcibly close zoom.us.app"
  end

  uninstall signal:    ["KILL", "us.zoom.xos"],
            pkgutil:   "us.zoom.pkg.videomeeting",
            launchctl: "us.zoom.ZoomDaemon",
            delete:    [
              "/Applications/zoom.us.app",
              "/Library/Internet Plug-Ins/ZoomUsPlugIn.plugin",
              "/Library/Logs/DiagnosticReports/zoom.us*",
              "/Library/PrivilegedHelperTools/us.zoom.ZoomDaemon",
            ]

  zap trash: [
    "~/.zoomus",
    "~/Desktop/Zoom",
    "~/Documents/Zoom",
    "~/Library/Application Scripts/*.ZoomClient3rd",
    "~/Library/Application Support/CloudDocs/session/containers/iCloud.us.zoom.videomeetings.plist",
    "~/Library/Application Support/CloudDocs/session/containers/iCloud.us.zoom.videomeetings",
    "~/Library/Application Support/CrashReporter/zoom.us*",
    "~/Library/Application Support/zoom.us",
    "~/Library/Caches/us.zoom.xos",
    "~/Library/Cookies/us.zoom.xos.binarycookies",
    "~/Library/Group Containers/*.ZoomClient3rd",
    "~/Library/HTTPStorages/us.zoom.xos",
    "~/Library/HTTPStorages/us.zoom.xos.binarycookies",
    "~/Library/Internet Plug-Ins/ZoomUsPlugIn.plugin",
    "~/Library/Logs/zoom.us",
    "~/Library/Logs/zoominstall.log",
    "~/Library/Logs/ZoomPhone",
    "~/Library/Preferences/us.zoom.airhost.plist",
    "~/Library/Preferences/us.zoom.caphost.plist",
    "~/Library/Preferences/us.zoom.Transcode.plist",
    "~/Library/Preferences/us.zoom.xos.Hotkey.plist",
    "~/Library/Preferences/us.zoom.xos.plist",
    "~/Library/Preferences/us.zoom.ZoomAutoUpdater.plist",
    "~/Library/Preferences/ZoomChat.plist",
    "~/Library/Safari/PerSiteZoomPreferences.plist",
    "~/Library/SafariTechnologyPreview/PerSiteZoomPreferences.plist",
    "~/Library/Saved Application State/us.zoom.xos.savedState",
    "~/Library/WebKit/us.zoom.xos",
  ]
end
