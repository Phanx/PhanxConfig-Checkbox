--[[--------------------------------------------------------------------
	PhanxConfig-Checkbox
	Simple checkbox widget generator.
	Based on tekKonfig-Checkbox by Tekkub.
	Requires LibStub.

	This library is not intended for use by other authors. Absolutely no
	support of any kind will be provided for other authors using it, and
	its internals may change at any time without notice.
----------------------------------------------------------------------]]

local MINOR_VERSION = tonumber(strmatch("$Revision$", "%d+"))

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-Checkbox", MINOR_VERSION)
if not lib then return end

------------------------------------------------------------------------

local scripts = {}

function scripts:OnClick()
	local checked = self:GetChecked() == 1
	PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
	self:GetScript("OnLeave")(self)
	if self.Callback then
		self:Callback(checked)
	end
end

function scripts:OnEnter()
	if self.tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
	end
end
function scripts:OnLeave()
	GameTooltip:Hide()
end

function scripts:OnEnable()
	if not self.disabled then return end
	local r, g, b = self.label:GetTextColor()
	self.label:SetTextColor(r * 2, g * 2, b * 2)
	self.disabled = nil
end
function scripts:OnDisable()
	if self.disabled then return end
	local r, g, b = self.label:GetTextColor()
	self.label:SetTextColor(r / 2, g / 2, b / 2)
	self.disabled = true
end

------------------------------------------------------------------------

local methods = {}

function methods:GetValue()
	return self:GetChecked() == 1
end
function methods:SetValue(value, auto)
	self:SetChecked(value)
end

function methods:GetTooltipText()
	return self.tooltipText
end
function methods:SetTooltipText(text)
	self.tooltipText = text
end

function methods:SetFunction(func)
	self.func = func
end

------------------------------------------------------------------------

function lib:New(parent, text, tooltipText)
	assert(type(parent) == "table" and type(rawget(parent, 0) == "userdata"), "PhanxConfig-Checkbox: parent must be a frame")
	if type(name) ~= "string" then name = nil end
	if type(tooltipText) ~= "string" then tooltipText = nil end

	local check = CreateFrame("CheckButton", nil, parent)
	check:SetSize(26, 26)

	check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")

	local label = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetPoint("LEFT", check, "RIGHT", 2, 1)
	label:SetText(text)
	check.label = label

	check:SetMotionScriptsWhileDisabled(true)
	for name, func in pairs(scripts) do
		check:SetScript(name, func)
	end
	for name, func in pairs(methods) do
		check[name] = func
	end

	check.tooltipText = tooltipText
	check:SetHitRectInsets(0, -1 * min(186, max(label:GetStringWidth(), 100)), 0, 0)

	return check
end

function lib.CreateCheckbox(...) return lib:New(...) end