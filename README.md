LogTenSafe Documentation {#mainpage}
========================

This is the Mac OS X client library for [LogTenSafe](http://logtensafe.com).
This client library allows the user to upload new logbooks for backup, or
download older backups of existing logbooks and place them in the correct
location. It also has the ability to create a launch daemon entry to
automatically upload changed logbooks.

This code is released under the MIT license. See the LICENSE.txt file for more
information.

Documentation is available using Doxygen. Run `doxygen` in the project directory
to generate HTML document to the `Documentation/html` directory.

Architecture
------------

### Application

The main window is controlled by the
@link LTSBackupListWindowController @endlink, which is spawned by the
@link LTSAppDelegate @endlink. The main window spawns new window controllers for
each of the sheets it displays.

Uploading and downloading is handled by singleton managers, in particular, the
@link LTSBackupsManager @endlink, which maintains a network-backed list of the
user's backups, and uploads new backups. It is powered by the
@link LTSNetworkManager @endlink, which makes authenticated network operations.

The network manager requires a Constants.plist file to be in the bundle
containing the URLs to use for connecting to LogTenSafe.

### Launch daemon

The launch daemon uses the @link LTSNetworkManager @endlink for its network
operations. To facilitate testing the launch daemon (running it outside the
application's bundle, where the Constants.plist file would not be availble), the
path to a Constants.plist file can be given as a command line argument. (The
debug run configuration is already set up like this.)

The launch daemon runs all network requests synchronously to avoid early
termination.

Authentication
--------------

Authentication credentials are stored in the user defaults. If the credentials
are not available or incorrect, the network manager returns an error, and the
window controller responds by prompting the user for credentials, then retrying
the operation.

The launch daemon does not use the standard user defaults, but creates a custom
user defaults suite so it can access the application's user defaults, and thus
the credentials.
