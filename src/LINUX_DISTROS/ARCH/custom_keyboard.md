---

- usually when you wanna configure your custom keyboard via [usevia.app](https://usevia.app/)
  or [launcher.keychron.com](https://launcher.keychron.com/), you go to
  the website, click connect ..and nothing happens, or there is an error
- that's because your user do not have permission to undrlying `/dev/...` file
  which "represents" keyboard
- workaround:
```sh
# STEP1: firs you need to figure out which device is mapped to the keyboard

### method1:
# open
chrome://device-log
# "authorize" the keyboard in via/launcher
# you should see error like "Failed to open '/dev/hidraw2'"

### method2:
# execute
sudo journalctl -f
# unplung and plug the keyboard
# you should see something like "hiddev96,hidraw2: USB HID v1.11 Device"

# STEP2: temporary allow rw access to the device
sudo ls -la /dev/hidraw2
sudo chmod o+rw /dev/hidraw2
sudo ls -la /dev/hidraw2

# STEP3: configure keyboard

# STEP4: revert permission
sudo ls -la /dev/hidraw2
sudo chmod o-rw /dev/hidraw2
sudo ls -la /dev/hidraw2
```
