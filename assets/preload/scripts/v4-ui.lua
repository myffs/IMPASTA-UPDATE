function onCreatePost()
    setProperty('timeTxt.x', 42 + (screenWidth / 2) - 585);
    setProperty('timeTxt.y', 20);
    setProperty('timeTxt.alignment', 'left');
    setProperty('timeTxt.size', 14);
    setProperty('timeTxt.borderSize', 1);
    if getPropertyFromClass('ClientPrefs', 'downScroll') then
        setProperty('timeTxt.y', screenHeight - 45);
    end

    setProperty('timeBarBG.color', getColorFromHex('FFFFFF')); --Umm.. i should stop looking for shit on source code
    setProperty('timeBarBG.antialiasing', false);
    setProperty('scoreTxt.color', getColorFromHex(getHealthColor('dad')));
    setProperty('botplayTxt.color', getColorFromHex(getHealthColor('dad')));
    setTimeBarColors('0xFF44f844', '0xFF2e412e');
    setProperty('timeBar.x', getProperty('timeTxt.x') - 10);
    setProperty('timeBar.y', getProperty('timeTxt.y') + 4);
end
function onUpdatePost(elapsed)
    setProperty('timeTxt.text', songName:upper());

    if ratingFC == 'SFC' or ratingFC == 'GFC' or ratingFC == 'FC' or ratingFC == 'SDCB' then
        setTextString('scoreTxt', 'Score: '..getProperty('songScore')..' | Combo Breaks: '..getProperty('songMisses')..' | Accuracy: '..(math.floor(getProperty('ratingPercent') * 10000) / 100)..'% | ['..ratingFC..']');
    else
        setTextString('scoreTxt', 'Score: '..getProperty('songScore')..' | Combo Breaks: '..getProperty('songMisses')..' | Accuracy: 0% | N/A');
    end

    setProperty('iconP1.origin.x', 20);
    setProperty('iconP1.origin.y', 0);
    setProperty('iconP2.origin.x', 80);
    setProperty('iconP2.origin.y', 0);
    setProperty('iconP1.scale.x', lerp(getProperty('iconP1.scale.x'), 1, boundTo(1 - (elapsed * 30), 0, 1)));
    setProperty('iconP2.scale.x', lerp(getProperty('iconP2.scale.x'), 1, boundTo(1 - (elapsed * 30), 0, 1)));
end
function getHealthColor(char) --this get health bar color script is made by @🇵🇷TehPuertoRicanSpartan🇵🇷#0811
    return string.format('%02x%02x%02x', getProperty(char..'.healthColorArray[0]'), getProperty(char..'.healthColorArray[1]'), getProperty(char..'.healthColorArray[2]'))
end
function onEvent(n)
    if n == 'Change Character' then
        setProperty('scoreTxt.color', getColorFromHex(getHealthColor('dad')));
        setProperty('botplayTxt.color', getColorFromHex(getHealthColor('dad')));
    end
end
function lerp(a,b,t) return a * (1-t) + b * t end --https://love2d.org/forums/viewtopic.php?t=83180
function boundTo(value, min, max) --boundTo is for not let the value go lower than the min and upper than the max.
    newValue = value;
    if newValue < min then
        newValue = min;
    elseif newValue > max then
        newValue = max;
    end
    return newValue;
end
function getIconColor(chr)
	return getColorFromHex(rgbToHex(getProperty(chr .. ".healthColorArray")))
end

function rgbToHex(array)
	return string.format('%.2x%.2x%.2x', array[1], array[2], array[3])
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	if _G['boyfriendGhostData.strumTime'] == getPropertyFromGroup('notes', id, 'strumTime') and not isSustainNote then
		createGhost('boyfriend')
	end
	if not isSustainNote then
		_G['boyfriendGhostData.strumTime'] = getPropertyFromGroup('notes', id, 'strumTime')
		updateGData('boyfriend')	
	end
end
function opponentNoteHit(id, direction, noteType, isSustainNote)
	if _G['dadGhostData.strumTime'] == getPropertyFromGroup('notes', id, 'strumTime') and not isSustainNote then
		createGhost('dad')
	end
	if not isSustainNote then
		_G['dadGhostData.strumTime'] = getPropertyFromGroup('notes', id, 'strumTime')
		updateGData('dad')	
	end
end

function createGhost(char)
	songPos = getSongPosition() --in case game stutters
    makeAnimatedLuaSprite(char..'Ghost'..songPos, getProperty(char..'.imageFile'),getProperty(char..'.x'),getProperty(char..'.y'))
    addLuaSprite(char..'Ghost'..songPos, false)
    setProperty(char..'Ghost'..songPos..'.scale.x',getProperty(char..'.scale.x'))
	setProperty(char..'Ghost'..songPos..'.scale.y',getProperty(char..'.scale.y'))
	setProperty(char..'Ghost'..songPos..'.flipX', getProperty(char..'.flipX'))
	setProperty(char..'Ghost'..songPos..'.color', getIconColor(char))
	setProperty(char..'Ghost'..songPos..'.alpha', 1)
	doTweenAlpha(char..'Ghost'..songPos..'delete', char..'Ghost'..songPos, 0, 0.6)
	setProperty(char..'Ghost'..songPos..'.animation.frameName', _G[char..'GhostData.frameName'])
	setProperty(char..'Ghost'..songPos..'.offset.x', _G[char..'GhostData.offsetX'])
	setProperty(char..'Ghost'..songPos..'.offset.y', _G[char..'GhostData.offsetY'])
	setObjectOrder(char..'Ghost'..songPos, getObjectOrder(char..'Group')-1)
end

function onTweenCompleted(tag)
	if (tag:sub(#tag- 5, #tag)) == 'delete' then
		removeLuaSprite(tag:sub(1, #tag - 6), true)
	end
end

function updateGData(char)
	_G[char..'GhostData.frameName'] = getProperty(char..'.animation.frameName')
	_G[char..'GhostData.offsetX'] = getProperty(char..'.offset.x')
	_G[char..'GhostData.offsetY'] = getProperty(char..'.offset.y')
end
