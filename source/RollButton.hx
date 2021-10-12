class RollButton extends FlxSprite
{
	public var slot_index:Int = 0;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);
		loadGraphic(AssetPaths.d12_roll__png);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this))
		{
			if (PlayState.self.GAME_STATE == GameState.IDLE)
			{
				FlxG.sound.play(AssetPaths.pickup__ogg);
				for (slot in PlayState.self.slots)
					slot.roll();
				PlayState.self.GAME_STATE = GameState.ROLLING;
				slot_index = 0;
				FlxG.camera.shake(0.01, 0.05);
				if (PlayState.self.d_money <= 0)
					PlayState.self.gg_lol();
				PlayState.self.money -= PlayState.self.ROLL_COST;
			}
			else if (PlayState.self.GAME_STATE == GameState.ROLLING)
			{
				FlxG.sound.play(AssetPaths.hit__ogg);
				FlxG.camera.shake(0.01, 0.05);
				PlayState.self.slots.members[slot_index].stop();
				if (slot_index == 2)
					PlayState.self.GAME_STATE = GameState.EVALUATE;
				slot_index++;
			}
		}
	}
}
