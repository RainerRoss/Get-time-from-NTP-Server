# Get-time-from-NTP-Server

## The idea

There are requirements where the exact time is needed from an NTP server. Unfortunately I have not found a webservice for this and have decided to write a RPG program to get the time from an NTP service.

## How does it work

Normally I would have assumed to get the data via a GET or POST request but unfortunately this does not work for NTP servers because they only communicate via sockets. At this point I would like to thank <strong>Scott Klement</strong> (https://www.scottklement.com/rpg/socktut/tutorial.html), whose socket tutorial has served me very well.

## Manual install

```
- download HTPLOG00.SQL
- download GETNTPTIME.SQLRPGLE

- create   table NTPLOG00 
- create   program GETNTPTIME 

- call     program GETNTPTIME
```

## Logfile result

![Screenshot 2025-05-26 232035](https://github.com/user-attachments/assets/497df5bc-848a-4136-a8a4-b7d65d01e419)
