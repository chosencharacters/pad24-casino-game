import flixel.FlxG;
import flixel.FlxSprite;

// Slot icons just represent one of the symbols
class SlotIcon extends FlxSprite
{
	var STOPPED:Bool = false;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);
		loadGraphic(AssetPaths.d12_icons__png, true, 7, 9);
		roll();
	}

	public function roll()
	{
		animation.frameIndex = PlayState.self.ran.int(0, animation.frames);
		STOPPED = false;
	}

	public function next()
	{
		if (STOPPED)
			return;
		if (animation.frameIndex < animation.frames)
			animation.frameIndex = animation.frameIndex + 1;
		else
			animation.frameIndex = 0;
	}

	public function stop()
	{
		STOPPED = true;
	}
}
