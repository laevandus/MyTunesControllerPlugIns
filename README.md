# MyTunesController PlugIns

PlugIns used by MyTunesController for fetching lyrics.

## Writing new plug-ins

* Use Xcode bundle template
* Add LyricsFetcher.h file and implement a NSObject subclass which conforms to that.

Best start would be to check examples I have included.

After bulding a plug-in, copy it here:
~/Library/Application Support/MyTunesController/PlugIns

