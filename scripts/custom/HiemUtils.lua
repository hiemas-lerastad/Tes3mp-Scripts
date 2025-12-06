--[[
  HiemUtils

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
]]--

local HiemUtils = {}
HiemUtils.validators = {}
HiemUtils.restockers = {}

HiemUtils.Data = jsonInterface.load("custom/HIEMDataList.json")

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

function HiemUtils.loadCustomData()
  HiemUtils.custom = jsonInterface.load("custom/HiemCustom.json")

  if not HiemUtils.custom then
    HiemUtils.custom = {}
  end
end
-- HiemUtils.custom = HiemUtils.loadCustomData()


function HiemUtils.saveCustomData()
  jsonInterface.quicksave("custom/HiemCustom.json", HiemUtils.custom)
end

function HiemUtils.getDistance(coord1, coord2)
    -- Get the length for each of the components x and y
    local xDist = coord2.x - coord1.x
    local yDist = coord2.y - coord1.y

    return math.sqrt((xDist ^ 2) + (yDist ^ 2)) 
end

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
      HiemUtils.unequipPlayerItem(pid, item)

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
    end

    HiemUtils.sendInventoryChanges(pid)
end

function HiemUtils.unequipPlayerItem(pid, item)
  local itemsFound = 0

  if tableHelper.containsKeyValue(Players[pid].data.equipment, "refId", item.refId, true) then
      local itemSlot = tableHelper.getIndexByNestedKeyValue(Players[pid].data.equipment, "refId", item.refId, true)
      Players[pid].data.equipment[itemSlot] = nil
      itemsFound = itemsFound + 1
  end

  if itemsFound > 0 then
      Players[pid]:QuicksaveToDrive()
      Players[pid]:LoadEquipment()
  end
end

-- Crafting Functions

function HiemUtils.validators.soulValue(item, req, pid)
  if not (item.soul == "") and  HiemUtils.Data.actors[item.soul] >= req.soulMinSize then
    return true
  end

  return false
end

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

function HiemUtils.generateRequirementsString(label, reqs, labels)
  local items = ""
  local skills = ""

  if not labels then
    labels = HiemUtils.defaultLabels
  end
  
  if reqs.items then
    for i=1, #reqs.items do
      local itemReq = reqs.items[i]
      items = items .. labels.item .. itemReq.label .. " " .. itemReq.count .. "\n"
    end
  end

  if reqs.skills then
    for i=1, #reqs.skills do
      local skillReq = reqs.skills[i]
      skills = skills .. labels.skill .. skillReq.name .. " " .. skillReq.value .. "\n"
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

  local newSkillValue = skillValue + increaseAmount;
  Players[pid].data.skills[skillName].base = newSkillValue;

  local levelProgress = tes3mp.GetLevelProgress(pid) + increaseAmount
  Players[pid].data.stats.levelProgress = levelProgress

  local skillIncrease = tes3mp.GetSkillIncrease(pid, attributeId) + increaseAmount
  Players[pid].data.attributes[attributeName].skillIncrease = skillIncrease;

  local attributeArgs = {pid, Players[pid].data.attributes}
  local eventStatus = customEventHooks.triggerValidators('OnPlayerAttribute', attributeArgs)

  customEventHooks.triggerHandlers('OnPlayerAttribute', eventStatus, attributeArgs)

  local skillArgs = {pid, Players[pid].data.skills}
  local eventStatus = customEventHooks.triggerValidators('OnPlayerSkill', skillArgs)
  customEventHooks.triggerHandlers('OnPlayerSkill', eventStatus, skillArgs)

  if isMinorSkill or isMajorSkill then
    tes3mp.SetLevelProgress(pid, levelProgress)
  end

  tes3mp.SetSkillIncrease(pid, attributeId, skillIncrease);
  tes3mp.SetSkillBase(pid, skillId, newSkillValue);

  tes3mp.MessageBox(pid, HiemUtils.GUIConfig.skillIncreaseId, labels.skillIncreaseMessage:gsub("SKILLNAME", skillName):gsub("VALUE", newSkillValue))

  tes3mp.SendSkills(pid);
  tes3mp.SendAttributes(pid);
  tes3mp.SendLevel(pid);
end

function HiemUtils.getSkillValue(pid, skillName)
  local skillId = tes3mp.GetSkillId(skillName)
  local skillBase = tes3mp.GetSkillBase(pid, skillId)
  local skillModifier = tes3mp.GetSkillModifier(pid, skillId)
  local skillDamage = tes3mp.GetSkillDamage(pid, skillId)

  local skillValue = (skillBase + skillModifier) - skillDamage
  return skillValue
end

function HiemUtils.getSkillBreakpoint(pid, skillName, breakpoints, key)
  local skillValue = HiemUtils.getSkillValue(pid, skillName)
  local currentBreakpoint

  for i=1, #breakpoints do
    if skillValue >= breakpoints[i][key] then
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

function HiemUtils.addRecords(type, list, quicksave)
  if not HiemUtils.custom then
    HiemUtils.loadCustomData()
  end

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

    if quicksave then
      recordStore:QuicksaveToDrive()
      tes3mp.ClearRecords()
      tes3mp.SetRecordType(enumerations.recordType[string.upper(type)])
      packetBuilder.AddRecordByType(id, item, type)
    end

    if type == "spell" and item.birthsign == true then
      if not HiemUtils.custom.birthsignUpdates then
        HiemUtils.custom.birthsignUpdates = {}
      end

      HiemUtils.custom.birthsignUpdates[id] = item
    end
  end
  recordStore:Save()
  HiemUtils.saveCustomData()
end

function HiemUtils.updateBirthsignSpells(pid)
  tes3mp.ClearRecords()
  tes3mp.SetRecordType(enumerations.recordType["SPELL"])

  if not HiemUtils.custom then
    HiemUtils.loadCustomData()
  end

  if not HiemUtils.custom.birthsignUpdates then
    HiemUtils.custom.birthsignUpdates = {}
  end

  for key, value in pairs(HiemUtils.custom.birthsignUpdates) do
    packetBuilder.AddRecordByType(key, value, "spell")
  end
  tes3mp.SendRecordDynamic(pid, false, false)
end

customEventHooks.registerHandler("OnPlayerConnect", function(eventStatus, pid)
    if Players[pid] ~= nil then
        HiemUtils.updateBirthsignSpells(pid)
    end
end)

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
      rotZ = reference.rotation[3],
      -- scale = 1.0,
    }

    local scale = 1.0;

    if reference.scale then
      scale = reference.scale
    end

    local type = 'place'
    if logicHandler.GetRecordTypeByRecordId(reference.id) == 'npc' or logicHandler.GetRecordTypeByRecordId(reference.id) == 'creature' then
      type = 'spawn'
    end

    local uniqueIndex = HiemUtils.placeObject(reference.id, location, scale, cellDescription, type)

    if type == 'spawn' and not HiemUtils.hasValue(LoadedCells[cellDescription].data.packets.actorList, uniqueIndex) then
      table.insert(LoadedCells[cellDescription].data.packets.actorList, uniqueIndex)
    end

    local record = logicHandler.GetRecordStoreByRecordId(reference.id)
    if record then
      local inventory = record.data.permanentRecords[reference.id].inventory
      if inventory then
        HiemUtils.stockItems(inventory, cellDescription, uniqueIndex)

        if not HiemUtils.hasValue(LoadedCells[cellDescription].data.packets.container, uniqueIndex) then
          table.insert(LoadedCells[cellDescription].data.packets.container, uniqueIndex)
        end

        for i,item in ipairs(inventory) do
          if item[1] < 0 then
            if not HiemUtils.custom.restockers[uniqueIndex] then
              HiemUtils.custom.restockers[uniqueIndex] = {}
            end

            local formattedItem = {
              count = 0 - item[1],
              refId = item[2]
            }

            table.insert(HiemUtils.custom.restockers[uniqueIndex], formattedItem)
          end
        end
        HiemUtils.saveCustomData()
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

function HiemUtils.placeObject(refId, location, scale, cell, type)
  local mpNum = WorldInstance:GetCurrentMpNum() + 1
  local refIndex =  0 .. "-" .. mpNum
  
  WorldInstance:SetCurrentMpNum(mpNum)
  tes3mp.SetCurrentMpNum(mpNum)
  
  if not LoadedCells[cell] then
    logicHandler.LoadCell(cell)
  end

  LoadedCells[cell]:InitializeObjectData(refIndex, refId)

  LoadedCells[cell].data.objectData[refIndex].location = location
  LoadedCells[cell].data.objectData[refIndex].scale = scale

  table.insert(LoadedCells[cell].data.packets[type], refIndex)
  if scale ~= nil and scale ~= 1 then
      tableHelper.insertValueIfMissing(LoadedCells[cell].data.packets.scale, refIndex)
  end

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
      tes3mp.SetObjectScale(scale)
      tes3mp.SendObjectScale(true)
    end
  end
  
  LoadedCells[cell]:Save()
  return refIndex
end

-- NPC Functions

function HiemUtils.stockItems(itemsToStock, cellDescription, uniqueIndex)
    if not HiemUtils.custom then
      HiemUtils.loadCustomData()
    end

    if not HiemUtils.custom.restockers then 
      HiemUtils.custom.restockers = {}
      HiemUtils.saveCustomData()
    end

    if itemsToStock ~= nil then
        local cell = LoadedCells[cellDescription]
        local objectData = cell.data.objectData
        local reloadInventory = false

        if not objectData[uniqueIndex].inventory then
          objectData[uniqueIndex].inventory = {}
        end

        local currentInventory = objectData[uniqueIndex].inventory

        for i, v in pairs(itemsToStock) do
          if v[1] < 0 then
            v.count = 0 - v[1]
          else
            v.count = v[1]
          end
        end

        if objectData[uniqueIndex] ~= nil then

            for _, object in pairs(currentInventory) do
                for i, itemData in pairs(itemsToStock) do
                    if object.refId == itemData[2] then
                        if object.count < itemData["count"] then
                            object.count = itemData["count"]
                            if not reloadInventory then reloadInventory = true end
                        else
                            itemsToStock[i][1] = object.count
                        end
                    end
                end
            end

            for i, v in pairs(itemsToStock) do
                if not tableHelper.containsValue(currentInventory, itemsToStock[i].refId, true) then
                    inventoryHelper.addItem(currentInventory, itemsToStock[i][2], itemsToStock[i]["count"], itemsToStock[i][3] or -1, itemsToStock[i][4] or -1, itemsToStock[i][5] or "")
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

function HiemUtils.RestockContainer(eventStatus, pid, cellDescription, objects)
  if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
    if HiemUtils.custom and HiemUtils.custom.restockers then
      for uniqueIndex, object in pairs(objects) do
        for restockerIndex, merchantRefid in pairs(HiemUtils.custom.restockers) do
          if restockerIndex == uniqueIndex then
            if object.dialogueChoiceType == 3 then -- BARTER
              local itemsToStock = HiemUtils.custom.restockers[restockerIndex]

              if itemsToStock ~= nil then
                local cell = LoadedCells[cellDescription]
                local objectData = cell.data.objectData
                local reloadInventory = false

                if not objectData[uniqueIndex].inventory then
                  objectData[uniqueIndex].inventory = {}
                end

                local currentInventory = objectData[uniqueIndex].inventory

                if objectData[uniqueIndex] ~= nil then

                  for i, itemData in pairs(itemsToStock) do
                    local objectFound = false;
                    for _, object in pairs(currentInventory) do
                      if object.refId == itemData.refId then
                        objectFound = true;

                        if object.count < itemData.count then
                          object.count = itemData.count

                          if not reloadInventory then reloadInventory = true end
                        end
                      end
                    end

                    -- try fix but for double stock on first server init

                    if not objectFound then
                      inventoryHelper.addItem(currentInventory, itemData.refId, itemData["count"], itemData[3] or -1, itemData[4] or -1, itemData[5] or "")
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
          end
        end
      end
    end
  end
end
customEventHooks.registerValidator("OnObjectDialogueChoice", HiemUtils.RestockContainer)

function HiemUtils.OnPlayerCellChangeHandler(eventStatus, pid, playerPacket, previousCellDescription)
  if not HiemUtils.Data then
    HiemUtils.Data = jsonInterface.load("custom/HIEMDataList.json")
  end

  if HiemUtils.Data.chambers[playerPacket.location.cell] then
    local chamber = HiemUtils.Data.chambers[playerPacket.location.cell]
    HiemUtils.Log("Setting new lastExteriorCell for "..Players[pid].name..", Value: "..chamber.mapCoords.x..", "..chamber.mapCoords.y)
    Players[pid].data.customVariables.lastExteriorCell = chamber.mapCoords.x..", "..chamber.mapCoords.y
  elseif HiemUtils.Data.locations[playerPacket.location.cell] then
    local location = HiemUtils.Data.locations[playerPacket.location.cell]
    HiemUtils.Log("Setting new lastExteriorCell for "..Players[pid].name..", Value: "..location.mapCoords.x..", "..location.mapCoords.y)
    Players[pid].data.customVariables.lastExteriorCell = location.mapCoords.x..", "..location.mapCoords.y
  elseif string.match(playerPacket.location.cell, patterns.exteriorCell) then
    HiemUtils.Log("Setting new lastExteriorCell for "..Players[pid].name..", Value: "..playerPacket.location.cell)
    Players[pid].data.customVariables.lastExteriorCell = playerPacket.location.cell
  elseif string.match(previousCellDescription, patterns.exteriorCell) then
    HiemUtils.Log("Setting new lastExteriorCell for "..Players[pid].name..", Value: "..previousCellDescription)
    Players[pid].data.customVariables.lastExteriorCell = previousCellDescription
  end
end
customEventHooks.registerHandler("OnPlayerCellChange", HiemUtils.OnPlayerCellChangeHandler)

return HiemUtils