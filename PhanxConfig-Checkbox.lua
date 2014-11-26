--[[--------------------------------------------------------------------
	PhanxConfig-Checkbox
	Simple checkbox widget generator. Requires LibStub.
	Originally based on tekKonfig-Checkbox by Tekkub.
	https://github.com/Phanx/PhanxConfig-Checkbox

	Copyright (c) 2009-2014 Phanx <addons@phanx.net>. All rights reserved.

	Permission is granted for anyone to use, read, or otherwise interpret
	this software for any purpose, without any restrictions.

	Permission is granted for anyone to embed or include this software in
	another work not derived from this software that makes use of the
	interface provided by this software for the purpose of creating a
	package of the work and its required libraries, and to distribute such
	packages as long as the software is not modified in any way, including
	by modifying or removing any files.

	Permission is granted for anyone to modify this software or sample from
	it, and to distribute such modified versions or derivative works as long
	as neither the names of this software nor its authors are used in the
	name or title of the work or in any other way that may cause it to be
	confused with or interfere with the simultaneous use of this software.

	This software may not be distributed standalone or in any other way, in
	whole or in part, modified or unmodified, without specific prior written
	permission from the authors of this software.

	The names of this software and/or its authors may not be used to
	promote or endorse works derived from this software without specific
	prior written permission from the authors of this software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
----------------------------------------------------------------------]]

local MINOR_VERSION = 176

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-Checkbox", MINOR_VERSION)
if not lib then return end

------------------------------------------------------------------------

local scripts = {}

function scripts:OnClick()
	local checked = not not self:GetChecked() -- WOD: won't need typecasting
	PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
	self:GetScript("OnLeave")(self)

	local callback = self.Callback or self.OnValueChanged
	if callback then
		callback(self, checked)
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
	local r, g, b = self.labelText:GetTextColor()
	self.labelText:SetTextColor(r * 2, g * 2, b * 2)
	self.disabled = nil
end
function scripts:OnDisable()
	if self.disabled then return end
	local r, g, b = self.labelText:GetTextColor()
	self.labelText:SetTextColor(r / 2, g / 2, b / 2)
	self.disabled = true
end

------------------------------------------------------------------------

local methods = {}

function methods:GetValue()
	return not not self:GetChecked() -- WOD: won't need typecasting
end
function methods:SetValue(value)
	self:SetChecked(value)
end

function methods:GetLabel()
	return self.labelText:GetText()
end
function methods:SetLabel(text)
	self.labelText:SetText(text)
end

function methods:GetTooltip()
	return self.tooltipText
end
function methods:SetTooltip(text)
	self.tooltipText = text
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
	check.labelText = label

	check.tooltipText = tooltipText
	check:SetHitRectInsets(0, -1 * min(186, max(label:GetStringWidth(), 100)), 0, 0)
	check:SetMotionScriptsWhileDisabled(true)

	for name, func in pairs(scripts) do
		check:SetScript(name, func)
		check[name] = func
	end
	for name, func in pairs(methods) do
		check[name] = func
	end

	return check
end

function lib.CreateCheckbox(...) return lib:New(...) end