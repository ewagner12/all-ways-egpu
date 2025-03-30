# all-ways-egpu
Configures eGPU as primary under Linux Wayland desktops.

Note this script is not designed to replace existing solutions such as [gswitch](https://github.com/karli-sjoberg/gswitch) or [egpu-switcher](https://github.com/hertg/egpu-switcher). If you have an Xorg based desktop, these solutions are still the best option and should be preferred over this script.
For more info on why this script exists and how it works, see the [wiki](https://github.com/ewagner12/all-ways-egpu/wiki).

## Installation:
### Releases (Recommended):
Download and install the latest release using the following one line command:

```
cd ~; curl -qLs  https://github.com/ewagner12/all-ways-egpu/releases/latest/download/all-ways-egpu.zip  -o all-ways-egpu.zip; unzip all-ways-egpu.zip; cd all-ways-egpu-main; chmod +x install.sh; sudo ./install.sh install; cd ../; rm -rf all-ways-egpu.zip all-ways-egpu-main
```

If the above command fails due to a non-writable /usr then go to the next section below.
### SteamOS/Bazzite/User Installation:
This following installation method is specifically for those using Steam Deck/SteamOS 3.0 or any other distro (such as Bazzite/Fedora Silverblue) where the system files are read-only:

```
cd ~; curl -qLs  https://github.com/ewagner12/all-ways-egpu/releases/latest/download/all-ways-egpu.zip  -o all-ways-egpu.zip; unzip all-ways-egpu.zip; cd all-ways-egpu-main; chmod +x install.sh; sudo ./install.sh user-install; cd ../; rm -rf all-ways-egpu.zip all-ways-egpu-main
```
Note that running the command above adds ~/bin to your path in Bash. If using a different shell be sure to add ~/bin to your path in your shell.

### Git
Clone the repo to get the latest from github:
```
git clone https://github.com/ewagner12/all-ways-egpu.git
```

To install/uninstall navigate to the downloaded location and run the install.sh script:
```
cd all-ways-egpu; chmod +x install.sh; sudo ./install.sh install
```

## Uninstallation:
```
all-ways-egpu uninstall
```

## Usage:

As of version 0.30+ all functions can also be accessed through a menu system by simply clicking on the icon in your application menu or using the command `all-ways-egpu`. It is recommended to setup using option 1 and then switch to the eGPU using option 4 (Method 2). You may try out each of the methods to see which one works best for you.

If you want to skip the menu system, the following terminal commands can also be used. First setup the script based on your hardware, then follow one of the Methods below:
```
all-ways-egpu setup
```

### Method 1: Force iGPU off (Legacy/Alternate Method)
To enable forcing the chosen iGPU devices off (so that the display manager uses the eGPU)
```
all-ways-egpu configure egpu
```

To disable forcing the chosen iGPU devices off
```
all-ways-egpu configure internal
```

### Method 2: Switch boot_vga (Recommended Method)
This method simply switches the boot\_vga indicator flag that many Wayland compositors use in choosing the primary GPU. This is a less extreme method that may work better or have fewer side effects for some than Method 1. However, further testing is required to ensure it will work with any particular Wayland compositor. Currently, GNOME's mutter, Sway's wl\_roots and KDE Plasma's KWin seem to work with this method in my testing.
```
all-ways-egpu set-boot-vga egpu
```

additional info can be found using the help flag.

### Method 3: Set Compositor Variables (Desktop Specific)
This method sets the variables specifically used by the compositors: mutter (GNOME), KWin (KDE Plasma), gamescope-session (Bazzite-Deck and ChimeraOS), wlroots (Sway and others) and Hyprland. This hints to these desktops to use the eGPU as primary. This only works on those compositors specifically and may not always force applications to use the eGPU. Method 2 and Method 3 should be both used together for the best experience on the above desktops.
```
all-ways-egpu set-compositor-primary egpu
```

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

For Polkit version < 0.106:

Create file: */etc/polkit-1/localauthority/50-local.d/57-manage-egpu.pkla*

with the following contents: (replace group-name with your specific group as given by the command: `id -g -n $USER`)
```
[User permissions]
Identity=unix-group:group-name
Action=org.freedesktop.systemd1.manage-units
ResultActive=yes
```
## Entry point:

If custom commands need to be run before or after the all-ways-egpu script at boot, these can be added to `/usr/bin/all-ways-egpu-entry.sh` (Or `/home/$USER/bin/all-ways-egpu-entry.sh` if installed as a User Installation)

## Other Potential Issues:

- If the internal display is still off after logging in with eGPU attached, try switching to a different TTY with for example: CTRL-ALT-F1 and back.

- If the option "Attempt to re-enable these iGPU/initially disabled devices after boot" is chosen in the setup. The iGPU is activated after logging in. Thus, logging out will make the iGPU primary again until the computer is restarted.

- This script is still in the testing phase for a variety of desktops and distros. If you have issues be sure to include your specific desktop configuration.

- Note: the OpenRC calls currently assume the display manager is started with an init script called "display-manager". On some distros, xdm or a script with some other name is used. In these cases, I recommend linking that script with the following command: `ln -s /etc/init.d/xdm /etc/init.d/display-manager`. Also recommended to add the linked service to the default runlevel with the command: `rc-update add display-manager default`

- Applications that work on the console like Ubuntu's Plymouth (as invoked by the `splash` kernel parameter) may fail when using Method 1 due to the virtual console switching. It is currently recommended to disable this.

- If you have an nvidia card, you must choose "n" to the option "Attempt to re-enable these iGPU/initially disabled devices after boot". Otherwise, switching might result in a black screen. Once this option is disabled, switching should work normally.

- On Steam Deck/SteamOS the script requires root (sudo) privileges, but does not require setting the file system to read-write if installed in the Steam Deck/User Installation mode.

- Restarting the display manager when using GNOME Wayland with fractional scaling may lead to a laggy desktop. In this case a manual logout and login is recommended to avoid this.

- If using the SDDM login ensure the wayland backend is used.

- If seeing poor performance with an AMD GPU, see the performance fixes noted [here](https://github.com/ewagner12/all-ways-egpu/wiki/AMD-Performance-Fixes)

- PR's for any other issues welcome :)
