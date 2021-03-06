require "Window"
require "Unit"


---------------------------------------------------------------------------------------------------
-- Cinematics module definition

local Cinematics = {}

---------------------------------------------------------------------------------------------------
-- local constants
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Cinematics initialization
---------------------------------------------------------------------------------------------------
function Cinematics:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
	-- initialize our variables

	-- return our object
	return o
end

---------------------------------------------------------------------------------------------------
function Cinematics:Init()

	Apollo.RegisterAddon(self)
end

---------------------------------------------------------------------------------------------------
-- Cinematics EventHandlers
---------------------------------------------------------------------------------------------------


function Cinematics:OnLoad()
	Apollo.RegisterEventHandler("CinematicsNotify", "OnCinematicsNotify", self)
	Apollo.RegisterEventHandler("CinematicsCancel", "OnCinematicsCancel", self)
	-- load our forms
	self.wndCin = Apollo.LoadForm("Cinematics.xml", "CinematicsWindow", nil, self)
	self.wndCin:Show(false)
end
	
---------------------------------------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------------------------------------

function Cinematics:OnCinematicsNotify(msg, param)
	-- save the parameter and show the window
	self.wndCin:FindChild("Message"):SetText(msg)
	self.wndCin:Show(true)
	self.param = param
end

function Cinematics:OnCinematicsCancel(param)
	-- save the parameter and show the window
	if param == self.param then
		self.wndCin:Show(false)
	end
end

function Cinematics:OnPlay()
	-- call back to the game with 
	Cinematics_Play(self.param)
	self.wndCin:Show(false)
end

function Cinematics:OnCancel()
	-- call back to the game with
	Cinematics_Cancel(self.param)
	self.wndCin:Show(false)
end

---------------------------------------------------------------------------------------------------
-- Cinematics instance
---------------------------------------------------------------------------------------------------
local CinematicsInst = Cinematics:new()
Cinematics:Init()



		.r'�8H�[���7jDv]�F�R���!��r����(#��"x�6@� H��cn�`��1�P�0ZOI7�{�Zdf/`���M����8�߫�'�c^��P�"�U��vFV!�V��r�p�"�(b��"���o+��C<� ����Ktڤ�_+����fk�@z����M�i�����y��0�b>���A��W���D��V ����h��ej�ͦ�����>u�`�����~TK��SRI���+�u��G)K@�7}���Ϛ}CK�s �8<����;��H� �4��T��iޗG��b�ku�b2�.���.f������<]\ŷ̺�o����|p-	43� Z�/Ã(�7I��v�/��o���%�|RXB�O�	��p;6Q���� �����\y���]�z���?X]h������;�#*l<4G�����҆s�i"&zĺ�"��`;��,�Q�I�,՝���}|Qm�hf5��QK�$U'�	&�r-�tbu I���ܬ��I�ƶ	�
�E�\u�1�ɛ@����q�ZDU�)��8����T�a�/����:�L`�$$�`�H�ܳ
�Ad���H�����8����bQU����~v\}ɭ���uS�^��7~�yO�.D�"�*�Ln/�j\��K��4� 师+��U�����.��O�Ӵ��.�&a���0uU�@mN��ؼ�9���;CB*!q����Yi$03�.�(�<`g?�!`3�j��m�R,�' �zL	I��E�=��X��
�";��O	^[#Z��,��SO����ι�a���Y1�/�~���_]S|l��}T[1@�2=����[j%������Z*��As[;�����͒��ƪ !��VL��ٿ�V����Y�߁�[��䀉�6�u�� T�@@sP��C�x7�dP��io{h�ɭ*]��U?�dY�}L[�,�8���2�[��)oxLN�����_��
}N�������(]�.����t_"�ΰ�e���x�����l�\�o���	g�5(�;��QM}H'Sς$� ��ߙˋ�y���YjK�P�ж�����V���/ٵ�{A{7߹�V@[@���鋿\�m���jFn��0���@�)W)h��Tg�AdS�{�N���hh�؜�̸��@G�61r��PCG�"/�d�P��M�r�.�+$�h�WD�e��2 Y����p�	��͐�_�zC� H�0�b)��B���ay��ˣ�ӳEo{�3�Xk�	
�@���^�j�"�����Z��a��f!����֬8�A5%�`s�Y�]�.8	S4�H���̾&ikЖ���e����,�$Slʚr���c���n#h4�vZH�� �׸�7D; jh�"�"y�]g���R��3�K���)Ę5�W�HI