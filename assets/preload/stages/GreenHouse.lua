

--How makeLuaSprite works:
--makeLuaSprite(<SPRITE VARIABLE>, <SPRITE IMAGE FILE NAME>, <X>, <Y>);
--"Sprite Variable" is how you refer to the sprite you just spawned in other methods like "setScrollFactor" and "scaleObject" for example

--so for example, i made the sprites "stagelight_left" and "stagelight_right", i can use "scaleObject('stagelight_left', 1.1, 1.1)"
--to adjust the scale of specifically the one stage light on left instead of both of them

function onCreate()
	-- background shit
	makeLuaSprite('GreenHouseFront', 'GreenHouseFront', 90, 220);
	setScrollFactor('GreenHouseFront', 0.9, 0.9);
	scaleObject('GreenHouseFront', 0.9, 0.9);


	makeLuaSprite('GreenHouseBack', 'GreenHouseBack', 0, 0);
	setScrollFactor('GreenHouseBack', 0.9, 0.9);

	

	addLuaSprite('GreenHouseBack', false);
	addLuaSprite('GreenHouseFront', true);
end