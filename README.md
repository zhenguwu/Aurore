# Aurore
Custom Alarm Tweak

Some more info here: https://www.reddit.com/r/jailbreak/comments/hc1nui/upcoming_aurore_wake_up_to_your_favorite_music/
https://www.reddit.com/r/jailbreak/comments/hnnahk/paid_release_aurore_wake_up_to_music_and_much/

NOT UPDATED. Only tested on iOS 13 and Spotify 8.5.75

The code is very very complex to get the parts working together but if anyone wants to try updating it for newer iOS versions, here is a quick rundown of what is definitely broken.
- Tweak.xm (Line 944) Make sure SPTLinkDispatcherImplementation still handles Spotify urls
- Tweak.xm (Line 972) VISREFBaseHeaderController probably doesn't exist anymore. Spotify likes to change around the name of their objects. Find the new controller that has shuffle and play methods for a playlist
- Tweak.xm (Line 1011) SPTFreeTierAlbumViewController is like the one above but is the controller for albums. Again, it's probably renamed. IDK why albums and playlists had completely different controllers when I wrote this tweak
- Tweak.xm (Line 1140) MusicPlayControls is like VISREFBaseHeaderController but for Apple Music. I don't think Apple Music has changed much about the shuffle and play buttons so this might still be fine
- Tweak.xm (Line 1463) MTASleepDetailViewController is the controller for the sleep alarm in iOS 13. iOS 14 completely redesigned sleep alarm so it's very broken. Easy solution is to delete all of it and only have Aurore work on regular alarms as that seems the same in iOS 14+
- Tweak.xm (Line 737-742) The weather and greeting view isn't a thing anymore (?)
- tools/auroreAlarmManager (Line 106) Remove Hikari and remove pirate check at 175-182
- Makefile Remove Target_CC and Target_CCX (it's a custom toolchain I used to compile with obfuscation)
