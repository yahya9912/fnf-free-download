// shut up vsc

import flixel.ui.FlxBar;
import flixel.ui.FlxBarFillDirection;
import karaoke.game.FreeIcon;

public var healthBarShadow:FunkinSprite;
public var flowBarShadow:FunkinSprite;
public var flowBarBG:FunkinSprite;
public var flowBar:FlxBar;
public var flow:Float = 0;

public var scoreTxtShadow:FunkinText;

public var playerIcon:FunkinSprite;
public var opponentIcon:FunkinSprite;

public var uiskin:String = "default";

function onCountdown(event) {
	if (event.swagCounter != 4) {
		event.spritePath = "game/spr_countdown_" + event.swagCounter;
		event.soundPath = "gameplay/snd_" + (event.swagCounter == 3 ? "go" : FlxMath.remapToRange(event.swagCounter-1, -1, 3, 3, -1));
		event.scale = 2;
	}
}

function onPostCountdown(event) {
	if (event.sprite != null) {
		var spr = event.sprite;
		spr.antialiasing = false;
		FlxTween.cancelTweensOf(spr);
		FlxTween.tween(spr, {alpha: 0}, Conductor.crochet / 1000, {
			onComplete: (tween:FlxTween) -> {
				spr.destroy();
				remove(spr, true);
			}
		});
	}
}

function onSongStart() {
	canPause = true;
}

function postCreate() {
	canPause = false;
	for (sl in strumLines.members) {
        for (note in sl.notes.members)
            note.alpha = 1;
	}

	for (i in [iconP1, iconP2, healthBarBG, healthBar, scoreTxt, missesTxt, accuracyTxt])
		remove(i);

	healthBar = new FlxBar(0, 358, FlxBarFillDirection.RIGHT_TO_LEFT, FlxG.width*0.695, 15, this, 'health', 0, maxHealth);
	healthBar.scrollFactor.set();
	healthBar.createFilledBar(0xFF800080, 0xFFFFFF00);
	healthBar.cameras = [camHUD];
	healthBar.screenCenter(FlxAxes.X);
	add(healthBar);

	healthBarShadow = new FunkinSprite(healthBar.x+2, healthBar.y+(downscroll ? -4 : 2)).makeSolid(healthBar.width+2, healthBar.height+2, 0xFF000000);
	healthBarShadow.scrollFactor.set();
	healthBarShadow.cameras = [camHUD];
	insert(members.indexOf(healthBar), healthBarShadow);
	
	healthBarBG = new FunkinSprite(healthBar.x-2, healthBar.y-2).makeSolid(healthBar.width+4, healthBar.height+4, 0xFF000000);
	healthBarBG.scrollFactor.set();
	healthBarBG.cameras = [camHUD];
	insert(members.indexOf(healthBar), healthBarBG);

	flowBar = new FlxBar(0, healthBar.y - 19, FlxBarFillDirection.RIGHT_TO_LEFT, FlxG.width*0.4, 8);
	flowBar.scrollFactor.set();
	flowBar.createFilledBar(0xFF12484B, 0xFF37949A);
	flowBar.cameras = [camHUD];
	flowBar.screenCenter(FlxAxes.X);
	add(flowBar);

	flowBarShadow = new FunkinSprite(flowBar.x+2, flowBar.y+(downscroll ? -4 : 2)).makeSolid(flowBar.width+2, flowBar.height+2, 0xFF000000);
	flowBarShadow.scrollFactor.set();
	flowBarShadow.cameras = [camHUD];
	insert(members.indexOf(healthBar), flowBarShadow);

	flowBarBG = new FunkinSprite(flowBar.x-2, flowBar.y-2).makeSolid(flowBar.width+4, flowBar.height+4, 0xFF000000);
	flowBarBG.scrollFactor.set();
	flowBarBG.cameras = [camHUD];
	insert(members.indexOf(flowBar), flowBarBG);

	scoreTxt = new FunkinText(10, healthBarBG.y + healthBarBG.height, FlxG.width-20, 'score: 0 | misses: 0', 16, true);
	scoreTxt.alignment = 'center';
	scoreTxt.antialiasing = false;
	scoreTxt.scrollFactor.set();
	scoreTxt.borderSize = 2;
	scoreTxt.cameras = [camHUD];
	scoreTxt.font = Paths.font("COMICBD.TTF");
	add(scoreTxt);

	scoreTxtShadow = new FunkinText(scoreTxt.x+2, scoreTxt.y+2, FlxG.width-20, 'score: 0 | misses: 0', 16, true);
	scoreTxtShadow.alignment = 'center';
	scoreTxtShadow.antialiasing = false;
	scoreTxtShadow.scrollFactor.set();
	scoreTxtShadow.borderSize = 1;
	scoreTxtShadow.color = 0xFF000000;
	scoreTxtShadow.cameras = [camHUD];
	scoreTxtShadow.font = Paths.font("COMICBD.TTF");
	insert(members.indexOf(scoreTxt), scoreTxtShadow);

	// lunarcleint figured this out thank you lunar holy shit 🙏
	scoreTxt.textField.antiAliasType = scoreTxtShadow.textField.antiAliasType = 0; // advanced
	scoreTxt.textField.sharpness = scoreTxtShadow.textField.sharpness = 400; // max i think idk thats what it says

	// var ref:FunkinSprite = new FunkinSprite().loadGraphic(Paths.image('ref'));
	// ref.zoomFactor = 0;
	// ref.scrollFactor.set();
	// ref.scale.set(0.5, 0.5);
	// ref.updateHitbox();
	// ref.cameras = [camHUD];
	// ref.alpha = 0.9;
	// insert(0, ref);

	playerIcon = new FreeIcon("dude-" + uiskin);
	playerIcon.cameras = [camHUD];
	add(playerIcon);

	opponentIcon = new FreeIcon("strad-" + uiskin);
	opponentIcon.cameras = [camHUD];
	add(opponentIcon);

	playerIcon.y = healthBar.y - (playerIcon.height/2.25);
	opponentIcon.y = healthBar.y - (opponentIcon.height/2.25);

	switch(uiskin) {
		case "gaw":
			for (i in [healthBarShadow, healthBarBG, scoreTxtShadow, flowBarBG, flowBarShadow])
				i.colorTransform.color = 0xFFFFFFFF;
			
			healthBar.createFilledBar(0xFF000000, 0xFF000000);
			flowBar.createFilledBar(0xFF000000, 0xFFFFFFFF);

			scoreTxt.setFormat(scoreTxt.font, scoreTxt.size, 0xFF000000, scoreTxt.alignment, scoreTxt.borderStyle, 0xFFFFFFFF);
	}
}

var timer:Float = 0;
function postUpdate(elapsed:Float) {
	timer += elapsed;

	scoreTxt.text = scoreTxtShadow.text = 'score: ' + songScore + ' | misses: ' + misses;

	flowBar.y = Std.int((healthBar.y - 18) + (Math.sin(timer * 4.5) + 1) * 1.25); // tank you wizard 🙏
	flowBarShadow.y = flowBar.y+(downscroll ? -4 : 2);
	flowBarBG.y = flowBar.y - 2;

	playerIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 1, 0)) - 5);
	opponentIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 1, 0))) - (opponentIcon.width - 10);

	playerIcon.health = healthBar.percent / 100;
	opponentIcon.health = 1 - (healthBar.percent / 100);
}