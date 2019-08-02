# Zoom Calendar Alfred Workflow

This Alfred workflow retrieves [Zoom](https://zoom.us/) meeting URLs from your calendar and opens them directly from Alfred. No clicking on your calendar, no redirect through the browser!

## Installation

* `git clone` this repository
* `brew install ical-buddy` for calendar data retrieval, using [homebrew](https://brew.sh/)
* `./install.sh` to symlink this into Alfred's workflow directory

Type `zz` in Alfred to trigger this workflow. It will prompt you to allow Alfred pemissions to your calendar the first time it runs since it runs `icalBuddy` as a child process.
