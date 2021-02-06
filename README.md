# The Ur-Quan Masters MegaMod for Switch
A fork of The Ur-Quan Masters MegaMod by Serosis that runs on the Nintendo Switch as a Homebrew.

## Changes from the MegaMod

* A `build.sh` wrapper that takes care of the switch building.
* A new "switch" autoloading addon that provides a few switch specific fixes.

## Motivation

Just like Serosis, I made this port out of my love for Star Control II and The Ur-Quan Masters project. Fiddling with the code as a hobby to try and expand my skill as a programmer.

## Building Yourself

### Linux

Make sure you've installed the [devkitPro](https://devkitpro.org/wiki/devkitPro_pacman) and the required packages for the switch development, and have DEVKITPRO in your environment

    
    export DEVKITPRO=/opt/devkitpro
    # pacman -S switch-dev switch-portlibs


Then, `cd` into the project folder and run the build script:

    
    $ ./build-switch.sh build

That will compile the game and put the binary and the nro in `bin/switch`

### Other Platforms

I'm not sure, but it should not be too different. DevkitPro installs the same and you will need to use MSYS2 on Windows.


## Installing

1. Copy the contents of the release zip file to your `sdmc:/switch/` folder
2. Run the game through the hbmenu

Game content like `mm-0.8.0.85-content.uqm` goes in the `content/packages` folder relative to the NRO.

All the extra addons like `mm-0.8.0.85-hd.uqm` and `uqm-0.7.0-3dovideo.uqm` go in `content/addons`.

You can download more addons on the [MegaMod site](http://megamod.serosis.net/Releases).

## Bugs

* The game occasionally crashes on start
* When using the HD content, most settings screens in the main menu become almost unusable because of lagging
  * Same thing happens occasionally during dialogue sequences
  * The rest of the game plays perfectly well, although the loadings are slightly longer. Seems like a threading issue

## Controllers

The game is configured to use **Joycon 1** and **Joycon 2** by default, so it should be playable out of the box. You can adjust the controls in the settings, in `content/*.key` and `config/flight.cfg`

### Default Controls

#### Menu / Game

| Control      | Keys                                   |
| ------------ |:--------------------------------------:|
| Up           | Joycon 1: DPAD Up, Left Stick Up       |
| Down         | Joycon 1: DPAD Down, Left Stick Down   |
| Left         | Joycon 1: DPAD Left, Left Stick Left   |
| Right        | Joycon 1: DPAD Right, Left Stick Right |
| Select       | Joycon 1: A, Y                         |
| Cancel       | Joycon 1: B, X                         |
| Special      | Joycon 1: Right Stick (RS)             |
| Toggle Map   | Joycon 1: ZL                           |
| Map Search   | Joycon 1: ZR                           |
| Map Zoom In  | Joycon 1: R                            |
| Map Zoom Out | Joycon 1: L                            |
| Pause        | Joycon 1: Plus                         |
| Exit Game    | Joycon 1: Minus                        |

#### Melee

| Control | Player 1                               | Player 2                               |
| ------- |:--------------------------------------:|:--------------------------------------:|
| Up      | Joycon 1: DPAD Up, Left Stick Up       | Joycon 2: DPAD Up, Left Stick Up       |
| Down    | Joycon 1: DPAD Down, Left Stick Down   | Joycon 2: DPAD Down, Left Stick Down   |
| Left    | Joycon 1: DPAD Left, Left Stick Left   | Joycon 2: DPAD Left, Left Stick Left   |
| Right   | Joycon 1: DPAD Right, Left Stick Right | Joycon 2: DPAD Right, Left Stick Right |
| Weapon  | Joycon 1: A, ZR                        | Joycon 2: A, ZR                        |
| Special | Joycon 1: X, ZL                        | Joycon 2: X, ZL                        |
| Escape  | Joycon 1: B, Plus                      | Joycon 2: B, Plus                      |
| Thrust  | Joycon 1: Y                            | Joycon 2: Y                            |

### Joycon Keymap

Here is the Joycon mapping for the config files:

| KEY      | ID   |
| -------- |:----:|
| A        | 0    |
| B        | 1    |
| X        | 2    |
| Y        | 3    |
| LSTICK   | 4    |
| RSTICK   | 5    |
| LBUMPER  | 6    |
| RBUMPER  | 7    |
| LTRIGGER | 8    |
| RTRIGGER | 9    |
| PLUS     | 10   |
| MINUS    | 11   |
| DPADL    | 12   |
| DPADU    | 13   |
| DPADR    | 14   |
| DPADD    | 15   |

## About MegaMod

A full list of changes and features can be found on the [Main site](http://megamod.serosis.net/Features).

## Contributors

Me (yokai.shogun), Serosis, SlightlyIntelligentMonkey, Volasaurus, Ala-lala, and Kruzenshtern

The main menu music for the MegaMod is brought to you by Saibuster A.K.A. Itamar.Levy: https://soundcloud.com/itamar-levy-1/star-control-hyperdrive-remix, Mark Vera A.K.A. Jouni Airaksinen: https://www.youtube.com/watch?v=rsSc7x-p4zw, and Rush AX: http://star-control.com/fan/music.php.

And the default Super Melee menu music is by Flashy of Infinitum.

## License

The code in this repository is under GNU General Public License, version 2 http://www.gnu.org/licenses/old-licenses/gpl-2.0.html

The content in this repository is under Creative Commons Attribution-NonCommercial-ShareAlike, version 2.5 https://creativecommons.org/licenses/by-nc-sa/2.5/
