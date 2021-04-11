iOS Hand Shadows
=====

This code allows you to quickly and easily integrate hand shadows that follow your app's gestures in real time, allowing you to record more descriptive and intuitive demo videos.

## What is this?

This code lets you add hand shadows over your UI during your gestures, which makes
for immersive tutorial and demo videos.

Example: https://vine.co/v/OI2zM3bEIJx

![Example image](https://github.com/adamwulf/ios-hand-shadows/raw/master/example.gif)


## Documentation

Add a MMShadowHandView above all of your other views, and then call its methods
with arrays of CGPoints wrapped in NSValues. Run the code for a demo of the shadows.

## Building the Code

    git clone git@github.com:adamwulf/ios-hand-shadows.git
    cd ios-hand-shadows
    git submodule init
    git submodule update


Open iOSHandShadows.xcworkspace in Xcode

The submodule depends on [IOS-Universal-Framework](https://github.com/kstenerud/iOS-Universal-Framework)
and is built with the Real Framework option.

## Including in your project

1. Link against the built framework.
2. Add "-ObjC++ -lstdc++" to the Other Linker Flags in the project's Settings
3. #import &lt;PerformanceBezier/PerformanceBezier.h&gt;

## License

<a rel="license" href="http://creativecommons.org/licenses/by/3.0/us/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/3.0/us/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/3.0/us/">Creative Commons Attribution 3.0 United States License</a>.

For attribution, please include:

1. Mention original author "Adam Wulf for Loose Leaf app"
2. Link to https://getlooseleaf.com/opensource/
3. Link to https://github.com/adamwulf/PerformanceBezier



## Support this framework

This code is created by Adam Wulf ([@adamwulf](https://twitter.com/adamwulf)) as a part of the [Loose Leaf app](https://getlooseleaf.com).

Become a [Github Sponsor](https://github.com/sponsors/adamwulf) and buy me a coffee ☕️ 😄
