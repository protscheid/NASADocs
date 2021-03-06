-----------------------------------------------------------------------------------------------
-- Client Lua Script for ContextMenuItem
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "GameLib"
require "GroupLib"
require "ChatSystemLib"
require "FriendshipLib"
require "MatchingGame"

local knXCursorOffset = 10
local knYCursorOffset = 25

-- Head, Shoulder, Chest, Hands, Boots, etc.
local ktValidItemPreviewSlots = { [0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [16] = true }

local ktValidRaceWeaponPreview =
{	-- Pistols, Psyblades, Claws, Sword, Resonators, Gun
	[GameLib.CodeEnumRace.Aurin] 	= {	[45] = true, [46] = true, [48] = true },
	[GameLib.CodeEnumRace.Draken] 	= {	[45] = true, [48] = true, [51] = true },
	[GameLib.CodeEnumRace.Granok] 	= {	[51] = true, [79] = true, [204] = true },
	[GameLib.CodeEnumRace.Mechari] 	= { [48] = true, [51] = true, [79] = true, [204] = true },
	[GameLib.CodeEnumRace.Chua] 	= {	[45] = true, [46] = true, [79] = true, [204] = true },
	[GameLib.CodeEnumRace.Mordesh] 	= { [45] = true, [48] = true, [51] = true, [79] = true,	[204] = true },
	[GameLib.CodeEnumRace.Human] 	= {	[45] = true, [46] = true, [48] = true, [51] = true, [79] = true, [204] = true },
}

local ContextMenuItem = {}

function ContextMenuItem:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ContextMenuItem:Init()
    Apollo.RegisterAddon(self)
end

function ContextMenuItem:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ContextMenuItem.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

function ContextMenuItem:OnDocumentReady()
	if self.xmlDoc == nil then
		return
	end

	Apollo.RegisterEventHandler("ItemLink", 					"InitializeItemObject", self)
	Apollo.RegisterEventHandler("ShowItemInDressingRoom", 		"InitializeItemObject", self)
	Apollo.RegisterEventHandler("ToggleItemContextMenu", 		"InitializeItemObject", self) -- Potentially from code
	Apollo.RegisterEventHandler("GenericEvent_ContextMenuItem", "InitializeItemObject", self)

	-- Special Cases
	Apollo.RegisterEventHandler("SplitItemStack", 			"OnSplitItemStack", self)
	Apollo.RegisterEventHandler("DecorPreviewOpen", 		"OnDecorPreviewOpen", self)
end

function ContextMenuItem:InitializeItemObject(itemArg)
	if self.wndMain and self.wndMain:IsValid() then
		self.wndMain:Destroy()
		self.wndMain = nil
	end

	self.wndMain = Apollo.LoadForm(self.xmlDoc, "ContextMenuItemForm", "TooltipStratum", self)
	self.wndMain:SetData(itemArg)
	self.wndMain:Invoke()

	local tCursor = Apollo.GetMouse()
	self.wndMain:Move(tCursor.x - knXCursorOffset, tCursor.y - knYCursorOffset, self.wndMain:GetWidth(), self.wndMain:GetHeight())

	-- Enable / Disable the approriate buttons
	self.wndMain:FindChild("BtnEditRunes"):Enable(self:HelperValidateEditRunes(itemArg))
	self.wndMain:FindChild("BtnPreviewItem"):Enable(self:HelperValidatePreview(itemArg))
	self.wndMain:FindChild("BtnSplitStack"):Enable(itemArg and itemArg:GetStackCount() > 1)

	-- If Decor
	self.nDecorId = itemArg:GetHousingDecorInfoId()
	if self.nDecorId and self.nDecorId ~= 0 then
		self.wndMain:FindChild("BtnPreviewItem"):Enable(true)
	end
end

function ContextMenuItem:OnDecorPreviewOpen(nArgDecorId) -- Currently unable to offer Link to Chat, which requires the object
	Event_FireGenericEvent("GenericEvent_LoadDecorPreview", nArgDecorId)
end

function ContextMenuItem:OnSplitItemStack(itemArg) -- This is a common enough shortcut (Shift + Left Click) to skip the menu
	Event_FireGenericEvent("GenericEvent_SplitItemStack", itemArg)
end

function ContextMenuItem:OnRegularBtn(wndHandler, wndControl) -- Can be any of the buttons
	local itemArg = self.wndMain:GetData()
	local strButtonName = wndHandler:GetName()
	if strButtonName == "BtnSplitStack" then
		Event_FireGenericEvent("GenericEvent_SplitItemStack", itemArg)
	elseif strButtonName == "BtnLinkToChat" then
		Event_FireGenericEvent("GenericEvent_LinkItemToChat", itemArg)
	elseif strButtonName == "BtnEditRunes" then
		Event_FireGenericEvent("GenericEvent_RightClick_OpenEngraving", itemArg)
	elseif strButtonName == "BtnPreviewItem" and self.nDecorId and self.nDecorId ~= 0 then
		Event_FireGenericEvent("GenericEvent_LoadDecorPreview", self.nDecorId)
	elseif strButtonName == "BtnPreviewItem" then
		Event_FireGenericEvent("GenericEvent_LoadItemPreview", itemArg)
	end

	self.wndMain:Close()
	self.wndMain = nil
end

function ContextMenuItem:HelperValidateEditRunes(itemArg)
	if not itemArg or itemArg:GetStackCount() == 0 then
		return false
	end

	local tRunes = itemArg:GetRuneSlots()
	return tRunes and tRunes.arRuneSlots
end

function ContextMenuItem:HelperValidatePreview(itemArg)
	local bValidWeaponForRace = true
	local bValidItemPreview = ktValidItemPreviewSlots[itemArg:GetSlot()] -- See if this is an item type you can preview (i.e. not a gadget)

	-- For weapons only, see if it is a valid race weapon combo
	if bValidItemPreview and itemArg:GetSlot() == 16 then
		local unitPlayer = GameLib.GetPlayerUnit()
		local ePlayerRace = unitPlayer:GetRaceId()
		bValidWeaponForRace = ktValidRaceWeaponPreview[ePlayerRace] and ktValidRaceWeaponPreview[ePlayerRace][itemArg:GetItemType()]
	end

	return bValidItemPreview and bValidWeaponForRace

	--[[
	local bRightClassOrProf = false
	local tProficiency = itemArg:GetProficiencyInfo()
	local ePlayerClass = unitPlayer:GetClassId()

    if #eItemClass > 0 then
		for idx,tClass in ipairs(eItemClass) do
			if tClass.idClassReq == unitPlayer:GetClassId() then
				bRightClassOrProf = true
			end
		end
	elseif tProficiency then
		bRightClassOrProf = true -- tProficiency.bHasProficiency
	end
	]]--
end

local ContextMenuItemInst = ContextMenuItem:new()
ContextMenuItemInst:Init()
�dU�`ni0?:0�x}�x�!�P Y#�Ͷz��P2�}��P���52kd�Ȭ�Y#�̴^T2㚬 dhd�Ȭ�Y#�Ff�̿2�&�UE�\�<��C���52kd�Ȭ���Cf� �<�	, `i`����Y�f̿06�e�<ְ�aYò�e���	��HB��g�	aj����l{�p7�ʔ�.c��S�4�'eU�^���Ë۾%�JaS5�z�v>U�F"���!t��T� ��/B�T/�o��q��{ޜ�(�����#^ ϲɫc/K�^:p� ���n���uV^<�0����u�2����=c�|A����?=���~Rqq{
^� B��P��
~����q�a�0't�x���t�XU2�K�S8��.9:@!�d� �������!��
����I3W�̀�����/G	�]�va2��gd/%��l�i5k ��
\�  �z�Q���6��4�̶���������qx:b����7�;�1��u�8��G��% ��C�U �9�Ц� ά�}�ƃVQ�:�נ�AM�������X����%p��`_f�_�11�qlD�b"���Mc��&�M��6���l����� ��:���B�`� �����Gi��X��ꈰ��ʠ�|,;��� �0��q૪�_��y��~V��4Ri��H�ΐ�	斧�|,A�~H��n��Ǽ�*��e��aI�ҡ�R�O��t���D,}_�{��LCY��ZAW[�HA��T�����U�D�����;g�;�rƎ���B���Wޘ��y��Ye������F ��I1����'dJ0@���!�݉��Bi��{��� ��4��r4�N��AC�<�ƹ���Ot&[�Ӄ-@�՟pޘ�m�� �U��O�(p�8��6e(��&8���m�F�#��:�#���(�Y ��*B���}vVkѮ�l(\v>�f��_�_]~�%�X؇&�ɇD9�HC0�U
��n����~�����Υ�s��*�{���,��	��5ɹ�Kɱ[���&c��~!�`���h�Ey�\C%f�@�5��g�u�s`�Y���(-|oi��=uv,k`���z���+{ޢ0��~��#�[�]@��^�+}X�/���AC5 :�9@쳹�av�(�|������FrJ
������"�D��Sw���w�g�ֈ$_����_�v��5;#�ُ!@�p��>��bj����5��*K~��4��dew�'$������ϱ���W�e����ʯ�^����ȟ ���K��ݬ���R��������/_�z"Ũ/H�%��W�)���2�D��L�b���!�H
Љ�I��b-Ά$��i�=94[�� �f �20c��S���v+��N(�Z&w��tP��6��vl�>�]T�`A���x�-��)[4��{S|�K	_|�c�~�ڊ�F��V���M�4`��`�t�(�*"�PR6��N�-ʵ��)������<���D����������K��~�DA!i���Ag`��e8K��� ��o�:-&8>�1Ǉx�~ W��z��D�GS�4K}-��c�x�}�b�Ŏ�����r���"�¹+[���+���lq	șgL�Q�i���~C���F����'�q#��t��ɜ>O|��ڵj�MNₚ���Q�o&J2�(�0� ��Ȧ�5uVP���D���u��B����x��UM�0��m]Q�<�<8*HS��/��Ga���Q����$s���������Wc/{��W쥔������]uR&^������e��;�u�$Eu��ۥ����Y��Z�^R�J���_��â�`ɍ�:���uͩ
��Go@�[��#|s*�|���Z��Fo0zf��M����N�����!t�� ��,�t��"\tSuw�W�$ nf��t�q\�h��)`�z�{v����6�!j�(Fq^g��Z��A"�}��^S���'H��mP�+�l�G�E��� a�,'2:�c4���ώG��U}�j<ox�mZ�ax>,o����=�G�I��a��Ԥ��&�\�IM���
��=��x��M\A{5�z���<�ꌋ }�H��&�9>+x�z�YK7)`��-��M��� XmZ5e��?w��p�