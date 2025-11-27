--[[
  CareFreeLevelling

  A script that makes level up bonuses always +5

  Installation
  1) Place this file as `CareFreeLevelling.lua` inside your TES3MP servers `server\scripts\custom` folder.
  2) Open your `customScripts.lua` file in a text editor. 
      (It can be found in `server\scripts` folder.)
  3) Add the below line to your `customScripts.lua` file:
      require("custom/CareFreeLevelling")
  4) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.
  5) Save `customScripts.lua` and restart your server.
]]--

CareFreeLevelling = {}

function CareFreeLevelling.OnPlayerAttributeTest(eventStatus, pid)
  local playerRef = Players[pid];
  local attributes = playerRef.data.attributes;
  local attrbutesObject = {}

  for k, v in pairs(attributes) do
    attrbutesObject[k] = v.base;
    local id = tes3mp.GetAttributeId(k)
    Players[pid].data.attributes[k].skillIncrease = 10;
    tes3mp.SetSkillIncrease(pid, id, 10);
    tes3mp.SendAttributes(pid);
  end

  local attributeArgs = {pid, Players[pid].data.attributes}
  local eventStatus = customEventHooks.triggerValidators('OnPlayerAttribute', attributeArgs)
  customEventHooks.triggerHandlers('OnPlayerAttribute', eventStatus, attributeArgs)
end
customEventHooks.registerHandler("OnPlayerSkill", CareFreeLevelling.OnPlayerAttributeTest)
customEventHooks.registerHandler("OnPlayerLevel", CareFreeLevelling.OnPlayerAttributeTest)

return CareFreeLevelling;