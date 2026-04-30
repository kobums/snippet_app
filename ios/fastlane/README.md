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

### ios beta

```sh
[bundle exec] fastlane ios beta
```

TestFlight에 빌드 업로드

### ios release

```sh
[bundle exec] fastlane ios release
```

patch 버전 bump 후 App Store 업로드

### ios ship

```sh
[bundle exec] fastlane ios ship
```

버전 bump 후 TestFlight 배포

### ios promo

```sh
[bundle exec] fastlane ios promo
```

프로모션 텍스트 업데이트

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
