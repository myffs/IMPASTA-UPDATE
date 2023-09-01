// This is modified version of https://github.com/zacksgamerz/flixel-screenshot-plugin/blob/master/src/screenshotplugin/ScreenShotPlugin.hx
package;

import flixel.util.FlxTimer;
#if sys
import sys.FileSystem;
#end
#if android
import android.widget.Toast;
#end
import openfl.utils.ByteArray;
import openfl.display.Sprite;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flixel.input.keyboard.FlxKey;
import lime.utils.Log as LimeLogger;

using StringTools;

/**
 * @author SayofTheLor
 * @author zacksgamerz
 * @author mcagabe19
 */
class SSPlugin extends flixel.FlxBasic
{
	private static var current:SSPlugin = null;

	private var container:Sprite;
	private var flashSprite:Sprite;
	private var flashBitmap:Bitmap;
	private var screenshotSprite:Sprite;
	private var shotDisplayBitmap:Bitmap;
	private var outlineBitmap:Bitmap;

	private static var lastWidth:Int;
	private static var lastHeight:Int;

	public static var enabled:Bool = true;
	public static var screenshotKey:FlxKey = FlxKey.F2;
	public static var saveFormat(default, set):FileFormatOption = PNG;

	/**
	 * The color used for the flash
	 */
	public static var flashColor(default, set):Int = 0xFFFFFFFF;

	/**
	 * The color used for the outline in the screenshot display
	 */
	public static var outlineColor(default, set):Int = 0xFFFFFFFF;

	/**
	 * The quality of screenshots saved as `JPEG`, default to 80
	 */
	public static var JPEGQuality(default, set):Int = 80;

	inline public static function set_saveFormat(v:FileFormatOption)
	{
		if (v != JPEG && v != PNG)
		{
			FlxG.log.warn('ScreenShotPlugin: Unsupported format ${v}, using .png instead');
			v = PNG;
		}
		return saveFormat = v;
	}

	inline public static function set_flashColor(v:Int):Int
	{
		flashColor = v;
		if (current != null && current.flashBitmap != null)
			current.flashBitmap.bitmapData = new BitmapData(lastWidth, lastHeight, true, v);
		return flashColor;
	}

	inline public static function set_outlineColor(v:Int):Int
	{
		outlineColor = v;
		if (current != null && current.outlineBitmap != null)
			current.outlineBitmap.bitmapData = new BitmapData(Std.int(lastWidth / 5) + 10, Std.int(lastHeight / 5) + 10, true, outlineColor);
		return outlineColor;
	}

	inline public static function set_JPEGQuality(v:Int):Int
		return JPEGQuality = Std.int(Math.max(0, Math.min(100, v)));

	public static var onScreenshot:Void->Void = null;

	/**
	 * Initialize a new `ScreenShotPlugin` instance
	 */
	override public function new():Void
	{
		super();

		if (current != null)
		{
			destroy();
			return;
		}

		current = this;
		container = new Sprite();
		FlxG.stage.addChild(container);
		flashSprite = new Sprite();
		flashSprite.alpha = 0;
		flashBitmap = new Bitmap(new BitmapData(FlxG.width, FlxG.height, true, 0xFFFFFFFF));
		flashSprite.addChild(flashBitmap);
		screenshotSprite = new Sprite();
		screenshotSprite.alpha = 0;
		container.addChild(screenshotSprite);
		outlineBitmap = new Bitmap(new BitmapData(Std.int(FlxG.width / 5) + 10, Std.int(FlxG.height / 5) + 10, true, 0xffffffff));
		outlineBitmap.x = 5;
		outlineBitmap.y = 5;
		screenshotSprite.addChild(outlineBitmap);
		shotDisplayBitmap = new Bitmap();
		shotDisplayBitmap.scaleX /= 5;
		shotDisplayBitmap.scaleY /= 5;
		screenshotSprite.addChild(shotDisplayBitmap);
		container.addChild(flashSprite);
		@:privateAccess openfl.Lib.application.window.onResize.add((w, h) ->
		{
			flashBitmap.bitmapData = new BitmapData(w, h, true, 0xFFFFFFFF);
			outlineBitmap.bitmapData = new BitmapData(Std.int(w / 5) + 10, Std.int(h / 5) + 10, true, 0xffffffff);
		});
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.checkStatus(screenshotKey, JUST_PRESSED) && enabled)
			screenshot();
	}

	private function screenshot():Void
	{
		FlxTween.cancelTweensOf(flashSprite);
		FlxTween.cancelTweensOf(screenshotSprite);
		flashSprite.alpha = 0;
		screenshotSprite.alpha = 0;

		if (onScreenshot != null)
			onScreenshot();

		new FlxTimer().start(0.1, _ ->
		{
			final shot:Bitmap = new Bitmap(BitmapData.fromImage(FlxG.stage.window.readPixels()));
			final png:ByteArray = shot.bitmapData.encode(shot.bitmapData.rect, saveFormat.returnEncoder());
			png.position = 0;
			#if sys
			try
			{
				#if mobile
				if (!FileSystem.exists(SUtil.getStorageDirectory() + './screenshots/'))
					FileSystem.createDirectory(SUtil.getStorageDirectory() + './screenshots/');
				var path = SUtil.getStorageDirectory()
					+ 'screenshots/Screenshot '
					+ Date.now().toString().replace(' ', '-').replace(':', "'")
					+ saveFormat;
				#else
				var path = "screenshots/Screenshot " + Date.now().toString().split(":").join("-") + saveFormat;
				if (!FileSystem.exists("./screenshots/"))
					FileSystem.createDirectory("./screenshots/");
				#end
				sys.io.File.saveBytes(path, png);
			}
			catch (e:Dynamic)
			{
				#if android
				Toast.makeText("Error!\nClouldn't save the screenshot because:\n" + e, Toast.LENGTH_LONG);
				#else
				LimeLogger.println("Error!\nClouldn't save the screenshot because:\n" + e);
				#end
			}
			#end
			flashSprite.alpha = 1;
			FlxTween.tween(flashSprite, {alpha: 0}, 0.25);
			shotDisplayBitmap.bitmapData = shot.bitmapData;
			shotDisplayBitmap.x = outlineBitmap.x + 5;
			shotDisplayBitmap.y = outlineBitmap.y + 5;
			screenshotSprite.alpha = 1;
			FlxTween.tween(screenshotSprite, {alpha: 0}, 0.5, {startDelay: .5});

			if (onScreenshot != null)
				onScreenshot();
		});
	}

	inline private function resizeBitmap(width:Int, height:Int)
	{
		lastWidth = width;
		lastHeight = height;
		flashBitmap.bitmapData = new BitmapData(lastWidth, lastHeight, true, flashColor);
		outlineBitmap.bitmapData = new BitmapData(Std.int(lastWidth / 5) + 10, Std.int(lastHeight / 5) + 10, true, outlineColor);
	}

	override public function destroy():Void
	{
		if (current == this)
			current = null;

		if (FlxG.plugins.list.contains(this))
			FlxG.plugins.remove(this);

		FlxG.signals.gameResized.remove(this.resizeBitmap);
		FlxG.stage.removeChild(container);

		super.destroy();

		if (container == null)
			return;

		@:privateAccess
		for (parent in [container, flashSprite, screenshotSprite])
			for (child in parent.__children)
				parent.removeChild(child);

		container = null;
		flashSprite = null;
		flashBitmap = null;
		screenshotSprite = null;
		shotDisplayBitmap = null;
		outlineBitmap = null;
	}
}

enum abstract FileFormatOption(String) from String
{
	var JPEG = ".jpg";
	var PNG = ".png";

	public function returnEncoder():Any
	{
		return switch (this : FileFormatOption)
		{
			case JPEG: new openfl.display.JPEGEncoderOptions(SSPlugin.JPEGQuality);
			default: new openfl.display.PNGEncoderOptions();
		}
	}
}
