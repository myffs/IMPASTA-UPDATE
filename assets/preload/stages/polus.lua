
--How makeLuaSprite works:
--makeLuaSprite(<SPRITE VARIABLE>, <SPRITE IMAGE FILE NAME>, <X>, <Y>);
--"Sprite Variable" is how you refer to the sprite you just spawned in other methods like "setScrollFactor" and "scaleObject" for example

--so for example, i made the sprites "stagelight_left" and "stagelight_right", i can use "scaleObject('stagelight_left', 1.1, 1.1)"
--to adjust the scale of specifically the one stage light on left instead of both of them

function onCreate()
	-- background shit
	makeLuaSprite('front', 'front', 0, 90);
	setScrollFactor('front', 0.9, 0.9);
	scaleObject('front', 0.9, 0.9);


	makeLuaSprite('back', 'back', 0, 0);
	setScrollFactor('back', 0.9, 0.9);

	

	addLuaSprite('back', false);
	addLuaSprite('front', false);
end