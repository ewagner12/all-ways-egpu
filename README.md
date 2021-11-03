# all-ways-egpu
Configures eGPU as primary under Linux Wayland desktops.

Note this script is not designed to replace existing solutions such as [gswitch](https://github.com/karli-sjoberg/gswitch) or [egpu-switcher](https://github.com/hertg/egpu-switcher). If you have an Xorg based desktop, these solutions are still the best option and should be preferred over this script.

## Installation:
### Releases (Recommended):
Download and install the latest release using the following one line command:

```
cd ~; curl -qLs  https://github.com/ewagner12/all-ways-egpu/releases/latest/download/all-ways-egpu.zip  -o all-ways-egpu.zip; unzip all-ways-egpu.zip; cd all-ways-egpu-main; sudo make install; cd ../; rm -rf all-ways-egpu.zip all-ways-egpu-main
```

### Git
Clone the repo to get the latest from github:
```
git clone https://github.com/ewagner12/all-ways-egpu.git
```

To install/uninstall navigate to the downloaded location:
```
cd all-ways-egpu
```

Install:
```
make install
```

## Uninstallation:
```
all-ways-egpu uninstall
```

## Usage:

To setup the script based on your hardware:
```
all-ways-egpu setup
```

### Method 1: Force iGPU off
To enable forcing the chosen iGPU devices off (so that the display manager uses the eGPU)
```
all-ways-egpu configure egpu
```

To disable forcing the chosen iGPU devices off
```
all-ways-egpu configure internal
```

### Method 2: Switch boot_vga
This method simply switches the boot\_vga indicator flag that many Wayland compositors use in choosing the primary GPU. This is a less extreme method that may work better or have fewer side effects for some than Method 1. However, further testing is required to ensure it will work with any particular Wayland compositor. Currently, GNOME's mutter, Sway's wl\_roots and KDE Plasma's KWin seem to work with this method in my testing.
```
all-ways-egpu set-boot-vga egpu
```

additional info can be found using the help flag.

As of version 0.30 all functions can also be accessed through a menu system by simply using `all-ways-egpu`.

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

- Applications that work on the console like Ubuntu's Plymouth (as invoked by the `splash` kernel parameter) may fail due to the virtual console switching. It is currently recommended to disable this.

- I have also only tested with AMD eGPU + Intel iGPU so far. Nvidia testing is still to be done. Specifically, proprietery Nvidia drivers may not work yet.

- PR's for any other issues welcome :)
