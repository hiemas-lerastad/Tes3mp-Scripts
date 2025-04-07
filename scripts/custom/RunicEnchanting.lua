local HiemUtils = require("custom/HiemUtils")

RunicEnchanting = {}

RunicEnchanting.config = {
  -- Recipe to train enchanting (study)
  enchantTrainingRecipe = {
    items = {
      {
        name = {"misc_inkwell"},
        label = "Inkwell",
        count = 1,
        consumed = false
      },
      {
        name = {"misc_quill"},
        label = "Quill Pen",
        count = 1,
        consumed = false
      },
      {
        name = {"sc_paper plain"},
        label = "Paper",
        count = 1,
        consumed = true
      },
      {
        name = {
          "Soul_Gem",
          "re_soul_gem_02",
          "misc_soulgem_petty",
          "misc_soulgem_lesser",
          "misc_soulgem_common",
          "misc_soulgem_greater",
          "misc_soulgem_grand",
          "misc_soulgem_azura"
        },
        label = "Tiny Soul (15)",
        count = 1,
        soulMinSize = 15,
        consumed = "soul",
        additionalValidation = "soulValue"
      },
    },
    sounds = {
      success = "book open"
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
        name = {
          "sc_paper plain"
        },
        label = "Paper",
        count = 5,
        consumed = true
      }
    },
    sounds = {
      success = "book open"
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
        name = {"misc_soulgem_grand"},
        label = "Grand Soul Gem",
        count = 1,
        consumed = true
      }
    },
    sounds = {
      success = "potion fail"
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
        name = {"repair_prongs"},
        label = "Repair Prongs",
        count = 1,
        consumed = true
      },
      {
        name = {"hammer_repair"},
        label = "Apprentice's Armorer's Hammer",
        count = 1,
        consumed = true
      },
      {
        name = {
          "re_soul_gem_02",
          "misc_soulgem_petty",
          "misc_soulgem_lesser",
          "misc_soulgem_common",
          "misc_soulgem_greater",
          "misc_soulgem_grand",
          "misc_soulgem_azura"
        },
        label = "Tiny Soul (15)",
        count = 1,
        consumed = "soul",
        additionalValidation = "soulValue",
        soulMinSize = 15
      },
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

  gloveRecipe = {
    skills = {
      {
        name = "Enchant",
        value = 100
      },
    },
    items = {
      {
        name = {"extravagant_glove_right_01"},
        label = "Extravagant Right Glove",
        count = 1,
        consumed = true
      }
    }
  },

  armorerTrainingRecipe = {
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
        name = {"ingred_raw_ebony_01"},
        label = "Raw Ebony",
        count = 1,
        consumed = true
      },
      {
        name = {
          "re_soul_gem_02",
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

  toolUpgradeBreakpoints = {
    {
      clothLabel = "Stitched",
      metalLabel = "Etched",
      enchantRequirement = 30,
      enchantmentValue = 100,
      key = 're_upgraded_1_'
    },
    {
      clothLabel = "Embroidered",
      metalLabel = "Carved",
      enchantRequirement = 80,
      enchantmentValue = 1000,
      key = 're_upgraded_2_'
    },
    {
      clothLabel = "Inlaid",
      metalLabel = "Runic",
      enchantRequirement = 190,
      enchantmentValue = 10000,
      key = 're_upgraded_3_'
    }
  }
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
  requirements = "Crafting Requirements",
  requirementsError = "Requirements to craft not met",
  extract = "Extract ",
  currentValue = "Current Value: ",
  choice = "What would you like to do?",
  upgradeChoice = "What would you like to upgrade?",
  soulTrapMessage = "A soul has found purchase in a reservoir",
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
          magnitudeMax = 35000,
          magnitudeMin = 35000
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

  recordStore = RecordStores['cell']
  local cellList = {
    {
      type = "Cell",
      flags = { 0, 0 },
      id = "Reenum-Kur's Enchanting Shop",
      baseId = "Balmora, Guild of Mages",
      data = {
        flags = 1,
        grid = { 3747360, 1061158912 }
      },
      water_height = 0.0,
      atmosphereData = {
        ambientColor = {
          75,
          65,
          65,
          0
        },
        sunlightColor = {
          80,
          60,
          20,
          0
        },
        fogColor = {
          30,
          32,
          32,
          0
        },
        fogDensity = 0.75
      },
      itemsToRemove = {
        41910,
        41912,
        56847,
        67615,
        67616,
        67617,
        67618,
        67619,
        67620,
        67621,
        390613,
        470832,
        41881,
        41882,
        41885,
        41888,
        41890,
        41892,
        41893,
        41894,
        41895,
        41896,
        41897,
        41899,
        41900,
        41901,
        41902,
        41903,
        41905,
        41906,
        41907,
        41908,
        41914,
        41916,
        41917,
        41919,
        41920,
        56829,
        56832,
        56833,
        56834,
        56835,
        56836,
        56838,
        56840,
        56841,
        56842,
        56843,
        56844,
        56848,
        56849,
        56850,
        56852,
        56853,
        56854,
        56856,
        56857,
        56858,
        56859,
        56860,
        56861,
        56862,
        56865,
        56866,
        56867,
        56868,
        56869,
        56870,
        56871,
        56872,
        56873,
        56874,
        56875,
        56876,
        56877,
        56878,
        56879,
        56881,
        56884,
        56885,
        56886,
        56887,
        56888,
        56889,
        56890,
        56891,
        56892,
        56893,
        56894,
        56895,
        56896,
        56897,
        56898,
        56899,
        56908,
        56909,
        56911,
        56913,
        56914,
        56915,
        56916,
        56917,
        56919,
        56920,
        56921,
        56922,
        56923,
        56924,
        56925,
        56926,
        56927,
        56928,
        56929,
        56930,
        56931,
        56932,
        56933,
        56934,
        56935,
        56936,
        56937,
        56938,
        56939,
        56940,
        56941,
        56942,
        56943,
        56944,
        56945,
        56946,
        56947,
        56948,
        56949,
        56950,
        56954,
        56955,
        56956,
        56958,
        56959,
        56960,
        56961,
        56962,
        56963,
        56964,
        56965,
        56966,
        56967,
        56968,
        56969,
        56970,
        56971,
        56972,
        56973,
        56975,
        56976,
        56977,
        56978,
        56979,
        56980,
        56981,
        56982,
        56983,
        56984,
        56985,
        56986,
        56987,
        56988,
        56989,
        56990,
        56991,
        56992,
        56993,
        56994,
        56995,
        56996,
        56997,
        56998,
        56999,
        57000,
        57001,
        57002,
        57003,
        57004,
        57005,
        57006,
        57007,
        57008,
        57009,
        57010,
        57011,
        57012,
        57013,
        57014,
        57015,
        57016,
        57017,
        57018,
        57019,
        57020,
        57021,
        57022,
        57024,
        64193,
        86807,
        290469,
        290470,
        290471,
        290472,
        290473,
        310763,
        310764,
        310765,
        310766,
        310767,
        310768,
        310769,
        310770,
        310771,
        310772,
        332053,
        332054,
        378320,
        378321,
        378322,
        378323,
        378324,
        378325,
        378326,
        378327,
        378328,
        378329,
        378330,
        378331,
        378332,
        378333,
        378334,
        378335,
        378336,
        378338,
        378339,
        378340,
        378341,
        378342,
        378343,
        378344,
        378345,
        390615,
        390616,
        391124,
        460130,
        466173,
        466174,
        466175,
        466176,
        466177,
        466178,
        466179,
        466180,
        466181,
        466182,
        466183,
        469364,
        477571,
        478738,
        478739,
        478740,
        478741,
        478742,
        478743,
        478744,
        478745,
        478746,
        478747,
        478748,
        478749,
        478750,
        478751,
        478752,
        478753,
        478754,
        478755,
        478756,
        478757,
        478758,
        478759,
        478760,
        478761,
        478762,
        478763,
        478764,
        478765,
        478766,
        478767,
        480244,
        480245,
        480246,
        480247,
        480248,
        480249,
        480250,
        480251,
        480252,
        481297,
        481298,
        481299,
        483333,
        483334,
        483335,
        483336
      },
      references = {
        {
          mast_index = 0,
          refr_index = 1,
          id = "in_hlaalu_room_corner",
          temporary = true,
          translation = { 0.0, 510.0, 0.0 },
          rotation = { 0.0, 0.0, 1.5707964 }
        },
        {
          mast_index = 0,
          refr_index = 2,
          id = "in_hlaalu_room_corner",
          temporary = true,
          translation = { 255.0, 0.0, 0.0 },
          rotation = { 0.0, 0.0, -1.5707964 }
        },
        {
          mast_index = 0,
          refr_index = 3,
          id = "in_hlaalu_room_corner",
          temporary = true,
          translation = { 0.0, 0.0, 0.0 },
          rotation = { 0.0, 0.0, 0.0 }
        },
        {
          mast_index = 0,
          refr_index = 4,
          id = "in_hlaalu_room_corner",
          temporary = true,
          translation = { 255.0, 510.0, 0.0 },
          rotation = { 0.0, 0.0, 3.1415927 }
        },
        {
          mast_index = 0,
          refr_index = 5,
          id = "in_hlaalu_room_side",
          temporary = true,
          translation = { 0.0, 255.0, 0.0 },
          rotation = { 0.0, 0.0, -1.5707964 }
        },
        {
          mast_index = 0,
          refr_index = 6,
          id = "in_hlaalu_room_side",
          temporary = true,
          translation = { 255.0, 255.0, 0.0 },
          rotation = { 0.0, 0.0, 1.5707964 }
        },
        {
          mast_index = 0,
          refr_index = 7,
          id = "Furn_Com_RM_Bar_02",
          temporary = true,
          translation = { 90.0, 90.0, -90.0 },
          rotation = { 0.0, 0.0, 0.0 }
        },
        {
          mast_index = 0,
          refr_index = 8,
          id = "Furn_Com_RM_Bar_02",
          temporary = true,
          translation = { 90.0, 218.0, -90.0 },
          rotation = { 0.0, 0.0, 3.1415927 }
        },
        {
          mast_index = 0,
          refr_index = 9,
          id = "Furn_Com_RM_Bar_01",
          temporary = true,
          translation = { 90.0, 154.0, -90.0 },
          rotation = { 0.0, 0.0, 1.5707964 }
        }
      }
    }
  }

  for i=1, #cellList do
    local item = cellList[i]
    recordStore.data.permanentRecords[item.id] = item;
  end
  recordStore:Save()

  for i=1, #cellList do
    local item = cellList[i]
    HiemUtils.populateCell(item)
  end
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
  -- if not WorldInstance.data.customVariables.RE_Records_Initisalised then
  if true then
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
  HiemUtils.validateCraft(pid, reqs, false, false, RunicEnchanting.trainEnchantStudy)
end

function RunicEnchanting.trainEnchantStudy(pid, refId, reqs)
  HiemUtils.increaseSkill(pid, 'Enchant', 'Intelligence', 10)
end

-- Craft Book Copy
function RunicEnchanting.validateCraftBook(pid)
  local reqs = RunicEnchanting.config.bookRecipe
  HiemUtils.validateCraft(pid, reqs, "re_enchant_book")
end

-- Craft Soul Reservior
function RunicEnchanting.validateCraftGem(pid)
  local reqs =  RunicEnchanting.config.gemRecipe
  HiemUtils.validateCraft(pid, reqs, "re_soul_gem", true)
end

-- Craft Rune Smith's Tools
function RunicEnchanting.validateCraftTool(pid)
  local reqs = RunicEnchanting.config.toolsRecipe
  HiemUtils.validateCraft(pid, reqs, "re_upgrade_tool")
end

-- Craft Enchanters Gear (Undecided)
function RunicEnchanting.validateCraftGlove(pid)
  local reqs = RunicEnchanting.config.gloveRecipe
  HiemUtils.validateCraft(pid, reqs, "re_enchant_gloves")
end

-- Upgrade Armor (Rune Smith's Tools)
function RunicEnchanting.validateUpgradeArmor(pid, itemId)
  local reqs = RunicEnchanting.config.toolUpgradeRecipe
  HiemUtils.validateCraft(pid, reqs, itemId, false, RunicEnchanting.upgradeItem)
end

function RunicEnchanting.upgradeItem(pid, refId)
  local itemData = Data.items[(refId:gsub("-", "_"):gsub(" ", "_"))]
  local playerRef = Players[pid]
  local playerInv = playerRef.data.inventory

  local breakpoint = HiemUtils.getBreakpoint(pid, 'Enchant', RunicEnchanting.config.toolUpgradeBreakpoints, 'enchantRequirement')

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
        baseData = Data.items[(data.baseId:gsub("-", "_"):gsub(" ", "_"))]
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
  HiemUtils.addPlayerItems(pid, itemsToAdd)

  -- inventoryHelper.removeItem(playerInv, trueRefId, 1, -1, -1, "")

  -- tes3mp.ClearInventoryChanges(pid)
  -- tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.REMOVE)
  -- tes3mp.AddItemChange(pid, trueRefId, 1, -1, -1, "")
  -- tes3mp.SendInventoryChanges(pid)



  local itemsToAdd = {{refId = newRefId, count = 1, charge = -1, enchantmentCharge = -1, soul = ""}}
  HiemUtils.addPlayerItems(pid, itemsToAdd)

  -- inventoryHelper.addItem(playerInv, newRefId, 1, -1, -1, "")

  -- tes3mp.ClearInventoryChanges(pid)
  -- tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
  -- tes3mp.AddItemChange(pid, newRefId, 1, -1, -1, "")
  -- tes3mp.SendInventoryChanges(pid)

  -- local recordType
  -- local newRefId
  -- local trueRefId
  -- local trueName

  -- if itemData then
  --   newRefId = breakpoint.key..itemData.refId
  --   trueRefId = itemData.refId
  --   trueName = itemData.name
  -- else
  --   newRefId = breakpoint.key..refId
  --   trueRefId = refId
  -- end


  -- if logicHandler.GetRecordStoreByRecordId(refId) then
  --   recordType = logicHandler.GetRecordTypeByRecordId(refId)
  --   local recordData = logicHandler.GetRecordStoreByRecordId(refId)
  --   if recordData and recordData.baseId then
  --     trueName = 
  --   end
  -- elseif itemData then
  --   recordType = string.lower(itemData.type)
  -- end

  -- recordStore = RecordStores[recordType]

  -- local prefix = breakpoint.metalLabel
  -- if recordType == 'clothing' then
  --   prefix = breakpoint.clothLabel
  -- end

  -- local recordTable = {
  --   baseId = refId,
  --   enchantmentCharge = breakpoint.enchantmentValue,
  --   name = prefix..' '..trueName,
  --   refId = newRefId
  -- }

  -- recordStore.data.permanentRecords[newRefId] = recordTable

  -- recordStore:QuicksaveToDrive()
  -- tes3mp.ClearRecords()
  -- tes3mp.SetRecordType(enumerations.recordType[string.upper(recordType)])
  -- packetBuilder.AddRecordByType(newRefId, recordTable, recordType)
  -- tes3mp.SendRecordDynamic(pid, true, false)

  -- inventoryHelper.removeItem(playerInv, trueRefId, 1, -1, -1, "")

  -- tes3mp.ClearInventoryChanges(pid)
  -- tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.REMOVE)
  -- tes3mp.AddItemChange(pid, trueRefId, 1, -1, -1, "")
  -- tes3mp.SendInventoryChanges(pid)

  -- inventoryHelper.addItem(playerInv, newRefId, 1, -1, -1, "")

  -- tes3mp.ClearInventoryChanges(pid)
  -- tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
  -- tes3mp.AddItemChange(pid, newRefId, 1, -1, -1, "")
  -- tes3mp.SendInventoryChanges(pid)
end

-- Train Armorer (Etching)
function RunicEnchanting.validateCraftArmorerTraining(pid)
  local reqs = RunicEnchanting.config.armorerTrainingRecipe
  HiemUtils.validateCraft(pid, reqs, false, false, RunicEnchanting.trainArmorerPractice)
end

function RunicEnchanting.trainArmorerPractice(pid)
  HiemUtils.increaseSkill(pid, 'Armorer', 'Strength', 10)
end

function HiemUtils.validators.soulValue(item, req, pid)
  if not (item.soul == "") and Data.actors[item.soul] >= req.soulMinSize then
    return true
  end

  return false
end


-- GUI Functions
function RunicEnchanting.showBookGUI(pid)
  tes3mp.CustomMessageBox(pid, REBGuI1, color.DarkOrange..RunicEnchanting.labels.bookMain, RunicEnchanting.labels.bookStudy..";"..RunicEnchanting.labels.bookCopy..";"..RunicEnchanting.labels.upgradeToolName..";"..RunicEnchanting.labels.soulReservoirName..";"..RunicEnchanting.labels.enchantGloveName..";"..RunicEnchanting.labels.requirements..";"..RunicEnchanting.labels.close)
end

function RunicEnchanting.displayRequirementsGUI(pid)
  local reservoirRequirements = HiemUtils.generateRequirementsString(RunicEnchanting.labels.soulReservoirName, RunicEnchanting.config.gemRecipe)
  local toolsRequirements = HiemUtils.generateRequirementsString(RunicEnchanting.labels.upgradeToolName, RunicEnchanting.config.toolsRecipe)
  local bookRequirements = HiemUtils.generateRequirementsString(RunicEnchanting.labels.bookName, RunicEnchanting.config.bookRecipe)
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

  local breakpoint = HiemUtils.getBreakpoint(pid, 'Enchant', RunicEnchanting.config.toolUpgradeBreakpoints, 'enchantRequirement')

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
      elseif Data.items[(playerInv[i].refId:gsub("-", "_"):gsub(" ", "_"))] then
        enchantableItem = Data.items[(playerInv[i].refId:gsub("-", "_"):gsub(" ", "_"))]
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
  tes3mp.ListBox(pid, REUGuI2, RunicEnchanting.labels.upgradeChoice, enchantableListString)
end

function RunicEnchanting.OnGUIAction(eventStatus, pid, idGui, data)
  local isValid = eventStatus.validDefaultHandler
  if isValid ~= false then
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

        local itemsToAdd = {{refId = "re_soul_gem_02", count = 1, charge = -1, enchantmentCharge = -1, soul = "re_creature_soul_small"}}
        HiemUtils.addPlayerItems(pid, itemsToAdd)

        -- inventoryHelper.addItem(playerInv, "re_soul_gem_02", 1, -1, -1, "re_creature_soul_small")

        -- tes3mp.ClearInventoryChanges(pid)
        -- tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
        -- tes3mp.AddItemChange(pid, "re_soul_gem_02", 1, -1, -1, "re_creature_soul_small")
        -- tes3mp.SendInventoryChanges(pid)

        ReservoirList[playerRef.name] = ReservoirList[playerRef.name] - 100
        RunicEnchanting.saveReservoirData()
        return
      elseif tonumber(data) == 2 then
        local playerRef = Players[pid]
        local playerInv = playerRef.data.inventory

        local itemsToAdd = {{refId = "re_soul_gem_02", count = 1, charge = -1, enchantmentCharge = -1, soul = "re_creature_soul_large"}}
        HiemUtils.addPlayerItems(pid, itemsToAdd)

        ReservoirList[playerRef.name] = ReservoirList[playerRef.name] - 500
        RunicEnchanting.saveReservoirData()
        return
      elseif tonumber(data) == 3 then
        local playerRef = Players[pid]
        local playerInv = playerRef.data.inventory

        local itemsToAdd = {{refId = "re_soul_gem_02", count = 1, charge = -1, enchantmentCharge = -1, soul = "re_creature_soul_divine"}}
        HiemUtils.addPlayerItems(pid, itemsToAdd)

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
        RunicEnchanting.validateCraftArmorerTraining(pid)
        return
      elseif tonumber(data) == 2 then
        -- Do Nothing
        return
      end
    elseif idGui == REUGuI2 then
      if tonumber(data) < 10000 then
        local refId = UpgradeData[Players[pid].name][tonumber(data) + 1].refId
        RunicEnchanting.validateUpgradeArmor(pid, refId)
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
          if tonumber(Data.actors[value.refId]) <= tonumber(gemValue) then
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