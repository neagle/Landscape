package landscape {
	import caurina.transitions.Tweener;
	import flash.display.Sprite;
	import flash.display.*;
	import flash.filters.BlurFilter;
	import flash.filters.BitmapFilterQuality;

    public class Firefly extends Sprite {
        
		// Define constants
		
		public function Firefly():void {
			var firefly:Shape = drawBug(0, 0, 3);
			addChild(firefly);
		}
		
		private function drawBug(bugX = 0, bugY = 0, blur = 0):Shape {
			var bug:Shape = new Shape();
            bug.graphics.beginFill(0xFEFF8F);
            bug.graphics.drawCircle(bugX, bugY, 3);
            bug.graphics.endFill();
			
			var bugFilters:Array = new Array();
            var bugBlur:BlurFilter = new BlurFilter(blur, blur, BitmapFilterQuality.MEDIUM);
            bugFilters.push(bugBlur);
           
            bug.filters = bugFilters;
			
			return bug;
		}

    }
}
