--[[
  TrueLadyBirthsign

  This edits the lady birthsign so the fortify endurance effects increases base indurance so the amount of HP gained on level is increased

  Installation
  1) Ensure that HiemUtils.lua has been installed
  2) Place this file as `TrueLadyBirthsign.lua` inside your TES3MP servers `server\scripts\custom` folder.
  3) Open your `customScripts.lua` file in a text editor. 
      (It can be found in `server\scripts` folder.)
  4) Add the below line to your `customScripts.lua` file:
      require("custom/TrueLadyBirthsign")
  5) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.
  6) Save `customScripts.lua` and restart your server.
]]--

local HiemUtils = require("custom/HiemUtils")

TrueLadyBirthsign = {}

function TrueLadyBirthsign.OnServerPostInit(eventStatus)
  if not WorldInstance.data.customVariables.TLB_Records_Initisalised then
    TrueLadyBirthsign.createRecord()
    WorldInstance.data.customVariables.TLB_Records_Initisalised = true
  end
end
customEventHooks.registerHandler("OnServerPostInit", TrueLadyBirthsign.OnServerPostInit)


function TrueLadyBirthsign.createRecord()
  local spellList = {
    {
      birthsign = true,
      refId = "lady's grace",
      name = "Lady's Grace",
      baseId = "lady's grace",
      subtype = 1,
      cost = 0,
      flags = 0,
      effects = {{
        id = 79,
        attribute = 5,
        skill = -1,
        rangeType = 0,
        duration = 1,
        magnitudeMin = 0,
        magnitudeMax = 0
      }}
    },
  }

  HiemUtils.addRecords("spell", spellList)
end

function TrueLadyBirthsign.OnPlayerEndCharGen(eventStatus, pid)
  local player = Players[pid]
  local birthsign = tes3mp.GetBirthsign(pid)

  if birthsign == "lady's favor" then
    local attributeId = tes3mp.GetAttributeId("Endurance")
    local attributeValue = tes3mp.GetAttributeBase(pid, attributeId)
    local newAttributeValue = attributeValue + 25

    if newAttributeValue > 100 then
      newAttributeValue = 100
    end

    Players[pid].data.attributes["Endurance"].base = newAttributeValue;

    tes3mp.SetAttributeBase(pid, attributeId, newAttributeValue)
    tes3mp.SendAttributes(pid)
  end
end
customEventHooks.registerHandler("OnPlayerEndCharGen", TrueLadyBirthsign.OnPlayerEndCharGen)