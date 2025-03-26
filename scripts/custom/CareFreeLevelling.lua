CareFreeLevelling = {}

function CareFreeLevelling.OnPlayerAttributeTest(eventStatus, pid)
  local playerRef = Players[pid];
  local attributes = playerRef.data.attributes;
  local attrbutesObject = {}

  for k, v in pairs(attributes) do
    attrbutesObject[k] = v.base;
    local id = tes3mp.GetAttributeId(k)
    tes3mp.SetSkillIncrease(pid, id, 10);
    tes3mp.SendAttributes(pid);
  end

  tes3mp.LogMessage(2, tes3mp.GetSkillIncrease(pid, tes3mp.GetAttributeId('Strength')))
end
customEventHooks.registerHandler("OnPlayerSkill", CareFreeLevelling.OnPlayerAttributeTest)

return CareFreeLevelling;