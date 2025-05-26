# Get-time-from-NTP-Server

## The idea

There are requirements where the exact time is needed from an NTP server. Unfortunately I have not found a webservice for this and have decided to write an RPG program to get the time from an NTP service.

## How does it work

Normally I would have assumed to get the data via a GET or POST request but unfortunately this does not work for NTP servers because they only communicate via sockets. At this point I would like to thank <strong>Scott Klement</strong> [Sourcecode]https://www.scottklement.com/rpg/socktut/tutorial.html), whose socket tutorial has served me very well.
