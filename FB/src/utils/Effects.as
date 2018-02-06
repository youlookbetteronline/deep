package utils 
{
	import com.greensock.TweenMax;
	import effects.Particles;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author ...
	 */
	public class Effects 
	{
		
		public function Effects() 
		{
			
		}
		
		public static var particle:Particles;
		public static var intervalEff:int;
		public static var coordsEff:Object = {
			0:{x:40-100, y:-100},
			1:{x:100-100, y:-110},
			2:{x:160, y:-110},
			3:{x:220-100, y:-120},
			4:{x:380+100, y:-100},
			5:{x:260, y:-120},
			6:{x:190, y:-110},
			7:{x:60, y:-100},
			8:{x:120-100, y:-110},
			9:{x:200, y:-120},
			10:{x:250+100, y:-120},
			11:{x:360+100, y:-100},
			12:{x:220, y:-120}
		};
		
		public static function confeti(layer:Sprite, time:uint,coords:Object, params:Object = null):void
		{
			clearInterval(intervalEff);
			var countInterval:int = coords['interval'] || 12; ;
			var countEff:int = 0;
			if (countEff > countInterval)
				return;
			intervalEff = setInterval(function():void 
			{
				var dX:int = coords['x'] || 0; 
				var dY:int = coords['y'] || 0; 
				
				particle = new Particles();
				if (!coordsEff.hasOwnProperty(countEff))
				{
					clearInterval(intervalEff);
					return;
				}
				
				particle.init(layer, new Point(dX + coordsEff[countEff].x, dY + coordsEff[countEff].y), params);
				countEff++;
				if (countEff == countInterval)
					clearInterval(intervalEff);
			},time);
		}
		
		public static function randomTween(texture:BitmapData, container:DisplayObjectContainer, start:Point, count:int = 1, index:int = 1):void
		{
			var bmaps:Vector.<Bitmap> = new Vector.<Bitmap>();
			for (var i:int = 0; i < count; i++)
			{
				
				var bmap:Bitmap = new Bitmap(texture);
				bmaps.push(bmap);
				bmap.x = start.x;
				bmap.y = start.y;
				bmap.scaleX = bmap.scaleY = .2 + Math.random() * .3;
				container.addChildAt(bmap, index);
				var pnt:Object = {x:bmap.x - 100 + int(Math.random() * 200) , y:bmap.y - (100 + int(Math.random() * 100)) };
				Effects.objectTween(bmap, pnt, 0, function():void{
					if (bmap.parent)
						bmap.parent.removeChild(bmap);
				} );
			}
			setTimeout(function():void{
				for each(var _bmap:Bitmap in bmaps){
					if (_bmap.parent)
						_bmap.parent.removeChild(_bmap);
				}
			},1000)
		}
		
		public static function objectTween(target:*, point:Object, tAlpha:Number = 1, onComplete:Function = null, onCompleteParams:Array = null):void{
			var bezierPoints:Array = [];
			
			var bezierPoint:Object = point;
			bezierPoints.push(bezierPoint);
			
			var borders:Object = {a:point, b:{x:target.x, y:target.y}};
			var randomCount:int = 1;
			for (var i:int = 0; i < randomCount; i++) {
				bezierPoint = new Object();
				
				bezierPoint['x'] = int((target.x - point.x - 100) * Math.random()) + point.x + 50;
				bezierPoint['y'] = /*int((target.y - point.y - 100) * Math.random()) +*/ point.y - 120;
				
				bezierPoints.unshift(bezierPoint);
			}
			//var randomTime:Number = PATH_TIME + PATH_TIME * Math.random();
			
			if (onCompleteParams == null)
				onCompleteParams = [];
			
			TweenMax.to(target, 1, { alpha:tAlpha, bezierThrough:bezierPoints, orientToBezier:false, onComplete:onComplete, onCompleteParams:onCompleteParams});
		}
		
	}

}