package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.0'; //refixing a bit
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['Story Mode', 'Freeplay', 'Credits', 'Options'];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var starFG:FlxBackdrop;
	var starBG:FlxBackdrop;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In The Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		starFG = new FlxBackdrop(Paths.image('starFG', 'impasta'), #if (flixel_addons < "3.0.0") 1, 1, true, true #else XY, 1, 1 #end);
		starFG.updateHitbox();
		starFG.antialiasing = ClientPrefs.globalAntialiasing;
		starFG.scrollFactor.set();
		add(starFG);

		starBG = new FlxBackdrop(Paths.image('starBG', 'impasta'), #if (flixel_addons < "3.0.0") 1, 1, true, true #else XY, 1, 1 #end);
		starBG.updateHitbox();
		starBG.antialiasing = ClientPrefs.globalAntialiasing;
		starBG.scrollFactor.set();
		add(starBG);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		FlxG.mouse.visible = true;

		for (i in 0...optionShit.length)
		{
			var testButton:FlxSprite = new FlxSprite(0, 130);
			testButton.ID = i;
			if(i > 3)
				testButton.frames = Paths.getSparrowAtlas('Buttons_UI', 'impasta');
			else
				testButton.frames = Paths.getSparrowAtlas('Big_Buttons_UI', 'impasta');
			testButton.animation.addByPrefix('idle', optionShit[i] + ' Button', 24, true);
			testButton.animation.addByPrefix('hover', optionShit[i] + ' Select', 24, true);
			testButton.animation.play('idle');
			testButton.antialiasing = ClientPrefs.globalAntialiasing;
			testButton.scale.set(0.50 ,0.50);
			testButton.updateHitbox();
			testButton.screenCenter(X);
			testButton.scrollFactor.set();
			// brian was here

			//hi
			switch(i) {
				case 0:
					testButton.setPosition(400, 475);
				case 1:
					testButton.setPosition(633, 475);
				case 2:
					testButton.setPosition(400, 580);
				case 3:
					testButton.setPosition(633, 580);
				case 4:
					testButton.setPosition(455, 640);
				case 5:
					testButton.setPosition(590, 640);
				case 6:
					testButton.setPosition(725, 640);
			}
			menuItems.add(testButton);
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		add(menuItems);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Vs. Impasta v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var canClick:Bool = true;
	var usingMouse:Bool = false;

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}
			// da funi

			/* if (controls.ESCAPE)
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new FreeplayState());
				} */
	

			menuItems.forEach(function(spr:FlxSprite)
			{
				if(usingMouse)
				{
					if(!FlxG.mouse.overlaps(spr))
						spr.animation.play('idle');
				}
		
				if (FlxG.mouse.overlaps(spr))
				{
					if(canClick)
					{
						curSelected = spr.ID;
						usingMouse = true;
						spr.animation.play('hover');
					}
						
					if(FlxG.mouse.pressed && canClick)
					{
						switch (optionShit[curSelected]) {
							default: 
								selectSomething();
						}
					}
				}

				starFG.x -= 0.03;
				starBG.x -= 0.01;
		
				spr.updateHitbox();
			});
			
			/*#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end*/
		}

		super.update(elapsed);
	}

	function selectSomething()
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		
		canClick = false;
		FlxG.mouse.visible = false;

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
			{
				FlxTween.tween(starFG, {y: starFG.y + 500}, 0.7, {ease: FlxEase.quadInOut});
				FlxTween.tween(starBG, {y: starBG.y + 500}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.2});
				FlxG.camera.fade(FlxColor.BLACK, 0.7, false);
				FlxTween.tween(spr, {alpha: 0}, 1.3, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});
			}
			else
			{
				FlxTween.tween(starFG, {y: starFG.y + 500}, 1, {ease: FlxEase.quadInOut});
				FlxTween.tween(starBG, {y: starBG.y + 500}, 1, {ease: FlxEase.quadInOut, startDelay: 0.2});
				FlxG.camera.fade(FlxColor.BLACK, 0.7, false);
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					goToState();
				});
			}
		});
	}

	function goToState()
	{
		final daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'Story Mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'Freeplay':
				FlxG.switchState(new FreeplayState());
				trace("Freeplay Menu Selected");
			case 'Options':
				FlxG.switchState(new options.OptionsState());
				trace("Options Menu Selected");
			case 'Credits':
				FlxG.switchState(new CreditsState());
				trace("Gallery Menu Selected");
		}		
	}


	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('hover');
			}
			spr.updateHitbox();
		});
	}
}
