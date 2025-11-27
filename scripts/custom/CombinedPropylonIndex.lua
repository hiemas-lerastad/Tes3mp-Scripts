--[[
  CombinedPropylonIndex

  This scripts works as a replacement for the Master Propylon Index plugin so users do not have to download and enable the plugin
  A blueprint can be found in caldera mages guild, when used this item prompts a crafting menu in order to craft the combined index
  The default recipe requires all vanilla indexes (they are not consumed), a moderate sized soul in a soul gem (a value of 50 or higher), a piece of raw ebony and an enchant skill of 50 or higher

  The newly crafted index can be used in place of all of the individual indexes
  It can also be used (dragged onto character portrait) in order to teleport to the nearest propylon chamber (this feature can be disabled in the CombinedPropylonIndex.settings section)

  Installation
  1) Ensure that HiemUtils.lua has been installed
  2) Place this file as `CombinedPropylonIndex.lua` inside your TES3MP servers `server\scripts\custom` folder.
  3) Open your `customScripts.lua` file in a text editor. 
      (It can be found in `server\scripts` folder.)
  4) Add the below line to your `customScripts.lua` file:
      require("custom/CombinedPropylonIndex")
  5) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.
  6) Save `customScripts.lua` and restart your server.
]]--

local HiemUtils = require("custom/HiemUtils")

CombinedPropylonIndex = {}

CombinedPropylonIndex.labels = {
  indexName = "Combined Propylon Index",
  blueprintName = "Combined Propylon Index Blueprint",

  blueprintDescription = "These plans show how to create a combined propylon index with proficient enchanting skill using the other indexes and a large piece of ebony",
  craft = "Craft",

  teleportError = "You may not warp from an interior",

  close = "Close"
}

CombinedPropylonIndex.settings = {
  enableWarpClosest = true
}

CombinedPropylonIndex.config = {
  indexRecipe = {
    items = {
      {
        name = {"ingred_raw_ebony_01"},
        label = "Raw Ebony",
        count = 1,
        consumed = true
      },
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
      },
      {
        name = {"index_andra"},
        label = "Andasreth Propylon Index",
        count = 1,
        consumed = false
      },
      {
        name = {"index_beran"},
        label = "Berandas Propylon Index",
        count = 1,
        consumed = false
      },
      {
        name = {"index_falas"},
        label = "Falasmaryon Propylon Index",
        count = 1,
        consumed = false
      }, 
      {
        name = {"index_falen"},
        label = "Falensarano Propylon Index",
        count = 1,
        consumed = false
      },
      {
        name = {"index_hlor"},
        label = "Hlormaren Propylon Index",
        count = 1,
        consumed = false
      },
      {
        name = {"index_indo"},
        label = "Indoranyon Propylon Index",
        count = 1,
        consumed = false
      },
      {
        name = {"index_maran"},
        label = "Marandus Propylon Index",
        count = 1,
        consumed = false
      },
      {
        name = {"index_roth"},
        label = "Rotheran Propylon Index",
        count = 1,
        consumed = false
      },
      {
        name = {"index_telas"},
        label = "Telasero Propylon Index",
        count = 1,
        consumed = false
      },
      {
        name = {"index_valen"},
        label = "Valenvaryon Propylon Index",
        count = 1,
        consumed = false
      },     
    },
    skills = {
      {
        name = "Enchant",
        value = 50
      },
    },
    sounds = {
      success = "Repair"
    }
  },
}

CombinedPropylonIndex.ids = {
  blueprintGUI = 44332362,
  teleportErrorGUI = 44332363
}

function CombinedPropylonIndex.OnServerPostInit(eventStatus)
  if not WorldInstance.data.customVariables.CPI_Records_Initisalised then
    CombinedPropylonIndex.createRecord()
    WorldInstance.data.customVariables.CPI_Records_Initisalised = true
  end
end
customEventHooks.registerHandler("OnServerPostInit", CombinedPropylonIndex.OnServerPostInit)

function CombinedPropylonIndex.createRecord()
  local itemList = {
    {
      refId = "cpi_blueprint",
      baseId = "misc_dwrv_artifact70",
      name = CombinedPropylonIndex.labels.blueprintName,
      mesh = "m\\misc_dwrv_artifact70.nif",
      icon = "m\\misc_dwrv_artifact70.tga",
      weight = 0.10,
      value = 1200,
      script = ""
    },
    {
      refId = "cpi_index",
      baseId = "index_andra",
      name = CombinedPropylonIndex.labels.indexName,
      mesh = "m\\misc_portal_shard.nif",
      icon = "m\\misc_portal_shard.tga",
      weight = 2,
      value = 500,
      script = ""
    },
  }
  HiemUtils.addRecords("miscellaneous", itemList)

  local scriptList = {
    {
      refId = "Warp_Andra",
      scriptText = 'Begin Warp_Andra\nif ( menumode == 1 )\nreturn\nendif\nif ( OnActivate == 1 )\nif (  Player->GetItemCount, "Index_Andra" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 540, 630, -368, 270, "Andasreth, Propylon Chamber"\nelseif (  Player->GetItemCount, "cpi_index" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 540, 630, -368, 270, "Andasreth, Propylon Chamber"\nelse\nMessageBox "You do not have the Index for this Propylon."\nendif\nendif\nEnd Warp_Andra'
    },
    {
      refId = "Warp_Beran",
      scriptText = 'Begin Warp_Beran\nif ( menumode == 1 )\nreturn\nendif\nif ( OnActivate == 1 )\nif (  Player->GetItemCount, "Index_Andra" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 540, 1024, -608, 270, "Berandas, Propylon Chamber"\nelseif (  Player->GetItemCount, "cpi_index" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 540, 1024, -608, 270, "Berandas, Propylon Chamber"\nelse\nMessageBox "You do not have the Index for this Propylon."\nendif\nendif\nEnd Warp_Beran'
    },
    {
      refId = "Warp_Falas",
      scriptText = 'Begin Warp_Falas\nif ( menumode == 1 )\nreturn\nendif\nif ( OnActivate == 1 )\nif (  Player->GetItemCount, "Index_Andra" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 302, 504, -368, 270, "Falasmaryon, Propylon Chamber"\nelseif (  Player->GetItemCount, "cpi_index" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 302, 504, -368, 270, "Falasmaryon, Propylon Chamber"\nelse\nMessageBox "You do not have the Index for this Propylon."\nendif\nendif\nEnd Warp_Falas'
    },
    {
      refId = "Warp_Falen",
      scriptText = 'Begin Warp_Falen\nif ( menumode == 1 )\nreturn\nendif\nif ( OnActivate == 1 )\nif (  Player->GetItemCount, "Index_Andra" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 410 898 -496 270, "Falensarano, Propylon Chamber"\nelseif (  Player->GetItemCount, "cpi_index" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 410 898 -496 270, "Falensarano, Propylon Chamber"\nelse\nMessageBox "You do not have the Index for this Propylon."\nendif\nendif\nEnd Warp_Falen'
    },
    {
      refId = "Warp_Hlor",
      scriptText = 'Begin Warp_Hlor\nif ( menumode == 1 )\nreturn\nendif\nif ( OnActivate == 1 )\nif (  Player->GetItemCount, "Index_Andra" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 4097, 3898, 12758, 180, "Hlormaren, Propylon Chamber"\nelseif (  Player->GetItemCount, "cpi_index" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 4097, 3898, 12758, 180, "Hlormaren, Propylon Chamber"\nelse\nMessageBox "You do not have the Index for this Propylon."\nendif\nendif\nEnd Warp_Hlor'
    },
    {
      refId = "Warp_Indo",
      scriptText = 'Begin Warp_Indo\nif ( menumode == 1 )\nreturn\nendif\nif ( OnActivate == 1 )\nif (  Player->GetItemCount, "Index_Andra" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 489 766 -368 270, "Indoranyon, Propylon Chamber"\nelseif (  Player->GetItemCount, "cpi_index" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 489 766 -368 270, "Indoranyon, Propylon Chamber"\nelse\nMessageBox "You do not have the Index for this Propylon."\nendif\nendif\nEnd Warp_Indo'
    },
    {
      refId = "Warp_Maran",
      scriptText = 'Begin Warp_Maran\nif ( menumode == 1 )\nreturn\nendif\nif ( OnActivate == 1 )\nif (  Player->GetItemCount, "Index_Andra" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 244 888 -368 270, "Marandus, Propylon Chamber"\nelseif (  Player->GetItemCount, "cpi_index" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 244 888 -368 270, "Marandus, Propylon Chamber"\nelse\nMessageBox "You do not have the Index for this Propylon."\nendif\nendif\nEnd Warp_Maran'
    },
    {
      refId = "Warp_Roth",
      scriptText = 'Begin Warp_Roth\nif ( menumode == 1 )\nreturn\nendif\nif ( OnActivate == 1 )\nif (  Player->GetItemCount, "Index_Andra" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 244 888 -368 270, "Rotheran, Propylon Chamber"\nelseif (  Player->GetItemCount, "cpi_index" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 244 888 -368 270, "Rotheran, Propylon Chamber"\nelse\nMessageBox "You do not have the Index for this Propylon."\nendif\nendif\nEnd Warp_Roth'
    },
    {
      refId = "Warp_Telas",
      scriptText = 'Begin Warp_Telas\nif ( menumode == 1 )\nreturn\nendif\nif ( OnActivate == 1 )\nif (  Player->GetItemCount, "Index_Andra" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 408 767 -484 270, "Telasero, Propylon Chamber"\nelseif (  Player->GetItemCount, "cpi_index" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 408 767 -484 270, "Telasero, Propylon Chamber"\nelse\nMessageBox "You do not have the Index for this Propylon."\nendif\nendif\nEnd Warp_Telas'
    },
    {
      refId = "Warp_Valen",
      scriptText = 'Begin Warp_Valen\nif ( menumode == 1 )\nreturn\nendif\nif ( OnActivate == 1 )\nif (  Player->GetItemCount, "Index_Andra" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 290, 778, -496, 720, "Valenvaryon, Propylon Chamber"\nelseif (  Player->GetItemCount, "cpi_index" > 0 )\nPlaySound "Thunder2"\nPlayer->PositionCell, 290, 778, -496, 720, "Valenvaryon, Propylon Chamber"\nelse\nMessageBox "You do not have the Index for this Propylon."\nendif\nendif\nEnd Warp_Valen'
    },
  }
  HiemUtils.addRecords("script", scriptList)

  local objectList = {
    {
      id = "Caldera, Guild of Mages",
      references = {
        {
          id = "cpi_blueprint",
          translation = {
            920.00,
            860.00,
            460.00
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

function CombinedPropylonIndex.displayBlueprintGUI(pid)
  tes3mp.CustomMessageBox(pid, CombinedPropylonIndex.ids.blueprintGUI, color.DarkOrange..CombinedPropylonIndex.labels.blueprintDescription, CombinedPropylonIndex.labels.craft..";"..CombinedPropylonIndex.labels.close)
end

function CombinedPropylonIndex.validateCreateIndex(pid)
  local reqs = CombinedPropylonIndex.config.indexRecipe
  HiemUtils.validateCraft(pid, reqs, "cpi_index", false, false)
end

function CombinedPropylonIndex.OnBlueprintInteraction(data, pid)
  if tonumber(data) == 0 then
    CombinedPropylonIndex.validateCreateIndex(pid)
    return
  elseif tonumber(data) == 1 then
    -- Do Nothing
    return
  end
end

function CombinedPropylonIndex.warpClosestChamber(pid)
  local playerCoords = {
    x = tes3mp.GetExteriorX(pid),
    y = tes3mp.GetExteriorY(pid)
  }

  local lastExteriorCell = {}

  if (playerCoords.x > 30 or playerCoords.x < -20 or playerCoords.y > 30 or playerCoords.y < -20) then
    for token in string.gmatch(Players[pid].data.customVariables.lastExteriorCell, "[^, ]+") do
      if not lastExteriorCell.x then
        lastExteriorCell.x = token
      else
        lastExteriorCell.y = token
      end
    end
    playerCoords = lastExteriorCell
  end

  local closestChamber
  local smallestDistance

  for key, chamber in pairs(HiemUtils.Data.chambers) do
    local distance = HiemUtils.getDistance(playerCoords, chamber.mapCoords)

    if smallestDistance then
      if distance < smallestDistance then
        closestChamber = chamber
        smallestDistance = distance
      end
    else
      closestChamber = chamber
      smallestDistance = distance
    end
  end

  tes3mp.SetCell(pid, closestChamber.cellName)
  tes3mp.SendCell(pid)

  tes3mp.SetPos(pid, closestChamber.spawn.x, closestChamber.spawn.y, closestChamber.spawn.z)
  tes3mp.SetRot(pid, 0.0, closestChamber.spawn.rot)

  tes3mp.SendPos(pid)
end

function CombinedPropylonIndex.OnGUIAction(eventStatus, pid, idGui, data)
  local isValid = eventStatus.validDefaultHandler
  if isValid ~= false then
    if idGui == CombinedPropylonIndex.ids.blueprintGUI then
      CombinedPropylonIndex.OnBlueprintInteraction(data, pid)
    end
  end
end
customEventHooks.registerHandler("OnGUIAction", CombinedPropylonIndex.OnGUIAction)

function CombinedPropylonIndex.OnPlayerItemUseValidator(eventStatus, pid, refId)
    if refId == "cpi_blueprint" then
      CombinedPropylonIndex.displayBlueprintGUI(pid)
    elseif refId == "cpi_index" and CombinedPropylonIndex.settings.enableWarpClosest then
      CombinedPropylonIndex.warpClosestChamber(pid)
    end
end
customEventHooks.registerValidator("OnPlayerItemUse", CombinedPropylonIndex.OnPlayerItemUseValidator)