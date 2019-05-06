# MousePort Mac Client

MousePort Client for macOS

## Getting Started

```
cd ~/Downloads && curl -LO "https://github.com/iPAWiND/MousePort/releases/download/mac-client/latest.zip" && unzip latest.zip && rm latest.zip
```

CodeSign app with sandbox entitlements

```
cd ~/Downlaods && codesign -fs - --entitlements entitlements.plist MousePort.app
```

Upon first launch, you may need to allow it via GateKeeper (System Preferences-General)

### Note

The app uses full screen mode, to quit, you can use (command+q)

## Privacy Notice

The client app is signed with sandbox entitlements, and is only allowed to act as a network client and server.

All connections are made between your computer and iOS device on local network.

## Credits

[CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket)
