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

RunicEnchanting.npcs = {}

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
  -- miscellaneous
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
  HiemUtils.addRecords("miscellaneous", itemList)


  -- book
  local bookList = {
    {
      type = "Book",
      flags = { 0, 0 },
      id = "sc_paper enchanting",
      data = {
        weight = 1.0,
        value = 20,
        flags = 1,
        skill = "None",
        enchantment = 1000
      },
      name = "imbued paper",
      mesh = "m\\Misc_paper_plain_01.nif",
      icon = "m\\Tx_paper_plain_01.tga"
    }
  }
  HiemUtils.addRecords("book", bookList)


  -- enchantment
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
  HiemUtils.addRecords("enchantment", enchantList)

  -- clothing
  local clothingList = {
    {
      refId = "re_enchant_gloves",
      baseId = "aryongloveright",
      name = RunicEnchanting.labels.enchantGloveName,
      enchantmentId = "re_enchanting_enchant"
    }
  }
  HiemUtils.addRecords("clothing", clothingList)

  -- creature
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
  HiemUtils.addRecords("creature", creatureList)

  -- NPC
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
        { 10, "sc_paper plain" },
      },
      -- equipment = {
      --   [3] = {
      --     refId = "BM_NordicMail_PauldronL",
      --     count = 1,
      --     charge = -1,
      --     enchantmentCharge = -1
      --   },
      --   [4] = {
      --     refId = "BM_NordicMail_PauldronR",
      --     count = 1,
      --     charge = -1,
      --     enchantmentCharge = -1
      --   },
      --   [5] = {
      --     refId = "BM_NordicMail_gauntletL",
      --     count = 1,
      --     charge = -1,
      --     enchantmentCharge = -1
      --   },
      --   [6] = {
      --     refId = "BM_NordicMail_gauntletR",
      --     count = 1,
      --     charge = -1,
      --     enchantmentCharge = -1
      --   },
      --   [7] = {
      --     refId = "expensive_shoes_02",
      --     count = 1,
      --     charge = -1,
      --     enchantmentCharge = -1
      --   },
      --   [10] = {
      --     refId = "expensive_skirt_01",
      --     count = 1,
      --     charge = -1,
      --     enchantmentCharge = -1
      --   },
      --   [11] = {
      --     refId = "expensive_robe_02_a",
      --     count = 1,
      --     charge = -1,
      --     enchantmentCharge = -1
      --   },
      -- },
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

  -- cell
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
        {
            index = 41910,
            refId = "in_hlaalu_loaddoor_01"
        },
        {
            index = 41912,
            refId = "in_hlaalu_loaddoor_01"
        },
        {
            index = 56847,
            refId = "in_hlaalu_loaddoor_01"
        },
        {
            index = 67615,
            refId = "masalinie merian"
        },
        {
            index = 67616,
            refId = "marayn dren"
        },
        {
            index = 67617,
            refId = "sharn gra-muzgob"
        },
        {
            index = 67618,
            refId = "ajira"
        },
        {
            index = 67619,
            refId = "estirdalin"
        },
        {
            index = 67620,
            refId = "ranis athrys"
        },
        {
            index = 67621,
            refId = "galbedir"
        },
        {
            index = 390613,
            refId = "de_p_desk_01_galbedir"
        },
        {
            index = 470832,
            refId = "common_ring_01_mgbwg"
        },
        {
            index = 41881,
            refId = "in_hlaalu_hall_3way"
        },
        {
            index = 41882,
            refId = "in_hlaalu_hall_3way"
        },
        {
            index = 41885,
            refId = "in_hlaalu_hall_3way"
        },
        {
            index = 41888,
            refId = "in_hlaalu_hall_3way"
        },
        {
            index = 41890,
            refId = "in_hlaalu_hall_3way"
        },
        {
            index = 41892,
            refId = "in_hlaalu_hall_corner_01"
        },
        {
            index = 41893,
            refId = "in_hlaalu_hall_corner_01"
        },
        {
            index = 41894,
            refId = "in_hlaalu_hall_stairsr"
        },
        {
            index = 41895,
            refId = "in_hlaalu_hall_3way"
        },
        {
            index = 41896,
            refId = "in_hlaalu_hall_corner_01"
        },
        {
            index = 41897,
            refId = "in_hlaalu_hall_ramp"
        },
        {
            index = 41899,
            refId = "in_hlaalu_wall"
        },
        {
            index = 41900,
            refId = "in_hlaalu_hall_corner_01"
        },
        {
            index = 41901,
            refId = "in_hlaalu_hall_ramp"
        },
        {
            index = 41902,
            refId = "in_hlaalu_roomt_sided"
        },
        {
            index = 41903,
            refId = "in_hlaalu_roomt_corner_01"
        },
        {
            index = 41905,
            refId = "in_hlaalu_wall"
        },
        {
            index = 41906,
            refId = "in_hlaalu_roomt_corner_01"
        },
        {
            index = 41907,
            refId = "in_hlaalu_roomt_corner_01"
        },
        {
            index = 41908,
            refId = "in_hlaalu_roomt_corner_01"
        },
        {
            index = 41914,
            refId = "furn_de_rug_01"
        },
        {
            index = 41916,
            refId = "in_hlaalu_room_rail"
        },
        {
            index = 41917,
            refId = "light_de_candle_14_64"
        },
        {
            index = 41919,
            refId = "bk_OriginOfTheMagesGuild"
        },
        {
            index = 41920,
            refId = "misc_de_pot_redware_02"
        },
        {
            index = 56829,
            refId = "furn_de_p_chair_01"
        },
        {
            index = 56832,
            refId = "in_hlaalu_roomt_sided"
        },
        {
            index = 56833,
            refId = "in_hlaalu_room_door1"
        },
        {
            index = 56834,
            refId = "in_hlaalu_room_corner"
        },
        {
            index = 56835,
            refId = "in_hlaalu_room_corner"
        },
        {
            index = 56836,
            refId = "in_hlaalu_room_corner"
        },
        {
            index = 56838,
            refId = "in_hlaalu_doorjamb"
        },
        {
            index = 56840,
            refId = "Furn_de_rug_big_09"
        },
        {
            index = 56841,
            refId = "furn_de_rug_02"
        },
        {
            index = 56842,
            refId = "furn_de_p_table_05"
        },
        {
            index = 56843,
            refId = "light_com_candle_07_128"
        },
        {
            index = 56844,
            refId = "misc_de_bowl_orange_green_01"
        },
        {
            index = 56848,
            refId = "barrel_01_cheapfood5"
        },
        {
            index = 56849,
            refId = "barrel_02_Ingred"
        },
        {
            index = 56850,
            refId = "com_basket_01_ingredien"
        },
        {
            index = 56852,
            refId = "com_basket_01_food"
        },
        {
            index = 56853,
            refId = "com_sack_01_saltrice_10"
        },
        {
            index = 56854,
            refId = "com_sack_02_chpfood3"
        },
        {
            index = 56856,
            refId = "light_de_lamp_01"
        },
        {
            index = 56857,
            refId = "furn_de_p_shelf_02"
        },
        {
            index = 56858,
            refId = "light_de_candle_08_64"
        },
        {
            index = 56859,
            refId = "chest_small_01_ingredie"
        },
        {
            index = 56860,
            refId = "light_de_candle_08_64"
        },
        {
            index = 56861,
            refId = "de_p_desk_01_masalinie "
        },
        {
            index = 56862,
            refId = "de_p_desk_01_ajira"
        },
        {
            index = 56865,
            refId = "furn_de_p_table_04"
        },
        {
            index = 56866,
            refId = "Com_Sack_02_Ingred"
        },
        {
            index = 56867,
            refId = "Com_Sack_02_Ingred"
        },
        {
            index = 56868,
            refId = "com_sack_01_ingred"
        },
        {
            index = 56869,
            refId = "com_sack_01_ingred"
        },
        {
            index = 56870,
            refId = "misc_de_pot_blue_01"
        },
        {
            index = 56871,
            refId = "misc_de_pot_glass_peach_01"
        },
        {
            index = 56872,
            refId = "misc_de_pot_glass_peach_01"
        },
        {
            index = 56873,
            refId = "misc_de_pot_glass_peach_02"
        },
        {
            index = 56874,
            refId = "ingred_bonemeal_01"
        },
        {
            index = 56875,
            refId = "ingred_crab_meat_01"
        },
        {
            index = 56876,
            refId = "furn_de_tray_01"
        },
        {
            index = 56877,
            refId = "ingred_emerald_01"
        },
        {
            index = 56878,
            refId = "ingred_green_lichen_01"
        },
        {
            index = 56879,
            refId = "ingred_saltrice_01"
        },
        {
            index = 56881,
            refId = "light_de_candle_06_64"
        },
        {
            index = 56884,
            refId = "furn_de_rope_03"
        },
        {
            index = 56885,
            refId = "light_de_lantern_10_128_Static"
        },
        {
            index = 56886,
            refId = "light_de_lantern_10_177_Static"
        },
        {
            index = 56887,
            refId = "furn_de_rope_03"
        },
        {
            index = 56888,
            refId = "light_de_lantern_10_177_Static"
        },
        {
            index = 56889,
            refId = "furn_de_rope_03"
        },
        {
            index = 56890,
            refId = "light_de_lantern_10_177_Static"
        },
        {
            index = 56891,
            refId = "furn_de_rope_03"
        },
        {
            index = 56892,
            refId = "light_de_lantern_10_177_Static"
        },
        {
            index = 56893,
            refId = "furn_de_rope_03"
        },
        {
            index = 56894,
            refId = "light_de_lantern_10_128_Static"
        },
        {
            index = 56895,
            refId = "furn_de_rope_03"
        },
        {
            index = 56896,
            refId = "light_de_lantern_10_128_Static"
        },
        {
            index = 56897,
            refId = "furn_de_rope_03"
        },
        {
            index = 56898,
            refId = "light_de_lantern_10_177_Static"
        },
        {
            index = 56899,
            refId = "furn_de_rope_03"
        },
        {
            index = 56908,
            refId = "furn_de_r_table_07"
        },
        {
            index = 56909,
            refId = "furn_de_r_chair_03"
        },
        {
            index = 56911,
            refId = "light_de_candle_17_64"
        },
        {
            index = 56913,
            refId = "furn_de_r_table_07"
        },
        {
            index = 56914,
            refId = "furn_de_r_chair_03"
        },
        {
            index = 56915,
            refId = "furn_de_r_chair_03"
        },
        {
            index = 56916,
            refId = "light_de_candle_17_64"
        },
        {
            index = 56917,
            refId = "light_de_candle_17_64"
        },
        {
            index = 56919,
            refId = "furn_de_r_wallscreen_02"
        },
        {
            index = 56920,
            refId = "furn_de_r_wallscreen_02"
        },
        {
            index = 56921,
            refId = "furn_de_r_wallscreen_02"
        },
        {
            index = 56922,
            refId = "furn_de_r_wallscreen_02"
        },
        {
            index = 56923,
            refId = "furn_de_r_wallscreen_02"
        },
        {
            index = 56924,
            refId = "furn_de_r_bench_01"
        },
        {
            index = 56925,
            refId = "furn_de_r_bench_01"
        },
        {
            index = 56926,
            refId = "furn_de_r_bench_01"
        },
        {
            index = 56927,
            refId = "furn_de_r_bench_01"
        },
        {
            index = 56928,
            refId = "furn_de_r_shelf_01"
        },
        {
            index = 56929,
            refId = "furn_de_r_shelf_01"
        },
        {
            index = 56930,
            refId = "bk_BriefHistoryEmpire1"
        },
        {
            index = 56931,
            refId = "bk_BriefHistoryEmpire2"
        },
        {
            index = 56932,
            refId = "bk_BriefHistoryEmpire3"
        },
        {
            index = 56933,
            refId = "bk_BriefHistoryEmpire4"
        },
        {
            index = 56934,
            refId = "misc_de_pot_redware_04"
        },
        {
            index = 56935,
            refId = "misc_de_pot_redware_04"
        },
        {
            index = 56936,
            refId = "misc_de_pot_glass_peach_01"
        },
        {
            index = 56937,
            refId = "bk_HouseOfTroubles_o"
        },
        {
            index = 56938,
            refId = "furn_de_p_chair_01"
        },
        {
            index = 56939,
            refId = "furn_de_p_chair_01"
        },
        {
            index = 56940,
            refId = "ingred_saltrice_01"
        },
        {
            index = 56941,
            refId = "ingred_scrap_metal_01"
        },
        {
            index = 56942,
            refId = "sc_paper plain"
        },
        {
            index = 56943,
            refId = "sc_paper plain"
        },
        {
            index = 56944,
            refId = "furn_de_r_wallscreen_02"
        },
        {
            index = 56945,
            refId = "furn_de_r_wallscreen_02"
        },
        {
            index = 56946,
            refId = "furn_de_r_wallscreen_02"
        },
        {
            index = 56947,
            refId = "furn_de_r_wallscreen_02"
        },
        {
            index = 56948,
            refId = "furn_de_r_wallscreen_02"
        },
        {
            index = 56949,
            refId = "furn_de_r_table_07"
        },
        {
            index = 56950,
            refId = "furn_de_r_chair_03"
        },
        {
            index = 56954,
            refId = "furn_de_r_table_07"
        },
        {
            index = 56955,
            refId = "furn_de_r_chair_03"
        },
        {
            index = 56956,
            refId = "furn_de_r_chair_03"
        },
        {
            index = 56958,
            refId = "light_de_candle_17_64"
        },
        {
            index = 56959,
            refId = "Furn_De_R_Bookshelf_02"
        },
        {
            index = 56960,
            refId = "furn_de_r_shelf_01"
        },
        {
            index = 56961,
            refId = "active_de_p_bed_03"
        },
        {
            index = 56962,
            refId = "active_de_p_bed_03"
        },
        {
            index = 56963,
            refId = "Furn_de_rug_big_09"
        },
        {
            index = 56964,
            refId = "furn_de_p_table_01"
        },
        {
            index = 56965,
            refId = "furn_de_p_chair_01"
        },
        {
            index = 56966,
            refId = "furn_de_p_chair_01"
        },
        {
            index = 56967,
            refId = "furn_de_p_chair_01"
        },
        {
            index = 56968,
            refId = "de_p_closet_02_mguild"
        },
        {
            index = 56969,
            refId = "apparatus_a_calcinator_01"
        },
        {
            index = 56970,
            refId = "apparatus_m_mortar_01"
        },
        {
            index = 56971,
            refId = "apparatus_j_retort_01"
        },
        {
            index = 56972,
            refId = "apparatus_j_alembic_01"
        },
        {
            index = 56973,
            refId = "light_de_candle_17_64"
        },
        {
            index = 56975,
            refId = "Furn_de_rug_big_09"
        },
        {
            index = 56976,
            refId = "misc_com_bottle_09"
        },
        {
            index = 56977,
            refId = "misc_com_bottle_09"
        },
        {
            index = 56978,
            refId = "misc_com_bottle_15"
        },
        {
            index = 56979,
            refId = "misc_de_foldedcloth00"
        },
        {
            index = 56980,
            refId = "misc_de_goblet_02"
        },
        {
            index = 56981,
            refId = "misc_de_goblet_02"
        },
        {
            index = 56982,
            refId = "Misc_Com_Bottle_04"
        },
        {
            index = 56983,
            refId = "misc_de_goblet_07"
        },
        {
            index = 56984,
            refId = "misc_de_goblet_07"
        },
        {
            index = 56985,
            refId = "misc_com_basket_02"
        },
        {
            index = 56986,
            refId = "misc_com_bottle_03"
        },
        {
            index = 56987,
            refId = "Misc_Com_Bottle_04"
        },
        {
            index = 56988,
            refId = "misc_com_bottle_05"
        },
        {
            index = 56989,
            refId = "Misc_Com_Bottle_04"
        },
        {
            index = 56990,
            refId = "Misc_Com_Bottle_04"
        },
        {
            index = 56991,
            refId = "Misc_Com_Bottle_04"
        },
        {
            index = 56992,
            refId = "misc_com_bottle_05"
        },
        {
            index = 56993,
            refId = "misc_com_bottle_05"
        },
        {
            index = 56994,
            refId = "misc_com_bottle_05"
        },
        {
            index = 56995,
            refId = "misc_com_bottle_03"
        },
        {
            index = 56996,
            refId = "misc_com_bottle_03"
        },
        {
            index = 56997,
            refId = "Misc_Com_Bottle_14"
        },
        {
            index = 56998,
            refId = "Misc_Com_Bottle_14"
        },
        {
            index = 56999,
            refId = "Misc_Com_Bottle_14"
        },
        {
            index = 57000,
            refId = "Misc_Com_Bottle_14"
        },
        {
            index = 57001,
            refId = "Misc_Com_Bottle_14"
        },
        {
            index = 57002,
            refId = "Misc_Com_Bottle_14"
        },
        {
            index = 57003,
            refId = "misc_de_bowl_bugdesign_01"
        },
        {
            index = 57004,
            refId = "misc_de_goblet_03"
        },
        {
            index = 57005,
            refId = "misc_de_goblet_03"
        },
        {
            index = 57006,
            refId = "misc_de_goblet_03"
        },
        {
            index = 57007,
            refId = "misc_de_goblet_03"
        },
        {
            index = 57008,
            refId = "misc_de_goblet_03"
        },
        {
            index = 57009,
            refId = "misc_de_goblet_03"
        },
        {
            index = 57010,
            refId = "misc_de_goblet_03"
        },
        {
            index = 57011,
            refId = "Misc_DE_glass_green_01"
        },
        {
            index = 57012,
            refId = "Misc_DE_glass_green_01"
        },
        {
            index = 57013,
            refId = "Misc_DE_glass_green_01"
        },
        {
            index = 57014,
            refId = "Misc_DE_glass_green_01"
        },
        {
            index = 57015,
            refId = "Misc_DE_glass_green_01"
        },
        {
            index = 57016,
            refId = "Misc_DE_glass_green_01"
        },
        {
            index = 57017,
            refId = "Misc_DE_glass_green_01"
        },
        {
            index = 57018,
            refId = "misc_de_foldedcloth00"
        },
        {
            index = 57019,
            refId = "misc_de_foldedcloth00"
        },
        {
            index = 57020,
            refId = "misc_de_foldedcloth00"
        },
        {
            index = 57021,
            refId = "misc_de_pitcher_01"
        },
        {
            index = 57022,
            refId = "misc_de_pot_blue_01"
        },
        {
            index = 57024,
            refId = "in_hlaalu_hall_stairsl"
        },
        {
            index = 64193,
            refId = "furn_de_lecturn"
        },
        {
            index = 86807,
            refId = "de_r_chest_01_sharn"
        },
        {
            index = 290469,
            refId = "misc_uni_pillow_01"
        },
        {
            index = 290470,
            refId = "misc_uni_pillow_01"
        },
        {
            index = 290471,
            refId = "misc_uni_pillow_01"
        },
        {
            index = 290472,
            refId = "misc_uni_pillow_01"
        },
        {
            index = 290473,
            refId = "NorthMarker"
        },
        {
            index = 310763,
            refId = "misc_com_bottle_01"
        },
        {
            index = 310764,
            refId = "misc_com_bottle_03"
        },
        {
            index = 310765,
            refId = "misc_com_bottle_09"
        },
        {
            index = 310766,
            refId = "misc_com_bottle_11"
        },
        {
            index = 310767,
            refId = "misc_com_bottle_11"
        },
        {
            index = 310768,
            refId = "misc_de_bowl_redware_01"
        },
        {
            index = 310769,
            refId = "misc_de_bowl_redware_01"
        },
        {
            index = 310770,
            refId = "misc_de_goblet_02"
        },
        {
            index = 310771,
            refId = "misc_de_goblet_02"
        },
        {
            index = 310772,
            refId = "Furn_de_rug_big_09"
        },
        {
            index = 332053,
            refId = "chest_01_v_potion_al_02"
        },
        {
            index = 332054,
            refId = "chest_01_v_potion_h_03"
        },
        {
            index = 378320,
            refId = "in_hlaalu_hall_center"
        },
        {
            index = 378321,
            refId = "in_hlaalu_hall_corner_01"
        },
        {
            index = 378322,
            refId = "in_hlaalu_hall_rail"
        },
        {
            index = 378323,
            refId = "light_de_candle_06_64"
        },
        {
            index = 378324,
            refId = "light_com_candle_07_77"
        },
        {
            index = 378325,
            refId = "in_hlaalu_roomt_post"
        },
        {
            index = 378326,
            refId = "in_hlaalu_roomt_post"
        },
        {
            index = 378327,
            refId = "furn_planter_02"
        },
        {
            index = 378328,
            refId = "In_Hlaalu_Platform_01"
        },
        {
            index = 378329,
            refId = "flora_tree_ai_03"
        },
        {
            index = 378330,
            refId = "flora_bush_01"
        },
        {
            index = 378331,
            refId = "flora_bush_01"
        },
        {
            index = 378332,
            refId = "flora_bush_01"
        },
        {
            index = 378333,
            refId = "flora_grass_01"
        },
        {
            index = 378334,
            refId = "flora_grass_01"
        },
        {
            index = 378335,
            refId = "flora_grass_01"
        },
        {
            index = 378336,
            refId = "light_de_lamp_01_128"
        },
        {
            index = 378338,
            refId = "in_hlaalu_doorjamb_load"
        },
        {
            index = 378339,
            refId = "in_hlaalu_doorjamb_load"
        },
        {
            index = 378340,
            refId = "in_hlaalu_doorjamb_load"
        },
        {
            index = 378341,
            refId = "light_de_lantern_08_177_01"
        },
        {
            index = 378342,
            refId = "light_de_lantern_03_200"
        },
        {
            index = 378343,
            refId = "in_hlaalu_hall_center"
        },
        {
            index = 378344,
            refId = "furn_de_rope_03"
        },
        {
            index = 378345,
            refId = "furn_de_rope_03"
        },
        {
            index = 390615,
            refId = "bk_Ajira1"
        },
        {
            index = 390616,
            refId = "bk_Ajira2"
        },
        {
            index = 391124,
            refId = "common_ring_01_mge"
        },
        {
            index = 460130,
            refId = "com_chest_02_mg_supply"
        },
        {
            index = 466173,
            refId = "misc_lw_platter"
        },
        {
            index = 466174,
            refId = "Misc_SoulGem_Petty"
        },
        {
            index = 466175,
            refId = "Misc_SoulGem_Petty"
        },
        {
            index = 466176,
            refId = "Misc_SoulGem_Petty"
        },
        {
            index = 466177,
            refId = "Misc_SoulGem_Common"
        },
        {
            index = 466178,
            refId = "Misc_SoulGem_Common"
        },
        {
            index = 466179,
            refId = "Misc_SoulGem_Greater"
        },
        {
            index = 466180,
            refId = "Misc_SoulGem_Grand"
        },
        {
            index = 466181,
            refId = "Misc_SoulGem_Lesser"
        },
        {
            index = 466182,
            refId = "Misc_SoulGem_Lesser"
        },
        {
            index = 466183,
            refId = "Misc_SoulGem_Lesser"
        },
        {
            index = 469364,
            refId = "light_de_candle_14_64"
        },
        {
            index = 477571,
            refId = "com_chest_02_galbedir"
        },
        {
            index = 478738,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478739,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478740,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478741,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478742,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478743,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478744,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478745,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478746,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478747,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478748,
            refId = "furn_c_t_wizard_01"
        },
        {
            index = 478749,
            refId = "light_de_lantern_03_200"
        },
        {
            index = 478750,
            refId = "furn_de_rope_03"
        },
        {
            index = 478751,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478752,
            refId = "furn_c_t_ritual_01"
        },
        {
            index = 478753,
            refId = "light_de_lantern_03_200"
        },
        {
            index = 478754,
            refId = "furn_de_rope_03"
        },
        {
            index = 478755,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478756,
            refId = "light_de_lantern_03_200"
        },
        {
            index = 478757,
            refId = "furn_de_rope_03"
        },
        {
            index = 478758,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478759,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478760,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478761,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478762,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478763,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478764,
            refId = "Flame Light_64"
        },
        {
            index = 478765,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478766,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 478767,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 480244,
            refId = "In_Hlaalu_Platform_01"
        },
        {
            index = 480245,
            refId = "light_de_lantern_10_128_Static"
        },
        {
            index = 480246,
            refId = "furn_de_rope_03"
        },
        {
            index = 480247,
            refId = "flora_grass_01"
        },
        {
            index = 480248,
            refId = "furn_planter_01"
        },
        {
            index = 480249,
            refId = "Furn_De_Railing_04"
        },
        {
            index = 480250,
            refId = "Furn_De_Railing_04"
        },
        {
            index = 480251,
            refId = "Furn_De_Railing_04"
        },
        {
            index = 480252,
            refId = "Furn_De_Railing_06"
        },
        {
            index = 481297,
            refId = "furn_de_tapestry_07"
        },
        {
            index = 481298,
            refId = "flora_grass_01"
        },
        {
            index = 481299,
            refId = "furn_planter_01"
        },
        {
            index = 483333,
            refId = "bk_charterMG"
        },
        {
            index = 483334,
            refId = "bk_wherewereyoudragonbroke"
        },
        {
            index = 483335,
            refId = "bk_galerionthemystic"
        },
        {
            index = 483336,
            refId = "bk_fragmentonartaeum"
        }
      },
      references ={ {
        mast_index = 0,
        refr_index = 2,
        id = "herra witch warrior",
        temporary = false,
        translation = { 251.85272, 245.47557, -89.4133 },
        rotation = { 0.0, 0.0, 4.6831856 },
      }, {
        mast_index = 0,
        refr_index = 3,
        id = "in_hlaalu_room_corner",
        temporary = true,
        translation = { 0.0, 510.0, 0.0 },
        rotation = { 0.0, 0.0, 1.5707964 }
      }, {
        mast_index = 0,
        refr_index = 4,
        id = "in_hlaalu_room_corner",
        temporary = true,
        translation = { 255.0, 0.0, 0.0 },
        rotation = { 0.0, 0.0, -1.5707964 }
      }, {
        mast_index = 0,
        refr_index = 5,
        id = "in_hlaalu_room_corner",
        temporary = true,
        translation = { 0.0, 0.0, 0.0 },
        rotation = { 0.0, 0.0, 0.0 }
      }, {
        mast_index = 0,
        refr_index = 6,
        id = "in_hlaalu_room_corner",
        temporary = true,
        translation = { 255.0, 510.0, 0.0 },
        rotation = { 0.0, 0.0, 3.1415927 }
      }, {
        mast_index = 0,
        refr_index = 7,
        id = "in_hlaalu_room_side",
        temporary = true,
        translation = { 0.0, 255.0, 0.0 },
        rotation = { 0.0, 0.0, -1.5707964 }
      }, {
        mast_index = 0,
        refr_index = 8,
        id = "Furn_Com_RM_Bar_02",
        temporary = true,
        translation = { 171.58002, 200.89647, -90.0 },
        rotation = { 0.0, 0.0, 0.0 }
      }, {
        mast_index = 0,
        refr_index = 9,
        id = "Furn_Com_RM_Bar_02",
        temporary = true,
        translation = { 171.58002, 328.8965, -90.0 },
        rotation = { 0.0, 0.0, 3.1415927 }
      }, {
        mast_index = 0,
        refr_index = 10,
        id = "Furn_Com_RM_Bar_01",
        temporary = true,
        translation = { 171.58002, 264.89648, -90.0 },
        rotation = { 0.0, 0.0, 1.5707964 }
      }, {
        mast_index = 0,
        refr_index = 11,
        id = "in_hlaalu_room_side",
        temporary = true,
        translation = { 255.0, 255.0, 0.0 },
        rotation = { 0.0, 0.0, 1.5707964 }
      }, {
        mast_index = 0,
        refr_index = 12,
        id = "light_com_candle_04",
        temporary = true,
        translation = { 166.747, 195.468, -35.0 },
        rotation = { 0.0, 0.0, 0.0 }
      }, {
        mast_index = 0,
        refr_index = 13,
        id = "chest_small_01_herra",
        temporary = true,
        translation = { 466.65347, 193.59569, -27.0 },
        rotation = { 0.0, 0.0, 0.0 },
        owner = "herra witch warrior",
        health_left = 0
      } }
    }
  }

  HiemUtils.addRecords("cell", cellList)

  -- container
  local containerList = {
    {
      type = "Container",
      flags = { 0, 0 },
      id = "chest_small_01_herra",
      name = "Small Chest",
      mesh = "o\\Contain_chest_small_01.NIF",
      encumbrance = 80.0,
      container_flags = 8,
      inventory = { { 1, "Misc_Inkwell" }, { 1, "Misc_Quill" }, { 5, "Misc_SoulGem_Common" }, { 5, "Misc_SoulGem_Grand" }, { 5, "Misc_SoulGem_Greater" }, { 5, "Misc_SoulGem_Lesser" }, { 5, "Misc_SoulGem_Petty" }, { 10, "sc_paper enchanting" }, { 10, "sc_paper plain" } }
    }
  }
  HiemUtils.addRecords("container", containerList)

  -- scripts
  local scriptList = {
    {
      refId = "re_enchant_shop_door_entrance_script",
      scriptText = "Begin re_enchant_shop_door_entrance_script\nIf ( OnActivate == 1 )\n    Player->PositionCell, 0, 0, 0, 0, \"Reenum-Kur's Enchanting Shop\"\n    Player->PlaySoundVP, \"Door Latched Two Open\" 1 1\nEndif\nEnd re_enchant_shop_door_entrance_script"
    }
  }
  HiemUtils.addRecords("script", scriptList)

  -- activator
  local activatorList = {
    {
      refId = "re_enchant_shop_door_entrance",
      name = "Reenum-Kur's Enchanting Shop",
      model =  "d\\In_Hlaalu_Door.NIF",
      script = "re_enchant_shop_door_entrance_script"
    }
  }
  HiemUtils.addRecords("activator", activatorList)

  -- new cell population
  for i=1, #cellList do
    local item = cellList[i]
    HiemUtils.populateCell(item)
  end

  -- existing cell population
  local objectList = {
    {
      id = "-4, -2",
      references = {
        {
          id = "re_enchant_shop_door_entrance",
          translation = {
            -25313.225,
            -13993.441,
            1113.058
          },
          rotation = {
            0.0,
            0.0,
            4.712389
          }
        }
      }
    }
  }
  for i=1, #objectList do
    local item = objectList[i]
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
  if not WorldInstance.data.customVariables.RE_Records_Initisalised then
  -- if true then
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

  local itemsToAdd = {{refId = newRefId, count = 1, charge = -1, enchantmentCharge = -1, soul = ""}}
  HiemUtils.addPlayerItems(pid, itemsToAdd)
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