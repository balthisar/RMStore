# RMStoreTests

Tests have been provided for both MacOS and iOS targets. Note that these are the same
tests, but separate targets have been provided to ensure that tests pass on various
platforms.

## RMStoreTests target

This target uses the `RMStoreTestsHost` iOS application in order to work with the
keychain. Without a host application, the XCTest framework has no way to operate with
the keychain. This includes Catalyst.

Unfortunately, as of Xcode 11.2.1,Catalyst applications do not work as host applications
for XCTests, so there's no real way to perform testing on Catalyst.

## RMStoreTestsMacOS

Luckily the same code can be tested natively on macOS without Catalyst, and so this
target does that.

Note that when compiling for this test, the OCMock static library is for Catalyst. The
compiler will warn about this, but it's fine; all the same symbols are present. I just don't
want to inflate the repository with more binaries than are necessary.

## RMStoreTestsHost

This target is literally just a blank, default iOS/Catalyst target that serves as a host for
the XCTests under iOS, and hopefully someday, for Catalyst.

