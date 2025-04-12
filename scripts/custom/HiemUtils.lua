local HiemUtils = {}
HiemUtils.validators = {}

HiemUtils.defaultLabels = {
  meditateMessage = "You should rest and meditate on what you’ve learned",
  skillIncreaseMessage = "Your SKILLNAME skill increased to VALUE",
  item = " - Item: ",
  skill = " - Skill: ",
  requirementsError = "Requirements to craft not met",
  close = "Close"
}

HiemUtils.GUIConfig = {
  meditateId = 44332270,
  skillIncreaseId = 44332271,
  requirementsId = 44332272
}

-- Inventory Functions

function HiemUtils.sendInventoryChanges(pid)
  Players[pid]:LoadInventory()
  Players[pid]:LoadEquipment()
end

function HiemUtils.addPlayerItems(pid, itemTable)
    for _,item in pairs(itemTable) do
        if item.count == nil or item.count <= 0 then
            item.count = 1
        end
        inventoryHelper.addItem(Players[pid].data.inventory, item.refId, item.count, item.charge, item.enchantmentCharge, item.soul)
    end
    HiemUtils.sendInventoryChanges(pid)
end

function HiemUtils.removePlayerItems(pid, itemTable)
    for _,item in pairs(itemTable) do
        if item.count > 1 then
          local index = inventoryHelper.getItemIndex(Players[pid].data.inventory, item.refId, item.charge, item.enchantmentCharge, item.soul)
          if index then
            Players[pid].data.inventory[index].count = Players[pid].data.inventory[index].count - 1
          else
            inventoryHelper.removeClosestItem(Players[pid].data.inventory, item.refId, 1, item.charge, item.enchantmentCharge, item.soul)
          end
        else
          inventoryHelper.removeClosestItem(Players[pid].data.inventory, item.refId, 1, item.charge, item.enchantmentCharge, item.soul)
        end
        Players[pid]:LoadInventory()
        Players[pid]:LoadEquipment()
    end
    HiemUtils.sendInventoryChanges(pid)
end

-- Crafting Functions

function HiemUtils.validateCraft(pid, reqs, refId, soulFilled, callback, labels)
  local playerRef = Players[pid]
  local playerInv = playerRef.data.inventory
  local playerSkills = playerRef.data.skills
  local failed = false
  local failedMessage = ""
  local charge = -1
  local soul = ""
  local foundItems = {}

  if not labels then
    labels = HiemUtils.defaultLabels
  end

  if reqs.items then
    for i=1, #reqs.items do
      local itemReq = reqs.items[i]
      local itemFound = false
      local itemIndex = false

      for j=1, #playerInv do
        if playerInv[j] then
          for k=1, #itemReq.name do
            local itemName = itemReq.name[k];
            if playerInv[j].refId == itemName then
            
              if not itemReq.additionalValidation or (itemReq.additionalValidation and HiemUtils.validators[itemReq.additionalValidation] and HiemUtils.validators[itemReq.additionalValidation](playerInv[j], itemReq, pid)) then
                itemFound = true
                itemIndex = j
                reqs.items[i].item = playerInv[j]
                break
              end
            end
          end
        end
      end


      if itemFound then
        if playerInv[itemIndex].count < itemReq.count then
          failed = true
          failedMessage = failedMessage .. labels.item .. itemReq.label .. " " .. itemReq.count .. "\n"
        end
      else
        failed = true
        failedMessage = failedMessage .. labels.item .. itemReq.label .. " " .. itemReq.count .. "\n"
      end
    end
  end

  if reqs.skills then
    for i=1, #reqs.skills do
      local skillReq = reqs.skills[i]
      local skillValue = HiemUtils.getSkillValue(pid, skillReq.name)

      if skillValue < skillReq.value then
        failed = true
        failedMessage = failedMessage .. labels.skill .. skillReq.name .. " " .. skillReq.value .. "\n"
      end
    end
  end

  if not failed then
    local itemsToRemove = {}

    for i=1, #reqs.items do
      if reqs.items[i].consumed then
        table.insert(itemsToRemove, reqs.items[i].item)
      end


      if reqs.items[i].consumed == "soul" and reqs.items[i].item["refId"] == "misc_soulgem_azura" then
        local itemsToAdd = {reqs.items[i].item}
        HiemUtils.addPlayerItems(pid, itemsToAdd)
      end
    end

    HiemUtils.removePlayerItems(pid, itemsToRemove)

    if reqs.sounds then
      if reqs.sounds.success then
        HiemUtils.playSound(pid, reqs.sounds.success)
      end
    end

    if callback then
      callback(pid, refId, reqs)
    else
        local itemsToAdd = {{refId = refId, count = 1, charge = charge, enchantmentCharge = -1, soul = soul}}
        HiemUtils.addPlayerItems(pid, itemsToAdd)
    end
  else
    if reqs.sounds then
      if reqs.sounds.fail then
        HiemUtils.playSound(pid, reqs.sounds.fail)
      end
    end
    tes3mp.CustomMessageBox(pid, HiemUtils.GUIConfig.requirementsId, color.Default..labels.requirementsError.."\n\n"..color.Error..failedMessage, labels.close)
  end
end

function HiemUtils.generateRequirementsString(label, reqs)
  local items = ""
  local skills = ""
  if reqs.items then
    for i=1, #reqs.items do
      local itemReq = reqs.items[i]
      items = items .. HiemUtils.labels.item .. itemReq.label .. " " .. itemReq.count .. "\n"
    end
  end

  if reqs.skills then
    for i=1, #reqs.skills do
      local skillReq = reqs.skills[i]
      skills = skills .. HiemUtils.labels.skill .. skillReq.name .. " " .. skillReq.value .. "\n"
    end
  end

  return label.."\n"..skills..items.."\n"
end

-- Skill Functions

function HiemUtils.increaseSkill(pid, skillName, attributeName, amount, labels)
  local skillId = tes3mp.GetSkillId(skillName)
  local skillValue = tes3mp.GetSkillBase(pid, skillId)
  local attributeId = tes3mp.GetAttributeId(attributeName)
  local currentLevelProgress = tes3mp.GetLevelProgress(pid)

  if not labels then
    labels = HiemUtils.defaultLabels
  end

  local isMajorSkill = false
  for i=0,4 do
    if tes3mp.GetClassMajorSkill(pid, i) == skillId then
      isMajorSkill = true
    end
  end

  local isMinorSkill = false
  for i=0,4 do
    if tes3mp.GetClassMinorSkill(pid, i) == skillId then
      isMinorSkill = true
    end
  end

  local increaseAmount = amount
  if skillValue + amount > 100 then
    increaseAmount = 100 - skillValue;
  end

  if tes3mp.GetLevelProgress(pid) < 10 then
    if tes3mp.GetLevelProgress(pid) + increaseAmount >= 10 then
      tes3mp.MessageBox(pid, HiemUtils.GUIConfig.meditateId, labels.meditateMessage)
      HiemUtils.playSound(pid, "skillraise")
    end
  end

  tes3mp.SetLevelProgress(pid, tes3mp.GetLevelProgress(pid) + increaseAmount)
  tes3mp.SetSkillIncrease(pid, attributeId, tes3mp.GetSkillIncrease(pid, attributeId) + increaseAmount);
  tes3mp.SetSkillBase(pid, skillId, skillValue + increaseAmount);

  tes3mp.MessageBox(pid, HiemUtils.GUIConfig.skillIncreaseId, labels.skillIncreaseMessage:gsub("SKILLNAME", skillName):gsub("VALUE", skillValue + increaseAmount))

  tes3mp.SendLevel(pid)
  tes3mp.SendAttributes(pid);
  tes3mp.SendSkills(pid);
end

function HiemUtils.getSkillValue(pid, skillName)
  local skillId = tes3mp.GetSkillId(skillName)
  local skillBase = tes3mp.GetSkillBase(pid, skillId)
  local skillModifier = tes3mp.GetSkillBase(pid, skillId)
  local skillDamage = tes3mp.GetSkillBase(pid, skillId)

  local skillValue = (skillBase + skillModifier) - skillDamage
  return skillValue
end

function HiemUtils.getSkillBreakpoint(pid, skillName, breakpoints, key)
  local skillValue = HiemUtils.getSkillValue(pid, skillName)
  local currentBreakpoint

  for i=1, #breakpoints do
    if skillValue > breakpoints[i][key] then
      if currentBreakpoint then
        if currentBreakpoint[key] < breakpoints[i][key] then
          currentBreakpoint = breakpoints[i]
        end
      else
        currentBreakpoint = breakpoints[i]
      end
    end
  end

  return currentBreakpoint
end

-- Sound Functions

function HiemUtils.playSound(pid, sfxId, volume, pitch)
  if not volume then
    volume = 1
  end
  if not pitch then
    pitch = 1
  end
  logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySoundVP \""..sfxId .."\" "..volume.." "..pitch)
end

-- Data Functions

function HiemUtils.hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- Logging Functions

function HiemUtils.Log(o, pretty, depth, level)
  if not level then
    level = 2
  end

  if pretty and not depth then
    depth = 3
  end

  if pretty then
    tes3mp.LogMessage(level, HiemUtils.prettyDump(o, depth))
  else
    tes3mp.LogMessage(level, HiemUtils.dump(o))
  end
end

function HiemUtils.dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. HiemUtils.dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function HiemUtils.prettyDump(o,level)
    level = level or 1
    if type(o) == 'table' then
        local s = {}
        s[1] = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then 
                k = '"'..k..'"' 
            end
            s[#s+1] = string.rep('\t',level).. '['..k..'] = ' .. HiemUtils.prettyDump(v, level+1) .. ','
        end
        s[#s+1] = string.rep('\t',level) .. '} '
        return table.concat(s , "\n")
    else
        return tostring(o or 'nil')
    end
end

-- Recordstore Functions

function HiemUtils.addRecords(type, list)
  local recordStore = RecordStores[type]
  for i=1, #list do
    local item = list[i]
    local id = item.id
    if not item.id then
      id = item.refId
    end

    if item.container_flags then
      item.flags = item.container_flags
    end

    if type == 'npc' then
      item = HiemUtils.formatNPCRecordData(item)
    end

    recordStore.data.permanentRecords[id] = item;
  end
  recordStore:Save()

  -- for i=1, #list do
  --   local record = list[i]
  --   if record.inventory then
  --       for _, item in pairs(record.inventory) do
  --         packetBuilder.AddInventoryItemToRecord(item)
  --       end
  --   end
  -- end
end

function HiemUtils.formatNPCRecordData(item)
  item.gender = 1
  if string.find(item.mesh, 'female') then
    item.gender = 0
  end

  if item.data then
    item.level = item.data.level

    if item.data.stats then
      item.health = item.data.stats.health
      item.magicka = item.data.stats.magicka
      item.fatigue = item.data.stats.fatigue
    end
  end

  if item.ai_data then
    item.aiFight = item.ai_data.fight
    item.aiFlee = item.ai_data.flee
    item.aiAlarm = item.ai_data.alarm
    item.aiServices = item.ai_data.services
  end

  return item
end

-- Cell Functions

function HiemUtils.populateCell(cell)
  local cellDescription = cell.id
  local pid = 0
  local objects = {}
  logicHandler.LoadCell(cellDescription)

  local objectStatesToSave = {}
  if cell.itemsToRemove then
    for i=1, #cell.itemsToRemove do
      local item = cell.itemsToRemove[i]
      if item.index then
        objectStatesToSave = HiemUtils.removeObject(item.index.."-0", cellDescription, objectStatesToSave, item.refId)
      end
    end

    LoadedCells[cellDescription]:SaveObjectStates(objectStatesToSave)
    LoadedCells[cellDescription]:QuicksaveToDrive()
  end

  for i=1, #cell.references do
    local reference = cell.references[i]

    local location = {
      posX = reference.translation[1],
      posY = reference.translation[2],
      posZ = reference.translation[3],
      rotX = reference.rotation[1],
      rotY = reference.rotation[2],
      rotZ = reference.rotation[3]
    }

    local type = 'place'
    if logicHandler.GetRecordTypeByRecordId(reference.id) == 'npc' or logicHandler.GetRecordTypeByRecordId(reference.id) == 'creature' then
      type = 'spawn'
    end

    local uniqueIndex = HiemUtils.placeObject(reference.id, location, cellDescription, type)

    if type == 'spawn' and not HiemUtils.hasValue(LoadedCells[cellDescription].data.packets.actorList, uniqueIndex) then
      table.insert(LoadedCells[cellDescription].data.packets.actorList, uniqueIndex)
    end

    local record = logicHandler.GetRecordStoreByRecordId(reference.id)
    if record then
      -- if record.data.permanentRecords[reference.id].data then
      --   local stats = record.data.permanentRecords[reference.id].data.stats
      --   if stats then
          
      --   end
      -- end
      -- local equipment = record.data.permanentRecords[reference.id].equipment
      -- if equipment then
      --   HiemUtils.equipItems(equipment, cellDescription, uniqueIndex)

      --   if not HiemUtils.hasValue(LoadedCells[cellDescription].data.packets.equipment, uniqueIndex) then
      --     table.insert(LoadedCells[cellDescription].data.packets.equipment, uniqueIndex)
      --   end
      -- end

      local inventory = record.data.permanentRecords[reference.id].inventory
      if inventory then
        HiemUtils.stockItems(inventory, cellDescription, uniqueIndex)

        if not HiemUtils.hasValue(LoadedCells[cellDescription].data.packets.container, uniqueIndex) then
          table.insert(LoadedCells[cellDescription].data.packets.container, uniqueIndex)
        end
      end

    end
  end

  logicHandler.UnloadCell(cellDescription)
end

function HiemUtils.removeObject(refIndex, cellDescription, objectStatesToSave, refId)
    local objectData = LoadedCells[cellDescription].data.objectData[refIndex]
    local splitIndex = refIndex:split("-")
    tes3mp.ClearObjectList()
    tes3mp.SetObjectListCell(cellDescription)
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])
    tes3mp.SetObjectState(false)
    tes3mp.SendObjectState(true, false)

    tableHelper.insertValueIfMissing(LoadedCells[cellDescription].data.packets.state, refIndex)

    if LoadedCells[cellDescription].data.objectData[refIndex] then
      LoadedCells[cellDescription].data.objectData[refIndex].state = false

      if refId and not LoadedCells[cellDescription].data.objectData[refIndex].refId then
        LoadedCells[cellDescription].data.objectData[refIndex].refId = refId
      end
    elseif refId then
      LoadedCells[cellDescription].data.objectData[refIndex] = {
        state = false,
        refId = refId
      }
    end


    if objectStatesToSave and objectData then
      objectStatesToSave[refIndex] = {refId = objectData.refId, state = false}

      return objectStatesToSave
    elseif objectStatesToSave and refId then
      objectStatesToSave[refIndex] = {refId = refId, state = false}

      return objectStatesToSave
    end
end

function HiemUtils.placeObject(refId, location, cell, type)
  local mpNum = WorldInstance:GetCurrentMpNum() + 1
  local refIndex =  0 .. "-" .. mpNum
  
  WorldInstance:SetCurrentMpNum(mpNum)
  tes3mp.SetCurrentMpNum(mpNum)
  
  if not LoadedCells[cell] then
    logicHandler.LoadCell(cell)
  end

  LoadedCells[cell]:InitializeObjectData(refIndex, refId)
  LoadedCells[cell].data.objectData[refIndex].location = location
  table.insert(LoadedCells[cell].data.packets[type], refIndex)
 
  for onlinePid, player in pairs(Players) do
    if player:IsLoggedIn() then
      tes3mp.InitializeEvent(onlinePid)
      tes3mp.SetEventCell(cell)
      tes3mp.SetObjectRefId(refId)
      tes3mp.SetObjectRefNumIndex(0)
      tes3mp.SetObjectMpNum(mpNum)
      tes3mp.SetObjectPosition(location.posX, location.posY, location.posZ)
      tes3mp.SetObjectRotation(location.rotX, location.rotY, location.rotZ)
      tes3mp.AddWorldObject()
      tes3mp.SendObjectPlace()
    end
  end
  
  LoadedCells[cell]:Save()
  return refIndex
end

-- NPC Functions

function HiemUtils.stockItems(itemsToStock, cellDescription, uniqueIndex)
    if itemsToStock ~= nil then
        local cell = LoadedCells[cellDescription]
        local objectData = cell.data.objectData
        local reloadInventory = false

        if not objectData[uniqueIndex].inventory then
          objectData[uniqueIndex].inventory = {}
        end

        local currentInventory = objectData[uniqueIndex].inventory

        if objectData[uniqueIndex] ~= nil then

            for _, object in pairs(currentInventory) do
                for i, itemData in pairs(itemsToStock) do
                    if object.refId == itemsToStock[i].refId then
                        if object.count < itemsToStock[i].count then
                            object.count = itemsToStock[i].count
                            if not reloadInventory then reloadInventory = true end
                        else
                            itemsToStock[i].count = object.count
                        end
                    end
                end
            end

            for i, v in pairs(itemsToStock) do
                if not tableHelper.containsValue(currentInventory, itemsToStock[i].refId, true) then
                    inventoryHelper.addItem(currentInventory, itemsToStock[i][2], itemsToStock[i][1], itemsToStock[i][3] or -1, itemsToStock[i][4] or -1, itemsToStock[i][5] or "")
                    if not reloadInventory then reloadInventory = true end
                end
            end

            if reloadInventory then
                for i = 0, #Players do
                    if Players[i] ~= nil and Players[i]:IsLoggedIn() then
                        if Players[i].data.location.cell == cellDescription then
                            cell:LoadContainers(i, cell.data.objectData, {uniqueIndex})
                        end
                    end
                end
            end
        end
    end
end

function HiemUtils.equipItems(itemsToEquip, cellDescription, uniqueIndex)
  if itemsToStock ~= nil then
    local cell = LoadedCells[cellDescription]
    local objectData = cell.data.objectData

    if not objectData[uniqueIndex].equipment then
      objectData[uniqueIndex].equipment = {}
    end


    if objectData[uniqueIndex] ~= nil then
      local currentEquipment = objectData[uniqueIndex].equipment

      currentEquipment = itemsToEquip
    end
  end
end

return HiemUtils