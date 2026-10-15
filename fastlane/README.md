fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Run Tests

### ios release

```sh
[bundle exec] fastlane ios release
```

Build and deploy app release to TestFlight

### ios strip_local_network_plist_keys

```sh
[bundle exec] fastlane ios strip_local_network_plist_keys
```

Remove the Info.plist keys that only development builds need to reach a BFF on the local network

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
