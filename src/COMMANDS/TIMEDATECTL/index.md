#

- `timedatectl` output explained
```sh
Local time: Wed 2026-02-04 21:47:52 UTC      --> system clock, currently configured, timezone applied
Universal time: Wed 2026-02-04 21:47:52 UTC  --> system clock, in UTC
RTC time: Wed 2026-02-04 21:47:50            --> hardware clock (real-time clock)
Time zone: UTC (UTC, +0000)                  --> configured timezone
System clock synchronized: no                --> tells if system clock got configured by NTP service
NTP service: inactive                        --> NTP service is running?
RTC in local TZ: no                          --> this tells if RTC in in UTC or TZ,
                                                 we want it in UTC, value should be `no`
```

- usage
```sh
timedatectl set-timezone UTC               # set timezone
timedatectl set-time "YYYY-MM-DD HH:MM:SS" # set date and time

timedatectl set-local-rtc 0  # this sets RTC to be in UTC - usually this is the default
```

- step by step - set/fix date and time settings
```sh
timedatectl                                # init check
timedatectl set-ntp false                  # disable ntp
timedatectl set-time "YYYY-MM-DD HH:MM:SS" # set UTC date and time
date -u                                    # sanity check
timedatectl                                # sanity check
hwclock --systohc                          # sync system time to hw clock
hwclock --verbose                          # check HW clock aka RTC
timedatectl set-ntp true                   # enable ntp, note this requires ntp to be running
                                           # either systemd-timesyncd or chrony
timedatectl timesync-status                # check NTP sync
timedatectl                                # final check
```
