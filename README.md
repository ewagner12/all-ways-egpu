# all-ways-egpu
Configures eGPU as primary under Linux Wayland desktops.

Note this script is not designed to replace existing solutions such as [gswitch](https://github.com/karli-sjoberg/gswitch) or [egpu-switcher](https://github.com/hertg/egpu-switcher). If you have an Xorg based desktop, these solutions are still the best option and should be preferred over this script.

## Installation/Uninstallation:

Clone the repo:
```
git clone https://github.com/ewagner12/all-ways-egpu.git
```

To install/uninstall navigate to the downloaded location:
```
cd all-ways-egpu
```

Install:
```
sudo make install
```

Uninstall:
```
sudo make uninstall
```

## Usage:

To setup the script based on your hardware:
```
sudo all-ways-egpu setup
```

To enable forcing the chosen iGPU devices off (so that the display manager uses the eGPU)
```
sudo all-ways-egpu configure egpu
```

To disable forcing the chosen iGPU devices off
```
sudo all-ways-egpu configure internal
```

additional info can be found using the help flag.

## Extra Steps:

If the option "Attempt to re-enable these iGPU/initially disabled devices after boot" is chosen in the setup, after logging in, the script will prompt for your password each time to attempt to re-enable the iGPU (if not already done).

Given Polkit version >= 0.106 (check with `pkaction --version`) the password prompt can be bypassed by adding the following:

Create file: */etc/polkit-1/rules.d/57-manage-egpu.rules*

with following contents: (replace user-name with your specific login username as given by the command: `whoami`)
```
// Allow user-name to manage all-ways-egpu-user.service;
// fall back to implicit authorization otherwise.
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.systemd1.manage-units" &&
        action.lookup("unit") == "all-ways-egpu-user.service" &&
        subject.user == "user-name") {
        return polkit.Result.YES;
    }
});
```

For Polkit verison < 0.106:

Create file: */etc/polkit-1/localauthority/50-local.d/57-manage-egpu.pkla*

with the following contents: (replace group-name with your specific group as given by the command: `id -g -n $USER`)
```
[User permissions]
Identity=unix-group:group-name
Action=org.freedesktop.systemd1.manage-units
ResultActive=yes
```


## Other Potential Issues:

- If the internal display is still off after logging in with eGPU attached, try switching to a different TTY with for example: CTRL-ALT-F1 and back.

- If the option "Attempt to re-enable these iGPU/initially disabled devices after boot" is chosen in the setup. The iGPU is activated after logging in. Thus, logging out will make the iGPU primary again until the computer is restarted.

- This script is still in the testing phase for a variety of desktops and distros. If you have issues be sure to include your specific desktop configuration.

- Applications that work on the console like Ubuntu's Plymouth may fail due to the virtual console switching. It is currently recommended to disable this.

- I have also only tested with AMD eGPU + Intel iGPU so far. Nvidia testing is still to be done. Specifically, proprietery Nvidia drivers are not expected to work yet.

- PR's for any other issues welcome :)
