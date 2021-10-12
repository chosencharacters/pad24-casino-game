package;

import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.system.FlxAssets;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class PlayState extends FlxState
{
	public static var self:PlayState;

	public var ran:FlxRandom;

	public var slots:FlxTypedGroup<SlotIcon> = new FlxTypedGroup<SlotIcon>();

	var bg:FlxSprite;
	var button:RollButton;

	public var GAME_STATE:GameState = IDLE;

	var roll_rate:Int = 10;
	var tick:Int = 0;

	public var d_money:Int = 0;
	public var money:Int = 1000;
	public var max_money:Int = 9999;
	public var money_text:FlxBitmapText;

	public var ROLL_COST:Int = 100;

	var MATCH_VALUES:Array<Int> = [100, 300, 500];

	var match_return_to_bg_timer:Int = 0;

	override public function create()
	{
		super.create();
		self = this;
		ran = new FlxRandom();

		bgColor = 0xff4c334f;

		bg = new FlxSprite(0, 0, AssetPaths.d12_bg__png);

		FlxG.mouse.load(AssetPaths.d12_cursor__png, 4);

		for (i in 0...3)
		{
			slots.add(new SlotIcon(0, 7));
			switch (i)
			{
				case 1:
					slots.members[i].x = 8;
				case 2:
					slots.members[i].x = 16;
			}
		}

		var fontMono = FlxBitmapFont.fromMonospace(AssetPaths.d12_numbers__png, "0123456789", FlxPoint.weak(4, 5));

		money_text = new FlxBitmapText(fontMono);
		money_text.setPosition(9, 0);
		money_text.color = 0xffffde70;
		money_text.text = "1000";

		button = new RollButton(0, 17);

		add(bg);
		add(slots);
		add(button);
		add(money_text);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed(["R"]) || GAME_STATE == GAME_OVER && FlxG.mouse.justPressed && tick > 10)
			FlxG.resetGame();

		tick++;
		money_string_adjust();

		switch (button.slot_index)
		{
			case 0:
				roll_rate = 5;
			case 1:
				roll_rate = 7;
			case 2:
				roll_rate = 10;
		}

		if (GAME_STATE == ROLLING && tick % roll_rate == 0)
			for (slot in slots)
				slot.next();

		match_return_to_bg_timer--;
		if (match_return_to_bg_timer == 0)
			bgColor = 0xff4c334f;

		if (GAME_STATE == EVALUATE)
			evaluate_results();
	}

	function evaluate_results()
	{
		var results:Array<Int> = [0, 0, 0];

		for (i in 0...slots.length)
			results[i] = slots.members[i].animation.frameIndex;

		var MATCH:Bool = (results[0] == results[1] && results[1] == results[2]);

		if (MATCH)
			money = money + MATCH_VALUES[results[0]];

		bgColor = MATCH ? 0xff70c84a : 0xffbe353c;

		MATCH ? FlxG.sound.play(AssetPaths.sold__ogg) : FlxG.sound.play(AssetPaths.enemyboom__ogg);

		match_return_to_bg_timer = 15;

		GAME_STATE = IDLE;
	}

	function money_string_adjust()
	{
		var intensity:Int = Math.floor(Math.abs(d_money - money));

		if (intensity > 100)
			intensity = 50;
		else if (intensity > 50)
			intensity = 10;
		else if (intensity > 10)
			intensity = 1;

		if (d_money > money)
			d_money -= intensity;
		if (d_money < money)
			d_money += intensity;

		if (d_money < 0)
			d_money = 0;

		if (d_money >= max_money)
		{
			d_money = max_money;
			big_winner();
		}

		money_text.text = Std.string(d_money);
	}

	function hide_all()
	{
		slots.visible = false;
		money_text.visible = false;
		bg.visible = false;
		button.visible = false;
	}

	public function gg_lol()
	{
		hide_all();
		add(new FlxSprite(AssetPaths.d12_lose__png));
		GAME_STATE = GAME_OVER;
		tick = 0;
	}

	function big_winner()
	{
		hide_all();
		add(new FlxSprite(AssetPaths.d12_win__png));
		GAME_STATE = GAME_OVER;
		tick = 0;
	}
}

@:enum
abstract GameState(String)
{
	var IDLE:GameState = "idle";
	var EVALUATE:GameState = "evaluate";
	var ROLLING:GameState = "rolling";
	var GAME_OVER:GameState = "gg";
}
