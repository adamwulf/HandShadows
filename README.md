Hand Shadows
=====

This code allows you to quickly and easily integrate hand shadows that follow your app's gestures in real time, allowing you to record more
descriptive and intuitive demo videos.

## What is this?

This code lets you add hand shadows over your UI during your gestures, which makes
for immersive tutorial and demo videos.

<img src="https://github.com/adamwulf/HandShadows/raw/main/example.gif" width="600" />

## Swift Package Manager

Add the following to your Package.swift file:

```
dependencies: [
    .package(url: "git@github.com:adamwulf/HandShadows.git", branch: "main")
]
```

## Using

Add a HandShadowView above all of your other views, and then call its methods
with CGPoints of gesture touch locations. Run the code for a demo of the shadows.

## Demo

A demo is available at https://github.com/adamwulf/ios-hand-shadows

## License

HandShadows is available under the MIT license. See the [LICENSE](./LICENSE.md) file for more information.

## Support this framework

This code is created by Adam Wulf ([@adamwulf](https://twitter.com/adamwulf)) as a part of the [Loose Leaf](https://getlooseleaf.com) app.

Become a [Github Sponsor](https://github.com/sponsors/adamwulf) and buy me a coffee ☕️ 😄
