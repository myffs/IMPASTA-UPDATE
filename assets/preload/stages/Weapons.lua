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