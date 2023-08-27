bopping = true

function onCreatePost()	
	makeLuaSprite("LaboratoryBack", "LaboratoryBack", -780, 200)
	scaleObject("LaboratoryBack", 1.2, 1)
	setScrollFactor("LaboratoryBack", 0.99, 0.99)
	addLuaSprite("LaboratoryBack", false)
	
	makeLuaSprite("LaboratoryFront", "LaboratoryFront", 1409, 1229)
	scaleObject("LaboratoryFront", 1.2, 1)
	setScrollFactor("LaboratoryFront", 0.99, 0.99)
	addLuaSprite("LaboratoryFront", true)
		
		makeLuaSprite("LaboratoryOverlay", "LaboratoryOverlay", -1280, -800)
		scaleObject("LaboratoryOverlay", 1.1, 1.1)
		setScrollFactor("LaboratoryOverlay", 0.5, 0.5)
		setBlendMode("LaboratoryOverlay", "add")
		addLuaSprite("LaboratoryOverlay", true)
end

-- crash prevention
function onUpdate() end
function onUpdatePost() end
