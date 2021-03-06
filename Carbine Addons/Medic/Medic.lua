-----------------------------------------------------------------------------------------------
-- Client Lua Script for Medic
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "GameLib"
require "Unit"
require "Spell"

local Medic = {}

function Medic:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Medic:Init()
    Apollo.RegisterAddon(self, nil, nil, {"ActionBarFrame"})
end

function Medic:OnLoad()
	--[[ DEPRECATED: Replaced by \ClassResources\
	self.xmlDoc = XmlDoc.CreateFromFile("Medic.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)

	Apollo.RegisterEventHandler("ActionBarLoaded", "OnRequiredFlagsChanged", self)
	]]--
end

function Medic:OnDocumentReady()
	self.bDocLoaded = true
	self:OnRequiredFlagsChanged()
end

function Medic:OnRequiredFlagsChanged()
	if g_wndActionBarResources and self.bDocLoaded then
		if GameLib.GetPlayerUnit() then
			self:OnCharacterCreated()
		else
			Apollo.RegisterEventHandler("CharacterCreated", "OnCharacterCreated", self)
		end
	end
end

function Medic:OnCharacterCreated()
	local unitPlayer = GameLib.GetPlayerUnit()

	if not unitPlayer then
		return
	elseif unitPlayer:GetClassId() ~= GameLib.CodeEnumClass.Medic then
		if self.wndMain then
			self.wndMain:Destroy()
			self.wndMain = nil
			self.tCores = {}
		end
		return
	end

	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnFrame", self)

    self.wndMain = Apollo.LoadForm(self.xmlDoc, "MedicResourceForm", g_wndActionBarResources, self)
    
	local strResource = string.format("<T Font=\"CRB_InterfaceSmall\">%s</T>", Apollo.GetString("CRB_MedicResource"))
	self.wndMain:FindChild("ResourceContainer1"):SetTooltip(strResource)
	self.wndMain:FindChild("ResourceContainer2"):SetTooltip(strResource)
	self.wndMain:FindChild("ResourceContainer3"):SetTooltip(strResource)
	self.wndMain:FindChild("ResourceContainer4"):SetTooltip(strResource)

	self.tCores = {} -- windows

	for idx = 1,4 do
		self.tCores[idx] =
		{
			wndCore = Apollo.LoadForm(self.xmlDoc, "CoreForm",  self.wndMain:FindChild("ResourceContainer" .. idx), self),
			bFull = false
		}
	end

	self.xmlDoc = nil
end

function Medic:OnFrame()
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		return
	elseif unitPlayer:GetClassId() ~= GameLib.CodeEnumClass.Medic then
		if self.wndMain then
			self.wndMain:Destroy()
		end
		return
	end

	if not self.wndMain:IsValid() then
		return
	end

	local nLeft, nTop, nRight, nBottom = self.wndMain:GetRect() -- legacy code
	Apollo.SetGlobalAnchor("CastingBarBottom", 0.0, nTop - 15, true)

	self:DrawCores(unitPlayer) -- right id, draw core info

	-- Resource 2 (Mana)
	local nManaMax = unitPlayer:GetMaxMana()
	local nManaCurrent = unitPlayer:GetMana()
	self.wndMain:FindChild("ManaProgressBar"):SetMax(nManaMax)
	self.wndMain:FindChild("ManaProgressBar"):SetProgress(nManaCurrent)
	if nManaCurrent == nManaMax then
		self.wndMain:FindChild("ManaProgressText"):SetText(nManaMax)
	else
		--self.wndMain:FindChild("ManaProgressText"):SetText(string.format("%.02f/%s", nManaCurrent, nManaMax))
		self.wndMain:FindChild("ManaProgressText"):SetText(String_GetWeaselString(Apollo.GetString("Achievements_ProgressBarProgress"), math.floor(nManaCurrent), nManaMax))
	end

	local strMana = String_GetWeaselString(Apollo.GetString("Medic_FocusTooltip"), nManaCurrent, nManaMax)
	self.wndMain:FindChild("ManaProgressBar"):SetTooltip(string.format("<T Font=\"CRB_InterfaceSmall\">%s</T>", strMana))
end

function Medic:DrawCores(unitPlayer)

	local nResourceCurr = unitPlayer:GetResource(1)
	local nResourceMax = unitPlayer:GetMaxResource(1)

	for idx = 1, #self.tCores do
		--self.tCores[idx].wndCore:Show(nResourceCurr ~= nil and nResourceMax ~= nil and nResourceMax ~= 0)
		local bFull = idx <= nResourceCurr
		self.tCores[idx].wndCore:FindChild("CoreFill"):Show(idx <= nResourceCurr)

		if bFull ~= self.tCores[idx].bFull then
			if bFull == false then -- burned a core
				self.tCores[idx].wndCore:FindChild("CoreFlash"):SetSprite("CRB_WarriorSprites:sprWar_FuelRedFlashQuick")
			else -- generated a core
				self.tCores[idx].wndCore:FindChild("CoreFlash"):SetSprite("CRB_WarriorSprites:sprWar_FuelRedFlash")
			end
		end

		self.tCores[idx].bFull = bFull
	end
end

-----------------------------------------------------------------------------------------------
-- Medic Instance
-----------------------------------------------------------------------------------------------
local MedicInst = Medic:new()
MedicInst:Init()
�g��ir
����v�h��Aa!T�{��o�<�����b���|Z�pp+�Yf�˅4y�.c̈� K�1��[3��(:8�˫�蟣X_�mq%�$pB|�7�-f�Z��W%N��w�;)��Rݯ}u|��%�)[#5��ͰJwF�b�g?������j܌#�+Ø�)@�_��- �QsP{���>����w��=���a� #�Gl�ťpW��y����&���o��k#x`��a�?Z�����Rܽ�+�H�y��dؑ��,��sy?$#|���ixW>���AT!�~��C�B��9�һ��'t�7g\P8�/����ޕ�o7���I�C&HN_��ģ���A+�n��O�xD��o�&$�ҘrI���q`�r������݈�ڙ�%��0@����j~Y���|yAf���ÁjO��CՅ&��{a�nQ^Z"��� ��5F#�̌��B���
gTq9���^�&�/>�%V���%�A>��Ntm�=xi��QQ`l\q��a���:0G�`�J\��!.G
��)-){��lE�4y�J�y|ǢY�EqY�����2|!$ yH�Ϲd�W��4)�k����"|�O�o*:�����G�u��cep��p/X[X�O�u��i[\,4�y�Uctl8J����{���'xBv��U�=�u�2�!fN��#�	����"Mˢ��7a^�x��JV�y҅�YK����ͅ��&�][5����֡��㞶�`��i%Y��By�e|��er~͎P �u�גc�u[9ȩ��3@��Њ|�J���a����h0)[�#$<i�/������;�$,U�!��z�y�v�ql����1a8�`��h,���Y+ ��3U(�:����(Ԝ`H;{�/]��K����ʅ�sd��CӺ��j���k���ڢC2���O��n����B\��l��F^=<�U�J�?��l ���>�<1�V����wO<;��K���C����=}���$�kD⢇962S$�ut�8q��S6xJ��G� �g���ݺ��ӧ���%d��G�"����ФH�s�����.�'�gjۼP���M�;��w�r�$,6�M����I���y��zKl(|��wܻ��=�
�V�w^㞿)�n�c�f<�s�f&Ot0�H峉�d��
:�T /7mw����<P��.�欥$T����U:��D��>��^;�8f���R�)�$_n߀l��HK��x���	�i�Ѕ����nl����g��wyenM-�F(�,��`*�W�gYG�Ga�Fq�rxl��侪�T	��U栿�?ᬿ��;F3M�]��vSb?Z��� O�F쐧`����Qi�!㕛�(��ZV6Ю�p��uV�ٹ��iY���"�V6��2m�5]YQ� [�#�[-���Y���'���g����n�s]�#6א�k�s:PW�F����y�J�Z�}�-W��Rɚd��ZL�H�m��E�v�g{4s��ڍ@���cB���?��[]Ӡ �}J��V�6ڏJ��h��4lC�fd6�)ᴎ�h̭�#�͐��>�Q')Uǯ&5�3�Z/$z�'�4�������1�|�û�[-r��@�F�\A!�6�
�nF��*�`3�9�J���?_��MG�����f+
��w���s*�џyL8N�-4ҺI	n�k#呱��?;�'��hy8�D����-t���y�w�Y����v��ô��k�g�$�T���$�wjˇ��ݒ���(pu���n�48��c�<qY&b߉̉��-!csq��qq���2���*)��O�#aM+Oc�(�DGO������!RKG�d8�0���������A�r�����]N�4�~�+�PRI�v⯮�p��8ɤ-�i�&�-N��|S+U���n.��8Z���V�8�9)�}�1���eRȩ��q�yTT*gG�n��	��Y���eU�����+8��G�ʥ�R�(�~N��ִ#ۖ�ճ��,F�7�"oѾǦޕN�w���%6jVC��fS�f3��4.uR1��֜芩c�عH���e��.��TLŏ@k���̊:�)T��������>MM�<Kʕ}�G��B:8��+pۚ�N'��a��G.;��Rj��6. 34}ҡ*��8��}!�����Q�и����<T1U���<�<�t	��U�������6�9ؓ0���K�����N��&�NJDL�\6�[����`�l��m�y�edh6�{dM�7B�^��.U[�n���	K;�ޮ����d ���Uήa{�����'_�z��%<���q]�E�y���1�{�X7�J��1�r�\ N�
a��M7��5cl�]rKZ[�C�<6�u4�!N�H����(H
$nʜ����"ص��jz|f��W���NSW13<'�ݦ��P�刽P��6S�;���@�^g%���RQp���{�Bv�x���
�w��i�Zgq��:����֧G�t�Hn�K��L�Ӆ�l�*�|�v�Y-�~Y�� X��H@�3�d�q��+����gzv��˶��Z`;��x�&p��E+�7�����`,^h���UkgN��!�t�ƙxK/P��YL���)�D�x[%�z��	-���9EO�	���Ϗ'�4_����7�i�c'�킧�;K�`M;u5����F�3j��>�8�
y��h`���ܞ�w��x��:��͡ǃ3O�l�\&3���Hiu��H����7���ζ��:�y�EҀ��2�@�W�1/��n�n?-��)�ܷ�kW�����z�}��χ�w���;\K�Ժ���>���&/��. 6о���.�A�;���G�;�����i�K���,g�3�-$p��w3�]%�X��z�z����^"\j�Ƹ���_'b<�iϋ���tiW�R^�����$~���m˂��B�v{8�4׍-a3��Jp�oF�\G�X�$���&�T�3���oJC�G���
�d�
!e�����d�/�y�E�HA� ��ȩ�<���"�{����Y~4��e��)�7�`4h:�%�@I<��B���\���*�Ø5H=bD���L�%7_ϥ;!��@��;�������@��%��e�mU�����DӪ���Z*3�c�0��-��-Ć��h���|i:����`u�%��ܝ�&D6wZ��Yh}ozwx���j�r>
��?��8�����Շ��>4� ���!����uɩ����[�C�D��W`0�߸c��Ё��=r��C2����9'*�{V��w@��
Jg)㋝ �,�%�'iJ^S`n,�My-re�tVW*�
]�tM���|�<�WIn�H�B?��A�l���fL��@�}�B�n`�