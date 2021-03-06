-----------------------------------------------------------------------------------------------
-- Client Lua Script for CrowdControlGameplay
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "Unit"
require "GameLib"

local CrowdControlGameplay = {}

function CrowdControlGameplay:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function CrowdControlGameplay:Init()
    Apollo.RegisterAddon(self)
end

function CrowdControlGameplay:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("CrowdControlGameplay.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

function CrowdControlGameplay:OnDocumentReady()
	if self.xmlDoc == nil then
		return
	end
	Apollo.RegisterEventHandler("ActivateCCStateStun", "OnActivateCCStateStun", self) -- Starting the UI
	Apollo.RegisterEventHandler("UpdateCCStateStun", "OnUpdateCCStateStun", self) -- Hitting the interact key
	Apollo.RegisterEventHandler("RemoveCCStateStun", "OnRemoveCCStateStun", self) -- Close the UI
	Apollo.RegisterEventHandler("StunVGPressed", "OnStunVGPressed", self)
	
	self.wndProgress = nil
end

-----------------------------------------------------------------------------------------------
-- Rapid Tap
-----------------------------------------------------------------------------------------------

function CrowdControlGameplay:OnActivateCCStateStun(eChosenDirection)
	if self.wndProgress and self.wndProgress:IsValid() then
		self.wndProgress:Destroy()
		self.wndProgress = nil
	end

	self.wndProgress = Apollo.LoadForm(self.xmlDoc, "ButtonHit_Progress", nil, self)
	self.wndProgress:Show(true) -- to get the animation
	self.wndProgress:FindChild("TimeRemainingContainer"):Show(false)

	local strNone		= Apollo.GetString("Keybinding_Unbound")
	local strLeft 		= GameLib.GetKeyBinding("StunBreakoutLeft")
	local strUp 		= GameLib.GetKeyBinding("StunBreakoutUp")
	local strRight 		= GameLib.GetKeyBinding("StunBreakoutRight")
	local strDown 		= GameLib.GetKeyBinding("StunBreakoutDown")
	local bLeftUnbound 	= strLeft == strNone
	local bUpUnbound 	= strUp == strNone
	local bRightUnbound = strRight == strNone
	local bDownUnbound 	= strDown == strNone
	local bLeft 		= eChosenDirection == Unit.CodeEnumCCStateStunVictimGameplay.Left
	local bUp 			= eChosenDirection == Unit.CodeEnumCCStateStunVictimGameplay.Forward
	local bRight 		= eChosenDirection == Unit.CodeEnumCCStateStunVictimGameplay.Right
	local bDown 		= eChosenDirection == Unit.CodeEnumCCStateStunVictimGameplay.Backward

	-- TODO: Swap to Stun Breakout Keys when they exist
	self.wndProgress:FindChild("ProgressButtonArtLeft"):SetText(bLeftUnbound and "" or strLeft)
	self.wndProgress:FindChild("ProgressButtonArtUp"):SetText(bUpUnbound and "" or strUp)
	self.wndProgress:FindChild("ProgressButtonArtRight"):SetText(bRightUnbound and "" or strRight)
	self.wndProgress:FindChild("ProgressButtonArtDown"):SetText(bDownUnbound and "" or strDown)

	-- Disabled is invisible text, which will hide the button text
	self.wndProgress:FindChild("ProgressButtonArtLeft"):Enable(bLeft)
	self.wndProgress:FindChild("ProgressButtonArtUp"):Enable(bUp)
	self.wndProgress:FindChild("ProgressButtonArtRight"):Enable(bRight)
	self.wndProgress:FindChild("ProgressButtonArtDown"):Enable(bDown)

	self.wndProgress:FindChild("NoBindsWarning"):Show(bLeftUnbound or bUpUnbound or bRightUnbound or bDownUnbound)
	
	if not bLeft and not bUp and not bRight and not bDown then -- Error Case
		self:OnRemoveCCStateStun()
		return
	end

	self:OnCalculateTimeRemaining()
end

function CrowdControlGameplay:OnRemoveCCStateStun() -- Also from lua
	if self.wndProgress and self.wndProgress:IsValid() then
		self.wndProgress:Destroy()
		self.wndProgress = nil
	end
end

function CrowdControlGameplay:OnUpdateCCStateStun(fProgress) -- Updates Progress Bar
	if not self.wndProgress or not self.wndProgress:IsValid() then
		return
	end

	if self.wndProgress:FindChild("ProgressBar") then
		self.wndProgress:FindChild("ProgressBar"):SetMax(100)
		self.wndProgress:FindChild("ProgressBar"):SetFloor(0)
		self.wndProgress:FindChild("ProgressBar"):SetProgress(fProgress * 100)
	end

	self:OnCalculateTimeRemaining()
end

function CrowdControlGameplay:OnCalculateTimeRemaining()
	local nTimeRemaining = GameLib.GetCCStateStunTimeRemaining()
	if not nTimeRemaining or nTimeRemaining <= 0 then
		if self.wndProgress and self.wndProgress:IsValid() then
			self.wndProgress:Show(false)
			--timers currently can't be started during their callbacks, because of a Code bug.
			self.timerCalculateRemaining = ApolloTimer.Create(0.1, false, "OnCalculateTimeRemaining", self)
		end
		return
	end

	if self.wndProgress and self.wndProgress:IsValid() and self.wndProgress:FindChild("TimeRemainingContainer") then
		self.wndProgress:Show(true)
		self.wndProgress:FindChild("TimeRemainingContainer"):Show(true)
		
		local nMaxTime = self.wndProgress:FindChild("TimeRemainingBar"):GetData()
		if not nMaxTime or nTimeRemaining > nMaxTime then
			nMaxTime = nTimeRemaining
			self.wndProgress:FindChild("TimeRemainingBar"):SetMax(100)
			self.wndProgress:FindChild("TimeRemainingBar"):SetData(nMaxTime)
			self.wndProgress:FindChild("TimeRemainingBar"):SetProgress(100)
		end
		self.wndProgress:FindChild("TimeRemainingBar"):SetProgress(math.min(math.max(nTimeRemaining / nMaxTime * 100, 0), 100), 50) -- 2nd Arg is the rate
	end

	if nTimeRemaining > 0 then
		--timers currently can't be started during their callbacks, because of a Code bug.
		self.timerCalculateRemaining = ApolloTimer.Create(0.1, false, "OnCalculateTimeRemaining", self)
	end
end

function CrowdControlGameplay:OnStunVGPressed(bPushed)
	if self.wndProgress and self.wndProgress:IsValid() then
		self.wndProgress:FindChild("ProgressButtonArtLeft"):SetCheck(bPushed)
		self.wndProgress:FindChild("ProgressButtonArtUp"):SetCheck(bPushed)
		self.wndProgress:FindChild("ProgressButtonArtDown"):SetCheck(bPushed)
		self.wndProgress:FindChild("ProgressButtonArtRight"):SetCheck(bPushed)
	end
end

local CrowdControlGameplayInst = CrowdControlGameplay:new()
CrowdControlGameplayInst:Init()
end
	end
end

function Crafting:OnTutorialItemBtn(wndHandler, wndControl)
	if wndHandler ~= wndControl or not wndHandler:GetData() then
		return
	end

	local nLeft, nTop, nRight, nBottom = wndHandler:GetAnchorOffsets()
	self.wndTutorialPopup:SetAnchorOffsets(nRight, nBottom, nRight + self.wndTutorialPopup:GetWidth(), nBottom + self.wndTutorialPopup:GetHeight())
	self.wndTutorialPopup:FindChild("TutorialPopupText"):SetText(Apollo.GetString(ktTutorialText[wndHandler:GetData()]))
	self.wndTutorialPopup:Show(not self.wndTutorialPopup:IsShown())
end

function Crafting:OnTutorialPopupCloseBtn()
	self.wndTutorialPopup:Show(false)
end

local CraftingInst = Crafting:new()
CraftingInst:Init()
�� �  ���" ��M�4K+��N(�Z&w��tP��6��vl�>�]T�`A���x�-��)[4��{S|�K	_|�c�~�ڊ�F��V���M�4`��`�t�(�*"�PR6��N�-ʵ��)������<���D����������K��~�DA!i���Ag`��e8K��� ��o�:-&8>�1Ǉx�~ W��z��D�GS�4K}-��c�x�}�b�Ŏ�����r���"�¹+[���+���lq	șgL�Q�i���~C���F����'�q#��t��ɜ>O|��ڵj�MNₚ���Q�o&J2�(�0� ��Ȧ�5uVP���D���u��B����x��UM�0��m]Q�<�<8*HS��/��Ga���Q����$s���������Wc/{��W쥔������]uR&^������e��;�u�$Eu��ۥ����Y��Z�^R�J���_��â�`ɍ�:���uͩ
��Go@�[��#|s*�|���Z��Fo0zf��M����N�����!t�� ��,�t��"\tSuw�W�$ nf��t�q\�h��)`�z�{v����6�!j�(Fq^g��Z��A"�}��^S���'H��mP�+�l�G�E��� a�,'2:�c4���ώG��U}�j<ox�mZ�ax>,o����=�G�I��a��Ԥ��&�\�IM���
��=��x��M\A{5�z���<�ꌋ }�H��&�9>+x�z�YK7)`��-��M��� XmZ5e��?w��p�    �� z  z��" p�F(4M���u�_�Q���:�����$I�˨jj�d��! #(
�P�2s���NZ;�����P��꘥����q�%D���7ӟ���j3ک��_.W����+�B���Q���?��D uP䪷� ��)R���'�)�)��Í&U��!��D���� ���@v����@���,m+�V�83]|����O �,�#@�A*�7\�;s'��L���m�L%g���x�,�X�-�߇��ί�E�a�iz��މ1��(�f�@R.�>.}wIz� Hr- 
I.�� �[�Cv��|Ҭ)	B���䗨��