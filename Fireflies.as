package landscape {
	import flash.display.Sprite;
	import flash.display.*;
	import flash.filters.BlurFilter;
	import flash.filters.BitmapFilterQuality;
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.CurveModifiers;
	CurveModifiers.init();

    public class Fireflies extends Sprite {
        
		// Define constants
		private var stageWidth;
		private var stageHeight;
		
		public function Fireflies(stageWidth, stageHeight, horizon, numberFireflies):void {
			stageWidth = stageWidth;
			stageHeight = stageHeight;
			for(var i:int = 0; i<numberFireflies; i++) {
				var size = Math.ceil((Math.random() * 2)) + 1;
				var firefly = drawBug(Math.random() * stageWidth, ((Math.random()* 200) - 100) + horizon - 100, size, size + 2);
				addChild(firefly);
				firefly.alpha = 0;

				animateFirefly(firefly, firefly.x, firefly.y);
			}
		}
		
		private function drawBug(bugX = 0, bugY = 0, size = 1, blur = 0):Sprite {
			var firefly:Sprite = new Sprite();
			var bug:Shape = new Shape();
            bug.graphics.beginFill(0xE9FF8F);
            bug.graphics.drawCircle(bugX, bugY, size);
            bug.graphics.endFill();
			
			var bugFilters:Array = new Array();
            var bugBlur:BlurFilter = new BlurFilter(blur, blur, BitmapFilterQuality.MEDIUM);
            bugFilters.push(bugBlur);
           
            bug.filters = bugFilters;
			firefly.addChild(bug);
			
			return firefly;
		}
		
		private function animateFirefly(firefly, fireflyX, fireflyY):void {
			var destinationX:int = Math.ceil(Math.random() * 50) - 25;
			if (destinationX > stageWidth) { destinationX = -destinationX; }
			var destinationY:int = Math.ceil(Math.random() * 50) - 25;
			if (destinationY > stageHeight) { destinationY = -destinationY; }
			
			var delay:Number = Math.random() * 25;
			var time = (Math.random() * 2) + 1;
			
			// trace('Firefly #' + i + ': ' + 'delay: ' + delay + ' destination X: ' + destinationX + ' Y: ' + destinationY);
			
			var fireflyPath = new Array();
			fireflyPath.push({ x: destinationX + ((Math.random() * 50) - 25), y: destinationY + ((Math.random() * 50) - 25)});
			fireflyPath.push({ x: destinationX + ((Math.random() * 50) - 25), y: destinationY + ((Math.random() * 50) - 25)});
		
			Tweener.addTween(firefly, {x: destinationX, y: destinationY, _bezier: fireflyPath, time: time, transition: 'easeinoutquad', delay: delay, onComplete: animateFirefly, onCompleteParams: [firefly, destinationX, destinationY]});
			Tweener.addTween(firefly, {alpha: 1, time: .5, transition: 'easeinoutquad', delay: delay});
			Tweener.addTween(firefly, {alpha: 0, time: .5, transition: 'easeinoutquad', delay: delay + time - .5});
		}

    }
}
