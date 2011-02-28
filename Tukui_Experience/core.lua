local T, C, L = unpack(Tukui)

local Config = {
	tFormat = 4, -- 1 = 100%
						-- 2 = 10000 / 21000
						-- 3 = 100% (1000 / 5000)
						-- 4 = 1000 / 5000 (100%)
	-- vShort = true,
	font = C["media"].pixel_font or C["media"].font,
	size = 12,
	style = "MONOCHROMEOUTLINE",
	alignment = { "CENTER", 0, 1 },
	shadow = true,
	texture = C["media"].blank,
	
	colors = {
		{ .67, 0, 0 }, 		-- Hated
		{ .72, 0, 0 }, 		-- Hostile
		{ .7, .3, .3 }, 	-- Unfriendly
		{ .83, .63, 0 }, 	-- Neutral
		{ .33, .7, .3 }, 	-- Friendly
		{ .33, .7, .3 }, 	-- Honored
		{ .33, .7, .3 }, 	-- Revered
		{ .05, .79, .49 }, 	-- Exalted
	},
}

local function CreateBorder(f)
	if f.b then return end
	
	local b = CreateFrame("Frame", f:GetName() and f:GetName() .. "Border" or nil, f)
	b:Point("TOPLEFT", -1, 1)
	b:Point("BOTTOMRIGHT", 1, -1)
	b:SetBackdrop({
		edgeFile = C["media"].blank, 
		edgeSize = 1,
	})
	b:SetBackdropBorderColor(unpack(C["media"].backdropcolor))
	f.b = b
end

local addon = CreateFrame("Button", "TukuiExperience", UIParent)
addon:Height(19)
addon:Point("TOPLEFT", TukuiMinimapStatsLeft or TukuiMinimap, "BOTTOMLEFT", 0, -3)
addon:Point("TOPRIGHT", TukuiMinimapStatsRight or TukuiMinimap, "BOTTOMRIGHT", 0, -3)
addon:SetFrameLevel(1)
addon:SetFrameStrata("BACKGROUND")
addon:SetBackdrop({
	bgFile = C["media"].blank,
})
addon:SetBackdropColor(unpack(C["media"].bordercolor))
CreateBorder(addon)
if Config.shadow then
	addon:CreateShadow("Default")
end

local expBar = CreateFrame("StatusBar", nil, addon)
expBar:SetFrameLevel(addon:GetFrameLevel())
expBar:Point("TOPLEFT", 2, -2)
expBar:Point("BOTTOMRIGHT", -2, 2)
expBar:SetStatusBarTexture(Config.texture)
expBar:SetStatusBarColor(.3, .3, .8)
CreateBorder(expBar)
expBar:Hide()

local restedBar = CreateFrame("StatusBar", nil, expBar)
restedBar:SetFrameLevel(expBar:GetFrameLevel())
restedBar:SetAllPoints()
restedBar:SetStatusBarTexture(Config.texture)
restedBar:SetStatusBarColor(.3, .3, .8, .4)
CreateBorder(restedBar)
restedBar:Hide()

local expBG = expBar:CreateTexture(nil, 'BORDER')
expBG:SetAllPoints()
expBG:SetTexture(C["media"].blank)
expBG:SetVertexColor(.05, .05, .05)	

local expText = expBar:CreateFontString(nil, "OVERLAY")
expText:SetFont(Config.font, Config.size, Config.style)
expText:SetPoint(unpack(Config.alignment))

local repBar = CreateFrame("StatusBar", nil, addon)
repBar:Point("TOPLEFT", 2, -2)
repBar:Point("BOTTOMRIGHT", -2, 2)
repBar:SetStatusBarTexture(Config.texture)
CreateBorder(repBar)
repBar:Hide()

local repBG = repBar:CreateTexture(nil, 'BORDER')
repBG:SetAllPoints()
repBG:SetTexture(C["media"].blank)
repBG:SetVertexColor(.05, .05, .05)	

local repText = repBar:CreateFontString(nil, "OVERLAY")
repText:SetFont(Config.font, Config.size, Config.style)
repText:SetPoint(unpack(Config.alignment))

local function Update()
	local _, id, min, max, value = GetWatchedFactionInfo()
		
	local rMax = (max - min)
	local rGained = (value - min)
	local rNeed = (max - value)
		
	local perGain = format("%.1f%%", (rGained / rMax) * 100)
	local perNeed = format("%.1f%%", (rNeed / rMax) * 100)

	if UnitLevel("player") == MAX_PLAYER_LEVEL then
		expBar:Hide()

		repBar:Show()
		repBar:ClearAllPoints()
		repBar:Point("TOPLEFT", 2, -2)
		repBar:Point("BOTTOMRIGHT", -2, 2)
				
		repBar:SetMinMaxValues(min, max)
		repBar:SetValue(value)
	
		if Config.tFormat == 1 then
			repText:SetText(perGain)
		elseif Config.tFormat == 2 then
			repText:SetText(rGained .. " / " .. rMax)
		elseif Config.tFormat == 3 then
			repText:SetText(perGain .. " " .. "(" .. rGained .. "/" .. rMax ..")")
		elseif Config.tFormat == 4 then
			repText:SetText(rGained .. " / " .. rMax .. " " .. "(" .. perGain .. ")")
		end
	
		if id > 0 then
			repBar:SetStatusBarColor(unpack(Config.colors[id]))
			addon:Show()
		else
			addon:Hide()
		end

	else
		expBar:Show()

		if id > 0 then
			expBar:ClearAllPoints()
			expBar:Point("TOPLEFT", 2, -2)
			expBar:Point("TOPRIGHT", -2, -2)
			expBar:Height(11)
			
			repBar:Show()
			repBar:ClearAllPoints()
			repBar:Point("TOPLEFT", expBar, "BOTTOMLEFT", 0, -3)
			repBar:Point("TOPRIGHT", expBar, "BOTTOMRIGHT", 0, -3)
			repBar:Height(1)
			
			repBar:SetMinMaxValues(min, max)
			repBar:SetValue(value)

			repBar:SetStatusBarColor(unpack(Config.colors[id]))
		else
			expBar:ClearAllPoints()
			expBar:Point("TOPLEFT", 2, -2)
			expBar:Point("BOTTOMRIGHT", -2, 2)
			
			repBar:Hide()
		end
		
		local eCurrent = UnitXP("player")
		local eMax = UnitXPMax("player")
		local eRested = GetXPExhaustion()

		local perGain = format("%.1f%%", (eCurrent / eMax) * 100)
		local perNeed = format("%.1f%%", ((eMax - eCurrent) / eMax) * 100)

		expBar:SetMinMaxValues(0, eMax)
		expBar:SetValue(eCurrent)
		
		if eRested and eRested > 0 then
			restedBar:Show()
			restedBar:SetMinMaxValues(0, eMax)
			restedBar:SetValue(eCurrent + eRested)
		else
			restedBar:Hide()
		end
		
		expText:SetText(perGain)
	end
end
addon:SetScript("OnEvent", Update)
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("PLAYER_XP_UPDATE")
addon:RegisterEvent("PLAYER_LEVEL_UP")
addon:RegisterEvent("UPDATE_EXHAUSTION")
addon:RegisterEvent("PLAYER_UPDATE_RESTING")
addon:RegisterEvent("UPDATE_FACTION")

local function Tooltip()
	local name, id, min, max, value = GetWatchedFactionInfo()
		
	local rMax = (max - min)
	local rGained = (value - min)
	local rNeed = (max - value)
		
	local perGain = format("%.1f%%", (rGained / rMax) * 100)
	local perNeed = format("%.1f%%", (rNeed / rMax) * 100)
	
	GameTooltip:SetOwner(TukuiInfoLeft, "ANCHOR_TOPLEFT", 0, select(4, T.DataTextTooltipAnchor(expText)))

	if UnitLevel("player") < MAX_PLAYER_LEVEL then
		local eCurrent = UnitXP("player")
		local eMax = UnitXPMax("player")
		local eRested = GetXPExhaustion()

		local perGain = format("%.1f%%", (eCurrent / eMax) * 100)
		local perNeed = format("%.1f%%", ((eMax - eCurrent) / eMax) * 100)

		GameTooltip:AddLine(T.cStart .. "Experience:")
		GameTooltip:AddDoubleLine("Gained: ", eCurrent.." ("..perGain..")", 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine("Needed: ", eMax - eCurrent.." ("..perNeed..")", 1, 1, 1, .8, .3, .3)
		GameTooltip:AddDoubleLine("Total: ", eMax, 1, 1, 1, 1, 1, 1)
		if eRested and eRested > 0 then
			GameTooltip:AddDoubleLine("Rested:", eRested.." ("..format("%.f%%", eRested / eMax * 100)..")", 1, 1, 1, .3, .3, .8)
		end
		if id > 0 then
			GameTooltip:AddLine' '
		end
	end
	
	if id > 0 then
		GameTooltip:AddLine(T.cStart .. "Reputation:")
		GameTooltip:AddDoubleLine("Faction: ", name, 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine("Standing: ", _G['FACTION_STANDING_LABEL'..id], 1, 1, 1, unpack(Config.colors[id]))
		GameTooltip:AddDoubleLine("Gained: ", value - min.." ("..perGain..")", 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine("Needed: ", max - value.." ("..perNeed..")", 1, 1, 1, .8, .3, .3)
		GameTooltip:AddDoubleLine("Total: ", max - min, 1, 1, 1, 1, 1, 1)
	end
	
	GameTooltip:Show()
end
addon:SetScript('OnLeave', GameTooltip_Hide)
addon:SetScript('OnEnter', Tooltip)	

addon:SetScript("OnMouseDown", function() ToggleCharacter("ReputationFrame") end)