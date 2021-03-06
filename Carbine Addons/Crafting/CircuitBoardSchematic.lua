-----------------------------------------------------------------------------------------------
-- Client Lua Script for CirtcuitBoardSchematic
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "CraftingLib"

local ktCraftingAttributeIconsText =
{ 	-- There are only 15 needed for Crafting
	[Unit.CodeEnumProperties.Dexterity] 					= {"Icon_Windows_UI_CRB_Attribute_Finesse", 			Apollo.GetString("CRB_Finesse")},
	[Unit.CodeEnumProperties.Technology] 					= {"Icon_Windows_UI_CRB_Attribute_Technology", 			Apollo.GetString("CRB_Tech_Attribute")},
	[Unit.CodeEnumProperties.Magic] 						= {"Icon_Windows_UI_CRB_Attribute_Moxie", 				Apollo.GetString("CRB_Moxie")},
	[Unit.CodeEnumProperties.Wisdom] 						= {"Icon_Windows_UI_CRB_Attribute_Insight", 			Apollo.GetString("UnitPropertyInsight")},
	[Unit.CodeEnumProperties.Stamina] 						= {"Icon_Windows_UI_CRB_Attribute_Grit", 				Apollo.GetString("CRB_Grit")},
	[Unit.CodeEnumProperties.Strength] 						= {"Icon_Windows_UI_CRB_Attribute_BruteForce", 			Apollo.GetString("CRB_Brutality")},
	[Unit.CodeEnumProperties.Rating_AvoidReduce] 			= {"Icon_Windows_UI_CRB_Attribute_Strikethrough", 		Apollo.GetString("CRB_Strikethrough_Rating")},
	[Unit.CodeEnumProperties.Rating_CritChanceIncrease] 	= {"Icon_Windows_UI_CRB_Attribute_CriticalHit", 		Apollo.GetString("CRB_Critical_Chance")},
	[Unit.CodeEnumProperties.RatingCritSeverityIncrease] 	= {"Icon_Windows_UI_CRB_Attribute_CriticalSeverity", 	Apollo.GetString("CRB_Critical_Severity")},
	[Unit.CodeEnumProperties.Rating_AvoidIncrease] 			= {"Icon_Windows_UI_CRB_Attribute_Deflect", 			Apollo.GetString("CRB_Deflect_Rating")},
	[Unit.CodeEnumProperties.Rating_CritChanceDecrease] 	= {"Icon_Windows_UI_CRB_Attribute_DeflectCritical", 	Apollo.GetString("CRB_Deflect_Critical_Hit_Rating")},
	[Unit.CodeEnumProperties.BaseHealth] 					= {"Icon_Windows_UI_CRB_Attribute_Health", 				Apollo.GetString("CRB_Health_Max")},

	[Unit.CodeEnumProperties.ManaPerFiveSeconds] 			= {"Icon_Windows_UI_CRB_Attribute_Recovery", 			Apollo.GetString("CRB_Attribute_Recovery_Rating")},
	[Unit.CodeEnumProperties.Armor] 						= {"Icon_Windows_UI_CRB_Attribute_Armor", 				Apollo.GetString("CRB_Armor") },
	[Unit.CodeEnumProperties.ShieldCapacityMax] 			= {"Icon_Windows_UI_CRB_Attribute_ShieldCap", 			Apollo.GetString("CBCrafting_Shields")},
}

local karSocketLineArt =
{
	[1] 	= "",
	[2] 	= "SocketFlairLine_2",
	[3] 	= "SocketFlairLine_3",
	[4] 	= "SocketFlairLine_4",
	[5] 	= "SocketFlairLine_5",
	[6] 	= "SocketFlairLine_6",
	[7] 	= "SocketFlairLine_7",
	[8] 	= "SocketFlairLine_8",
	[9] 	= "SocketFlairLine_9",
	[10] 	= "SocketFlairLine_10",
	[11] 	= "SocketFlairLine_11",
	[12] 	= "SocketFlairLine_12",
	[13] 	= "SocketFlairLine_13",
}

-- TODO: Can condense all these Cap/Resist/Inductor into one table
local karSocketLineArtColor =
{
	[Item.CodeEnumMicrochipType.Capacitor] 	= "sprCircuit_Line_RedVertical",
	[Item.CodeEnumMicrochipType.Resistor] 	= "sprCircuit_Line_BlueVertical",
	[Item.CodeEnumMicrochipType.Inductor] 	= "sprCircuit_Line_GreenVertical",
	-- Default: "sprCircuit_Line_WhiteVertical"
}

local karSocketNodeArtColor =
{
	[Item.CodeEnumMicrochipType.Capacitor] 	= "sprCircuit_BottomAccent_Red",
	[Item.CodeEnumMicrochipType.Resistor] 	= "sprCircuit_BottomAccent_Blue",
	[Item.CodeEnumMicrochipType.Inductor] 	= "sprCircuit_BottomAccent_Green",
	-- Default: "sprCircuit_BottomAccent_White"
}

local ktValidSocketItemMatch =
{
	[Item.CodeEnumMicrochipType.Capacitor] 	= true,
	[Item.CodeEnumMicrochipType.Resistor] 	= true,
	[Item.CodeEnumMicrochipType.Inductor] 	= true,
}

local ktSocketTypeToString =
{
	[Item.CodeEnumMicrochipType.Capacitor] 	= Apollo.GetString("CRB_RedCapacitor"),
	[Item.CodeEnumMicrochipType.Resistor] 	= Apollo.GetString("CRB_BlueResistor"),
	[Item.CodeEnumMicrochipType.Inductor] 	= Apollo.GetString("CRB_GreenInductor"),
}

local ktSocketTypeGoodColor =
{
	[Item.CodeEnumMicrochipType.Capacitor] 	= "sprCircuit_Circle_Red_Adorn3",
	[Item.CodeEnumMicrochipType.Resistor] 	= "sprCircuit_Circle_Blue_Adorn3",
	[Item.CodeEnumMicrochipType.Inductor] 	= "sprCircuit_Circle_Green_Adorn3",
}

local ktSocketTypeAverageColor =
{
	[Item.CodeEnumMicrochipType.Capacitor] 	= "sprCircuit_Circle_Red_Adorn2",
	[Item.CodeEnumMicrochipType.Resistor] 	= "sprCircuit_Circle_Blue_Adorn2",
	[Item.CodeEnumMicrochipType.Inductor] 	= "sprCircuit_Circle_Green_Adorn2",
}

local ktSocketTypeBadColor =
{
	[Item.CodeEnumMicrochipType.Capacitor] 	= "sprCircuit_Circle_Red_Adorn1",
	[Item.CodeEnumMicrochipType.Resistor] 	= "sprCircuit_Circle_Blue_Adorn1",
	[Item.CodeEnumMicrochipType.Inductor] 	= "sprCircuit_Circle_Green_Adorn1",
}

local karEvalStrings =
{
	[Item.CodeEnumItemQuality.Inferior] 		= Apollo.GetString("CRB_Inferior"),
	[Item.CodeEnumItemQuality.Average] 			= Apollo.GetString("CRB_Average"),
	[Item.CodeEnumItemQuality.Good] 			= Apollo.GetString("CRB_Good"),
	[Item.CodeEnumItemQuality.Excellent] 		= Apollo.GetString("CRB_Excellent"),
	[Item.CodeEnumItemQuality.Superb] 			= Apollo.GetString("CRB_Superb"),
	[Item.CodeEnumItemQuality.Legendary] 		= Apollo.GetString("CRB_Legendary"),
	[Item.CodeEnumItemQuality.Artifact] 		= Apollo.GetString("CRB_Artifact"),
}

local karEvalColors =
{
	[Item.CodeEnumItemQuality.Inferior] 		= "ItemQuality_Inferior",
	[Item.CodeEnumItemQuality.Average] 			= "ItemQuality_Average",
	[Item.CodeEnumItemQuality.Good] 			= "ItemQuality_Good",
	[Item.CodeEnumItemQuality.Excellent] 		= "ItemQuality_Excellent",
	[Item.CodeEnumItemQuality.Superb] 			= "ItemQuality_Superb",
	[Item.CodeEnumItemQuality.Legendary] 		= "ItemQuality_Legendary",
	[Item.CodeEnumItemQuality.Artifact]		 	= "ItemQuality_Artifact",
}

CircuitBoardSchematic = {}

function CircuitBoardSchematic:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function CircuitBoardSchematic:delete()
	Apollo.RemoveEventHandler("CraftingUpdateCurrent", self)
	Apollo.RemoveEventHandler("UpdateInventory", self)
	Apollo.RemoveEventHandler("CraftingInterrupted", self)
	Apollo.UnlinkAddon(self.luaOwner, self)
end

function CircuitBoardSchematic:Init(luaOwner, xmlDoc, wndParent, idSchematic, bPreviewOnly, bHasMaterials)
	Apollo.LinkAddon(luaOwner, self)

	Apollo.RegisterEventHandler("CraftingUpdateCurrent", 		"OnCraftingUpdateCurrent", self)
	Apollo.RegisterEventHandler("UpdateInventory", 				"UpdatePreview", self)
	Apollo.RegisterEventHandler("CraftingInterrupted",			"UpdatePreview", self)

	self.tSchematicInfo = CraftingLib.GetSchematicInfo(idSchematic)
	if not self.tSchematicInfo then
		return nil
	end

	self.xmlDoc = xmlDoc
	self.luaOwner = luaOwner
	self.wndMain = wndParent -- Apollo.LoadForm(self.xmlDoc, "CircuitBoardSchematic", wndParent, self)
	self.wndPropertyPickerWindow = nil
	self.nTEMPThresholdSelected = {} -- TODO TEMP: We don't need this table, we can rewrite/refactor the UI code to derive
	self.tSocketThresholds = {} -- TODO REFACTOR, way too many parallel tables with the same data
	self.tLayoutLocToIdx = {}
	self.tLayoutIdxToLoc = {}
	self.tSocketButtons = {}
	self.tSocketItems = {}
	self.wndArrowTutorial = -1 -- This is -1 if not set yet, then 0 after it's been set (and we no longer ever want to show it)
	self.bPreviewOnly = bPreviewOnly

	self:Initialize(self.tSchematicInfo)
	self:UpdatePreview()

	local tNetworkTimingIssueHack = nil
	local tCurrentCraft = CraftingLib.GetCurrentCraft()
	if bPreviewOnly == nil then
		self.tSocketButtons[1]:Enable(false)
	end

	if bPreviewOnly or not bHasMaterials then
		self.tSocketButtons[1]:Enable(true)
	elseif tCurrentCraft and tCurrentCraft.nSchematicId == idSchematic then
		tNetworkTimingIssueHack = tCurrentCraft
	end

	-- Reset UI
	self.wndMain:FindChild("FailPercentText"):Show(false)
	self.wndMain:FindChild("FailChargeBar"):SetProgress(0)
	self.wndMain:FindChild("OverchargeBar"):SetProgress(0)
	self.wndMain:FindChild("OverchargeCurrentText"):SetText("")

	-- On the unlikely chance that the network timing is off, force a UI refresh.
	if not tNetworkTimingIssueHack then
		tCurrentCraft = CraftingLib.GetCurrentCraft()
		if tCurrentCraft and tCurrentCraft.schematicId == idSchematic then
			self:OnCraftingUpdateCurrent()
		end
	end

	return self
end

function CircuitBoardSchematic:Initialize(tSchematicInfo)
	for idx = 1, 13 do
		local wndSocketButton = self.wndMain:FindChild("SocketButton"..idx)
		wndSocketButton:DestroyChildren()
	end

	for idx = 1, 13 do
		if idx == 1 then
			self.tSocketButtons[idx] = self.wndMain:FindChild("SocketButton"..idx)
			self.tSocketButtons[idx]:SetData(idx)
			self.tSocketButtons[idx]:Show(false)
		else
			self.tSocketButtons[idx] = Apollo.LoadForm(self.xmlDoc, "CircuitSocketItem", self.wndMain:FindChild("SocketButton"..idx), self)
			self.tSocketButtons[idx]:SetData(idx)
			self.tSocketButtons[idx]:Show(false)
		end
	end

	local tSchematicInfoSockets = tSchematicInfo.tSockets
	if #tSchematicInfoSockets <= 0 then
		return
	end

	-- Place left column power core
	local tCountPerParent = {}
	for idx = 1, #tSchematicInfoSockets do
		local tCurrSocket = tSchematicInfoSockets[idx]
		tCountPerParent[tCurrSocket.nParent] = (tCountPerParent[tCurrSocket.nParent] or 0) + 1
		if tCurrSocket.nParent == 0 then
			self.tLayoutLocToIdx[1] = idx -- TODO REFACTOR
			self.tLayoutIdxToLoc[idx] = 1
		end
	end

	-- Place middle sockets
	for idx = 1, #tSchematicInfoSockets do
		local tCurrSocket = tSchematicInfoSockets[idx]
		if tCurrSocket.nParent == 1 then
			local nLocation = self:GetSocketLocationWithParents(idx, tCurrSocket.nParent, tCountPerParent[tCurrSocket.nParent])
			if nLocation then
				self.tLayoutLocToIdx[nLocation] = idx
				self.tLayoutIdxToLoc[idx] = nLocation
			end
		end
	end

	-- Then right column sockets
	for idx = 1, #tSchematicInfoSockets do
		local tCurrSocket = tSchematicInfoSockets[idx]
		if tCurrSocket.nParent > 1 then
			local nLocation = self:GetSocketLocationWithParents(idx, tCurrSocket.nParent, tCountPerParent[tCurrSocket.nParent])
			if nLocation then
				self.tLayoutLocToIdx[nLocation] = idx
				self.tLayoutIdxToLoc[idx] = nLocation
			end
		end
	end

	-- Socket Line art
	local wndSocketFlairLayer = self.wndMain:FindChild("SocketsFlairLayer")
	for idx = 1, #karSocketLineArt do
		local wndSocketLine = wndSocketFlairLayer:FindChild(karSocketLineArt[idx])
		if wndSocketLine then
			wndSocketLine:Show(false)
			if wndSocketLine:FindChild("SocketFlairNode") then
				wndSocketLine:FindChild("SocketFlairNode"):Show(true)
			end
		end
	end

	-- After init, show the relevant sockets
	local tValidLocations = {}
	local tValidLocations_Node = {}
	for idx, nLocation in pairs(self.tLayoutIdxToLoc) do
		local wndSocket = self.tSocketButtons[nLocation]
		wndSocket:Show(true)

		-- Socket Line Art
		local tCurrSocket = tSchematicInfoSockets[idx]
		local wndSocketLine = wndSocketFlairLayer:FindChild(karSocketLineArt[nLocation])
		if wndSocketLine then
			local strSocketLineSprite = karSocketLineArtColor[tCurrSocket.eSocketType] or "sprCircuit_Line_WhiteVertical"
			local strSocketNodeSprite = karSocketNodeArtColor[tCurrSocket.eSocketType] or "sprCircuit_BottomAccent_White"
			tValidLocations[nLocation] = strSocketLineSprite
			tValidLocations_Node[nLocation] = strSocketNodeSprite

			if wndSocketLine:FindChild("SocketFlairNodeArt") then
				wndSocketLine:FindChild("SocketFlairNodeArt"):SetSprite(strSocketNodeSprite)
			end
			wndSocketLine:FindChild("SocketFlairLineColor"):SetSprite(strSocketLineSprite)
			wndSocketLine:Show(true)
		end

		if nLocation == 1 then
			local wndPowerPicker = Apollo.LoadForm(self.xmlDoc, "PowerCorePicker", wndSocket, self)
			wndPowerPicker:FindChild("PowerCorePickerBtn"):SetData(idx)
			wndPowerPicker:FindChild("PowerCorePickerBtn"):AttachWindow(wndPowerPicker:FindChild("PowerCorePickerPopout"))

			local bFoundAnItem = false
			local tPowerCorePickerDupeList = {}
			wndPowerPicker:FindChild("PowerCorePickerList"):DestroyChildren()
			for idx, tCurrentPowerCore in pairs(CraftingLib.GetAvailablePowerCores(tSchematicInfo.nSchematicId) or {}) do -- Can be invalid for locked chips
				if not tPowerCorePickerDupeList[tCurrentPowerCore:GetItemId()] then
					bFoundAnItem = true
					tPowerCorePickerDupeList[tCurrentPowerCore:GetItemId()] = true

					local wndCurrItem = Apollo.LoadForm(self.xmlDoc, "PowerCoreItemBtn", wndPowerPicker:FindChild("PowerCorePickerList"), self)
					wndCurrItem:FindChild("PowerCoreItemSprite"):SetSprite(tCurrentPowerCore:GetIcon())
					wndCurrItem:FindChild("PowerCoreItemSprite"):SetText(tCurrentPowerCore:GetBackpackCount()) -- Makes sense to not include bank count here
					wndCurrItem:SetData(tCurrentPowerCore)
					self:HelperBuildItemTooltip(wndCurrItem, tCurrentPowerCore)
				end
			end
			wndPowerPicker:FindChild("PowerCorePickerList"):ArrangeChildrenTiles(0)
			wndPowerPicker:FindChild("PowerCorePickerList"):SetText(bFoundAnItem and "" or Apollo.GetString("CBCrafting_GoFindPowerAmps"))
		end
	end

	-- Last second visiblity
	local tLastSecondArt = { { 2, 5, 6, 7 }, { 3, 8, 9, 10 }, { 4, 11, 12, 13 } }
	for idx, tNumberSet in pairs(tLastSecondArt) do
		local nParent, nLeft, nMid, nRight = unpack(tNumberSet)
		if tValidLocations[nParent] and tValidLocations[nMid] then
			wndSocketFlairLayer:FindChild(karSocketLineArt[nMid]):FindChild("SocketFlairLineColor"):SetSprite(tValidLocations[nMid])
			wndSocketFlairLayer:FindChild(karSocketLineArt[nMid]):FindChild("SocketFlairNodeArt"):SetSprite(tValidLocations_Node[nMid])
			wndSocketFlairLayer:FindChild(karSocketLineArt[nMid]):FindChild("SocketFlairLineParentColor"):SetSprite(tValidLocations[nParent])
		elseif tValidLocations[nParent] and (tValidLocations[nLeft] or tValidLocations[nRight]) then
			wndSocketFlairLayer:FindChild(karSocketLineArt[nMid]):Show(false)
		elseif tValidLocations[nParent] then -- Implict nothing is on below it
			wndSocketFlairLayer:FindChild(karSocketLineArt[nMid]):Show(true)
			wndSocketFlairLayer:FindChild(karSocketLineArt[nMid]):FindChild("SocketFlairLineColor"):SetSprite(tValidLocations[nParent])
			wndSocketFlairLayer:FindChild(karSocketLineArt[nMid]):FindChild("SocketFlairNodeArt"):SetSprite(tValidLocations_Node[nParent])
			wndSocketFlairLayer:FindChild(karSocketLineArt[nMid]):FindChild("SocketFlairLineParentColor"):SetSprite(tValidLocations[nParent])
		end
		wndSocketFlairLayer:FindChild(karSocketLineArt[nParent]):FindChild("SocketFlairNode"):Show(tValidLocations[nLeft] or tValidLocations[nRight])
	end
end

-----------------------------------------------------------------------------------------------
-- Main Draw Method
-----------------------------------------------------------------------------------------------

function CircuitBoardSchematic:UpdatePreview()
	if not self.wndMain or not self.wndMain:IsValid() or not self.wndMain:IsVisible() then
		return
	end

	local tMicrochips, tThresholds = self:HelperGetUserSelection()
	local tCraftInfo = CraftingLib.GetPreviewInfo(self.tSchematicInfo.nSchematicId, tMicrochips, tThresholds)

	local bParentBlocker = false
	for idx, strWindowName in pairs({ "PreviewOnlyBlocker", "NoStationBlocker", "NoMaterialsBlocker", "NotKnownBlocker", "PostCraftBlocker" }) do
		if self.wndMain:FindChild(strWindowName):IsShown() then
			bParentBlocker = true
			break
		end
	end

	local bDidSelections = true
	local bFoundASocket = false
	for idx, tSocket in ipairs(tCraftInfo.tSockets) do
		local nLayoutLoc = self.tLayoutIdxToLoc[idx]
		local wndSocketButton = self.tSocketButtons[nLayoutLoc]

		-- Draw Sockets
		if nLayoutLoc and wndSocketButton and wndSocketButton:FindChild("CircuitPickerIcon") then
			local bLocalSelection = self:DrawSocket(wndSocketButton, nLayoutLoc, tSocket, bParentBlocker)
			bDidSelections = bDidSelections and bLocalSelection
			bFoundASocket = true
		end
	end

	-- Verification of Craft Btn
	local bOverchargeCanCraft, strPopupText = self:UpdateOverchargeBars(tMicrochips, tThresholds)
	local bHaveBagSpace = self.wndMain:FindChild("HiddenBagWindow"):GetTotalEmptyBagSlots() > 0
	if not bOverchargeCanCraft then
		-- Do nothing
	elseif not bDidSelections then
		strPopupText = string.format("<P Font=\"CRB_InterfaceSmall_O\" Align=\"Center\" TextColor=\"UI_TextMetalBodyHighlight\">%s</P>", Apollo.GetString("CBCrafting_NeedMoreSelections"))
	elseif not bHaveBagSpace then
		strPopupText = string.format("<P Font=\"CRB_InterfaceSmall_O\" Align=\"Center\" TextColor=\"xkcdReddish\">%s</P>", Apollo.GetString("CBCrafting_NoBagSpace"))
	elseif not bFoundASocket then
		strPopupText = string.format("<P Font=\"CRB_InterfaceSmall_O\" Align=\"Center\" TextColor=\"UI_TextMetalBodyHighlight\">%s</P>", Apollo.GetString("CBCrafting_NoSocketsNoInputNeeded"))
	end

	self.wndMain:FindChild("WarningWindowText"):SetAML(strPopupText or "")
	self.wndMain:FindChild("WarningWindowText"):Show(string.len(strPopupText or "") > 0 and not bParentBlocker)
	self.wndMain:FindChild("CraftButton"):Enable(bOverchargeCanCraft and bDidSelections and bHaveBagSpace and not bParentBlocker)

	-- Tooltip
	self:HelperBuildTooltip(self.wndMain, self.wndMain:FindChild("TooltipHolder"), tCraftInfo.itemPreview)
end

function CircuitBoardSchematic:DrawSocket(wndSocketButton, nLayoutLoc, tSocket, bParentBlocker)
	local nSocket = self.tLayoutLocToIdx[nLayoutLoc]
	local tSocketIdxData = nSocket and self.tSchematicInfo.tSockets[nSocket] or nil

	-- Icons (Can be either Power Core or other sockets)
	local itemCurr = self.tSocketItems[nLayoutLoc]
	if not itemCurr then
		itemCurr = nSocket and tSocketIdxData and self:GetSystemSocketItem(nSocket) -- Can still be nil
	end
	wndSocketButton:FindChild("CircuitPickerIcon"):SetBGColor("white")
	wndSocketButton:FindChild("CircuitPickerIcon"):SetSprite(itemCurr and itemCurr:GetIcon() or "")
	self:HelperBuildItemTooltip(wndSocketButton:FindChild("CircuitPickerIcon"), itemCurr or "")

	-- Icon Text
	if tSocket.arProperties and tSocket.arProperties[1] then
		wndSocketButton:FindChild("CircuitPickerIconText"):SetText(String_GetWeaselString(Apollo.GetString("CBCrafting_PlusChipValue"), tSocket.arProperties[1].nValue))
	else
		wndSocketButton:FindChild("CircuitPickerIconText"):SetText("")
	end

	-- Icon Multiply (TODO TEMP HACK!)
	local tItemChipInfo = itemCurr and itemCurr:GetMicrochipInfo() or nil
	if tItemChipInfo and tItemChipInfo.eType then
		if tItemChipInfo.eType == Item.CodeEnumMicrochipType.Capacitor then
			wndSocketButton:FindChild("CircuitPickerIcon"):SetBGColor("UI_WindowTextCraftingRedCapacitor")
		elseif tItemChipInfo.eType == Item.CodeEnumMicrochipType.Inductor then
			wndSocketButton:FindChild("CircuitPickerIcon"):SetBGColor("UI_WindowTextCraftingGreenInductor")
		elseif tItemChipInfo.eType == Item.CodeEnumMicrochipType.Resistor then
			wndSocketButton:FindChild("CircuitPickerIcon"):SetBGColor("UI_WindowTextCraftingBlueResistor")
		end
	end

	-- If Locked Power Core
	if wndSocketButton:FindChild("PowerCorePickerBtn") then
		wndSocketButton:FindChild("PowerCorePickerBtn"):Show(tSocketIdxData.bIsChangeable)
	end

	-- Not Power Core or weird sockets
	if wndSocketButton:FindChild("CircuitPickerBtn") then
		-- Locked or unlocked
		local bLocked = not ktValidSocketItemMatch[tSocketIdxData.eSocketType]
		if bLocked and tSocket.arProperties and tSocket.arProperties[1] then
			local nBudgetLockValue = tSocket.arProperties[1].nValue
			wndSocketButton:FindChild("CircuitPickerIconText"):SetText(String_GetWeaselString(Apollo.GetString("CBCrafting_PlusChipValue"), nBudgetLockValue))
		end
		--wndSocketButton:FindChild("CircuitPickerAdornLock"):Show(not ktValidSocketItemMatch[tSocketIdxData.eSocketType])

		-- Type and Efficiency
		local strAdornSprite = ""
		local strHugeTooltip = "<P Font=\"CRB_InterfaceSmall_O\">" .. (bLocked and Apollo.GetString("CBCrafting_LockedCircuit") or Apollo.GetString("CBCrafting_CircuitSlot")) .. "</P>"
		if ktValidSocketItemMatch[tSocketIdxData.eSocketType] then
			local strEfficiency = ""
			if tSocket.fMultiplier < 0.95 then
				strEfficiency = Apollo.GetString("CBCrafting_GoodEfficiency")
				strAdornSprite = ktSocketTypeGoodColor[tSocketIdxData.eSocketType]
			elseif tSocket.fMultiplier > 1.05 then
				strEfficiency = Apollo.GetString("CBCrafting_BadEfficiency")
				strAdornSprite = ktSocketTypeBadColor[tSocketIdxData.eSocketType]
			else
				strEfficiency = Apollo.GetString("CBCrafting_AverageEfficiency")
				strAdornSprite = ktSocketTypeAverageColor[tSocketIdxData.eSocketType]
			end

			if math.abs(tSocket.fMultiplier) < 1000 then -- Sanity Check
				local strNumbers = String_GetWeaselString(strEfficiency, tSocket.fMultiplier)
				local strType = String_GetWeaselString(Apollo.GetString("CBCrafting_Type"), ktSocketTypeToString[tSocketIdxData.eSocketType])
				strHugeTooltip = string.format("%s<P Font=\"CRB_InterfaceSmall_O\">%s</P><P Font=\"CRB_InterfaceSmall_O\">%s</P>", strHugeTooltip, strType, strNumbers)
			end
		else
			if tSocket.fMultiplier < 0.95 then
				strAdornSprite = "sprCircuit_Circle_Silver_Adorn3"
			elseif tSocket.fMultiplier > 1.05 then
				strAdornSprite = "sprCircuit_Circle_Silver_Adorn1"
			else
				strAdornSprite = "sprCircuit_Circle_Silver_Adorn2"
			end
		end
		wndSocketButton:FindChild("CircuitPickerAdorn"):SetSprite(strAdornSprite)

		-- Power Section
		local strExactCharge = tSocket.nCharge and String_GetWeaselString(Apollo.GetString("CBCrafting_ExactChargeTooltip"), string.format("%.2f", tSocket.nCharge)) or ""
		local bColorMisMatch = tItemChipInfo and tSocketIdxData and ktValidSocketItemMatch[tSocketIdxData.eSocketType] and tItemChipInfo.eType ~= tSocketIdxData.eSocketType
		wndSocketButton:FindChild("CircuitSocketChargeText"):SetText(tSocket.nCharge and string.format("%.f", tSocket.nCharge) or "")
		wndSocketButton:FindChild("CircuitSocketChargeText"):Show(tSocket.nCharge and tSocket.nCharge ~= 0)
		strHugeTooltip = tSocket.nCharge and string.format("%s<P Font=\"CRB_InterfaceSmall_O\">%s</P>", strHugeTooltip, strExactCharge) or strHugeTooltip

		if bLocked then
			wndSocketButton:FindChild("CircuitSocketChargeText"):SetTextColor(ApolloColor.new("UI_TextMetalBodyHighlight"))
			wndSocketButton:FindChild("CircuitPickerSmallRight"):Enable(false)
			wndSocketButton:FindChild("CircuitPickerSmallLeft"):Enable(false)
		else
			wndSocketButton:FindChild("CircuitSocketChargeText"):SetTextColor(bColorMisMatch and "red" or "white")

			-- Charge Left Right Arrows Tutorial
			for idx, strCurr in pairs({ "CircuitPickerSmallRight", "CircuitPickerSmallLeft" }) do
				if tSocketIdxData.bIsChangeable and self.wndArrowTutorial == -1 then
					self.wndArrowTutorial = Apollo.LoadForm(self.xmlDoc, "Tutorial_SmallRightArrow", wndSocketButton:FindChild(strCurr), self)
					local nTextWidth = Apollo.GetTextWidth("CRB_Interface9_O", Apollo.GetString("CRB_Crafting_AdjustChargeTutorial"))
					local nLeft, nTop, nRight, nBottom = self.wndArrowTutorial:GetAnchorOffsets()
					self.wndArrowTutorial:SetAnchorOffsets(nLeft, nTop, nLeft + nTextWidth + 72, nBottom)
				end
			end
		end
		strHugeTooltip = bColorMisMatch and string.format("%s<P Font=\"CRB_InterfaceSmall_O\">%s</P>", strHugeTooltip, Apollo.GetString("CBCrafting_MismatchTooltip")) or strHugeTooltip

		-- Save data for the click
		local eParentUnitProperty = tItemChipInfo and tItemChipInfo.idUnitProperty or nil
		wndSocketButton:FindChild("CircuitPickerBtn"):SetData({ nLayoutLoc, eParentUnitProperty })
		wndSocketButton:FindChild("CircuitPickerBtn"):Show(tSocketIdxData.bIsChangeable and not tSocketIdxData.itemDefaultChip)
		wndSocketButton:FindChild("CircuitPickerAdorn"):SetTooltip(strHugeTooltip)
	end

	-- Thresholds
	local wndThreshold = self.tSocketThresholds[nLayoutLoc]
	if tSocket.nThresholdCount > 1 then
		if not wndThreshold then
			wndThreshold = Apollo.LoadForm(self.xmlDoc, "Threshold", wndSocketButton, self)
			self.tSocketThresholds[nLayoutLoc] = wndThreshold
		end

		wndThreshold:Show(true)
		wndThreshold:FindChild("ThresholdRotateContainer"):DestroyChildren()

		local nDegreePerItem = 180 / (tSocket.nThresholdCount + 1)
		for nSocketValue = 1, tSocket.nThresholdCount do
			local wndRotate = Apollo.LoadForm(self.xmlDoc, "ThresholdRotateItem", wndThreshold:FindChild("ThresholdRotateContainer"), self)
			wndRotate:SetRotation(-90 + nSocketValue * nDegreePerItem)
			wndRotate:FindChild("RotateBall"):SetData(nSocketValue)
			wndRotate:FindChild("RotateTestBtn"):SetData(nLayoutLoc)

			if not self.nTEMPThresholdSelected[nLayoutLoc] then
				self.nTEMPThresholdSelected[nLayoutLoc] = nSocketValue
			end

			if self.nTEMPThresholdSelected and self.nTEMPThresholdSelected[nLayoutLoc] and self.nTEMPThresholdSelected[nLayoutLoc] == nSocketValue then
				-- This is DestroyingChildren, so we can assume default state is whatever is set in XML
				wndRotate:FindChild("RotateBall"):Show(true)
				wndRotate:FindChild("RotateTestBtn"):SetCheck(true)
			end
		end

		-- Threshold Progress Bar and BG Glow
		local strThresholdBGColor = "00aaaaff"
		if self.nTEMPThresholdSelected and self.nTEMPThresholdSelected[nLayoutLoc] then
			local nSocketValue = self.nTEMPThresholdSelected[nLayoutLoc]
			if nSocketValue == 1 then
				strThresholdBGColor = "66aaaaff"
			elseif nSocketValue == 2 then
				strThresholdBGColor = "99aaaaff"
			elseif nSocketValue == 3 then
				strThresholdBGColor = "ffaaaaff"
			end

			wndThreshold:FindChild("ThresholdProgressBar"):SetMax(1)
			wndThreshold:FindChild("ThresholdProgressBar"):SetProgress(1) -- TODO: Temp hack to do some radial clipping, can remove after new art
			wndThreshold:FindChild("ThresholdProgressBar"):SetBGColor(strThresholdBGColor)
			wndThreshold:FindChild("ThresholdMiddleGlow"):SetBGColor(strThresholdBGColor)
		end
	elseif wndThreshold and wndThreshold:IsValid() then
		wndThreshold:Destroy()
		self.tSocketThresholds[nLayoutLoc] = nil
	end

	-- Arrow helper
	local bFoundItem = itemCurr
	local bShowArrowPulse = not bParentBlocker and not bFoundItem
	wndSocketButton:FindChild("CircuitPickerArrowPulse"):Show(bShowArrowPulse)

	if bShowArrowPulse and wndSocketButton:FindChild("CircuitPickerArrowPulse"):FindChild("Tutorial_AddChip") then
		local wndTutorialAddChip = wndSocketButton:FindChild("CircuitPickerArrowPulse"):FindChild("Tutorial_AddChip")
		local nTextWidth = Apollo.GetTextWidth("CRB_Interface9_O", Apollo.GetString("CRB_Crafting_AddChipTutorial"))
		local nLeft, nTop, nRight, nBottom = wndTutorialAddChip:GetAnchorOffsets()
		wndTutorialAddChip:SetAnchorOffsets(nLeft, nTop, nLeft + nTextWidth + 72, nBottom)
	end

	return bFoundItem
end

function CircuitBoardSchematic:UpdateOverchargeBars(tMicrochips, tThresholds)
	local tOverchargeInfo = CraftingLib.GetCurrentOverchargeInfo(tMicrochips, tThresholds)
	if not tOverchargeInfo then
		return true -- No Overcharge, pass it
	end

	local fRawCurrCharge = tOverchargeInfo.fCraftingOvercharge
	local fRawThreshold = tOverchargeInfo.fOverchargeCompleteSuccess
	local fRawMaxOvercharge = tOverchargeInfo.fOverchargeAllowable
	local nPercentFail = tOverchargeInfo.fCraftingFailChance * 100
	local nPercentMax = tOverchargeInfo.fFailureAtAllowable * 100
	local nChanceToFail = math.min(nPercentFail, nPercentMax)

	self.wndMain:FindChild("OverchargeBar"):SetMax(fRawThreshold)
	self.wndMain:FindChild("OverchargeBar"):SetProgress(fRawCurrCharge, fRawThreshold / 2.5) -- 2nd arg is for animation
	self.wndMain:FindChild("OverchargeBar"):SetStyleEx("EdgeGlow", fRawCurrCharge < fRawThreshold * 0.93)
	self.wndMain:FindChild("OverchargeBar"):SetTooltip(String_GetWeaselString(Apollo.GetString("Crafting_OverchargeTooltip"), fRawCurrCharge, fRawThreshold))
	self.wndMain:FindChild("OverchargeCurrentText"):SetText(String_GetWeaselString(Apollo.GetString("Achievements_ProgressBarProgress"), math.floor(fRawCurrCharge), math.floor(fRawThreshold)))

	self.wndMain:FindChild("FailChargeBar"):SetMax(fRawMaxOvercharge - fRawThreshold)
	self.wndMain:FindChild("FailChargeBar"):SetProgress(fRawCurrCharge - fRawThreshold)
	self.wndMain:FindChild("FailChargeBar"):SetFullSprite(fRawCurrCharge > fRawMaxOvercharge and "sprCircuit_Failcharge_ProgRed" or "sprCircuit_Failcharge_ProgBlue")
	self.wndMain:FindChild("FailChargeFrameFlair"):SetSprite(fRawCurrCharge > fRawMaxOvercharge and "sprCircuit_HandStopIcon" or "sprCircuit_CheckIcon")

	local bWasPercentShown = self.wndMain:FindChild("FailPercentText"):IsShown()
	-- Chance to fail text
	local nFailPercent = fRawCurrCharge > fRawMaxOvercharge and 100 or math.max(math.floor(nChanceToFail), 1)
	self.wndMain:FindChild("FailPercentText"):SetText(String_GetWeaselString(Apollo.GetString("CRB_Percent"), nFailPercent))
	self.wndMain:FindChild("FailPercentText"):Show(nChanceToFail > 0)

	if nChanceToFail > 0 and not bWasPercentShown then
		Sound.Play(Sound.PlayUICraftingOverchargeWarning)
	end


	local strWarningText = ""
	if fRawCurrCharge > fRawMaxOvercharge then
		strWarningText = Apollo.GetString("CBCrafting_TooMuchChargeError")
	elseif (fRawCurrCharge / fRawThreshold) < 0.75 then
		strWarningText = Apollo.GetString("CBCrafting_TooLittleChargeError")
	end
	return fRawCurrCharge < fRawMaxOvercharge, "<P Font=\"CRB_InterfaceSmall_O\" Align=\"Center\" TextColor=\"UI_TextMetalBodyHighlight\">"..strWarningText.."</P>"
end

function CircuitBoardSchematic:OnThresholdRotateBtnCheck(wndHandler, wndControl)
	local nSocketValue = wndHandler:FindChild("RotateBall"):GetData()
	local nLayoutLoc = wndHandler:FindChild("RotateTestBtn"):GetData()
	self.nTEMPThresholdSelected[nLayoutLoc] = nSocketValue
	self:UpdatePreview()
end

-----------------------------------------------------------------------------------------------
-- Circuit Picker Functions
-----------------------------------------------------------------------------------------------

function CircuitBoardSchematic:OnDestroyPropertyPicker(wndHandler, wndControl) -- Also from uncheck and window closed xml events, wndHandler is CircuitPickerBtn
	if self.wndPropertyPickerWindow and self.wndPropertyPickerWindow:IsValid() then
		if self.wndPropertyPickerWindow:GetData() then
			self.wndPropertyPickerWindow:GetData():SetCheck(false) -- TODO HACK
		end
		self.wndPropertyPickerWindow:Destroy()
		self.wndPropertyPickerWindow = nil
	end
	self:UpdatePreview() -- This needs to update and re-check CraftBtn's Enable vs Disable, as we temporarily turn it off while property picker is up
end

function CircuitBoardSchematic:OnBuildPropertyPicker(wndHandler, wndControl) -- wndHandler is CircuitPickerBtn, data is { self.tLayoutIdxToLoc[nSocketIdx], eBrutalityId }
	if self.wndPropertyPickerWindow and self.wndPropertyPickerWindow:IsValid() then
		self.wndPropertyPickerWindow:Destroy()
		self.wndPropertyPickerWindow = nil
	end

	local nLayoutLoc = wndHandler:GetData()[1]
	local eParentChipProperty = wndHandler:GetData()[2]
	local wndSocket = self.tSocketButtons[nLayoutLoc]
	self.wndPropertyPickerWindow = Apollo.LoadForm(self.xmlDoc, "PropertyPicker", self.wndMain, self)
	self.wndPropertyPickerWindow:SetData(wndHandler)

	-- Build duplicate comparison list
	local tAlreadyPresentTypes = {}
	for nIdx, itemCurr in pairs(self.tSocketItems) do
		local tCurrItemChipInfo = itemCurr:GetMicrochipInfo()
		if tCurrItemChipInfo and tCurrItemChipInfo.idUnitProperty then -- Can be looping through power cores and etc.
			tAlreadyPresentTypes[ tCurrItemChipInfo.idUnitProperty ] = true
		end
	end

	for nIdx, tSocket in pairs(self.tSchematicInfo.tSockets) do
		local itemChip = self:GetSystemSocketItem(nIdx)
		if itemChip ~= nil then
			local tCurrItemChipInfo = itemChip:GetMicrochipInfo()
			if tCurrItemChipInfo and tCurrItemChipInfo.idUnitProperty then -- Can be looping through power cores and etc.
				tAlreadyPresentTypes[ tCurrItemChipInfo.idUnitProperty ] = true
			end
		end
	end

	local nCurrentPowerCore = self.tSocketItems[1] and self.tSocketItems[1]:GetItemId()
	for eChipType, arProperties in pairs(CraftingLib.GetAvailableProperties(self.tSchematicInfo.nSchematicId, nCurrentPowerCore)) do
		for idx, eProperty in pairs(arProperties) do
			local wndButton = nil
			if eChipType == Item.CodeEnumMicrochipType.Resistor then
				wndButton = Apollo.LoadForm(self.xmlDoc, "PropertyPickerResistor", self.wndPropertyPickerWindow:FindChild("PropertyPickerResistorList"), self)
			elseif eChipType == Item.CodeEnumMicrochipType.Inductor then
				wndButton = Apollo.LoadForm(self.xmlDoc, "PropertyPickerInductor", self.wndPropertyPickerWindow:FindChild("PropertyPickerInductorList"), self)
			elseif eChipType == Item.CodeEnumMicrochipType.Capacitor then
				wndButton = Apollo.LoadForm(self.xmlDoc, "PropertyPickerCapacitor", self.wndPropertyPickerWindow:FindChild("PropertyPickerCapacitorList"), self)
			end

			local tMapping = ktCraftingAttributeIconsText[eProperty]
			wndButton:FindChild("PropertyPickerAGBIcon"):SetSprite(tMapping and tMapping[1] or "") -- GOTCHA: These are BGColor multiplied in xml (and why they are separate)
			wndButton:FindChild("PropertyPickerAGBBtn"):SetData({ wndSocket, eProperty, nLayoutLoc })

			wndButton:FindChild("PropertyPickerAGBTooltipHack"):SetTooltip(tMapping and tMapping[2] or "")
			if eParentChipProperty and eParentChipProperty == eProperty then
				wndButton:FindChild("PropertyPickerAGBBtn"):SetCheck(true)
				wndButton:FindChild("PropertyPickerAGBTooltipHack"):SetTooltip(Apollo.GetString("CBCrafting_CircuitTypeAlreadyPicked"))
			elseif tAlreadyPresentTypes[eProperty] then
				wndButton:FindChild("PropertyPickerAGBIcon"):SetBGColor(ApolloColor.new("55888888"))
				wndButton:FindChild("PropertyPickerAGBBtn"):Enable(false)
				wndButton:FindChild("PropertyPickerAGBTooltipHack"):SetTooltip(Apollo.GetString("CBCrafting_CircuitTypeAlreadyPicked"))
			end
		end
	end

	local nSocket = self.tLayoutLocToIdx[nLayoutLoc]
	local tSocketIdxData = nSocket and self.tSchematicInfo.tSockets[nSocket] or nil
	local bSocketTypeMatch = tSocketIdxData and tSocketIdxData.eSocketType
	self.wndPropertyPickerWindow:FindChild("PropertyPickerResistorCheck"):Show(bSocketTypeMatch and tSocketIdxData.eSocketType == Item.CodeEnumMicrochipType.Resistor)
	self.wndPropertyPickerWindow:FindChild("PropertyPickerInductorCheck"):Show(bSocketTypeMatch and tSocketIdxData.eSocketType == Item.CodeEnumMicrochipType.Inductor)
	self.wndPropertyPickerWindow:FindChild("PropertyPickerCapacitorCheck"):Show(bSocketTypeMatch and tSocketIdxData.eSocketType == Item.CodeEnumMicrochipType.Capacitor)

	-- Resize based on the longest window
	local nResistWidth = self.wndPropertyPickerWindow:FindChild("PropertyPickerResistorList"):ArrangeChildrenHorz(0)
	local nInducWidth = self.wndPropertyPickerWindow:FindChild("PropertyPickerInductorList"):ArrangeChildrenHorz(0)
	local nCapacWidth = self.wndPropertyPickerWindow:FindChild("PropertyPickerCapacitorList"):ArrangeChildrenHorz(0)
	local nMaxWidth = math.max(nResistWidth, nInducWidth, nCapacWidth) + 145

	local nLeft, nTop, nRight, nBottom = self.wndPropertyPickerWindow:GetAnchorOffsets()
	local nParentLeft, nParentTop, nParentRight, nParentBottom = wndSocket:GetParent():GetAnchorOffsets()
	self.wndPropertyPickerWindow:SetAnchorOffsets(nParentLeft + nLeft, nParentTop + nTop, nParentLeft + nLeft + nMaxWidth, nParentTop + nBottom)

	self.wndMain:FindChild("CraftButton"):Enable(false) -- When open, so no one accidentally clicks it. When closed, we'll do UpdatePreview() and re-enable accordingly.
	self.wndPropertyPickerWindow:Invoke()
end

function CircuitBoardSchematic:OnPropertyBtn(wndHandler, wndControl) -- PropertyPickerAlphaBtn or PropertyPickerBetaBtn or PropertyPickerGammaBtn
	local wndSocket = wndHandler:GetData()[1]
	local eProperty = wndHandler:GetData()[2]
	local nLayoutLoc = wndHandler:GetData()[3]
	local tSocketIdxData = self.tSchematicInfo.tSockets[ self.tLayoutLocToIdx[nLayoutLoc] ]

	if tSocketIdxData and tSocketIdxData.bIsChangeable and not tSocketIdxData.itemDefaultChip then -- Not valid mod conditions
		local nBestGuess = 2 -- We'll just start at the lowest chip (e.g. 3 Brutality)
		local nCurrentPowerCore = self.tSocketItems[1] and self.tSocketItems[1]:GetItemId()
		local tMicrochips = CraftingLib.GetAvailableMicrochips(self.tSchematicInfo.nSchematicId, eProperty, nBestGuess, 1, nCurrentPowerCore)
		if tMicrochips and tMicrochips[1] then
			self.tSocketItems[nLayoutLoc] = tMicrochips[1]
			wndSocket:FindChild("CircuitPickerSmallLeft"):Enable(false)
			wndSocket:FindChild("CircuitPickerSmallRight"):Enable(true)
			wndSocket:FindChild("CircuitPickerSmallLeft"):SetData({ nBestGuess = nBestGuess - 1, wndSocket = wndSocket, eProperty = eProperty, nLayoutLoc = nLayoutLoc })
			wndSocket:FindChild("CircuitPickerSmallRight"):SetData({ nBestGuess = nBestGuess + 1, wndSocket = wndSocket, eProperty = eProperty, nLayoutLoc = nLayoutLoc })
		end
	end

	self:OnDestroyPropertyPicker()
end

function CircuitBoardSchematic:OnCircuitPickerLeftRight(wndHandler, wndControl) -- CircuitPickerSmallLeft or CircuitPickerSmallRight
	local wndSocket = wndHandler:GetData().wndSocket
	local nBestGuess = wndHandler:GetData().nBestGuess
	local eProperty = wndHandler:GetData().eProperty
	local nLayoutLoc = wndHandler:GetData().nLayoutLoc
	local nCurrentPowerCore = self.tSocketItems[1] and self.tSocketItems[1]:GetItemId()

	-- nShiftRange is how far ahead to seek in GetAvailableMicrochips
	local nNewLeft = 0
	local nNewRight = 0
	local nShiftRange = 5

	local tMicrochips = CraftingLib.GetAvailableMicrochips(self.tSchematicInfo.nSchematicId, eProperty, nBestGuess, nShiftRange, nCurrentPowerCore)
	if tMicrochips and tMicrochips[nShiftRange] and Apollo.IsShiftKeyDown() and wndHandler:GetName() == "CircuitPickerSmallRight" then
		nNewLeft = nBestGuess + nShiftRange - 2
		nNewRight = nBestGuess + nShiftRange
		self.tSocketItems[nLayoutLoc] = tMicrochips[nShiftRange]
	elseif tMicrochips and tMicrochips[1] then
		nNewLeft = nBestGuess - 1
		nNewRight = nBestGuess + 1
		self.tSocketItems[nLayoutLoc] = tMicrochips[1]
	end

	-- Enable / Disable if valid
	local tValidLeft = CraftingLib.GetAvailableMicrochips(self.tSchematicInfo.nSchematicId, eProperty, nNewLeft, 1, nCurrentPowerCore)
	local tValidRight = CraftingLib.GetAvailableMicrochips(self.tSchematicInfo.nSchematicId, eProperty, nNewRight, 1, nCurrentPowerCore)
	wndSocket:FindChild("CircuitPickerSmallLeft"):Enable(tValidLeft and tValidLeft[1])
	wndSocket:FindChild("CircuitPickerSmallRight"):Enable(tValidRight and tValidRight[1])
	wndSocket:FindChild("CircuitPickerSmallLeft"):SetData({ nBestGuess = nNewLeft, wndSocket = wndSocket, eProperty = eProperty, nLayoutLoc = nLayoutLoc })
	wndSocket:FindChild("CircuitPickerSmallRight"):SetData({ nBestGuess = nNewRight, wndSocket = wndSocket, eProperty = eProperty, nLayoutLoc = nLayoutLoc })

	if self.wndArrowTutorial and self.wndArrowTutorial ~= -1 and self.wndArrowTutorial ~= 0 then
		self.wndArrowTutorial:Destroy()
		self.wndArrowTutorial = 0
	end

	self:OnDestroyPropertyPicker()
end

function CircuitBoardSchematic:OnPowerCoreItemBtn(wndHandler, wndControl) -- PowerCoreItemBtn, data is tCurrentPowerCore
	self.wndMain:FindChild("SocketsLayer"):FindChild("PowerCorePickerBtn"):SetCheck(false)
	self.tSocketItems = {} -- Wipe all previous chip data, as there may now be invalid choices
	self.tSocketItems[1] = wndHandler:GetData()
	self:UpdatePreview()
end

-----------------------------------------------------------------------------------------------
-- Helper Functions
-----------------------------------------------------------------------------------------------

function CircuitBoardSchematic:HelperGetUserSelection() -- Also from Crafting.lua
	local tMicrochips = {}
	local tThresholds = {}
	for idx = 1, #self.tSchematicInfo.tSockets do
		local nLayoutLoc = self.tLayoutIdxToLoc[idx] -- TODO REFACTOR: These arrays are parallel and can be rewritten
		if nLayoutLoc then
			tMicrochips[idx] = 0
			if self.tSocketItems[nLayoutLoc] then
				tMicrochips[idx] = self.tSocketItems[nLayoutLoc]:GetItemId()
			end

			tThresholds[idx] = 0
			if self.tSocketThresholds[nLayoutLoc] and self.nTEMPThresholdSelected[nLayoutLoc] then
				tThresholds[idx] = self.nTEMPThresholdSelected[nLayoutLoc] - 1 -- GOTCHA: C++ is index by 0 instead of 1
			end
		end
	end
	return tMicrochips, tThresholds
end

function CircuitBoardSchematic:GetSocketLocationWithParents(idx, nParent, nParentCount)
	-- This is necessary because we the data provided doesn't know it's location. So parents must be used to deduce it.
	if nParent == 0 then
		return 1
	end

	local nParentLoc = self.tLayoutIdxToLoc[nParent]
	if not nParentLoc then
		-- malformed schematic
		return nil
	end

	local karSocketChildOffsets = { 1, 3, 5, 7 }
	local nChildOffset = karSocketChildOffsets[nParentLoc]
	if not nChildOffset then
		-- malformed schematic
		return nil
	end

	local nTarget = nParentLoc + nChildOffset
	if nParentCount == 1 then
		return nTarget + 1
	end

	if nParentCount == 2 then
		if self.tLayoutLocToIdx[nTarget] then
			return nTarget + 2
		else
			return nTarget
		end
	end

	if self.tLayoutLocToIdx[nTarget + 1] then
		return nTarget + 2
	elseif self.tLayoutLocToIdx[nTarget] then
		return nTarget + 1
	else
		return nTarget
	end
end

function CircuitBoardSchematic:GetSystemSocketItem(nSocket)
	-- get the server selected random chip
	local tCurrentCraft = CraftingLib.GetCurrentCraft()
	if tCurrentCraft and tCurrentCraft.tMicrochips and tCurrentCraft.tMicrochips[nSocket].itemChip then
		return tCurrentCraft.tMicrochips[nSocket].itemChip
	end
	-- get the static defined chip
	if self.tSchematicInfo.tSockets[nSocket].itemDefaultChip then
		return self.tSchematicInfo.tSockets[nSocket].itemDefaultChip
	end
	return nil
end

function CircuitBoardSchematic:OnTutorialItemBtn(wndHandler, wndControl)
	self.luaOwner:OnTutorialItemBtn(wndHandler, wndControl)
end

function CircuitBoardSchematic:OnCraftingUpdateCurrent()
	local nLastSchematicId = self.tSchematicInfo.nSchematicId or 0
	if not nLastSchematicId or nLastSchematicId == 0 then
		return
	end

	local tCurrentCraft = CraftingLib.GetCurrentCraft()
	self.tSchematicInfo = CraftingLib.GetSchematicInfo(nLastSchematicId)

	if not tCurrentCraft or not tCurrentCraft.tMicrochips then
		return
	end

	for idx, nLocation in pairs(self.tLayoutIdxToLoc) do
		-- If the randomized chip is defined then update the socket.
		-- This will be a server-determined random chip.
		if tCurrentCraft.tMicrochips[idx].itemChip then
			local wndSocketButton = self.tSocketButtons[nLocation]
			if not wndSocketButton:FindChild("CircuitPickerBtn") then
				-- Oops, we are closing so not all the sub windows exist and no need to update.
				return
			end
			self.tSocketItems[wndSocketButton:GetData()] = nil
			self:UpdatePreview()
		end
	end
end

function CircuitBoardSchematic:HelperBuildTooltip(wndOwner, wndParent, itemCurr )
	wndParent:DestroyChildren()

	-- Set up Flags. Unique flags are bInvisibleFrame and tModData.
	local tFlags = { bInvisibleFrame = true, bPermanent = true, wndParent = wndParent, bNotEquipped = true, bPrimary = true }

	local tResult = Tooltip.GetItemTooltipForm(wndOwner, wndParent, itemCurr, tFlags)
	local wndTooltip = nil
	if tResult then
		if type(tResult) == 'table' then
			wndTooltip = tResult[0]
		elseif type(tResult) == 'userdata' then
			wndTooltip = tResult
		end
	end

	if wndTooltip then
		local nLeft, nTop, nRight, nBottom = wndParent:GetAnchorOffsets()
		wndParent:SetAnchorOffsets(nLeft, nTop, nRight + wndTooltip:GetWidth(), nTop + wndTooltip:GetHeight())
	end
end

function CircuitBoardSchematic:HelperBuildItemTooltip(wndArg, itemCurr)
	if itemCurr == "" then
		wndArg:SetTooltip("")
		return
	end

	local itemEquipped = itemCurr and itemCurr:GetEquippedItemForItemType() or nil
	Tooltip.GetItemTooltipForm(self, wndArg, itemCurr, {bPrimary = true, bSelling = false, itemCompare = itemEquipped})
end
 Tooltip="">
        <Control Class="Window" LAnchorPoint="0" LAnchorOffset="20" TAnchorPoint="1" TAnchorOffset="-80" RAnchorPoint="1" RAnchorOffset="-20" BAnchorPoint="1" BAnchorOffset="-14" RelativeToClient="1" Font="CRB_Interface9" Text="" BGColor="UI_WindowBGDefault" TextColor="UI_TextMetalBodyHighlight" Template="Default" TooltipType="OnCursor" Name="DyeChannelText" TooltipColor="" DT_RIG