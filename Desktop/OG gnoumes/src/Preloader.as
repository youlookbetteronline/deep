package 
{
	import com.greensock.TweenLite;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class Preloader extends Sprite
	{
		private var point1:Shape;
		private var point2:Shape;
		private var point3:Shape;
		
		private var tween1:TweenLite;
		private var tween2:TweenLite;
		private var tween3:TweenLite;
		private var timeout1:int;
		private var timeout2:int;
		
		public function Preloader(color:uint = 0xeeeeee) 
		{
			point1 = new Shape();
			point1.graphics.beginFill(color);
			point1.graphics.drawCircle(0, 0, 2);
			point1.graphics.endFill();
			point1.x = 30;
			point1.alpha = 0;
			addChild(point1);
			
			point2 = new Shape();
			point2.graphics.beginFill(color);
			point2.graphics.drawCircle(0, 0, 2);
			point2.graphics.endFill();
			point2.x = 50;
			point2.alpha = 0;
			addChild(point2);
			
			point3 = new Shape();
			point3.graphics.beginFill(color);
			point3.graphics.drawCircle(0, 0, 2);
			point3.graphics.endFill();
			point3.x = 70;
			point3.alpha = 0;
			addChild(point3);
			
			beginCircle();
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
		}
		
		private function beginCircle():void {
			tween1 = TweenLite.to(point1, 0.15, { alpha:1, onComplete:function():void {
				tween1 = TweenLite.to(point1, 1.5, { alpha:0 } );
			}} );
			timeout1 = setTimeout(function():void {
				tween2 = TweenLite.to(point2, 0.15, { alpha:1, onComplete:function():void {
					tween2 = TweenLite.to(point2, 1.5, { alpha:0 } );
				}} );
			}, 150);
			timeout2 = setTimeout(function():void {
				tween3 = TweenLite.to(point3, 0.15, { alpha:1, onComplete:function():void {
					tween3 = TweenLite.to(point3, 1.5, { alpha:0, onComplete:function():void {
						timeout1 = setTimeout(beginCircle, 200);
					}} );
				}} );
			}, 300);
		}
		
		private function onRemove(e:Event):void {
			if (tween1) tween1.kill();
			if (tween2) tween2.kill();
			if (tween3) tween3.kill();
			if (timeout1) clearTimeout(timeout1);
			if (timeout2) clearTimeout(timeout2);
		}
		
	}

}