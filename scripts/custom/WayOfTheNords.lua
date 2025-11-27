--[[
  WayOfTheNords

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
]]--

local HiemUtils = require("custom/HiemUtils")


WayOfTheNords = {}


WayOfTheNords.labels = {
  spiritStoneName = "Spirit Stone",
  spiritPearlName = "Spirit Pearl",
  upgradeToolName = "Atmoran Chisel",
  smallSpiritPearlName = "Small Spirit Pearl",
  moderateSpiritPearlName = "Moderate Spirit Pearl",
  largeSpiritPearlName = "Large Spirit Pearl",

  smallSpiritPearlCreatureName = "Small",
  moderateSpiritPearlCreatureName = "Moderate",
  largeSpiritPearlCreatureName = "Large",

  extract = "Extract ",
  currentValue = "Current Value: ",
  close = "Close",
  back = "Back",
  choice = "What would you like to do?",

  upgrade = "Etch Runes into Items",
  practice = "Practice Etching",
  upgradeChoice = "What would you like to upgrade?",

  etchSkillFailMessage = "You are not skilled enough to etch properly",
  soulTrapMessage = "A soul has settled in the spirit stone",

  enchantRingName = "Spirit Pearl Ring",
  craftRing = "Socket Spirit Pearl"
}


WayOfTheNords.settings = {
  smallSpiritPearlValue = 100,
  moderateSpiritPearlValue = 500,
  largeSpiritPearlValue = 1000,
  trainingValues = {
    enchant = 2,
    armorer = 5
  }
}

WayOfTheNords.config = {
  toolUpgradeBreakpoints = {
    {
      clothLabel = "Stitched",
      metalLabel = "Etched",
      enchantRequirement = 30,
      enchantmentValue = 100,
      key = 'wotn_upgraded_1_'
    },
    {
      clothLabel = "Embroidered",
      metalLabel = "Carved",
      enchantRequirement = 80,
      enchantmentValue = 1000,
      key = 'wotn_upgraded_2_'
    },
    {
      clothLabel = "Inlaid",
      metalLabel = "Runic",
      enchantRequirement = 190,
      enchantmentValue = 15000,
      key = 'wotn_upgraded_3_'
    }
  },

  etchingTrainingRecipe = {
    items = {
      {
        name = {"ingred_raw_ebony_01"},
        label = "Raw Ebony",
        count = 1,
        consumed = true
      }
    },
    sounds = {
      success = "Repair"
    }
  },

  toolUpgradeRecipe = {
    items = {
      {
        name = {
          "wotn_spirit_pearl",
          "misc_soulgem_petty",
          "misc_soulgem_lesser",
          "misc_soulgem_common",
          "misc_soulgem_greater",
          "misc_soulgem_grand",
          "misc_soulgem_azura"
        },
        label = "Moderate Soul (50)",
        count = 1,
        consumed = "soul",
        additionalValidation = "soulValue",
        soulMinSize = 50
      }
    },
    sounds = {
      success = "Repair"
    }
  },

  craftRingRecipe = {
    items = {
      {
        name = {
          "common_ring_01",
          "common_ring_02",
          "common_ring_03",
          "common_ring_04",
          "common_ring_05",
          "expensive_ring_01",
          "expensive_ring_02",
          "expensive_ring_03",
          "extravagant_ring_01",
          "extravagant_ring_02",
          "exquisite_ring_01",
          "exquisite_ring_02"
        },
        label = "Ring",
        count = 1,
        consumed = true,
      },
      {
        name = {
          "wotn_spirit_stone",
        },
        label = "Spirit Stone",
        count = 1,
        consumed = false,
        additionalValidation = "spiritStoneValue"
      }
    },
    skills = {
      {
        name = "Enchant",
        value = 150
      },
    },
    sounds = {
      success = "Repair"
    }
  },
}


local SpiritStoneList
-- local Data
local SoulTrapList = {}
local UpgradeData = {}


WayOfTheNords.ids = {
  soulStoneGUI = 44332259,
  soulTrapGUI = 44332260,
  toolGUI = 44332261,
  toolUpgradeGUI = 44332262,
}


function WayOfTheNords.loadSpiritStoneData()
  SpiritStoneList = jsonInterface.load("custom/WOTNSpiritStoneList.json")
end


function WayOfTheNords.saveSpiritStoneData()
  jsonInterface.quicksave("custom/WOTNSpiritStoneList.json", SpiritStoneList)
end


function WayOfTheNords.initialseData()
  WayOfTheNords.loadSpiritStoneData()
  if not SpiritStoneList then 
    SpiritStoneList = {}
    WayOfTheNords.saveSpiritStoneData()
  end

  -- Data = jsonInterface.load("custom/HIEMDataList.json")

  HiemUtils.Data.actors["wotn_creature_soul_small"] = WayOfTheNords.settings.smallSpiritPearlValue
  HiemUtils.Data.actors["wotn_creature_soul_moderate"] = WayOfTheNords.settings.moderateSpiritPearlValue
  HiemUtils.Data.actors["wotn_creature_soul_large"] = WayOfTheNords.settings.largeSpiritPearlValue
end


function WayOfTheNords.OnServerPostInit(eventStatus)
  if not WorldInstance.data.customVariables.WOTN_Records_Initisalised then
    WayOfTheNords.createRecord()
    WorldInstance.data.customVariables.WOTN_Records_Initisalised = true
  end

  WayOfTheNords.initialseData()
end
customEventHooks.registerHandler("OnServerPostInit", WayOfTheNords.OnServerPostInit)


function WayOfTheNords.createRecord()
  local itemList = {
    {
      refId = "wotn_spirit_stone",
      name = WayOfTheNords.labels.spiritStoneName,
      mesh = "n\\Ingred_Red_Lichen_01.nif",
      icon = "n\\Tx_red_lichen_01.tga",
      weight = 1,
      value = 3000,
      script = ""
    },
    {
      refId = "wotn_spirit_pearl",
      name = WayOfTheNords.labels.spiritPearlName,
      mesh = "n\\Ingred_pearl_01.NIF",
      icon = "n\\Tx_pearl.tga",
      weight = 0.1,
      value = 0,
      script = ""
    },
    {
      refId = "wotn_upgrade_tool",
      name = WayOfTheNords.labels.upgradeToolName,
      mesh = "m\\Misc_Com_Wood_Knife.NIF",
      icon = "m\\Misc_Com_Wood_Knife.tga",
      weight = 1,
      value = 1000,
      script = ""
    },
  }
  HiemUtils.addRecords("miscellaneous", itemList)

  local bookList = {
    {
      type = "Book",
      flags = { 0, 0 },
      id = "wotn_paper_enchanting",
      weight = 1.0,
      value = 20,
      enchantmentCharge = 1000,
      name = "imbued paper",
      data = {
        weight = 1.0,
        value = 20,
        flags = 1,
        skill = "None",
        enchantment = 1000
      },
      mesh = "m\\Misc_paper_plain_01.nif",
      icon = "m\\Tx_paper_plain_01.tga"
    }
  }
  HiemUtils.addRecords("book", bookList)

  local creatureList = {
    {
      baseId = "ancestor_ghost_summon",
      refId = "wotn_creature_soul_small",
      name = WayOfTheNords.labels.smallSpiritPearlCreatureName,
      soulValue = WayOfTheNords.settings.smallSpiritPearlValue
    },
    {
      baseId = "ancestor_ghost_summon",
      refId = "wotn_creature_soul_moderate",
      name = WayOfTheNords.labels.moderateSpiritPearlCreatureName,
      soulValue = WayOfTheNords.settings.moderateSpiritPearlValue
    },
    {
      baseId = "ancestor_ghost_summon",
      refId = "wotn_creature_soul_large",
      name = WayOfTheNords.labels.largeSpiritPearlCreatureName,
      soulValue = WayOfTheNords.settings.largeSpiritPearlValue
    },
  }
  HiemUtils.addRecords("creature", creatureList)

  local npcList = {
    {
      type = "Npc",
      flags = { 0, 0 },
      id = "herra witch warrior",
      baseId = "fryfnhild",
      name = "Herra Witch-Warrior",
      mesh = "base_anim_female.nif",
      race = "Nord",
      class = "Witch",
      faction = "",
      head = "B_N_Nord_F_Head_08",
      hair = "b_n_nord_f_hair_04",
      npc_flags = 9,
      data = {
        level = 20,
        stats = {
          attributes = { 50, 30, 50, 30, 40, 50, 30, 50 },
          skills = { 5, 5, 15, 10, 15, 10, 15, 10, 5, 80, 10, 20, 35, 35, 35, 10, 50, 35, 5, 15, 15, 15, 30, 5, 60, 15, 5 },
          health = 50,
          magicka = 60,
          fatigue = 180
        },
        disposition = 50,
        reputation = 0,
        rank = 0,
        gold = 0
      },
      inventory = {
        { 1, "BM_NordicMail_gauntletL" },
        { 1, "BM_NordicMail_gauntletR" },
        { 1, "BM_NordicMail_PauldronL" },
        { 1, "BM_NordicMail_PauldronR" },
        { 1, "expensive_robe_02_a" },
        { 1, "expensive_shoes_02" },
        { 1, "expensive_skirt_01" },
        { -1, "Misc_Inkwell" },
        { -1, "Misc_Quill" },
        { -5, "Misc_SoulGem_Common" },
        { -5, "Misc_SoulGem_Grand" },
        { -5, "Misc_SoulGem_Greater" },
        { -5, "Misc_SoulGem_Lesser" },
        { -5, "Misc_SoulGem_Petty" },
        { -20, "sc_paper plain" },
        { -10, "wotn_paper_enchanting" },
        { -1, "wotn_spirit_stone" },
        { -1, "wotn_upgrade_tool" },
      },
      spells = {
        "holy word",
        "turn undead",
        "frenzy creature",
        "frenzy humanoid",
        "demoralize creature",
        "demoralize humanoid",
        "father's hand",
        "noise",
        "detect enchantment",
        "tevral's hawkshaw",
        "almalexia's grace",
        "blindself"
      },
      ai_data = {
        hello = 30,
        fight = 30,
        flee = 30,
        alarm = 0,
        services = 113951
      },
      ai_packages = { },
      travel_destinations = { }
    }
  }
  HiemUtils.addRecords("npc", npcList)

  local scriptList = {
    {
      refId = "wotn_herra_house_entrance_script",
      scriptText = "Begin wotn_herra_house_entrance_script\nIf ( OnActivate == 1 )\n    Player->PositionCell, 140.000, -208.000, -152.686, 318.9, \"Herra's Rune Workshop\"\n    Player->PlaySoundVP, \"Door Latched Two Open\" 1 1\nEndif\nEnd wotn_herra_house_entrance_script"
    },
    {
      refId = "wotn_herra_house_exit_script",
      scriptText = "Begin wotn_herra_house_exit_script\nIf ( OnActivate == 1 )\n    Player->PositionCell, -178618.109, 156824.125, 894.873, 160.0, \"-22, 19\"\n    Player->PlaySoundVP, \"Door Latched Two Open\" 1 1\nEndif\nEnd wotn_herra_house_exit_script"
    }
  }
  HiemUtils.addRecords("script", scriptList)

  local activatorList = {
    {
      refId = "wotn_herra_house_entrance",
      name = "Herra's Rune Workshop",
      model =  "d\\Ex_S_door.NIF",
      script = "wotn_herra_house_entrance_script"
    },
    {
      refId = "wotn_herra_house_exit",
      name = "Solstheim",
      model =  "d\\In_S_door.NIF",
      script = "wotn_herra_house_exit_script"
    }
  }
  HiemUtils.addRecords("activator", activatorList)

  local cellList = {
    {
      type = "Cell",
      flags = { 0, 0 },
      id = "Herra's Rune Workshop",
      baseId = "Skaal Village, Shaman's Hut",
      data = {
        flags = 5,
        grid = {
          3223332,
          1061997773
        }
      },
      water_height = 0.0,
      atmosphere_data = {
        ambient_color = {
          50,
          50,
          40,
          0
        },
        sunlight_color = {
          80,
          60,
          40,
          0
        },
        fog_color = {
          36,
          47,
          49,
          0
        },
        fog_density = 0.8,
      },
      itemsToRemove = {
        {
            index = 11561,
            refId = "korst wind-eye"
        },
        {
            index = 11798,
            refId = "In_S_door"
        }
      },
      references = {
        {
          mast_index = 0,
          refr_index = 2,
          id = "herra witch warrior",
          temporary = false,
          translation = {
            28.519083,
            -80.00934,
            -215.55405
          },
          rotation = {
            0.0,
            0.0,
            0.0
          }
        },
        {
          id = "wotn_herra_house_exit",
          translation = {
            220.000,
            -250.000,
            -150.000
          },
          rotation = {
            0.0,
            0.0,
            5.682816
          },
          scale = 1.1500001
        }
      }
    }
  }

  HiemUtils.addRecords("cell", cellList)

  for i=1, #cellList do
    local item = cellList[i]
    HiemUtils.populateCell(item)
  end

  local objectList = {
    {
      id = "-22, 19",
      references = {
        {
          id = "chimney_smoke_small",
          translation = {
            -178887.64,
            157850.4,
            1721.0592
          },
          rotation = {
            0.0,
            0.0,
            3.7831879
          },
          scale = 1.4000001
        },
        {

          id = "ex_nord_chimney_01",
          translation = {
            -178893.11,
            157846.33,
            1678.0365
          },
          rotation = {
            0.0,
            0.0,
            4.483187
          },
          scale = 1.4000001
        },
        {
          id = "ex_snow_roof",
          translation = {
            -178767.55,
            157483.48,
            1605.5968
          },
          rotation = {
            0.0,
            0.0,
            5.983186
          },
          scale = 0.96000004
        },
        {
          id = "ex_S_wolf",
          translation = {
            -178664.67,
            156981.98,
            1678.8915
          },
          rotation = {
            0.0,
            0.0,
            2.8000002
          }
        },
        {
          id = "Ex_S_Longhouse_red02",
          translation = {
            -178787.84,
            157450.92,
            1401.9037
          },
          rotation = {
            0.0,
            0.0,
            2.8710666
          }
        },
        {
          id = "ex_S_window_closed",
          translation = {
            -178487.05,
            157026.77,
            1102.8087
          },
          rotation = {
            0.0,
            0.0,
            2.8710666
          }
        },
        {
          id = "ex_S_window_closed",
          translation = {
            -178838.27,
            156926.42,
            1102.8087
          },
          rotation = {
            0.0,
            0.0,
            2.8710666
          }
        },
        {
          id = "ex_snow_ledge",
          translation = {
            -178826.98,
            156907.8,
            1021.9672
          },
          rotation = {
            0.0,
            0.0,
            1.3000002
          },
          scale = 0.65000004
        },
        {
          id = "wotn_herra_house_entrance",
          translation = {
            -178598.52,
            156964.08,
            1000.0417
          },
          rotation = {
            0.0,
            0.0,
            2.7925267
          },
          scale = 1.1
        },
        {
          id = "ex_snow_roof",
          translation = {
            -178930.98,
            157866.06,
            894.787
          },
          rotation = {
            0.0,
            0.0,
            4.363323
          },
          scale = 0.96000004
        },
        {
          id = "ex_snow_roof",
          translation = {
            -179145.3,
            157480.78,
            892.0418
          },
          rotation = {
            0.0,
            0.0,
            3.1415927
          },
          scale = 0.96000004
        },
      }
    },
  }
  for i=1, #objectList do
    local item = objectList[i]
    HiemUtils.populateCell(item)
  end
end


-- Crafting

function WayOfTheNords.validateCraftEtchingTraining(pid)
  local reqs = WayOfTheNords.config.etchingTrainingRecipe
  HiemUtils.validateCraft(pid, reqs, false, false, WayOfTheNords.trainEtchingPractice)
end

function WayOfTheNords.trainEtchingPractice(pid)
  HiemUtils.increaseSkill(pid, 'Armorer', 'Strength', WayOfTheNords.settings.trainingValues.armorer)
  HiemUtils.increaseSkill(pid, 'Enchant', 'Intelligence', WayOfTheNords.settings.trainingValues.enchant)
end

function WayOfTheNords.validateUpgradeArmor(pid, itemId)
  local reqs = WayOfTheNords.config.toolUpgradeRecipe
  HiemUtils.validateCraft(pid, reqs, itemId, false, WayOfTheNords.upgradeItem)
end

function WayOfTheNords.upgradeItem(pid, refId, reqs)
  local itemData = HiemUtils.Data.items[(refId:gsub("-", "_"):gsub(" ", "_"))]
  local playerRef = Players[pid]
  local playerInv = playerRef.data.inventory

  local breakpoint = HiemUtils.getSkillBreakpoint(pid, 'Enchant', WayOfTheNords.config.toolUpgradeBreakpoints, 'enchantRequirement')

  if breakpoint then
    if not itemData and logicHandler.GetRecordStoreByRecordId(refId) then
      local data = logicHandler.GetRecordStoreByRecordId(refId)

      if data.data then
        if data.data.generatedRecords and data.data.generatedRecords[refId] then
          data = data.data.generatedRecords[refId]
        elseif data.data.permanentRecords and data.data.permanentRecords[refId] then
          data = data.data.permanentRecords[refId]
        end
      end

      local type = logicHandler.GetRecordTypeByRecordId(refId)

      if data.baseId then
        local baseData = logicHandler.GetRecordStoreByRecordId(data.baseId)
        if baseData then
          if baseData.data.generatedRecords and data.data.generatedRecords[refId] then
            baseData = baseData.data.generatedRecords[refId]
          elseif data.data.permanentRecords and data.data.permanentRecords[refId] then
            baseData = baseData.data.permanentRecords[refId]
          end
        else
          baseData = HiemUtils.Data.items[(data.baseId:gsub("-", "_"):gsub(" ", "_"))]
        end

        itemData = {
          type = type,
          refId = data.baseId,
          trueRefId = data.refId,
          name = baseData.name,
          enchantmentCharge = data.enchantmentCharge
        }
      else
        itemData = {
          type = type,
          refId = data.refId,
          name = data.name,
          enchantmentCharge = data.enchantmentCharge
        }
      end

      if reqs.sounds then
        if reqs.sounds.success then
          HiemUtils.playSound(pid, reqs.sounds.success)
        end
      end
    end

    local prefix = breakpoint.metalLabel
    if itemData.type == 'clothing' then
      prefix = breakpoint.clothLabel
    end

    local newRefId = breakpoint.key..itemData.refId

    if not logicHandler.GetRecordStoreByRecordId(newRefId) then
      local recordType = string.lower(itemData.type)
      recordStore = RecordStores[recordType]

      local recordTable = {
        baseId = itemData.refId,
        enchantmentCharge = breakpoint.enchantmentValue,
        name = prefix..' '..itemData.name,
        refId = newRefId
      }

      recordStore.data.permanentRecords[newRefId] = recordTable

      recordStore:Save()
      recordStore:QuicksaveToDrive()
      tes3mp.ClearRecords()
      tes3mp.SetRecordType(enumerations.recordType[string.upper(recordType)])
      packetBuilder.AddRecordByType(newRefId, recordTable, recordType)
      tes3mp.SendRecordDynamic(pid, true, false)
    end

    local trueRefId = itemData.refId
    if itemData.trueRefId then
      trueRefId = itemData.trueRefId
    end


    local itemsToRemove = {{refId = trueRefId, count = 1, charge = -1, enchantmentCharge = -1, soul = ""}}
    HiemUtils.removePlayerItems(pid, itemsToRemove)

    local itemsToAdd = {{refId = newRefId, count = 1, charge = -1, enchantmentCharge = -1, soul = ""}}
    HiemUtils.addPlayerItems(pid, itemsToAdd)
  else
    tes3mp.MessageBox(pid, WayOfTheNords.ids.toolUpgradeGUI, WayOfTheNords.labels.etchSkillFailMessage)
  end
end

function WayOfTheNords.validateCreateRing(pid)
  local reqs = WayOfTheNords.config.craftRingRecipe
  HiemUtils.validateCraft(pid, reqs, false, false, WayOfTheNords.craftRing)
end

function WayOfTheNords.craftRing(pid, refId, reqs)
  local enchantValue = SpiritStoneList[Players[pid].name]
  SpiritStoneList[Players[pid].name] = 0
  WayOfTheNords.saveSpiritStoneData()

  local enchantList = {
    {
      refId = "wotn_ring_enchant_"..enchantValue,
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
          magnitudeMax = enchantValue,
          magnitudeMin = enchantValue
        }
      }
    }
  }
  HiemUtils.addRecords("enchantment", enchantList, true)
  tes3mp.SendRecordDynamic(pid, true, false)

  -- clothing
  local clothingList = {
    {
      refId = "wotn_ring_"..enchantValue,
      baseId = "expensive_ring_03",
      name = WayOfTheNords.labels.enchantRingName,
      enchantmentId = "wotn_ring_enchant_"..enchantValue
    }
  }

  HiemUtils.addRecords("clothing", clothingList, true)
  tes3mp.SendRecordDynamic(pid, true, false)

  local itemsToAdd = {{refId = "wotn_ring_"..enchantValue, count = 1, charge = -1, enchantmentCharge = -1, soul = ""}}
  HiemUtils.addPlayerItems(pid, itemsToAdd)
end

function HiemUtils.validators.spiritStoneValue(item, req, pid)
  if SpiritStoneList[Players[pid].name] and SpiritStoneList[Players[pid].name] > 0 then
    return true
  end

  return false
end

-- GUI

function WayOfTheNords.displaySpiritStoneGUI(pid)
  local currentAmount = SpiritStoneList[Players[pid].name] or 0
  local buttons = WayOfTheNords.labels.close
  if currentAmount >= 1000 then
    buttons = WayOfTheNords.labels.close..";"..WayOfTheNords.labels.extract..WayOfTheNords.labels.smallSpiritPearlName.." ("..WayOfTheNords.settings.smallSpiritPearlValue..");"..WayOfTheNords.labels.extract..WayOfTheNords.labels.moderateSpiritPearlName.." ("..WayOfTheNords.settings.moderateSpiritPearlValue..");"..WayOfTheNords.labels.extract..WayOfTheNords.labels.largeSpiritPearlName.." ("..WayOfTheNords.settings.largeSpiritPearlValue..")"
  elseif currentAmount >= 500 then
    buttons = WayOfTheNords.labels.close..";"..WayOfTheNords.labels.extract..WayOfTheNords.labels.smallSpiritPearlName.." ("..WayOfTheNords.settings.smallSpiritPearlValue..");"..WayOfTheNords.labels.extract..WayOfTheNords.labels.moderateSpiritPearlName.." ("..WayOfTheNords.settings.moderateSpiritPearlValue..")"
  elseif currentAmount >= 100 then
    buttons = WayOfTheNords.labels.close..";"..WayOfTheNords.labels.extract..WayOfTheNords.labels.smallSpiritPearlName.." ("..WayOfTheNords.settings.smallSpiritPearlValue..")"
  end
  tes3mp.CustomMessageBox(pid, WayOfTheNords.ids.soulStoneGUI, color.DarkOrange..WayOfTheNords.labels.currentValue..currentAmount.."\n"..WayOfTheNords.labels.choice, buttons)
end


function WayOfTheNords.displayToolGUI(pid)
  tes3mp.CustomMessageBox(pid, WayOfTheNords.ids.toolGUI, color.DarkOrange..WayOfTheNords.labels.choice, WayOfTheNords.labels.upgrade..";"..WayOfTheNords.labels.practice..";"..WayOfTheNords.labels.craftRing..";"..WayOfTheNords.labels.close)
end


function WayOfTheNords.displayUpgradeGUI(pid)
  local player = Players[pid]
  local playerInv = player.data.inventory
  local enchantableList = {}
  local enchantableListString = ""

  local breakpoint = HiemUtils.getSkillBreakpoint(pid, 'Enchant', WayOfTheNords.config.toolUpgradeBreakpoints, 'enchantRequirement')
  if breakpoint then
    for i=1, #playerInv do
      local enchantableItem = false
      if playerInv[i] then
        if logicHandler.GetRecordStoreByRecordId(playerInv[i].refId) then
          local tempItem = logicHandler.GetRecordStoreByRecordId(playerInv[i].refId)
          if #tempItem.data.generatedRecords and tempItem.data.generatedRecords[playerInv[i].refId] then
            enchantableItem = tempItem.data.generatedRecords[playerInv[i].refId]
          end
          if #tempItem.data.permanentRecords and tempItem.data.permanentRecords[playerInv[i].refId] then
            enchantableItem = tempItem.data.permanentRecords[playerInv[i].refId]
          end
        elseif HiemUtils.Data.items[(playerInv[i].refId:gsub("-", "_"):gsub(" ", "_"))] then
          enchantableItem = HiemUtils.Data.items[(playerInv[i].refId:gsub("-", "_"):gsub(" ", "_"))]
        end
        if enchantableItem then
          if enchantableItem.enchantmentCharge and not enchantableItem.enchantmentId then
            if enchantableItem.enchantmentCharge > 0 and enchantableItem.enchantmentCharge < breakpoint.enchantmentValue then
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
    tes3mp.ListBox(pid, WayOfTheNords.ids.toolUpgradeGUI, WayOfTheNords.labels.upgradeChoice, enchantableListString)
  else
    tes3mp.MessageBox(pid, WayOfTheNords.ids.toolGUI, WayOfTheNords.labels.etchSkillFailMessage)
  end
end


-- Item Actions

function WayOfTheNords.OnSoulStoneInteraction(data, pid)
  if tonumber(data) == 0 then
    -- Do Nothing
    return
  elseif tonumber(data) == 1 then
    local playerRef = Players[pid]
    local playerInv = playerRef.data.inventory

    local itemsToAdd = {{refId = "wotn_spirit_pearl", count = 1, charge = -1, enchantmentCharge = -1, soul = "wotn_creature_soul_small"}}
    HiemUtils.addPlayerItems(pid, itemsToAdd)

    SpiritStoneList[playerRef.name] = SpiritStoneList[playerRef.name] - 100
    WayOfTheNords.saveSpiritStoneData()
    return
  elseif tonumber(data) == 2 then
    local playerRef = Players[pid]
    local playerInv = playerRef.data.inventory

    local itemsToAdd = {{refId = "wotn_spirit_pearl", count = 1, charge = -1, enchantmentCharge = -1, soul = "wotn_creature_soul_moderate"}}
    HiemUtils.addPlayerItems(pid, itemsToAdd)

    SpiritStoneList[playerRef.name] = SpiritStoneList[playerRef.name] - 500
    WayOfTheNords.saveSpiritStoneData()
    return
  elseif tonumber(data) == 3 then
    local playerRef = Players[pid]
    local playerInv = playerRef.data.inventory

    local itemsToAdd = {{refId = "wotn_spirit_pearl", count = 1, charge = -1, enchantmentCharge = -1, soul = "wotn_creature_soul_large"}}
    HiemUtils.addPlayerItems(pid, itemsToAdd)

    SpiritStoneList[playerRef.name] = SpiritStoneList[playerRef.name] - 1000
    WayOfTheNords.saveSpiritStoneData()
    return
  end
end


function WayOfTheNords.OnToolInteraction(data, pid)
  if tonumber(data) == 0 then
    -- show upgrade gui
    WayOfTheNords.displayUpgradeGUI(pid)
    return
  elseif tonumber(data) == 1 then
    -- show practice gui
    WayOfTheNords.validateCraftEtchingTraining(pid)
    return
  elseif tonumber(data) == 2 then
    -- Do Nothing
    WayOfTheNords.validateCreateRing(pid)
    return
  elseif tonumber(data) == 3 then
    -- Do Nothing
    return
  end
end


function WayOfTheNords.OnToolUpgradeInteraction(data, pid)
  if tonumber(data) < 10000 then
    local refId = UpgradeData[Players[pid].name][tonumber(data) + 1].refId
    WayOfTheNords.validateUpgradeArmor(pid, refId)
  end
end


-- Hooks

function WayOfTheNords.OnGUIAction(eventStatus, pid, idGui, data)
  local isValid = eventStatus.validDefaultHandler
  if isValid ~= false then
    if idGui == WayOfTheNords.ids.soulStoneGUI then
      WayOfTheNords.OnSoulStoneInteraction(data, pid)
    elseif idGui == WayOfTheNords.ids.toolGUI then
      WayOfTheNords.OnToolInteraction(data, pid)
    elseif idGui == WayOfTheNords.ids.toolUpgradeGUI then
      WayOfTheNords.OnToolUpgradeInteraction(data, pid)
    end
  end
end
customEventHooks.registerHandler("OnGUIAction", WayOfTheNords.OnGUIAction)

function WayOfTheNords.OnActorDeath(eventStatus, pid, cellDescription, actors)
  for key, value in pairs(actors) do
    if SoulTrapList[value.uniqueIndex] then
      local player = Players[SoulTrapList[value.uniqueIndex].pid]
      local playerInv = player.data.inventory
      local alternative = false

      SoulTrapList[value.uniqueIndex] = false

      for gemKey, gemValue in pairs(HiemUtils.Data.gems) do
        if HiemUtils.Data.actors[value.refId] then
          if tonumber(HiemUtils.Data.actors[value.refId]) <= tonumber(gemValue) then
            if inventoryHelper.containsItem(playerInv, gemKey, -1, -1, "") then
              alternative = true
            end
          end
        end
      end

      if not alternative and HiemUtils.Data.actors[value.refId] then
        local indexes = inventoryHelper.getItemIndexes(playerInv, "wotn_spirit_stone")
        if #indexes then
          if indexes[1] then
            local spiritStone = playerInv[indexes[1]]
            if SpiritStoneList[player.name] then
              SpiritStoneList[player.name] = SpiritStoneList[player.name] + HiemUtils.Data.actors[value.refId]
            else
              SpiritStoneList[player.name] = HiemUtils.Data.actors[value.refId]
            end
            tes3mp.MessageBox(pid, WayOfTheNords.ids.soulTrapGUI, WayOfTheNords.labels.soulTrapMessage)
            WayOfTheNords.saveSpiritStoneData()
          end
        end
      end
    end
  end
end
customEventHooks.registerValidator("OnActorDeath", WayOfTheNords.OnActorDeath)


function WayOfTheNords.OnActorSpellsActive(eventStatus, pid, cellDescription, actors)
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
customEventHooks.registerValidator("OnActorSpellsActive", WayOfTheNords.OnActorSpellsActive)


function WayOfTheNords.OnPlayerItemUseValidator(eventStatus, pid, refId)
    if refId == "wotn_spirit_stone" then
      WayOfTheNords.displaySpiritStoneGUI(pid)
    elseif refId == "wotn_upgrade_tool" then
      WayOfTheNords.displayToolGUI(pid)
    end
end
customEventHooks.registerValidator("OnPlayerItemUse", WayOfTheNords.OnPlayerItemUseValidator)


