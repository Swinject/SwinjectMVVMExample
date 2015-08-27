# SwinjectMVVMExample

This is an example project to demonstrate [dependency injection](https://en.wikipedia.org/wiki/Dependency_injection) and [Swinject](https://github.com/Swinject/Swinject) in [MVVM (Model-View-ViewModel)](https://en.wikipedia.org/wiki/Model_View_ViewModel) architecture with [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa). The app asynchronously searches, downloads and displays images obtained from [Pixabay](https://pixabay.com) via [its API](https://pixabay.com/api/docs/).

![Screen Record](Assets/ScreenRecord.gif)

## Requirements

- Xcode 7 beta 6
- [Carthage](https://github.com/Carthage/Carthage) 0.7.5 or later
- [Pixabay](https://pixabay.com/api/docs/) API username and key

## Setup

1. Download the source code or clone the repository.
2. Run `carthage bootstrap --no-build`.
2. Run `carthage build`.
3. Get a free API username and key from [Pixabay](https://pixabay.com/). They are displayed in [the API documentation page](https://pixabay.com/api/docs/) after you log in there.
4. Create a text file named `Pixabay.Config.swift` with the following content in `ExampleModel` folder in the project. The strings `"YOUR_USERNAME"` and `"YOUR_API_KEY"` should be replaced with your own username and key.

**Pixabay.Config.swift**

    extension Pixabay {
        internal struct Config {
            internal static let apiUsername = "YOUR_USERNAME"
            internal static let apiKey = "YOUR_API_KEY"
        }
    }

## Blog Posts

Blog posts to demonstrate step-by-step development of the project will be submitted to the following website soon.

[https://yoichitgy.github.io](https://yoichitgy.github.io)

## Icon Images

Icon images used in the app are licensed under [Creative Commons Attribution-NoDerivs 3.0 Unported](https://creativecommons.org/licenses/by-nd/3.0/) by [Icons8](https://icons8.com).

- [Visible Icon](http://ic8.link/986)
- [Download From Cloud](http://ic8.link/4717)
- [Thumb Up](http://ic8.link/2744)

## License

MIT license. See the [LICENSE file](LICENSE.txt) for details.
