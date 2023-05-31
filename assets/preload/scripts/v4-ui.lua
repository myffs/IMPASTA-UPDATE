-- Combo script from somewhere in the vanilla ui Script, by: Bombastic_Tom

------ Config ------
local timeBar = true -- Make the V4 timebar always appear or never
local oldCombo = true -- If set to true, the combo UI will be right beside Girlfriend. Otherwise, it'll stay on the UI.
--------------------


---- DON'T CHANGE ANYTHING BELOW THIS POINT!!! ----
----- (Unless you know what you're doing lol) -----
local start = false

function onCreatePost()
	if oldCombo then
		setProperty("showCombo", false)
		setProperty("showComboNum", false)
		setProperty("showRating", false)
	end
	setTextString("botplayTxt", "Botplay.exe")
	if downScroll then
		setProperty("botplayTxt.y", getProperty("healthBar.y")+40)
	else
		setProperty("botplayTxt.y", getProperty("healthBar.y")-60)
	end
	
	if timeBar == false then
		close()
	end
	setProperty("timeBarBG.visible", false)
	setProperty("timeBar.visible", false)
	setProperty("timeTxt.visible", false)
	
	makeLuaText("v4TimeTxt", string.upper(songName), 400, 42 + (screenWidth / 2) - 585, 20)
	setTextFont("v4TimeTxt", "vcr-v4.ttf")
	setObjectCamera("v4TimeTxt", "hud")
	setTextSize("v4TimeTxt", 14)
	setTextColor("v4TimeTxt", "FFFFFF")
	setTextAlignment("v4TimeTxt", "left")
	setTextBorder("v4TimeTxt", 1, "000000")
	if (downscroll == true) then
		setProperty("v4TimeTxt.y", screenHeight - 45)
	end
	setProperty("v4TimeTxt.alpha", 0)
	
	makeLuaSprite("v4TimeBarBG", "timeBar", getProperty("v4TimeTxt.x"), getProperty("v4TimeTxt.y") + (getProperty("v4TimeTxt.height") / 4))
	setObjectCamera("v4TimeBarBG", "hud")
	setProperty("v4TimeBarBG.alpha", 0)
	addLuaSprite("v4TimeBarBG")
	
	makeLuaSprite("v4TimeBar", "", -getProperty('v4TimeBarBG.x') + 2, getProperty('v4TimeBarBG.y') + 4)
	makeGraphic("v4TimeBar", (getProperty('v4TimeBarBG.width') - 7) / 2, getProperty('v4TimeBarBG.height') - 8, "44d844")
	setObjectCamera("v4TimeBar", "hud")
	setProperty("v4TimeBar.visible", false)
	setProperty("v4TimeBar.alpha", 0)
	addLuaSprite("v4TimeBar")
	setProperty("v4TimeBar.origin.x", getProperty("v4TimeBar.width"))
	
	setProperty("v4TimeTxt.x", getProperty("v4TimeTxt.x")+10)
	setProperty("v4TimeTxt.y", getProperty("v4TimeTxt.y")+4)
	addLuaText("v4TimeTxt")
end

function onSongStart()
	start = true
	doTweenAlpha(1, "v4TimeBarBG", 1, 0.5, "circOut")
	doTweenAlpha(2, "v4TimeBar", 1, 0.5, "circOut")
	doTweenAlpha(3, "v4TimeTxt", 1, 0.5, "circOut")
end

function onBeatHit()
	for i=1,2 do
		cancelTween('icon'..i..'x')
		cancelTween('icon'..i..'y')
		doTweenX('icon'..i..'x', 'iconP'..i..'.scale', 1, 0.05, 'quadOut')
		doTweenY('icon'..i..'y', 'iconP'..i..'.scale', 1, 0.05, 'quadOut')
	end
end

function onUpdate(elapsed)
	if start == true then
		setProperty("v4TimeBar.visible", true)
		local percent = -(getSongPosition()/songLength)
		local scale = (percent * 2)
		setProperty("v4TimeBar.scale.x", scale)
	end
end

function to_hex(rgb)
    return string.format('%x', (rgb[1] * 0x10000) + (rgb[2] * 0x100) + rgb[3])
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function getRating()
	if ratingFC ~= '' then
		return ratingName..' ('..round(rating*100, 2)..'%) - '..ratingFC
	else
		return '0%'
	end
end

function onUpdatePost(elapsed)
	if start == true and getProperty('timeTxt.text') ~= "" then
		setTextString('v4TimeTxt', string.upper(getProperty('timeTxt.text')))
	end
	setProperty("iconP1.y", getProperty('healthBar.y') + (getProperty("iconP1.height") / 2)-147)
	setProperty("iconP2.y", getProperty('healthBar.y') + (getProperty("iconP2.height") / 2)-147)
	setTextColor("scoreTxt", to_hex(getProperty('dad.healthColorArray')))
	setTextColor("botplayTxt", to_hex(getProperty('dad.healthColorArray')))
	setTextString('scoreTxt','Score: '..score..' | Combo Breaks: '..misses..' | Accuracy: '..getRating())
end

function string.starts(str, start)
    return string.sub(str, 1, string.len(start)) == start
end
function string.split(str, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

if oldCombo then

function judgeNote(noteTime)
	local timingWindows = {
		getPropertyFromClass('ClientPrefs', 'sickWindow'),
		getPropertyFromClass('ClientPrefs', 'goodWindow'),
		getPropertyFromClass('ClientPrefs', 'badWindow')
	}

	local windowNames = {'sick', 'good', 'bad'}

	for thing=1, #timingWindows do
		if noteTime <= timingWindows[thing] then
			return windowNames[thing]
		end
	end
	return 'shit'
end

local count = 0

function goodNoteHit(a,b,c,isSustainNote)
	if botPlay then
		return
	end

	if not isSustainNote then

	local noteHitDelay = math.abs(getPropertyFromClass('Conductor', 'songPosition') - getPropertyFromGroup('notes', a, 'strumTime'))
	local myRating = judgeNote(noteHitDelay)
	local pixel = getPropertyFromClass('PlayState', 'isPixelStage')
		local pixelShitPart1 = ''
		local pixelShitPart2 = ''
		local scaleShit = 0.7
		local antialiasing = getPropertyFromClass('ClientPrefs',
												'globalAntialiasing')
		if pixel then
			pixelShitPart1 = 'pixelUI/'
			pixelShitPart2 = '-pixel'
			scaleShit = getPropertyFromClass('PlayState', 'daPixelZoom') * 0.85
			antialiasing = false
		end
	
	count = count + 1
	
	makeLuaSprite('comboRating'..count, pixelShitPart1 .. myRating .. pixelShitPart2, 0, 0)
	screenCenter('comboRating'..count)
	setProperty('comboRating'..count..'.x', screenWidth * 0.55 - 40)
	setProperty('comboRating'..count..'.y', getProperty('comboRating'..count..'.y') - 60)
	
	if not pixel then
		setGraphicSize('comboRating'..count, getProperty('comboRating'..count..'.width') * 0.7)
	else
		setGraphicSize('comboRating'..count, getProperty('comboRating'..count..'.width') * scaleShit)
	end
	setProperty('comboRating'..count..'.antialiasing', antialiasing)
	
	updateHitbox('comboRating'..count)
	addLuaSprite('comboRating'..count, true)
	
	setProperty('comboRating'..count..'.acceleration.y', 550)
	setProperty('comboRating'..count..'.velocity.y', getProperty('comboRating'..count..'.velocity.y') - math.random(140, 175))
	setProperty('comboRating'..count..'.velocity.x', math.random(0, 10))
	runTimer('comboRating'..count, crochet * 0.001)
	
	-- Modified combo text code made by Stilic
	
	--if getProperty('combo') > 9 then
	--	-- lot of vars but shut up i know we need these
	--count = count + 1
	--	local tag = 'combo' .. count
	--	local offset = {0,0} --getPropertyFromClass('ClientPrefs', 'comboOffset')
	--
	--	-- pixel style is great too
	--	makeLuaSprite(tag, pixelShitPart1 .. 'combo' .. pixelShitPart2, screenWidth * 0.55 + 45, 0)
	--	scaleObject(tag, scaleShit, scaleShit)
	--	updateHitbox(tag)
	--
	--	-- i wanted to put that after ratio var but psych don't let me do that
	--	screenCenter(tag, 'y')
	--setProperty(tag .. '.y', getProperty(tag..'.y') + 35)
	--
	--	-- my brain told me to fix the offsets as fast as i can
	--
	--	-- box2d based??? dik
	--	setProperty(tag .. '.acceleration.y', 600)
	--	setProperty(tag .. '.velocity.y', getProperty(tag .. '.velocity.y') - 150)
	--setProperty(tag .. '.velocity.x', getProperty(tag .. '.velocity.x') - math.random(1,10))
	--
	--	setProperty(tag .. '.antialiasing', antialiasing)
	--	addLuaSprite(tag, true)
	--
	--	-- fuck psych doesn't support startDelay so i use a timer instead
	--	runTimer(tag, crochet * 0.001)
	--end
	
	local combo = getProperty('combo')
	local seperatedScore = {}
	
	if combo >= 1000 then
		table.insert(seperatedScore, math.floor(combo / 1000) % 10)
	end
	table.insert(seperatedScore, math.floor(combo / 100) % 10)
	table.insert(seperatedScore, math.floor(combo / 10) % 10)
	table.insert(seperatedScore, combo % 10)
	
	for number,i in pairs(seperatedScore) do
	
		count = count + 1
		makeLuaSprite('comboNum'..count,  pixelShitPart1 .. 'num'..i .. pixelShitPart2, 0, 0)
		screenCenter('comboNum'..count)
		setProperty('comboNum'..count..'.x', screenWidth * 0.55 + (43 * (number-1)) - 90)
		setProperty('comboNum'..count..'.y', getProperty('comboNum'..count..'.y') + 80)
	
		if not pixel then
			setGraphicSize('comboNum'..count, getProperty('comboNum'..count..'.width') * 0.5)
		else
			setGraphicSize('comboNum'..count, getProperty('comboNum'..count..'.width') * getPropertyFromClass('PlayState', 'daPixelZoom'))
		end
		updateHitbox('comboNum'..count)
		setProperty('comboNum'..count..'.antialiasing', antialiasing)
		
		addLuaSprite('comboNum'..count, true)
	
		setProperty('comboNum'..count..'.acceleration.y', math.random(200, 300))
		setProperty('comboNum'..count..'.velocity.y', getProperty('comboNum'..count..'.velocity.y') - math.random(140, 160))
		setProperty('comboNum'..count..'.velocity.x', math.random() + math.random(-5, 5))
		runTimer('comboNum'..count, crochet * 0.002)
		end
	end
end

function onTweenCompleted(tag)
    if tag:starts('combo') then
        removeLuaSprite(tag, true)
    end
end

function onTimerCompleted(tag)
    if tag:starts('combo') then
        doTweenAlpha(tag, tag, 0, 0.2, 'linear')
    end
end

end
