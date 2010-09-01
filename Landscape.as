package {
	import landscape.Fireflies;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.text.engine.*;
    import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
    import flash.display.Sprite;
	import flash.geom.*
	import flash.display.*
	import flash.events.*
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	// import flash.text.TextField;
	import flash.text.TextFormat;
	// import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.SoundShortcuts;
	SoundShortcuts.init();
	
	// [SWF( backgroundColor='0x10101a', frameRate='44', width='384', height='384')]

    public class Landscape extends Sprite {
		
		// Define constants
		// private var horizon:int = (stage.stageHeight / 3) * 2;
		public const HORIZON:int = 300;
		//The total length of the wave
		// private var waveLength:Number  = stage.stageWidth;
		//The 'shift' of the wave i.e. when the first arc is made
		public const PHASE:Number = 0;
		//The height of ONE side of the wave (the total height is double this, because the wave arcs downward)
		public const AMPLITUDE:int = 50;
		//The frequency of the wave i.e. how many 'sides' (arcs) to draw
		public const FREQUENCY:int = 2;
		
		var resizeTimer:Timer = new Timer(5, 1);

		public function Landscape():void {
			
			var d:MonsterDebugger = new MonsterDebugger(this); 
			
			stage.quality = StageQuality.MEDIUM;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			stage.addEventListener(Event.RESIZE, onResizeStage);
			
			
			resizeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, bigBang);
			
			initialize();
			
		}
		
		private function bigBang(e:TimerEvent):void {
			var holder = stage.getChildAt(0);
			// trace ('before : '+holder.numChildren);
			while(holder.numChildren) {
				holder.removeChildAt(0);
			}
			// trace ('after : '+holder.numChildren);
			initialize();
		}
		
		private function initialize():void {
			var stars1:Bitmap = drawStars(1000, 3);
			var stars2:Bitmap = drawStars(1000, 1);
			addChildAt(stars1, 0);
			addChildAt(stars2, 1);
			
			var moonHalo:Sprite = drawMoon(100, 100);
            var moon:Sprite = drawMoon(75, 5);
            moon.addChild(moonHalo);
            addChildAt(moon, 2);
           
            moon.buttonMode = true;
           
            moon.alpha = 1;
            moon.x = stage.stageWidth / 2;
            moon.y = HORIZON;
            moon.rotation = 50;
			
			animateStarGlow();
			
			var sunset:Sprite = drawSunset(AMPLITUDE, 0, HORIZON);
			addChildAt(sunset, 4);
			
			var horizonSign:Sprite = drawHorizonSign('Nate Eagle', HORIZON);
			addChildAt(horizonSign, 5);
			horizonSign.x = 0;
			horizonSign.y = HORIZON;
			
			// trace(horizonSign.getChildAt(0));
			for(var i:int = 0; i < horizonSign.numChildren; i++) {
				horizonSign.getChildAt(i).addEventListener(MouseEvent.CLICK, horizonLetterClick);
			}
			
			var land:Sprite = drawLand(AMPLITUDE, HORIZON);
			addChild(land);
			land.x = 0;
			land.y = 0;
			
			/*var horizonNavigation:Sprite = drawHorizonNavigation('About Portfolio Blog', horizon);
			addChild(horizonNavigation);
			horizonNavigation.x = 0;
			horizonNavigation.y = horizon + 30;*/
			
			
			// Tweener.addTween(sunset, {y: stage.stageHeight, transition: 'linear', time: 500});
			
			var moonGlow:Bitmap = drawMoonGlow();
            addChild(moonGlow);
		
			var fireflies:Sprite = new Fireflies(stage.stageWidth, stage.stageHeight, HORIZON, 10);
			addChild(fireflies);
		
			var grain:Bitmap = drawGrain();
			addChild(grain);
			
			/*var black:Bitmap = drawBlack();
			addChild(black);
			black.alpha = 1;
			Tweener.addTween(black, {alpha: 0, transition: 'linear', time: 5});*/
		}
		
		private function onResizeStage(e:Event):void {
			resizeTimer.reset();
			// trace('Stage width:' + stage.stageWidth + ' Stage height: ' + stage.stageHeight);
			resizeTimer.start();
		}
		
		private function drawBlack():Bitmap {
			var blackData:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000);
			var black:Bitmap = new Bitmap(blackData);
			return black;
		}
		
		private function horizonLetterClick(event:Event):void {
			var letter = event.target;
			var letterParent = event.target.parent;
			var letterSoundChannel = new SoundChannel();
			var letterText = event.target.textBlock.content.text;
			var letterStatus = event.target.userData;
			
			// trace(letterParent.getChildIndex(letter));
			// if (letterStatus == 'off') { activate(); } else { deactivate(); }
			activate();
			
			function activate():void {
				var newLetter:TextLine = colorChange(0xFEFFBF);
				newLetter.userData = 'on';
				playSound();
				 
				Tweener.addTween(newLetter, {alpha: 1, transition: 'linear', time: .1, onComplete: colorChangeComplete});
				
				function colorChangeComplete():void {
					// letterParent.removeChild(letter);
				}
				 
				newLetter.addEventListener(MouseEvent.CLICK, deactivate);
				
				function deactivate():void {
					
					
					Tweener.addTween(newLetter, {alpha: 0, transition: 'linear', time: .1, onComplete: deactivateComplete});
					
					function deactivateComplete():void {
						newLetter.parent.removeChild(newLetter);
						stopSound();
					}
				}
			}
			
			function colorChange(letterColor:uint):TextLine {
				
				var newFormat:ElementFormat = event.target.textBlock.content.elementFormat.clone();
				newFormat.color = letterColor;
				event.target.textBlock.content.elementFormat = newFormat;
				var character:TextLine = event.target.textBlock.createTextLine(null, 600);
				
				letterParent.addChild(character);
				character.x = event.target.x;
				character.y = event.target.y;
				character.rotation = event.target.rotation;
				character.alpha = 0;
				
				return character;
			}
			
			function playSound():void {
				var snd:Sound = new Sound();
				var soundURL:String;
				var repeat:int = int.MAX_VALUE;
				switch (letterParent.getChildIndex(letter)) {
					case 0:
						soundURL = 'audio/crickets2.mp3';
						break;
					case 1:
						soundURL = 'audio/nightingales.mp3';
						break;
					case 2:
						soundURL = 'audio/garden_chimes.mp3';
						break;
					case 3:
						soundURL = 'audio/cicada.mp3';
						break;
					case 5:
						soundURL = 'audio/tawny_owl.mp3';
						break;
					case 6:
						soundURL = 'audio/harmonica.mp3';
						break;
					case 7:
						soundURL = 'audio/radio.mp3';
						repeat = 0;
						break;
					default:
						soundURL = 'audio/crickets.mp3';
						trace('No sound assigned.');
				}
				snd.load(new URLRequest(soundURL));
				
				letterSoundChannel = snd.play(0, repeat);
			}
			
			function stopSound():void {
				Tweener.addTween(letterSoundChannel, {_sound_volume: 0, transition: 'linear', time: 1, onComplete: stopComplete});
				function stopComplete():void {
					letterSoundChannel.stop();
					letterSoundChannel = null;
				}
			}
		}

		// For now we see through a glass, darkly.
		private function drawGrain():Bitmap {
			var grainData:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
			var seed:int = int(Math.random() * int.MAX_VALUE);
			grainData.noise(seed, 0, 0xFF, BitmapDataChannel.RED, true);
			
			var grain:Bitmap = new Bitmap(grainData);
			grain.alpha = .15;
			// addChild(grain);

			return grain;
		}
		
		// Starry, starry night. Paint your palette blue and grey.
        private function drawStars(stars:int, blur:int):Bitmap {
           
            var starrySkyData:BitmapData = new BitmapData(stage.stageWidth, HORIZON, true, 0);
            var starrySky:Bitmap = new Bitmap(starrySkyData);
            addChild(starrySky);

            starrySkyData.lock();
           
            for(var i:uint = 0; i < stars; i++) {
               
                var radius:Number = Math.ceil((Math.random() * 3)) / 2;
                var starX:uint = Math.random() * starrySky.width;
                var starY:uint = Math.random() * starrySky.height;
                var starOpacity:int = Math.random() * 100;
                var starColorString:String = '0x' + starOpacity + 'FFFFFF';
                var starColor:uint = Number(starColorString);
               
                var star:Shape = new Shape();
                star.graphics.beginFill(0xFFFFFF);
                star.graphics.drawCircle(starX, starY, radius);
                star.graphics.endFill();
               
                starrySkyData.draw(star);
            }
           
            starrySkyData.unlock();
           
            var starFilters:Array = new Array();
            var starBlur:BlurFilter = new BlurFilter(blur, blur, BitmapFilterQuality.MEDIUM);
            starFilters.push(starBlur);
           
            starrySky.filters = starFilters;
           
            return starrySky;  
        }
       	
		// The stars hang bright above, silent, as if they watched the sleeping earth.
        private function drawStarGlow():Bitmap {
            var starGlowData:BitmapData = new BitmapData(stage.stageWidth, HORIZON);
            var starGlow:Bitmap = new Bitmap(starGlowData);
           
            var baseX:Number = 100;
            var baseY:Number = 75;
            var numOctaves:Number = 2;
            var randomSeed:Number = Math.random();
            var stitch:Boolean = true;
            var fractalNoise:Boolean = true;
            var channelOptions:Number = BitmapDataChannel.BLUE | BitmapDataChannel.ALPHA;
            var grayScale:Boolean = false;
            var offsets:Array = new Array(new Point(), new Point());
           
            starGlowData.perlinNoise(baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions, grayScale, offsets);
           
            var starGlowColor = new ColorTransform();
            starGlowColor.color = 0x3b7c92;
            starGlow.transform.colorTransform = starGlowColor;
           
            return starGlow;
        }
		
		private function animateStarGlow():void {
			var cloudTile:Sprite = new Sprite();
			addChild(cloudTile);
			var tile1:Bitmap = drawStarGlow();
			var tile2:Bitmap = drawStarGlow();
			var tile3:Bitmap = new Bitmap();
			tile3.bitmapData = tile1.bitmapData;
			tile3.transform = tile1.transform;
			
			cloudTile.addChild(tile1);
			cloudTile.addChild(tile2);
			cloudTile.addChild(tile3);
			
			tile1.x = 0;
			tile2.x = stage.stageWidth;
			tile3.x = stage.stageWidth * 2;
			
			cloudTile.alpha = .6;
			
			animateCloudTile();
			
			function animateCloudTile():void {
				trace('Time');
				var time:int = 60;
				cloudTile.x = 0;
				Tweener.addTween(cloudTile, {x: cloudTile.x - stage.stageWidth * 2, transition: 'linear', time: time, onComplete: animateCloudTile});
				
			};
		}
       
        private function drawMoonGlow():Bitmap {
            var moonGlowData:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight * 2, true, 0);
            var moonGlow:Bitmap = new Bitmap(moonGlowData);
           
            var moonGlowGrad:Sprite = new Sprite();
           
            var fillType:String = GradientType.RADIAL;
            var colors:Array = [0x000000, 0x000000];
            var alphas:Array = [0, .8];
            var ratios:Array = [0, 255];
            var matr:Matrix = new Matrix();
            matr.createGradientBox(stage.stageWidth, stage.stageHeight * 2, 3 * Math.PI / 2, 0, -stage.stageHeight / 2);
            var spreadMethod:String = SpreadMethod.PAD;
            moonGlowGrad.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod); 
            moonGlowGrad.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight * 2);
           
            moonGlowData.draw(moonGlowGrad);
           
            return moonGlow;
        }
		
		// This land is your land; this land is my land
		private function drawLand(amplitude:int, yOffset:int):Sprite {
			var land:Sprite = new Sprite();
			// addChild(land);
			
			//The offset of the x axis
			var xOffset : Number = 0;
			// The offset of the y axis
			// var yOffset : Number = 0;
			land.graphics.beginFill(0x2e8cbd);
			//Set your line style options
			land.graphics.lineStyle( 0 , 0x000000 , 0 );
			//Move to the starting position
			land.graphics.moveTo( xOffset , yOffset );
			//The changing y coordinate
			var yPosition : Number = yOffset;
			//The changing x coordinate
			var xPosition : Number = xOffset;
			while( xPosition <= stage.stageWidth )
			{
			    yPosition = findHorizon(xPosition);
				// yPosition = findHorizonSlope(xPosition);
			    land.graphics.lineTo( xPosition + xOffset , yPosition + yOffset );
			    xPosition++;
			}
			
			land.graphics.lineTo( stage.stageWidth , stage.stageHeight );
			land.graphics.lineTo( 0 , stage.stageHeight );
			land.graphics.lineTo( 0 , yOffset );
			land.graphics.endFill();
			
			return land;
		}
		
		// Is there anything more beautiful than a beautiful, beautiful flamingo, flying across in front of a beautiful sunset?
		// And he's carrying a beautiful rose in his beak, and also he's carrying a very beautiful painting with his feet.
		// And also, you're drunk.
		private function drawSunset(amplitude:int, yOffset:int, horizon:int):Sprite {
			var sunset:Sprite = new Sprite();
			// addChild(sunset);
			
			var sunsetHeight:int = (horizon + amplitude) - yOffset;
			
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0xd03000, 0xffcb2d, 0x3b7c92, 0x000000];
			var alphas:Array = [1, .8, .6, 0];
			var ratios:Array = [5, 40, 100, 220];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(stage.stageWidth, sunsetHeight, 3 * Math.PI / 2, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;
			sunset.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
			sunset.graphics.drawRect(0, yOffset, stage.stageWidth, sunsetHeight);
			
			sunset.alpha = 1;
			
			return sunset;
		}
		
		// Goodnight, Moon.
        private function drawMoon(radius:int, blur:int):Sprite {
            var moon:Sprite = new Sprite();
           
            var moonShape:Shape = new Shape();
            moonShape.graphics.beginFill(0xe7f2f4);
            moonShape.graphics.drawCircle(0, -stage.stageWidth / 3, radius);
            moonShape.graphics.endFill();
           
            moon.addChild(moonShape);
           
            var moonFilters:Array = new Array();
            var moonBlur:BlurFilter = new BlurFilter(blur, blur, BitmapFilterQuality.MEDIUM);
            moonFilters.push(moonBlur);
           
            moon.filters = moonFilters;
           
            return moon;
        }
		
		// Never look down to test the ground before taking your next step; only he
		// who keeps his eye fixed on the far horizon will find the right road.
		private function findHorizon(horizonX:Number):Number {
			// Constants are defined at the beginning of the file			
			var waveLength:Number = stage.stageWidth;
			var horizonY:Number = AMPLITUDE * Math.sin( ( ( horizonX / waveLength ) * ( Math.PI * FREQUENCY ) ) + PHASE );
			
			return horizonY;
		}
		
		private function findHorizonSlope(horizonX:Number):Number {
			var horizonSlope:Number;
			var waveLength:Number = stage.stageWidth;
			horizonSlope = ( AMPLITUDE * Math.PI * FREQUENCY * Math.cos((Math.PI * FREQUENCY * horizonX) / waveLength) ) / waveLength;
			
			return horizonSlope;
		}
		
		private function drawHorizonSign(horizonSignText:String, horizon:int):Sprite {
			
			var horizonSign:Sprite = new Sprite();
			
			var fd:FontDescription = new FontDescription();
            fd.fontName = "Almonte";
            // fd.fontName = 'Rosewood Std';
			fd.fontWeight = flash.text.engine.FontWeight.BOLD;
			
            
			var xOffset:Number = stage.stageWidth / 9;
			for(var i:int = 0; i < horizonSignText.length; i++) {
				var str:String = horizonSignText.substring(i, i+1);
				
				var horizonSignTextBlock:TextBlock = new TextBlock();
				
				var ef1:ElementFormat = new ElementFormat(fd);
				ef1.fontSize = 100 + Math.random() * 100;
				ef1.color = 0x992f16;
				ef1.alpha = 100;
				ef1.kerning = flash.text.engine.Kerning.ON;
				ef1.trackingRight = 2;
				ef1.typographicCase = flash.text.engine.TypographicCase.UPPERCASE;
				ef1.alignmentBaseline = flash.text.engine.TextBaseline.DESCENT;
				ef1.ligatureLevel = flash.text.engine.LigatureLevel.EXOTIC;
				
				var te1:TextElement = new TextElement(str, ef1);
				horizonSignTextBlock.content = te1;
				var character:TextLine = horizonSignTextBlock.createTextLine(null, 600);
				horizonSign.addChild(character);
				character.x = xOffset;
				var characterY:int = findHorizon(character.x) - (character.height / 5);
				// character.y = character.y + character.height;
				character.y = characterY;
				
				xOffset += character.width + (Math.random() * 40);
				
				// Tweener.addTween(character, {y: characterY, transition: 'easeIn', time: 25, delay: Math.random() * 3});
		
				var slope:Number = findHorizonSlope(character.x) * 180 / Math.PI;
				character.rotation = slope;
				character.userData = 'off';
				// trace('Slope: ' + slope);
				// trace('Width of this character: ' + character.width);
				
				/*var ef2:ElementFormat = new ElementFormat(fd);
				ef2.fontSize = ef1.fontSize;
				ef2.color = 0x333333;
				ef2.alpha = 0.3;
				ef2.kerning = flash.text.engine.Kerning.OFF;
				ef2.typographicCase = flash.text.engine.TypographicCase.UPPERCASE;
				ef2.digitCase = flash.text.engine.DigitCase.OLD_STYLE;
				ef2.textRotation = flash.text.engine.TextRotation.ROTATE_180;
				
				tb.content.elementFormat = ef2;
				var character2:TextLine = tb.createTextLine(null, 600);
				horizonSign.addChild(character2);
				character2.x = xOffset;
				character2.y = findHorizon(character2.x) + (character2.height / 5);
		
				var slope:Number = findHorizonSlope(character2.x) * 180 / Math.PI;
				character2.rotation = slope;*/
				
				// xOffset = xOffset + character.width - Math.random() * 10;
			}
			
			horizonSign.buttonMode = true;
			return horizonSign;
		}
		
		private function drawHorizonNavigation(horizonNavigationText:String, horizon:int):Sprite {
			
			var horizonNavigation:Sprite = new Sprite();
			
			var fd:FontDescription = new FontDescription();
            fd.fontName = "Almonte";
            // fd.fontName = 'Rosewood Std';
			fd.fontWeight = flash.text.engine.FontWeight.BOLD;
			
            
			var xOffset:Number = stage.stageWidth / 3;
			for(var i:int = 0; i < horizonNavigationText.length; i++) {
				var str:String = horizonNavigationText.substring(i, i+1);
				
				var horizonNavigationTextBlock:TextBlock = new TextBlock();
				
				var ef1:ElementFormat = new ElementFormat(fd);
				ef1.fontSize = 60;
				ef1.color = 0x1D4C9F;
				ef1.alpha = 100;
				ef1.kerning = flash.text.engine.Kerning.ON;
				ef1.trackingRight = 2;
				ef1.typographicCase = flash.text.engine.TypographicCase.UPPERCASE;
				ef1.alignmentBaseline = flash.text.engine.TextBaseline.DESCENT;
				ef1.ligatureLevel = flash.text.engine.LigatureLevel.EXOTIC;
				
				var te1:TextElement = new TextElement(str, ef1);
				horizonNavigationTextBlock.content = te1;
				var character:TextLine = horizonNavigationTextBlock.createTextLine(null, 600);
				horizonNavigation.addChild(character);
				character.x = xOffset;
				var characterY:int = findHorizon(character.x) - (character.height / 5);
				// character.y = character.y + character.height;
				character.y = characterY;
				
				xOffset += character.width;
				
				// Tweener.addTween(character, {y: characterY, transition: 'easeIn', time: 25, delay: Math.random() * 3});
		
				var slope:Number = findHorizonSlope(character.x) * 180 / Math.PI;
				character.rotation = slope;
				character.userData = 'off';
			}
			
			horizonNavigation.buttonMode = true;
			return horizonNavigation;
		}

    }
}
