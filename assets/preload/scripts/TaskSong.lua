function onCreatePost()
    if checkFileExists('data/'..songPath..'/info.txt') then
        --debugPrint('it exists');
        makeLuaText('text', getTextFromFile('data/'..songPath..'/info.txt'), 0, 0, 200);
        setProperty('text.alignment', 'left');
        setProperty('text.size', 24);
        setProperty('text.font', 'arial.ttf');
        setProperty('text.borderSize', 1);
        setObjectCamera('text', 'camOther');
        addLuaText('text');

        size = getProperty('text.width')

        makeLuaSprite('creditbg', nil, size - 12, 200 - 12);
        makeGraphic('creditbg', size + 24, getProperty('text.height') + 24, 'FFFFFF');
        setObjectCamera('creditbg', 'camOther');
        setProperty('creditbg.alpha', 0.47);
        addLuaSprite('creditbg');

        setProperty('creditbg.x', -size);
        setProperty('text.x', -size);
    end
end
function onCountdownTick(counter)
    if counter == 0 then
        doTweenX('bgthingin', 'creditbg', 0, 1, 'quintInOut');
        doTweenX('textthingin', 'text', 0, 1, 'quintInOut');
    end 
end
function onTweenCompleted(tag)
    if tag == 'bgthingin' then
        runTimer('bgthingout', 2);
    end
    if tag == 'bgthingout' then
        removeLuaSprite('creditbg', true);
        removeLuaText('text', true);
    end
end
function onTimerCompleted(tag)
    if tag == 'bgthingout' then
        doTweenX('bgthingout', 'creditbg', -size - size - 50, 1, 'quintInOut');
        doTweenX('textthingout', 'text', -size - size - 50, 1, 'quintInOut');
    end
end