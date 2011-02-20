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

local f = CreateFrame("Button", nil, UIParent)
f:Height(19)
f:Point("TOPLEFT", TukuiMinimapStatsLeft or TukuiMinimap, "BOTTOMLEFT", 0, -3)
f:Point("TOPRIGHT", TukuiMinimapStatsRight or TukuiMinimap, "BOTTOMRIGHT", 0, -3)
f:SetFrameLevel(1)
f:SetFrameStrata("BACKGROUND")
f:SetBackdrop({
	bgFile = C["media"].blank,
})
f:SetBackdropColor(unpack(C["media"].bordercolor))
CreateBorder(f)
if Config.shadow then
	f:CreateShadow("Default")
end

local esb = CreateFrame("StatusBar", nil, f)
esb:SetFrameLevel(f:GetFrameLevel())
esb:Point("TOPLEFT", 2, -2)
esb:Point("BOTTOMRIGHT", -2, 2)
esb:SetStatusBarTexture(C["media"].blank)
esb:SetStatusBarColor(.3, .3, .8)
CreateBorder(esb)
esb:Hide()

local resb = CreateFrame("StatusBar", nil, esb)
resb:SetFrameLevel(esb:GetFrameLevel())
resb:SetAllPoints()
resb:SetStatusBarTexture(C["media"].blank)
resb:SetStatusBarColor(.3, .3, .8, .4)
CreateBorder(resb)
resb:Hide()

local ebg = esb:CreateTexture(nil, 'BORDER')
ebg:SetAllPoints()
ebg:SetTexture(C["media"].blank)
ebg:SetVertexColor(.05, .05, .05)	

local et = esb:CreateFontString(nil, "OVERLAY")
et:SetFont(Config.font, Config.size, Config.style)
et:SetPoint(unpack(Config.alignment))

local rsb = CreateFrame("StatusBar", nil, f)
rsb:Point("TOPLEFT", 2, -2)
rsb:Point("BOTTOMRIGHT", -2, 2)
rsb:SetStatusBarTexture(C["media"].blank)
CreateBorder(rsb)
rsb:Hide()

local rbg = rsb:CreateTexture(nil, 'BORDER')
rbg:SetAllPoints()
rbg:SetTexture(C["media"].blank)
rbg:SetVertexColor(.05, .05, .05)	

local rt = rsb:CreateFontString(nil, "OVERLAY")
rt:SetFont(Config.font, Config.size, Config.style)
rt:SetPoint(unpack(Config.alignment))

local colors = {
	{ r = .67, g = 0, b = 0 }, -- Hated
	{ r = .72, g = 0, b = 0 }, -- Hostile
	{ r = .7, g = .3, b = .3 }, -- Unfriendly
	{ r = .83, g = .63, b = 0 }, -- Neutral
	{ r = .33, g = .7, b = .3 }, -- Friendly
	{ r = .33, g = .7, b = .3 }, -- Honored
	{ r = .33, g = .7, b = .3 }, -- Revered
	{ r = .05, g = .79, b = .49 }, -- Exalted
}

local function experience()
	local _, id, min, max, value = GetWatchedFactionInfo()
	local colors = colors[id]
		
	local rMax = (max - min)
	local rGained = (value - min)
	local rNeed = (max - value)
		
	local perGain = format("%.1f%%", (rGained / rMax) * 100)
	local perNeed = format("%.1f%%", (rNeed / rMax) * 100)

	if UnitLevel("player") == MAX_PLAYER_LEVEL then
		esb:Hide()

		rsb:Show()
		rsb:ClearAllPoints()
		rsb:Point("TOPLEFT", 2, -2)
		rsb:Point("BOTTOMRIGHT", -2, 2)
				
		rsb:SetMinMaxValues(min, max)
		rsb:SetValue(value)
	
		if Config.tFormat == 1 then
			rt:SetText(perGain)
		elseif Config.tFormat == 2 then
			rt:SetText(rGained .. " / " .. rMax)
		elseif Config.tFormat == 3 then
			rt:SetText(perGain .. " " .. "(" .. rGained .. "/" .. rMax ..")")
		elseif Config.tFormat == 4 then
			rt:SetText(rGained .. " / " .. rMax .. " " .. "(" .. perGain .. ")")
		end
	
		if id > 0 then
			rsb:SetStatusBarColor(colors.r, colors.g, colors.b)
			f:Show()
		else
			f:Hide()
		end

	else
		esb:Show()

		if id > 0 then
			esb:ClearAllPoints()
			esb:Point("TOPLEFT", 2, -2)
			esb:Point("TOPRIGHT", -2, -2)
			esb:Height(11)
			
			rsb:Show()
			rsb:ClearAllPoints()
			rsb:Point("TOPLEFT", esb, "BOTTOMLEFT", 0, -3)
			rsb:Point("TOPRIGHT", esb, "BOTTOMRIGHT", 0, -3)
			rsb:Height(1)
			
			rsb:SetMinMaxValues(min, max)
			rsb:SetValue(value)

			rsb:SetStatusBarColor(colors.r, colors.g, colors.b)
		else
			esb:ClearAllPoints()
			esb:Point("TOPLEFT", 2, -2)
			esb:Point("BOTTOMRIGHT", -2, 2)
			
			rsb:Hide()
		end
		
		local eCurrent = UnitXP("player")
		local eMax = UnitXPMax("player")
		local eRested = GetXPExhaustion()

		local perGain = format("%.1f%%", (eCurrent / eMax) * 100)
		local perNeed = format("%.1f%%", ((eMax - eCurrent) / eMax) * 100)

		esb:SetMinMaxValues(0, eMax)
		esb:SetValue(eCurrent)
		
		if eRested and eRested > 0 then
			resb:Show()
			resb:SetMinMaxValues(0, eMax)
			resb:SetValue(eCurrent + eRested)
		else
			resb:Hide()
		end
		
		et:SetText(perGain)
	end
end
f:SetScript("OnEvent", experience)
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_XP_UPDATE")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("UPDATE_EXHAUSTION")
f:RegisterEvent("PLAYER_UPDATE_RESTING")
f:RegisterEvent("UPDATE_FACTION")



-- local function tt()
	--
-- end

-- f:SetScript('OnLeave', GameTooltip_Hide)
-- f:SetScript('OnEnter', tt)	
