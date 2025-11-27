# Scripts

## CareFreeLevelling

  A script that makes level up bonuses always +5

  Installation
  1) Place this file as `CareFreeLevelling.lua` inside your TES3MP servers `server\scripts\custom` folder.
  2) Open your `customScripts.lua` file in a text editor. 
      (It can be found in `server\scripts` folder.)
  3) Add the below line to your `customScripts.lua` file:
      require("custom/CareFreeLevelling")
  4) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.
  5) Save `customScripts.lua` and restart your server.


## ClearBounty

  A simple script that adds a command to clear your own bounty

  Installation
  1) Place this file as `ClearBounty.lua` inside your TES3MP servers `server\scripts\custom` folder.
  2) Open your `customScripts.lua` file in a text editor. 
      (It can be found in `server\scripts` folder.)
  3) Add the below line to your `customScripts.lua` file:
      require("custom/ClearBounty")
  4) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.
  5) Save `customScripts.lua` and restart your server.


## HiemUtils

  This contains many utility functions compiled for shared use within different scripts

  Installation
  1) Place this file as `HiemUtils.lua` inside your TES3MP servers `server\scripts\custom` folder.
  2) Place the `HiemDataList.json` file inside your TES3MP servers `server\data\custom` folder.
  3) Open your `customScripts.lua` file in a text editor. 
      (It can be found in `server\scripts` folder.)
  4) Add the below line to your `customScripts.lua` file (make sure it is higher up than any scripts that require this one):
      require("custom/HiemUtils")
  5) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.
  6) Save `customScripts.lua` and restart your server.


## CombinedPropylonIndex

  This scripts works as a replacement for the Master Propylon Index plugin so users do not have to download and enable the plugin
  A blueprint can be found in caldera mages guild, when used this item prompts a crafting menu in order to craft the combined index
  The default recipe requires all vanilla indexes (they are not consumed), a moderate sized soul in a soul gem (a value of 50 or higher), a piece of raw ebony and an enchant skill of 50 or higher

  The newly crafted index can be used in place of all of the individual indexes
  It can also be used (dragged onto character portrait) in order to teleport to the nearest propylon chamber (this feature can be disabled in the CombinedPropylonIndex.settings section)

  Installation
  1) Ensure that HiemUtils.lua has been installed
  2) Place this file as `CombinedPropylonIndex.lua` inside your TES3MP servers `server\scripts\custom` folder.
  3) Open your `customScripts.lua` file in a text editor. 
      (It can be found in `server\scripts` folder.)
  4) Add the below line to your `customScripts.lua` file:
      require("custom/CombinedPropylonIndex")
  5) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.
  6) Save `customScripts.lua` and restart your server.


## WayOfTheNords

  WIP - This adds a new building and merchant in solsteim that sells two unique items
  The first item is a "Spirit Stone"
  This works as a soul bank, and any soul trapped enemies souls will be added a a value associated with a player
  These can be extracted to "spirit pearls" that can be used as soul gems, with values of 100, 500 or 1000 by default

  The second item is an "Atmoran Chisel"
  this can be used to train enchant and armorer using ebony ore,
    upgrade the enchant capacity or armour and clothing
    and create a "spirit pearl ring" which has a fortify enchant constant effect equal to yout spirit stone value

  Installation
  1) Ensure that HiemUtils.lua has been installed
  2) Place this file as `WayOfTheNords.lua` inside your TES3MP servers `server\scripts\custom` folder.
  3) Open your `customScripts.lua` file in a text editor. 
      (It can be found in `server\scripts` folder.)
  4) Add the below line to your `customScripts.lua` file:
      require("custom/WayOfTheNords")
  5) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.

  6) Save `customScripts.lua` and restart your server.


## FurnishedBlodskallsHouse

  This script adds high capacity containers to the blodskaals house in skaal village

  Installation
  1) Ensure that HiemUtils.lua has been installed
  2) Place this file as `FurnishedBlodskallsHouse.lua` inside your TES3MP servers `server\scripts\custom` folder.
  3) Open your `customScripts.lua` file in a text editor. 
      (It can be found in `server\scripts` folder.)
  4) Add the below line to your `customScripts.lua` file:
      require("custom/FurnishedBlodskallsHouse")
  5) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.
  6) Save `customScripts.lua` and restart your server.