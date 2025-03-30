RunicEnchanting = {}

RunicEnchanting.config = {
  enchantTrainingRecipe = {
    items = {
      {
        name = "Misc_Inkwell",
        label = "Inkwell",
        count = 1,
        consumed = false
      },
      {
        name = "Misc_Quill",
        label = "Quill Pen",
        count = 1,
        consumed = false
      },
      {
        name = "sc_paper plain",
        label = "Paper",
        count = 1,
        consumed = true
      }
    }
  },
  -- Recipe for Crafting Book
  bookRecipe = {
    skills = {
      {
        name = "Enchant",
        value = 30
      }
    },
    items = {
      {
        name = "sc_paper plain",
        label = "Paper",
        count = 5,
        consumed = true
      }
    }
  },

  -- Recipe for Soul Reservoir
  gemRecipe = {
    skills = {
      {
        name = "Enchant",
        value = 30
      },
      {
        name = "Armorer",
        value = 50
      },
    },
    items = {
      {
        name = "misc_soulgem_grand",
        label = "Grand Soul Gem",
        count = 1,
        consumed = true
      }
    }
  },

  -- Recipe for Rune Smith's Tools
  toolsRecipe = {
    skills = {
      {
        name = "Enchant",
        value = 10
      },
      {
        name = "Armorer",
        value = 20
      },
    },
    items = {
      {
        name = "repair_prongs",
        label = "Repair Prongs",
        count = 1,
        consumed = true
      },
      {
        name = "hammer_repair",
        label = "Apprentice's Armorer's Hammer",
        count = 1,
        consumed = true
      },
      {
        name = "Soul_Gem",
        label = "Soul Gem",
        count = 1,
        consumed = 'soul',
        soulMinSize = 15
      },
      {
        name = "ingred_raw_ebony_01",
        label = "Raw Ebony",
        count = 1,
        consumed = true
      }
    }
  },

  gloveRecipe = {
    skills = {
      {
        name = "Enchant",
        value = 100
      },
    },
    items = {
      {
        name = "extravagant_glove_right_01",
        label = "Extravagant Right Glove",
        count = 1,
        consumed = true
      }
    }
  },

  armorerTrainingRecipe = {
    items = {
      {
        name = "ingred_raw_ebony_01",
        label = "Raw Ebony",
        count = 1,
        consumed = true
      }
    }
  },

  toolUpgradeRecipe = {
    items = {
      {
        name = "ingred_raw_ebony_01",
        label = "Raw Ebony",
        count = 1,
        consumed = true
      },
      {
        name = "Soul_Gem",
        label = "Soul Gem",
        count = 1,
        consumed = 'soul',
        soulMinSize = 50
      }
    }
  },
}

RunicEnchanting.labels = {
  bookMain = "The book is full of schematics of strange objects and tools.\nWhat would you like to attempt to craft",
  toolMain = "What would you like to use the tools for",
  soulReservoirName = "Soul Reservoir",
  upgradeToolName = "Rune Smith's Tools",
  soulReservoirName = "Soul Reservoir",
  soulVialName = "Soul Vial",
  enchantGloveName = "Glove of Enchanting",
  bookName = "Secrets of Runic Enchanting",
  bookCopy = "Copy this Tome",
  bookStudy = "Study this Tome",
  upgrade = "Etch Runes into Items",
  practice = "Practice Etching",
  close = "Close",
  back = "Back",
  smallSoulMass = "Small mass of souls",
  largeSoulMass = "Large mass of souls",
  divineSoulMass = "Divine mass of souls",
  prefix = "Runic ",
  item = " - Item: ",
  skill = " - Skill: ",
  requirements = "Crafting Requirements",
  requirementsError = "Requirements to craft not met",
  extract = "Extract ",
  currentValue = "Current Value: ",
  choice = "What would you like to do?",
  upgradeChoice = "What would you like to upgrade?",
  soulTrapMessage = "A soul has found purchase in a reservoir"
}

-- Don't edit below here unless you know what you are doing

local ReservoirList
local Data
local SoulTrapList = {}
local UpgradeData = {}

local REBGuI1 = 44332256 -- Book, main gui
local REBGuI2 = 44332257 -- Book, error gui
local REBGuI3 = 44332258 -- Book, requirements gui

local RERGuI1 = 44332259 -- Reservoir, main gui
local RERGuI2 = 44332260 -- Reservoir, soul trap message

local REUGuI1 = 44332261 -- Upgrade, main gui
local REUGuI2 = 44332262 -- Upgrade, upgrade gui
local REUGuI3 = 44332263 -- Upgrade, break gui

function RunicEnchanting.createRecord()
  recordStore = RecordStores["miscellaneous"]

  local itemList = {
    {
      refId = "re_enchant_book",
      name = RunicEnchanting.labels.bookName,
      icon = "m\\Tx_folio_03.tga",
      model = "m\\Text_Folio_03.NIF",
      weight = 3,
      value = 200,
      script = ""
    },
    {
      refId = "re_soul_gem",
      name = RunicEnchanting.labels.soulReservoirName,
      icon = "m\\Tx_pot_blue_02.tga",
      model = "m\\Misc_pot_blue_02.NIF",
      weight = 1,
      value = 300,
      script = ""
    },
    {
      refId = "re_soul_gem_02",
      name = RunicEnchanting.labels.soulVialName,
      icon = "m\\Tx_pot_blue_01.tga",
      model = "m\\Misc_pot_blue_01.NIF",
      weight = 0.1,
      value = 0,
      script = ""
    },
    {
      refId = "re_upgrade_tool",
      name = RunicEnchanting.labels.upgradeToolName,
      icon = "m\\Tx_repair_S_01.tga",
      model = "m\\Repair_SecretMaster_01.NIF",
      weight = 1,
      value = 200,
      script = ""
    },
  }

  for i=1, #itemList do
    local item = itemList[i]
    recordStore.data.permanentRecords[item.refId] = {
      baseId = item.baseId,
      name = item.name,
      model = item.model,
      icon = item.icon,
      weight = item.weight,
      value = item.value,
      keyState = item.keyState,
      script = item.script
    }
    
  end
  recordStore:Save()

  recordStore = RecordStores["enchantment"]

  local enchantList = {
    {
      refId = "re_enchanting_enchant",
      subtype = 3,
      cost = 0,
      charge = 0,
      flags = 0,
      effects = {
        {
          id = 83,
          attribute = -1,
          skill = 9,
          rangeType = 0,
          area = 0,
          duration = 1,
          magnitudeMax = 4000,
          magnitudeMin = 4000
        }
      }
    }
  }

  for i=1, #enchantList do
    local item = enchantList[i]
    recordStore.data.permanentRecords[item.refId] = item;
  end
  recordStore:Save()

  recordStore = RecordStores["clothing"]

  local clothingList = {
    {
      refId = "re_enchant_gloves",
      baseId = "aryongloveright",
      name = RunicEnchanting.labels.enchantGloveName,
      enchantmentId = "re_enchanting_enchant"
    }
  }

  for i=1, #clothingList do
    local item = clothingList[i]
    recordStore.data.permanentRecords[item.refId] = item;
    
  end
  recordStore:Save()

  recordStore = RecordStores["creature"]

  local creatureList = {
    {
      baseId = "ancestor_ghost_summon",
      refId = "re_creature_soul_small",
      name = RunicEnchanting.labels.smallSoulMass,
      soulValue = 100
    },
    {
      baseId = "ancestor_ghost_summon",
      refId = "re_creature_soul_large",
      name = RunicEnchanting.labels.largeSoulMass,
      soulValue = 500
    },
    {
      baseId = "ancestor_ghost_summon",
      refId = "re_creature_soul_divine",
      name = RunicEnchanting.labels.divineSoulMass,
      soulValue = 1000
    },
  }

  for i=1, #creatureList do
    local creature = creatureList[i]
    recordStore.data.permanentRecords[creature.refId] = {
      baseId = creature.baseId,
      id = creature.refId,
      name = creature.name,
      soulValue = creature.soulValue,
    } 
  end
  recordStore:Save()
end

function RunicEnchanting.loadReservoirData()
  ReservoirList = jsonInterface.load("custom/REReservoirList.json")
end

function RunicEnchanting.saveReservoirData()
  jsonInterface.quicksave("custom/REReservoirList.json", ReservoirList)
end

function RunicEnchanting.initialseData()
  RunicEnchanting.loadReservoirData()
  if not ReservoirList then 
    ReservoirList = {}
    RunicEnchanting.saveReservoirData()    
  end

  Data = jsonInterface.load("custom/REDataList.json")
end

function RunicEnchanting.OnServerPostInit(eventStatus)
  if not WorldInstance.data.customVariables.RE_Records_Initisalised then
    RunicEnchanting.createRecord()
    WorldInstance.data.customVariables.RE_Records_Initisalised = true

    local placementConfig = {
      {
        cellId = 'Balmora, Guild of Mages',
        location = {posX = -601, posY = 43.932, posZ = 20.597, rotX = 0, rotY = 21000, rotZ = 0},
        refId = 're_enchant_book'
      }
    }

    for i=1,#placementConfig do
      local cellId = placementConfig[i].cellId
      local location = placementConfig[i].location
      local targetData = {
        refId = placementConfig[i].refId
      }

      local targetUniqueIndex = logicHandler.CreateObjectAtLocation(cellId, location, targetData, "place")
    end
  end

  RunicEnchanting.initialseData()
end

customEventHooks.registerHandler("OnServerPostInit", RunicEnchanting.OnServerPostInit)



-- Crafting/Training Functions
-- Train Enchanting (Study)
function RunicEnchanting.validateCraftEnchantTraining(pid)
  local reqs = RunicEnchanting.config.enchantTrainingRecipe
  RunicEnchanting.validateCraft(pid, reqs, false, false, RunicEnchanting.trainEnchantStudy)
end

function RunicEnchanting.trainEnchantStudy(pid, refId, reqs)
  RunicEnchanting.increaseSkill(pid, 'Enchant', 'Intelligence', 10)
end

-- Craft Book Copy
function RunicEnchanting.validateCraftBook(pid)
  local reqs = RunicEnchanting.config.bookRecipe
  RunicEnchanting.validateCraft(pid, reqs, "re_enchant_book")
end

-- Craft Soul Reservior
function RunicEnchanting.validateCraftGem(pid)
  local reqs =  RunicEnchanting.config.gemRecipe
  RunicEnchanting.validateCraft(pid, reqs, "re_soul_gem", true)
end

-- Craft Rune Smith's Tools
function RunicEnchanting.validateCraftTool(pid)
  local reqs = RunicEnchanting.config.toolsRecipe
  RunicEnchanting.validateCraft(pid, reqs, "re_upgrade_tool")
end

-- Craft Enchanters Gear (Undecided)
function RunicEnchanting.validateCraftGlove(pid)
  local reqs = RunicEnchanting.config.gloveRecipe
  RunicEnchanting.validateCraft(pid, reqs, "re_enchant_gloves")
end

function RunicEnchanting.validateCraftArmorerTraining(pid)
  local reqs = RunicEnchanting.config.armorerTrainingRecipe
  RunicEnchanting.validateCraft(pid, reqs, false, false, RunicEnchanting.trainArmorerPractice)
end

function RunicEnchanting.trainArmorerPractice(pid)
  RunicEnchanting.increaseSkill(pid, 'Armorer', 'Strength', 10)
end



-- Utility Functions
function RunicEnchanting.increaseSkill(pid, skillName, attributeName, amount)
  local skillId = tes3mp.GetSkillId(skillName)
  local skillValue = tes3mp.GetSkillBase(pid, id)
  local attributeId = tes3mp.GetAttributeId(attributeName)
  local currentLevelProgress = tes3mp.GetLevelProgress(pid)

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

  tes3mp.SetLevelProgress(pid, tes3mp.GetLevelProgress(pid) + increaseAmount)
  tes3mp.SetSkillIncrease(pid, attributeId, tes3mp.SetSkillIncrease(pid) + increaseAmount);
  tes3mp.SetSkillBase(pid, skillId, skillValue + increaseAmount);

  tes3mp.SendLevel(pid)
  tes3mp.SendAttributes(pid);
  tes3mp.SendSkills(pid);
end

function RunicEnchanting.validateCraft(pid, reqs, refId, soulFilled, callback)
  local playerRef = Players[pid]
  local playerInv = playerRef.data.inventory
  local playerSkills = playerRef.data.skills
  local failed = false
  local failedMessage = ""
  local charge = 0
  local soul = ""

  if soulFilled then
    charge = #ReservoirList +  1
  end

  if reqs.items then
    for i=1, #reqs.items do
      local itemReq = reqs.items[i]
      local itemFound = false
      local itemIndex = false

      if reqs.items[i].name == "Soul_Gem" then
        local gemList = Data.gems
        table.insert(gemList, "re_soul_gem_02")
        for j=1, #gemList do
          for k=1, #playerInv do
            if playerInv[k] then
              if playerInv[k].refId == gemList[j].name and playerInv[k].charge >= itemReq.soulMinSize then
                itemFound = true
                itemIndex = k
              end
            end
          end
        end
      else
        for j=1, #playerInv do
          if playerInv[j] then
            if playerInv[j].refId == itemReq.name then
              itemFound = true
              itemIndex = j
            end
          end
        end
      end

      if itemFound then
        if playerInv[itemIndex].count < itemReq.count then
          failed = true
          failedMessage = failedMessage .. RunicEnchanting.labels.item .. itemReq.label .. " " .. itemReq.count .. "\n"
        end
      else
        failed = true
        failedMessage = failedMessage .. RunicEnchanting.labels.item .. itemReq.label .. " " .. itemReq.count .. "\n"
      end
    end
  end

  if reqs.skills then
    for i=1, #reqs.skills do
      local skillReq = reqs.skills[i]

      if playerSkills[skillReq.name].base < skillReq.value then
        failed = true
        failedMessage = failedMessage .. RunicEnchanting.labels.skill .. skillReq.name .. " " .. skillReq.value .. "\n"
      end
    end
  end

  if not failed then
    if reqs.items then
      for i=1, #reqs.items do
        if reqs.items[i].consumed then
          inventoryHelper.removeItem(
              playerInv,
              reqs.items[i].name,
              reqs.items[i].count,
              -1,
              -1,
              ""
          )
        end

        tes3mp.ClearInventoryChanges(pid)
        tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.REMOVE)
        tes3mp.AddItemChange(pid, reqs.items[i].name, reqs.items[i].count, -1, -1, "")

        if reqs.items[i].consumed == "soul" and reqs.items[i].name == "misc_soulgem_azura" then
          tes3mp.ClearInventoryChanges(pid)
          tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
          inventoryHelper.addItem(playerInv, reqs.items[i].name, reqs.items[i].count, -1, -1, "")
          tes3mp.AddItemChange(pid, reqs.items[i].name, reqs.items[i].count, -1, -1, "")
        end

        tes3mp.SendInventoryChanges(pid)
      end
    end

    if callback then
      callback(pid, refId, reqs)
    else
      inventoryHelper.addItem(playerInv, refId, 1, charge, -1, soul)

      tes3mp.ClearInventoryChanges(pid)
      tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
      tes3mp.AddItemChange(pid, refId, 1, charge, -1, soul)
      tes3mp.SendInventoryChanges(pid)

      if not ReservoirList[playerRef.name] then
        ReservoirList[playerRef.name] = 0
        RunicEnchanting.saveReservoirData()
      end
    end
  else
    tes3mp.CustomMessageBox(pid, REBGuI2, color.Default..RunicEnchanting.labels.requirementsError.."\n\n"..color.Error..failedMessage, RunicEnchanting.labels.close)
  end
end

function RunicEnchanting.generateRequirementsString(label, reqs)
  local items = ""
  local skills = ""
  if reqs.items then
    for i=1, #reqs.items do
      local itemReq = reqs.items[i]
      items = items .. RunicEnchanting.labels.item .. itemReq.label .. " " .. itemReq.count .. "\n"
    end
  end

  if reqs.skills then
    for i=1, #reqs.skills do
      local skillReq = reqs.skills[i]
      skills = skills .. RunicEnchanting.labels.skill .. skillReq.name .. " " .. skillReq.value .. "\n"
    end
  end

  return label.."\n"..skills..items.."\n"
end

function RunicEnchanting.dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


-- GUI Functions
function RunicEnchanting.showBookGUI(pid)
  -- tes3mp.CustomMessageBox(pid, REBGuI1, color.DarkOrange..RunicEnchanting.labels.bookMain, RunicEnchanting.labels.soulReservoirName..";"..RunicEnchanting.labels.upgradeToolName..";"..RunicEnchanting.labels.enchantGloveName..";"..RunicEnchanting.labels.bookCopy..";"..RunicEnchanting.labels.requirements..";"..RunicEnchanting.labels.close)
  tes3mp.CustomMessageBox(pid, REBGuI1, color.DarkOrange..RunicEnchanting.labels.bookMain, RunicEnchanting.labels.bookStudy..";"..RunicEnchanting.labels.bookCopy..";"..RunicEnchanting.labels.upgradeToolName..";"..RunicEnchanting.labels.soulReservoirName..";"..RunicEnchanting.labels.enchantGloveName..";"..RunicEnchanting.labels.close)
end

function RunicEnchanting.displayRequirementsGUI(pid)
  local reservoirRequirements = RunicEnchanting.generateRequirementsString(RunicEnchanting.labels.soulReservoirName, RunicEnchanting.config.gemRecipe)
  local toolsRequirements = RunicEnchanting.generateRequirementsString(RunicEnchanting.labels.upgradeToolName, RunicEnchanting.config.toolsRecipe)
  local bookRequirements = RunicEnchanting.generateRequirementsString(RunicEnchanting.labels.bookName, RunicEnchanting.config.bookRecipe)
  tes3mp.CustomMessageBox(pid, REBGuI3, color.DarkOrange..RunicEnchanting.labels.requirements.."\n\n"..color.Default..reservoirRequirements..toolsRequirements..bookRequirements, RunicEnchanting.labels.back..";"..RunicEnchanting.labels.close)
end

function RunicEnchanting.displayReservoirGUI(pid)
  local currentAmount = ReservoirList[Players[pid].name] or 0
  local buttons = RunicEnchanting.labels.close
  if currentAmount >= 1000 then
    buttons = RunicEnchanting.labels.close..";"..RunicEnchanting.labels.extract..RunicEnchanting.labels.smallSoulMass.." (100);"..RunicEnchanting.labels.extract..RunicEnchanting.labels.largeSoulMass.." (500);"..RunicEnchanting.labels.extract..RunicEnchanting.labels.largeSoulMass.." (1000)"
  elseif currentAmount >= 500 then
    buttons = RunicEnchanting.labels.close..";"..RunicEnchanting.labels.extract..RunicEnchanting.labels.smallSoulMass.." (100);"..RunicEnchanting.labels.extract..RunicEnchanting.labels.largeSoulMass.." (500)"
  elseif currentAmount >= 100 then
    buttons = RunicEnchanting.labels.close..";"..RunicEnchanting.labels.extract..RunicEnchanting.labels.smallSoulMass.." (100)"
  end
  tes3mp.CustomMessageBox(pid, RERGuI1, color.DarkOrange..RunicEnchanting.labels.currentValue..currentAmount.."\n"..RunicEnchanting.labels.choice, buttons)
end

function RunicEnchanting.displayToolGUI(pid)
  tes3mp.CustomMessageBox(pid, REUGuI1, color.DarkOrange..RunicEnchanting.labels.toolMain, RunicEnchanting.labels.upgrade..";"..RunicEnchanting.labels.practice..";"..RunicEnchanting.labels.close)
end

function RunicEnchanting.displayUpgradeGUI(pid)
  local player = Players[pid]
  local playerInv = player.data.inventory
  local enchantableList = {}
  local enchantableListString = ""

  for i=1, #playerInv do
    local enchantableItem = false
    if playerInv[i] then
      if logicHandler.IsGeneratedRecord(playerInv[i].refId) then
        if logicHandler.GetRecordStoreByRecordId(playerInv[i].refId) then
          local tempItem = logicHandler.GetRecordStoreByRecordId(playerInv[i].refId)
          if #tempItem.data.generatedRecords then
            enchantableItem = tempItem.data.generatedRecords[playerInv[i].refId]
          elseif #tempItem.data.permanentRecords then
            enchantableItem = tempItem.data.permanentRecords[playerInv[i].refId]
          end
        end
      elseif Data.items[(playerInv[i].refId:gsub("-", "_"):gsub(" ", "_"))] then
        enchantableItem = Data.items[(playerInv[i].refId:gsub("-", "_"):gsub(" ", "_"))]
      end
      if enchantableItem then
        if enchantableItem.enchant then
          if enchantableItem.enchant > 0 then
            enchantableListString = enchantableListString..enchantableItem.name.."\n"
            enchantableList[#enchantableList + 1] = {
              refId = enchantableItem.id or enchantableItem.refId,
              index = #enchantableList + 1,
            }
          end
        end
      end
    end
  end

  UpgradeData[player.name] = enchantableList
  tes3mp.ListBox(pid, REUGuI2, RunicEnchanting.labels.upgradeChoice, enchantableListString)
end

function RunicEnchanting.OnGUIAction(eventStatus, pid, idGui, data)
  local isValid = eventStatus.validDefaultHandler
  if isValid ~= false then
    -- if idGui == REBGuI1 then
    --   if tonumber(data) == 0 then
    --     -- Craft Soul Reservoir
    --     RunicEnchanting.validateCraftGem(pid)
    --     return
    --   elseif tonumber(data) == 1 then
    --     -- Craft Rune Smiths Tools
    --     RunicEnchanting.validateCraftTool(pid)
    --     return
    --   elseif tonumber(data) == 2 then
    --     -- Craft Glove
    --     RunicEnchanting.validateCraftGlove(pid)
    --     return
    --   elseif tonumber(data) == 3 then
    --     -- Craft Book Copy
    --     RunicEnchanting.validateCraftBook(pid)
    --     return
    --   elseif tonumber(data) == 4 then
    --     -- Display Requirements Screen
    --     RunicEnchanting.displayRequirementsGUI(pid)
    --     return
    --   elseif tonumber(data) == 5 then
    --     -- Do Nothing
    --     return
    --   end
    if idGui == REBGuI1 then
      if tonumber(data) == 0 then
        -- Study the Tome
        -- Increase Enchant Skill
        RunicEnchanting.validateCraftEnchantTraining(pid)
        return
      elseif tonumber(data) == 1 then
        -- Copy the Tome
        RunicEnchanting.validateCraftBook(pid)
        return
      elseif tonumber(data) == 2 then
        -- Craft Rune Smith's Tools
        RunicEnchanting.validateCraftTool(pid)
        return
      elseif tonumber(data) == 3 then
        -- Craft Soul Reservoir
        RunicEnchanting.validateCraftGem(pid)
        return
      elseif tonumber(data) == 4 then
        -- Craft Enchanting Gear (Glove)
        RunicEnchanting.validateCraftGlove(pid)
        return
      elseif tonumber(data) == 5 then
        -- Display Requirements Screen
        RunicEnchanting.displayRequirementsGUI(pid)
        return
      elseif tonumber(data) == 6 then
        -- Do Nothing
        return
      end
    elseif idGui == REBGuI3 then
      if tonumber(data) == 0 then
        RunicEnchanting.showBookGUI(pid)
        return
      elseif tonumber(data) == 1 then
        -- Do Nothing
        return
      end
    elseif idGui == RERGuI1 then
      if tonumber(data) == 0 then
        -- Do Nothing
        return
      elseif tonumber(data) == 1 then
        local playerRef = Players[pid]
        local playerInv = playerRef.data.inventory

        inventoryHelper.addItem(playerInv, "re_soul_gem_02", 1, -1, -1, "re_creature_soul_small")

        tes3mp.ClearInventoryChanges(pid)
        tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
        tes3mp.AddItemChange(pid, "re_soul_gem_02", 1, -1, -1, "re_creature_soul_small")
        tes3mp.SendInventoryChanges(pid)

        ReservoirList[playerRef.name] = ReservoirList[playerRef.name] - 100
        RunicEnchanting.saveReservoirData()
        return
      elseif tonumber(data) == 2 then
        local playerRef = Players[pid]
        local playerInv = playerRef.data.inventory

        inventoryHelper.addItem(playerInv, "re_soul_gem_02", 1, -1, -1, "re_creature_soul_large")

        tes3mp.ClearInventoryChanges(pid)
        tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
        tes3mp.AddItemChange(pid, "re_soul_gem_02", 1, -1, -1, "re_creature_soul_large")
        tes3mp.SendInventoryChanges(pid)

        ReservoirList[playerRef.name] = ReservoirList[playerRef.name] - 500
        RunicEnchanting.saveReservoirData()
        return
      elseif tonumber(data) == 3 then
        local playerRef = Players[pid]
        local playerInv = playerRef.data.inventory

        inventoryHelper.addItem(playerInv, "re_soul_gem_02", 1, -1, -1, "re_creature_soul_divine")

        tes3mp.ClearInventoryChanges(pid)
        tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
        tes3mp.AddItemChange(pid, "re_soul_gem_02", 1, -1, -1, "re_creature_soul_divine")
        tes3mp.SendInventoryChanges(pid)

        ReservoirList[playerRef.name] = ReservoirList[playerRef.name] - 1000
        RunicEnchanting.saveReservoirData()
        return
      end
    elseif idGui == REUGuI1 then
      if tonumber(data) == 0 then
        -- show upgrade gui
        RunicEnchanting.displayUpgradeGUI(pid)
        return
      elseif tonumber(data) == 1 then
        -- show practice gui
        RunicEnchanting.displayPracticeGUI(pid)
        return
      elseif tonumber(data) == 2 then
        -- Do Nothing
        return
      end
    elseif idGui == REUGuI2 then
      if tonumber(data) < 10000 then
        local refId = UpgradeData[Players[pid].name][tonumber(data) + 1].refId
        local itemData = Data.items[(refId:gsub("-", "_"):gsub(" ", "_"))]
        local playerRef = Players[pid]
        local playerInv = playerRef.data.inventory

        local recordType
        local newRefId
        local trueRefId
        local trueName
        if itemData then
          newRefId = "re_upgraded_"..itemData.refId
          trueRefId = itemData.refId
          trueName = itemData.name
        else
          newRefId = "re_upgraded_"..refId
          trueRefId = refId
        end

        if not logicHandler.IsGeneratedRecord(newRefId) then
          if logicHandler.IsGeneratedRecord(refId) then
            recordType = logicHandler.GetRecordTypeByRecordId(refId)
            trueName = GetRecordStoreByRecordId(refId).name
          elseif itemData then
            recordType = string.lower(itemData.type)
          end

          recordStore = RecordStores[recordType]

          local recordTable = {
            baseId = refId,
            enchantmentCharge = 10000,
            name = RunicEnchanting.labels.prefix..trueName
          }

          recordStore.data.permanentRecords[newRefId] = recordTable

          recordStore:QuicksaveToDrive()
          tes3mp.ClearRecords()
          tes3mp.SetRecordType(enumerations.recordType[string.upper(recordType)])
          packetBuilder.AddRecordByType(newRefId, recordTable, recordType)
          tes3mp.SendRecordDynamic(pid, true, false)
        end

        inventoryHelper.removeItem(playerInv, trueRefId, 1, -1, -1, "")

        tes3mp.ClearInventoryChanges(pid)
        tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.REMOVE)
        tes3mp.AddItemChange(pid, trueRefId, 1, -1, -1, "")
        tes3mp.SendInventoryChanges(pid)

        inventoryHelper.addItem(playerInv, newRefId, 1, -1, -1, "")

        tes3mp.ClearInventoryChanges(pid)
        tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
        tes3mp.AddItemChange(pid, newRefId, 1, -1, -1, "")
        tes3mp.SendInventoryChanges(pid)
      end
    end
  end
end

customEventHooks.registerHandler("OnGUIAction", RunicEnchanting.OnGUIAction)



function RunicEnchanting.OnPlayerItemUseValidator(eventStatus, pid, refId)
    if refId == "re_enchant_book" then
      RunicEnchanting.showBookGUI(pid)
    elseif refId == "re_soul_gem" then
      RunicEnchanting.displayReservoirGUI(pid)
    elseif refId == "re_upgrade_tool" then
      RunicEnchanting.displayToolGUI(pid)
    end
end

customEventHooks.registerValidator("OnPlayerItemUse", RunicEnchanting.OnPlayerItemUseValidator)



function RunicEnchanting.OnActorDeath(eventStatus, pid, cellDescription, actors)
  for key, value in pairs(actors) do
    if SoulTrapList[value.uniqueIndex] then
      local player = Players[SoulTrapList[value.uniqueIndex].pid]
      local playerInv = player.data.inventory
      local alternative = false

      SoulTrapList[value.uniqueIndex] = false

      for gemKey, gemValue in pairs(Data.gems) do
        if Data.actors[value.refId] then
          if Data.actors[value.refId] <= gemValue then
            if inventoryHelper.containsItem(playerInv, gemKey, -1, -1, "") then
              alternative = true
            end
          end
        end
      end

      if not alternative and Data.actors[value.refId] then
        local indexes = inventoryHelper.getItemIndexes(playerInv, "re_soul_gem")
        if #indexes then
          if indexes[1] then
            local reservoir = playerInv[indexes[1]]
            if ReservoirList[player.name] then
              ReservoirList[player.name] = ReservoirList[player.name] + Data.actors[value.refId]
            else
              ReservoirList[player.name] = Data.actors[value.refId]
            end
            tes3mp.MessageBox(pid, RERGuI2, RunicEnchanting.labels.soulTrapMessage)
            RunicEnchanting.saveReservoirData()
          end
        end
      end
    end
  end
end

customEventHooks.registerValidator("OnActorDeath", RunicEnchanting.OnActorDeath)



function RunicEnchanting.OnActorSpellsActive(eventStatus, pid, cellDescription, actors)
  local entry

  for actorKey, actorValue in pairs(actors) do
    for sourcesKey, sourcesValue in pairs(actorValue.spellsActive) do
      for i=1, #sourcesValue do
        if sourcesValue[i].hasPlayerCaster then
          local caster = sourcesValue[i].caster
          for effectKey, effectValue in pairs(sourcesValue[i].effects) do
            if effectValue.id == 58 then
              entry = {
                startTime = sourcesValue.startTime,
                duration = effectValue.duration,
                timeLeft = effectValue.timeLeft,
                casterName = caster.playerName,
                pid = caster.pid,
                uniqueIndex = actorValue.uniqueIndex,
                spellActiveChangesAction = actorValue.spellActiveChangesAction
              }
            end
          end
        end
      end
    end
  end

  if entry and entry.spellActiveChangesAction == 1 then
    SoulTrapList[entry.uniqueIndex] = entry
  elseif entry and entry.spellActiveChangesAction == 2 then
    SoulTrapList[entry.uniqueIndex] = nil
  end
end

customEventHooks.registerValidator("OnActorSpellsActive", RunicEnchanting.OnActorSpellsActive)



return RunicEnchanting;