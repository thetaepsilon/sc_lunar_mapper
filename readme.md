# sc\_lunar\_mapper: A userspace steam controller mouse/keyboard emulation program

## Say again?
sc\_lunar\_mapper is a lua program that reads the raw input events
sent by the [Steam controller](https://store.steampowered.com/app/353370/Steam_Controller/)
using the linux evdev API, and translates them to
keyboard and mouse pointer events using the linux uinput API.
This effectively allows you to control keyboard and mouse apps with the SC.



## But why
I don't intend to be bound to steam all the time -
I wanted the SC to be able to play casual 1st-person 3D games with a controller.
However all of the other solutions I have come across
have been a bit intermittent with their feature support,
and have also had the fatal problem that the udev rules they ship with
_cause the controller to lock up_.

For instance, [sc-controller](https://github.com/kozec/sc-controller)
ships with [a udev rule](https://github.com/kozec/sc-controller/blob/master/scripts/69-sc-controller.rules)
that is intended to set permissions on the USB device interfaces
that the SC presents when it is plugged in.
Questionable permissions aside, even if all lines are uncommented bar this one:
> SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"

the controller will fail to work - an inspection of dmesg revealed
that even the *kernel* thinks the device disconnected.

Is this a kernel bug? something managing to get run on my system?
udev being daft? (*insert systemd rant here*)
I didn't have time to find out as I had payed money for this hardware,
so I just wrote this instead.



## Dependencies
You will need lua 5.3 and the package
[lua-evdev](http://github.com/Tangent128/lua-evdev)
somewhere in your LUA_PATH.
Evidently due to the use of linux-specific interfaces,
you will require a working linux system with a kernel shipping with
the module `hid_steam` (available in kernels 4.18 and up).

If installed [via it's luarock](https://luarocks.org/modules/tangent128/evdev),
you will need to refer to your distro's instructions (if any)
on how to ensure the relevant environment variables are set,
otherwise something like `eval $(luarocks path)` in your shell should work.



## Running and usage
The default entry point main.lua is really just a thin wrapper to load a "handler script",
then glue it to the specified event node.
Running it looks something like this:
$ ./main.lua example_scripts/sc.lua /dev/input/eventX

Note that for the steam controller that event node should be the controller one,
and not the (rather poorly imo) emulated keyboard/mouse event nodes created for the controller's "lizard mode".

This script must return a function that is passed a loader object;
this loader object can be called with the names of the various lua components here to load them.
This function in turn must return an object with a single function (not method)
process\_event(), which is called for each event read from the input node.
See main.lua and the above mentioned example script (sc.lua) for details.

To actually translate events into something else like a keyboard/mouse input,
the uinput module should be used.
This is a pretty thin wrapper around the evdev library's Uinput module;
see UInputFactory.lua and the evdev.Uinput documentation for details,
and UInputFakeKeyboard.lua for what typical setup looks like.
The latter takes care of things like declaring used keys,
so usage of this is encoured where possible :).



## Why isn't X11 picking it up?
`TODO: haven't included the xorg.conf file for this yet.`

Generally speaking you want to assign the evdev nodes created by sc\_lunar\_mapper
(which appear when it acquires uinput nodes)
to X11's "evdev" input driver.
libinput doesn't appear to know what to do with it and proceeds to ignore it.

Currently there doesn't appear to be a facility that can be used
to provide hints to X11 about the simulated devices being a keyboard or mouse;
if you can get an InputClass to match it with evdev, they will work,
but creating one that matches is the harder part.
The solution used currently is to ensure a well-known "uinput" string
is present in the description string passed to the created uinput handle;
This can be matched in an InputClass using e.g. `MatchProduct "uinput"`.



## Contribution/TODO?
Probably on improving the user experience at the very least,
currently it's a bit manual.
Being able to choose keymaps more conveniently would be great,
however it would be best to leave that to other tools
that could in turn launch sc\_lunar\_mapper.

Code is public domain so any code contributed
would have to be accompanied by a copyright waiver.
I have better things to do with my controller than worry about licensing!



## Things this won't do
### Enabling/disabling the gyro, accelerometer etc.
After boot, the steam controller does not send the gyro
and other such sensor data by default.
It seems it requires explicit enablement -
[steamctrl](https://github.com/rodrigorc/steamctrl)
is a good place to look, as well as `drivers/hid/hid-steam.c`
in the linux kernel source for the relevant bitmask constants.

This in theory could be done in lua too
(if there exists a lua library to talk to `/dev/hidraw*`)
but is really outside the scope of this program.
That said, in theory sc\_lunar\_mapper could handle the events
when they are enabled, but will not have functionality to do so itself.
This is because, depending on the mapping config,
it may not be desirable to automatically turn it on and running all the time,
as users may at times inadvertently trigger it even while "resting" with it.
