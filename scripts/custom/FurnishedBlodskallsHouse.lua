--[[
  FurnishedBlodskallsHouse

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
]]--

local HiemUtils = require("custom/HiemUtils")

FurnishedBlodskallsHouse = {}

function FurnishedBlodskallsHouse.OnServerPostInit(eventStatus)
  if not WorldInstance.data.customVariables.FBSKH_Records_Initisalised then
    FurnishedBlodskallsHouse.createRecord()
    WorldInstance.data.customVariables.FBSKH_Records_Initisalised = true
  end
end
customEventHooks.registerHandler("OnServerPostInit", FurnishedBlodskallsHouse.OnServerPostInit)

function FurnishedBlodskallsHouse.createRecord()
  local containerList = {
    {
      refId = "fbskh_closet",
      baseId = "com_closet_01",
      encumbrance = 10000.0,
    },
    {
      refId = "fbskh_chest",
      baseId = "com_chest_11_empty",
      encumbrance = 10000.0,
    },
    {
      refId = "fbskh_small_chest",
      baseId = "chest_small_01_empty",
      encumbrance = 10000.0,
    },
    {
      refId = "fbskh_barrel",
      baseId = "barrel_01",
      encumbrance = 10000.0,
    },
  }
  HiemUtils.addRecords("container", containerList)

  local objectList = {
    {
      id = "Skaal Village, The Blodskaal's House",
      references = {
        {
          id = "fbskh_closet",
          translation = {
            -280.00,
            30.00,
            90.00
          },
          rotation = {
            0.0,
            0.0,
            11.0
          },
          scale = 1.0
        },
        {
          id = "fbskh_chest",
          translation = {
            10.00,
            -150.00,
            21.00
          },
          rotation = {
            0.0,
            0.0,
            0.0
          },
          scale = 1.0
        },
        {
          id = "fbskh_small_chest",
          translation = {
            -320.00,
            185.00,
            196.00
          },
          rotation = {
            0.0,
            0.0,
            11.0
          },
          scale = 1.0
        },
        {
          id = "fbskh_barrel",
          translation = {
            320.00,
            230.00,
            40.00
          },
          rotation = {
            0.0,
            0.0,
            0.0
          },
          scale = 1.0
        },
      }
    },
  }
  for i=1, #objectList do
    local item = objectList[i]
    HiemUtils.populateCell(item)
  end
end
