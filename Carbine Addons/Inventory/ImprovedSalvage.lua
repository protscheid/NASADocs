require "Window"
require "Apollo"
require "ApolloCursor"
require "GameLib"
require "Item"

local ImprovedSalvage = {}

local kidBackpack = 0

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

function ImprovedSalvage:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	return o
end

function ImprovedSalvage:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ImprovedSalvage.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self) 
end

function ImprovedSalvage:OnDocumentReady()
	if self.xmlDoc == nil then
		return
	end
	
	Apollo.RegisterEventHandler("WindowManagementReady", 	"OnWindowManagementReady", self)
	
	Apollo.RegisterEventHandler("RequestSalvageAll", "OnSalvageAll", self) -- using this for bag changes
	Apollo.RegisterSlashCommand("salvageall", "OnSalvageAll", self)

	self.wndMain = Apollo.LoadForm(self.xmlDoc, "ImprovedSalvageForm", nil, self)
	self.wndItemDisplay = self.wndMain:FindChild("ItemDisplayWindow")
	
	if self.locSavedWindowLoc then
		self.wndMain:MoveToLocation(self.locSavedWindowLoc)
	end
	
	self.tContents = self.wndMain:FindChild("HiddenBagWindow")
	self.arItemList = nil
	self.nItemIndex = nil

	self.wndMain:Show(false, true)
end

function ImprovedSalvage:OnWindowManagementReady()
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndMain, strName = Apollo.GetString("CRB_Salvage")})
end

--------------------//-----------------------------
function ImprovedSalvage:OnSalvageAll()
	self.arItemList = {}
	self.nItemIndex = 1
	
	local tInvItems = GameLib.GetPlayerUnit():GetInventoryItems()
	for idx, tItem in ipairs(tInvItems) do
		if tItem and tItem.itemInBag and tItem.itemInBag:CanSalvage() and not tItem.itemInBag:CanAutoSalvage() then
			table.insert(self.arItemList, tItem.itemInBag)
		end
	end

	self:RedrawAll()
end

function ImprovedSalvage:OnSalvageListItemCheck(wndHandler, wndControl)
	if not wndHandler or not wndHandler:GetData() then
		return
	end
	
	self.nItemIndex = wndHandler:GetData().nIdx
	
	local itemCurr = self.arItemList[self.nItemIndex]
	self.wndMain:SetData(itemCurr)
	self.wndMain:FindChild("SalvageBtn"):SetActionData(GameLib.CodeEnumConfirmButtonType.SalvageItem, itemCurr:GetInventoryId())
end

function ImprovedSalvage:OnSalvageListItemGenerateTooltip(wndControl, wndHandler) -- wndHandler is VendorListItemIcon
	if wndHandler ~= wndControl then
		return
	end

	wndControl:SetTooltipDoc(nil)

	local tListItem = wndHandler:GetData().tItem
	local tPrimaryTooltipOpts = {}

	tPrimaryTooltipOpts.bPrimary = true
	tPrimaryTooltipOpts.itemModData = tListItem.itemModData
	tPrimaryTooltipOpts.strMaker = tListItem.strMaker
	tPrimaryTooltipOpts.arGlyphIds = tListItem.arGlyphIds
	tPrimaryTooltipOpts.tGlyphData = tListItem.itemGlyphData
	tPrimaryTooltipOpts.itemCompare = tListItem:GetEquippedItemForItemType()

	if Tooltip ~= nil and Tooltip.GetSpellTooltipForm ~= nil then
		Tooltip.GetItemTooltipForm(self, wndControl, tListItem, tPrimaryTooltipOpts, tListItem.nStackSize)
	end
end

function ImprovedSalvage:RedrawAll()
	local itemCurr = self.arItemList[self.nItemIndex]
	
	if itemCurr ~= nil then
		local wndParent = self.wndMain:FindChild("MainScroll")
		local nScrollPos = wndParent:GetVScrollPos()
		wndParent:DestroyChildren()
		
		for idx, tItem in ipairs(self.arItemList) do
			local wndCurr = Apollo.LoadForm(self.xmlDoc, "SalvageListItem", wndParent, self)
			wndCurr:FindChild("SalvageListItemBtn"):SetData({nIdx = idx, tItem=tItem})
			wndCurr:FindChild("SalvageListItemBtn"):SetCheck(idx == self.nItemIndex)
			
			wndCurr:FindChild("SalvageListItemTitle"):SetTextColor(karEvalColors[tItem:GetItemQuality()])
			wndCurr:FindChild("SalvageListItemTitle"):SetText(tItem:GetName())
			
			local bTextColorRed = self:HelperPrereqFailed(tItem)
			wndCurr:FindChild("SalvageListItemType"):SetTextColor(bTextColorRed and "xkcdReddish" or "UI_TextHoloBodyCyan")
			wndCurr:FindChild("SalvageListItemType"):SetText(tItem:GetItemTypeName())
			
			wndCurr:FindChild("SalvageListItemCantUse"):Show(bTextColorRed)
			wndCurr:FindChild("SalvageListItemIcon"):GetWindowSubclass():SetItem(tItem)
		end
		
		wndParent:ArrangeChildrenVert(0)
		wndParent:SetVScrollPos(nScrollPos)
	
		self.wndMain:SetData(itemCurr)
		self.wndMain:FindChild("SalvageBtn"):SetActionData(GameLib.CodeEnumConfirmButtonType.SalvageItem, itemCurr:GetInventoryId())
		self.wndMain:Show(true)
		self.wndMain:ToFront()
	else
		self.wndMain:Show(false)
	end
	
end

function ImprovedSalvage:HelperPrereqFailed(tCurrItem)
	return tCurrItem and tCurrItem:IsEquippable() and not tCurrItem:CanEquip()
end

function ImprovedSalvage:OnSalvageCurr()
	if self.nItemIndex == #self.arItemList then 
		table.remove(self.arItemList, self.nItemIndex )
		self.nItemIndex = self.nItemIndex - 1
	else
		table.remove(self.arItemList, self.nItemIndex )
	end
	
	self:RedrawAll()
end

function ImprovedSalvage:OnCloseBtn()
	self.arItemList = {}
	self.wndMain:SetData(nil)
	self.wndMain:Show(false)
end

----------------globals----------------------------

local ImprovedSalvage_Singleton = ImprovedSalvage:new()
Apollo.RegisterAddon(ImprovedSalvage_Singleton)
ntrol Class="Button" Base="BK3:btnHolo_Pin_2" Font="Thick" ButtonType="Check" RadioGroup="" LAnchorPoint="1" LAnchorOffset="-19" TAnchorPoint="0.5" TAnchorOffset="-9" RAnchorPoint="1" RAnchorOffset="2" BAnchorPoint="0.5" BAnchorOffset="12" DT_VCENTER="1" DT_CENTER="1" TooltipType="OnCursor" Name="PinBtn" BGColor="UI_AlphaPercent60" TextColor="white" TooltipColor="" NormalTextColor="white" PressedTextColor="white" FlybyTextColor="white" PressedFlybyTextColor="white" DisabledTextColor="white" Sprite="" Tooltip="" RelativeToClient="1" TooltipId="" TestAlpha="0">
            <Event Name="ButtonCheck" Function="OnPinBtnChecked"/>
            <Event Name="ButtonUncheck" Function="OnPinBtnChecked"/>
        </Control>
        <Control Class="Window" LAnchorPoint="0" LAnchorOffset="-8" TAnchorPoint="0" TAnchorOffset="-5" RAnchorPoint="0" RAnchorOffset="30" BAnchorPoint="0" BAnchorOffset="33" RelativeToClient="1" Font="Default" Text="" BGColor="UI_WindowBGDefault" TextColor="UI_WindowTextDefault" Template="Default" TooltipType="OnCursor" Name="IconContainer" TooltipColor="" Picture="0" IgnoreMouse="1" Sprite="" NoClip="0" Tooltip="">
            <Control Class="Window" LAnchorPoint="0.5" LAnchorOffset="-12" TAnchorPoint="0.5" TAnchorOffset="-12" RAnchorPoint="0.5" RAnchorOffset="12" BAnchorPoint="0.5" BAnchorOffset="12" RelativeToClient="1" Font="CRB_Header10" Text="" BGColor="UI_WindowBGDefault" TextColor="UI_BtnTextHoloNormal" Template="Default" TooltipType="OnCursor" Name="Icon" TooltipColor="" Picture="1" IgnoreMouse="1" Sprite="" Tooltip="" TooltipId="" TooltipFont="CRB_InterfaceSmall_O" DT_CENTER="1" DT_VCENTER="1"/>
        </Control>
    </Form>
    <Form Class="Window" LAnchorPoint="0" LAnchorOffset="0" TAnchorPoint="0" TAnchorOffset="0" RAnchorPoint="0" RAnchorOffset="26" BAnchorPoint="0" BAnchorOffset="26" RelativeToClient="0" Font="Default" Text="" BGColor="UI_WindowBGDefault" TextColor="UI_WindowTextDefault" Template="Default" TooltipType="OnCursor" Name="InterfaceMenuButton" Border="0" Picture="1" SwallowMouseClicks="1" Moveable="0" Escapable="0" Overlapped="0" TooltipColor="" IgnoreMouse="1" NoClip="0" Tooltip="">
        <Control Class="Button" Base="HUD_BottomBar:btn_HUD_MenuIconBtn" Font="CRB_InterfaceSmall_O" ButtonType="PushButton" RadioGroup="" LAnchorPoint="0" LAnchorOffset="-6" TAnchorPoint="0" TAnchorOffset="-6" RAnchorPoint="0" RAnchorOffset="32" BAnchorPoint="0" BAnchorOffset="32" DT_VCENTER="1" DT_CENTER="1" TooltipType="OnCurs