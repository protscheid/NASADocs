-----------------------------------------------------------------------------------------------
-- Client Lua Script for Reputation
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "GameLib"

local Reputation = {}

local karRepToColor =
{
	ApolloColor.new("ff9aaea3"),
	ApolloColor.new("ff9aaea3"), -- Neutral
	ApolloColor.new("ff836725"), -- Liked
	ApolloColor.new("ffc1963d"), -- Accepted
	ApolloColor.new("fff1efda"), -- Popular
	ApolloColor.new("fffefbb5"), -- Esteemed
	ApolloColor.new("ffd5b66d"), -- Beloved
}

function Reputation:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Reputation:Init()
    Apollo.RegisterAddon(self)
end

-----------------------------------------------------------------------------------------------
-- Reputation OnLoad
-----------------------------------------------------------------------------------------------

function Reputation:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("Reputation.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

function Reputation:OnDocumentReady()
	if self.xmlDoc == nil then
		return
	end
	Apollo.RegisterEventHandler("GenericEvent_InitializeReputation", "OnGenericEvent_InitializeReputation", self)
	Apollo.RegisterEventHandler("GenericEvent_DestroyReputation", "OnGenericEvent_DestroyReputation", self)
	Apollo.RegisterEventHandler("ReputationChanged", "OnReputationChanged", self)
end

function Reputation:OnGenericEvent_InitializeReputation(wndParent)
	if self.wndMain and self.wndMain:IsValid() then
		self:ResetData()
		self:PopulateFactionList()
		return
	end

    self.wndMain = Apollo.LoadForm(self.xmlDoc, "ReputationForm", wndParent, self)
	if self.locSavedWindowLoc then
		self.wndMain:MoveToLocation(self.locSavedWindowLoc)
	end

	self.tReputationLevels = GameLib.GetReputationLevels()
	self.tStrToWndMapping = {}

	-- Default Height Constants
	-- nContainerTop - nBottom - nButtonBottom twice for top and bottom margin
	local wndHeight = Apollo.LoadForm(self.xmlDoc, "ListItemLabel", self.wndMain, self)
	local nLeft, nTop, nRight, nBottom = wndHeight:GetAnchorOffsets()
	local nButtonBottom = ({wndHeight:FindChild("ItemsBtn"):GetAnchorOffsets()})[4]
	local nContainerTop = ({wndHeight:FindChild("ItemsContainer"):GetAnchorOffsets()})[2]
	self.knHeightLabel = nBottom - nTop
	self.knExpandedHeightLabel = (nBottom - nTop) + (nContainerTop - nBottom - nButtonBottom) + (nContainerTop - nBottom - nButtonBottom)
	wndHeight:Destroy()

	wndHeight = Apollo.LoadForm(self.xmlDoc, "ListItemProgress", self.wndMain, self)
	nLeft, nTop, nRight, nBottom = wndHeight:GetAnchorOffsets()
	self.knHeightProgress = nBottom - nTop
	wndHeight:Destroy()

	wndHeight = Apollo.LoadForm(self.xmlDoc, "ListItemTopLevel", self.wndMain, self)
	nLeft, nTop, nRight, nBottom = wndHeight:GetAnchorOffsets()
	nButtonBottom = ({wndHeight:FindChild("ItemsBtn"):GetAnchorOffsets()})[4]
	nContainerTop = ({wndHeight:FindChild("ItemsContainer"):GetAnchorOffsets()})[2]
	self.knHeightTop = nBottom - nTop

	-- nContainerTop - nBottom - nButtonBottom twice for top and bottom margin + extra
	self.knExpandedHeightTop = (nBottom - nTop) + (nContainerTop - nBottom - nButtonBottom) + (nContainerTop - nBottom - nButtonBottom) + 35
	wndHeight:Destroy()

	self.tRepCount = 0

	self.tTopLabels = {}
	self.tSubLabels = {}
	self.tProgress	= {}

	self:ResetData()
	self:PopulateFactionList()
end

-----------------------------------------------------------------------------------------------
-- Reputation Functions
-----------------------------------------------------------------------------------------------

function Reputation:OnReputationChanged(tFaction)
	if not self.wndMain or not self.wndMain:IsValid() or not self.wndMain:IsVisible() then
		return
	end

	if self.tStrToWndMapping[tFaction.strParent] then -- Find if the parent and it exists
		for key, wndCurr in pairs(self.tStrToWndMapping[tFaction.strParent]:FindChild("ItemsContainer"):GetChildren()) do
			if wndCurr:GetData() == Apollo.StringToLower(tFaction.nOrder .. tFaction.strName) then
				self:BuildListItemProgress(wndCurr, tFaction)
				return
			end
		end
	end

	-- Add a new entry in the full redraw if we didn't find the parent or itself
	self:ResetData()
	self:PopulateFactionList()
end

function Reputation:OnGenericEvent_DestroyReputation()
	if self.wndMain and self.wndMain:IsValid() then
		self.wndMain:Destroy()
		self.wndMain = nil
		self.tStrToWndMapping = {}
	end
end

function Reputation:ResetData()
	self.tStrToWndMapping = {}
	self.wndMain:FindChild("FactionList"):DestroyChildren()
end

function Reputation:SortReps(tRepTable)
	self.tTopLabels = {}
	self.tSubLabels = {}
	self.tProgress = {}
	for idx, tReputation in pairs(tRepTable) do
		local bHasParent = tReputation.strParent and string.len(tReputation.strParent) > 0
		if not bHasParent then
			table.insert(self.tTopLabels, tReputation)
		elseif tReputation.bIsLabel then
			table.insert(self.tSubLabels, tReputation)
		else
			table.insert(self.tProgress, tReputation)
		end
	end
end

function Reputation:PopulateFactionList()
	local tReputations = GameLib.GetReputationInfo()
	if not tReputations then
		return
	end

	self.tRepCount = #tReputations
	self:SortReps(tReputations)

	local nSafetyCount = 0
	for idx, tReputation in pairs(self.tTopLabels) do
		nSafetyCount = nSafetyCount + 1
		if nSafetyCount < 99 then
			self:BuildFaction(tReputation, nil)
		end
	end

	for idx, tReputation in pairs (self.tSubLabels) do
		nSafetyCount = nSafetyCount + 1
		if nSafetyCount < 99 then
			self:BuildFaction(tReputation, self.tStrToWndMapping[tReputation.strParent])
		end
	end

	for idx, tReputation in pairs (self.tProgress) do
		nSafetyCount = nSafetyCount + 1
		if nSafetyCount < 99 then
			self:BuildFaction(tReputation, self.tStrToWndMapping[tReputation.strParent])
		end
	end

	-- Else condition is bHasParent but not mapped yet, in which case we try again later
	if nSafetyCount >= 99 then
		for idx, tFaction in pairs(tReputations) do
			ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug, String_GetWeaselString(Apollo.GetString("Reputation_NotFound"), tFaction.strParent))
		end
	end

	-- Sort list
	for key, wndCurr in pairs(self.tStrToWndMapping) do
		wndCurr:FindChild("ItemsContainer"):ArrangeChildrenVert(0, function(a,b) return (a:GetData() < b:GetData()) end)
	end
	self.wndMain:FindChild("FactionList"):ArrangeChildrenVert(0, function(a,b) return (a:GetData() < b:GetData()) end)

	self:ResizeItemContainer()
end

function Reputation:BuildFaction(tFaction, wndParent)
	-- This method is agnostic to what level it is at. It must work for level 2 and level 3 data and thus the XML has the same window names at all levels.
	if wndParent and not wndParent:FindChild("ItemsBtn"):IsChecked() then
		return
	end

	local wndCurr = nil
	-- There are 3 types of windows: Progress Bar, Labels with children, and Top Level (which has different bigger button art)
	if not wndParent then
		wndCurr = Apollo.LoadForm(self.xmlDoc, "ListItemTopLevel", self.wndMain:FindChild("FactionList"), self)
		wndCurr = self:BuildTopLevel(wndCurr, tFaction)
	elseif tFaction.bIsLabel then
		wndCurr = Apollo.LoadForm(self.xmlDoc, "ListItemLabel", wndParent:FindChild("ItemsContainer"), self)
		wndCurr:FindChild("ItemsBtn"):SetCheck(true)
		wndCurr:FindChild("ItemsBtnText"):SetText(tFaction.strName)
		self.tStrToWndMapping[tFaction.strName] = wndCurr
	else
		wndCurr = Apollo.LoadForm(self.xmlDoc, "ListItemProgress", wndParent:FindChild("ItemsContainer"), self)
		wndCurr = self:BuildListItemProgress(wndCurr, tFaction)
	end

	-- This data is used for sorting (First by Order then by Name if there is a tie. Lua's "<" operator will handle this on string comparisons.)
	wndCurr:SetData(Apollo.StringToLower(tFaction.nOrder .. tFaction.strName))
end

function Reputation:BuildTopLevel(wndCurr, tFaction)
	wndCurr:FindChild("ItemsBtn"):SetCheck(true)
	wndCurr:FindChild("ItemsBtnText"):SetText(tFaction.strName)
	wndCurr:FindChild("BaseProgressLevelBarC"):Show(not tFaction.bIsLabel)
	if not tFaction.bIsLabel then
		local tLevelData = self.tReputationLevels[tFaction.nLevel]
		wndCurr:FindChild("BaseProgressLevelBar"):SetMax(tLevelData.nMax)
		wndCurr:FindChild("BaseProgressLevelBar"):SetProgress(tFaction.nCurrent)
		wndCurr:FindChild("BaseProgressLevelText"):SetText(String_GetWeaselString(Apollo.GetString("TargetFrame_TextProgress"), Apollo.FormatNumber(tFaction.nCurrent, 0, true), Apollo.FormatNumber(tLevelData.nMax, 0, true)))
	end
	
	self.tStrToWndMapping[tFaction.strName] = wndCurr
	return wndCurr
end

function Reputation:BuildListItemProgress(wndCurr, tFaction)
	local tLevelData = self.tReputationLevels[tFaction.nLevel]
	wndCurr:FindChild("ProgressName"):SetText(tFaction.strName)
	wndCurr:FindChild("ProgressStatus"):SetText(tLevelData.strName)
	wndCurr:FindChild("ProgressStatus"):SetTextColor(karRepToColor[tFaction.nLevel + 1])
	wndCurr:FindChild("ProgressLevelBar"):SetMax(tLevelData.nMax)
	wndCurr:FindChild("ProgressLevelBar"):SetProgress(tFaction.nCurrent)
	wndCurr:FindChild("ProgressLevelBar"):SetBarColor(karRepToColor[tFaction.nLevel + 1])
	wndCurr:FindChild("ProgressLevelBar"):EnableGlow(tFaction.nCurrent > tLevelData.nMin)
	wndCurr:SetTooltip(string.format("%s/%s", Apollo.FormatNumber(tFaction.nCurrent, 0, true), Apollo.FormatNumber(tLevelData.nMax,0,true)))

	local strTooltip = String_GetWeaselString(Apollo.GetString("Reputation_ProgressText"), tFaction.strName, tLevelData.strName, Apollo.FormatNumber(tFaction.nCurrent, 0, true), Apollo.FormatNumber(tLevelData.nMax,0,true))
	return wndCurr
end

-----------------------------------------------------------------------------------------------
-- Resize Code
-----------------------------------------------------------------------------------------------

function Reputation:OnTopLevelToggle(wndHandler, wndControl) -- wndHandler is "ListItemTopLevel's ItemsBtn"
	self:ResizeItemContainer()
end

function Reputation:OnMiddleLevelLabelToggle(wndHandler, wndControl) -- wndHandler "ListItemLabel's ItemsBtn"
	self:ResizeItemContainer()
end

function Reputation:ResizeItemContainer()
	for key, wndTopGroup in pairs(self.wndMain:FindChild("FactionList"):GetChildren()) do
		local wndTopContainer = wndTopGroup:FindChild("ItemsContainer")
		local wndTopButton = wndTopGroup:FindChild("ItemsBtn")
		
		wndTopGroup:Show(#wndTopContainer:GetChildren() > 0)
		if wndTopGroup:IsShown() then
			local nTopHeight = self.knHeightTop

			local nMiddleHeight = 0
			wndTopContainer:Show(wndTopButton:IsChecked())
			
			local bEnableTop = false
			if wndTopButton:IsChecked() then
				nTopHeight = self.knExpandedHeightTop
				local bEnableMid = false
				for idx, wndMiddleGroup in pairs(wndTopContainer:GetChildren()) do
					local wndMiddleContainer = wndMiddleGroup:FindChild("ItemsContainer")
					local wndMiddleButton = wndMiddleGroup:FindChild("ItemsBtn")
					wndMiddleGroup:Show(not wndMiddleContainer or #wndMiddleContainer:GetChildren() > 0)

					if wndMiddleGroup:IsShown() then
						local nBottomHeight = 0
						local nHeightToUse = self.knHeightProgress
						

						-- Special formatting if it has a container (different height, show/hide, and arrange vert)
						if wndMiddleContainer then
							nHeightToUse = self.knHeightLabel
							
							wndMiddleContainer:Show(wndMiddleButton:IsChecked())
							
							if wndMiddleButton:IsChecked() then
								nBottomHeight = self.knHeightProgress * #wndMiddleContainer:GetChildren()
								nHeightToUse = self.knExpandedHeightLabel
							end
							
							if #wndMiddleContainer:GetChildren() > 0 and not bEnableMid then
								bEnableMid = true
							end
							
							wndMiddleContainer:ArrangeChildrenVert(0)
						end
						-- End special formatting

						local nLeft, nTop, nRight, nBottom = wndMiddleGroup:GetAnchorOffsets()
						wndMiddleGroup:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nBottomHeight + nHeightToUse)
						nMiddleHeight = nMiddleHeight + nBottomHeight + nHeightToUse
						
						if wndMiddleButton then
							if not bEnableMid then
								wndMiddleButton:SetCheck(false)
							end
							wndMiddleButton:Enable(bEnableMid)
						end
						
						if not bEnableTop then
							bEnableTop = true
						end
					end
				end
				if not bEnableTop then
					wndTopButton:SetCheck(false)
				end
				wndTopButton:Enable(bEnableTop)
			end

			local nLeft, nTop, nRight, nBottom = wndTopGroup:GetAnchorOffsets()
			wndTopGroup:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nMiddleHeight + nTopHeight)
			wndTopGroup:FindChild("ItemsContainer"):ArrangeChildrenVert(0)
		end
	end

	self.wndMain:FindChild("FactionList"):ArrangeChildrenVert(0)
end

local ReputationInst = Reputation:new()
ReputationInst:Init()
ignal" Function="ReportChat_NoPicked"/>
        </Control>
        <Pixie LAnchorPoint="0" LAnchorOffset="100" TAnchorPoint="0" TAnchorOffset="40" RAnchorPoint="1" RAnchorOffset="-100" BAnchorPoint="0" BAnchorOffset="84" BGColor="UI_WindowBGDefault" Font="CRB_HeaderMedium" TextColor="UI_WindowTitleYellow" Text="" TextId="ReportPlayer_Title" DT_CENTER="1" DT_VCENTER="1" Line="0"/>
        <Control Class="Button" Base="BK3:btnHolo_Check" Font="CRB_InterfaceMedium" ButtonType="Check" RadioGroup="" LAnchorPoint="0" LAnchorOffset="70" TAnchorPoint="1" TAnchorOffset="-82" RAnchorPoint="1" RAnchorOffset="-67" BAnchorPoint="1" BAnchorOffset="-44" DT_VCENTER="1" DT_CENTER="0" BGColor="UI_BtnBGDefault" TextColor="UI_BtnTextHoloListNormal" NormalTextColor="UI_TextHoloBody" PressedTextColor="UI_TextHoloBody" FlybyTextColor="UI_BtnTextBlueFlyby" PressedFlybyTextColor="UI_BtnTextBluePressedFlyby" DisabledTextColor="UI_BtnTextBlueDisabled" TooltipType="OnCursor" Name="IgnorePlayerCheckbox" TooltipColor="" Text="" TextId="ReportPlayer_AlsoAddToIgnoreList" DT_RIGHT="0" RelativeToClient="1" TooltipFont="CRB_InterfaceSmall_O" Tooltip="" TooltipId="ReportPlayer_IgnoreListTooltip" DT_WORDBREAK="1" DrawAsCheckbox="1">
            <Event Name="ButtonCheck" Function="OnIgnorePlayerCheckboxToggle"/>
            <Event Name="ButtonUncheck" Function="OnIgnorePlayerCheckboxToggle"/>
        </Control>
    </Form>
    <Form Class="Window" LAnchorPoint="0.5" LAnchorOffset="-225" TAnchorPoint="0.5" TAnchorOffset="-230" RAnchorPoint="0.5" RAnchorOffset="225" BAnchorPoint="0.5" BAnchorOffset="230" RelativeToClient="1" Font="Default" Text="" Template="Default" Name="ReportPlayerNamePicker" Border="0" Picture="1" SwallowMouseClicks="1" Moveable="1" Escapable="1" Overlapped="1" BGColor="white" TextColor="white" Sprite="BK3:UI_BK3_Holo_Framing_1" TransitionShowHide="1" TooltipColor="" Tooltip="" TestAlpha="1">
        <Event Name="WindowClosed" Function="OnNamePickerClose"/>
        <Control Class="Window" LAnchorPoint="0" LAnchorOffset="70" TAnchorPoint="0" TAnchorOffset="90" RAnchorPoint="1" RAnchorOffset="-70" BAnchorPoint="0" BAnchorOffset="185" RelativeToClient="1" Font="Default" Text="" BGColor="UI_WindowBGDefault" TextColor="UI_WindowTextDefault" Template="Default" TooltipType="OnCursor" Name="LastTargetContainer1" TooltipColor="" Picture="1" IgnoreMouse="1" Sprite="BK3:UI_BK3_Holo_InsetHeaderThin">
            <Pixie LAnchorPoint="0" LAnchorOffset="10" TAnchorPoint="0" TAnchorOffset="5" RAnchorPoint="1" RAnchorOffset="-10" BAnchorPoint="0" BAnchorOffset="30" BGColor="UI_WindowBGDefault" Font="CRB_InterfaceMedium" TextColor="UI_TextHoloTitle" Text="" TextId="ReportPlayer_LastTarget" DT_VCENTER="1" Line="0" DT_CENTER="1"/>
            <Control Class="Window" LAnchorPoint="1" LAnchorOffset="-27" TAnchorPoint="0" TAnchorOffset="7" RAnchorPoint="1" RAnchorOffset="-5" BAnchorPoint="0" BAnchorOffset="29" RelativeToClient="1" Font="Default" Text="" BGColor="UI_WindowBGDefault" TextColor="UI_WindowTextDefault" Template="Default" TooltipType="OnCursor" Name="LastTargetTooltipExplain1" TooltipColor="white" Sprite="CRB_Basekit:kitIcon_Holo_QuestionMark