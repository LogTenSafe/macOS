---
title: Automatic backups
description: Automatically back up your logbook when it’s changed.
keywords: automatic backups, automatically back up, auto backup
order: 3
---

LogTenSafe can automatically back up your logbook when it changes. Because of
macOS security restrictions, there are some important caveats to using this
feature:

- You must have created at least one manual backup, as described in
  [**Backing up your logbook**](backing-up.html).
- You must leave the LogTenSafe application running in the background in order
  for automatic backups to proceed. It’s ok to close the window, but you cannot
  quit the application, or the automatic backups will stop.

To turn on automatic backups, tick the **Check for logbook changes and
automatically back up** checkbox.

![Main application window](main-window.png)

Assuming the application stays running, your logbook will be checked three times
per day. If LogTenSafe detects that your logbook has been changed, it will
upload the new backup to LogTenSafe.com.

You can stop automatic backups by unticking the checkbox.
