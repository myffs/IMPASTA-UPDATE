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