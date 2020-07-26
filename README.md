# Kali-Raspberry-Pi
---
## kali-rpi-wifi-mgmt
A simple script to connect to the internet or reset the default gateway on a Raspberry Pi running Kali Linux with dual wireless adapters, with one hosting an access point.

```
~~~~~~~~~~~~~~~~~~~~~
 M A I N - M E N U
~~~~~~~~~~~~~~~~~~~~~
1. Connect to Internet
2. Reset Default Gateway
3. Test Internet
4. Exit

Enter choice [ 1 - 3]
```
1. **Connect to Internet**
    1. Prompts for wlan interface name and wpa_supplicant file location
    2. Removes specified wlan interface's run file
    3. Kills wpa_supplicant if it's already running
    4. Connects to the Internet
2. **Reset Default Gateway**
    1. Checks if default route exists
    2. If not, it will prompt for default gateway IP and wlan interface name
    3. Then creates the default route

    \* I added this feature because, for some reason, the default route entry would disappear. I'm not sure if it's because the wireless gets confused because it's hosting an AP while connected to another one or it's a bug in the OS.
2. **Test Internet**
    1. Tests internet connectivity against www.google.com