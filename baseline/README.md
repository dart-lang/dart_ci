A CLI application that copies test results from one builder to another.

Example:
```
# Initialize debug-mac builder with results from debug-linux on main and dev:
$ bin/baseline.dart -n -debug-linux:debug-mac -cmain,dev -mtest-linux:test-mac
```
