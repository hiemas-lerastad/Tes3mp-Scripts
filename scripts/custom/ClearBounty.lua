--[[
  ClearBounty

  A simple script that adds a command to clear your own bounty

  Installation
  1) Place this file as `ClearBounty.lua` inside your TES3MP servers `server\scripts\custom` folder.
  2) Open your `customScripts.lua` file in a text editor. 
      (It can be found in `server\scripts` folder.)
  3) Add the below line to your `customScripts.lua` file:
      require("custom/ClearBounty")
  4) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.
  5) Save `customScripts.lua` and restart your server.
]]--

ClearBounty = {}

ClearBounty.clearBounty = function(pid)
  logicHandler.RunConsoleCommandOnPlayer(pid, "SetPCCrimeLevel 0")
end

customCommandHooks.registerCommand("clearbounty", function(pid, cmd)
  ClearBounty.clearBounty(pid)
end)

return ClearBounty;