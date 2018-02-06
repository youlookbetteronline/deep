package hlp 
{
	import com.greensock.plugins.BlurFilterPlugin;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.IsoConvert;
	import core.IsoTile;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author ...
	 */
	public class HighlightZone extends Sprite {
		
		private var _bound:Rectangle = new Rectangle();
		private var _tween:TweenMax;
		public function HighlightZone() {
			//animate();
		}
		
		public function animate():void {
			var target:Sprite = this;
			tween1();
			
			function tween1():void {
				if (_tween != null) {
					_tween.kill();
					_tween = null;
				}
				_tween = TweenMax.to(target, .8, { glowFilter: {inner:true, color:0x00FF00, alpha:1, strength: 2, blurX:25, blurY:25,knockout:true}, onComplete:tween2} );
			}
			
			function tween2():void {
				if (_tween != null) {
					_tween.kill();
					_tween = null;
				}
				TweenMax.to(target, .8, { glowFilter: {inner:true, color:0x00FF00, alpha:0.3, strength: 4, blurX:6, blurY:6, knockout:true}, onComplete:tween1 } );
			}
		}
		
		public function dispose():void {
			if (_tween != null) {
				_tween.kill();
				_tween = null;
			}
			if (parent) {
				parent.removeChild(this);
			}
		}
		
		private static var points:Array = [];
		public static function zone(x:int, z:int, sizeX:int, sizeZ:int = 0, color:uint = 0x00FF00, fill:Boolean = true):HighlightZone {
			points = [];
			var _plane:Sprite = new Sprite();

			if (sizeZ == 0) sizeZ = sizeX;
			var point1:Object = IsoConvert.isoToScreen( -sizeX, 	-sizeZ, 		true, true);
			var point2:Object = IsoConvert.isoToScreen( sizeX, 	-sizeZ, 		true, true);
			var point3:Object = IsoConvert.isoToScreen( sizeX, 	sizeZ, 	true, true);
			var point4:Object = IsoConvert.isoToScreen( -sizeX, 	sizeZ, 	true, true);
			points.push(point4);
			points.push(point3);
			points.push(point2);
			points.push(point1);
			
			_plane.graphics.lineStyle(4, color, 1);
			if(fill)_plane.graphics.beginFill(color, 0.4);
			_plane.graphics.moveTo(point1.x, point1.y);
			_plane.graphics.lineTo(point2.x, point2.y);
			_plane.graphics.lineTo(point3.x, point3.y);
			_plane.graphics.lineTo(point4.x, point4.y);
			_plane.graphics.lineTo(point1.x, point1.y);
			if(fill)_plane.graphics.endFill();
			
			
			var hZone:HighlightZone = new HighlightZone();
			hZone.addChild(_plane);
			//hZone.filters = [new GlowFilter(0x00FF00,0.3,6,6,4,1,true,true)];
			
			var pos:Object = IsoConvert.isoToScreen(x, z, true);
			hZone.x = pos.x;
			hZone.y = pos.y;
			App.map.mLand.addChild(hZone);
			hZone.alpha = 0.5;
			
			return hZone;
		}
		
		override public function getBounds(targetCoordinateSpace:DisplayObject):Rectangle {
			var rect:Rectangle = super.getBounds(targetCoordinateSpace);
			rect.top = rect.y +  rect.height / 2 +  points[1].y;
			rect.left = rect.x +  rect.width / 2 +  points[1].x;
			return rect;
		}
		
		public function getPoints():Array {
			var result:Array = [];
			var bound:Rectangle = super.getBounds(App.self);
			for each (var point:Object in points) {
				result.push( {x:bound.x + point.x + bound.width / 2, y:bound.y + point.y + bound.height / 2} );
			}
			
			return result;
		}
	}
}