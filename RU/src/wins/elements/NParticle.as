package wins.elements 
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.data.TweenMaxVars;
	import com.greensock.easing.Back;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Linear;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author ...
	 */
	public class NParticle extends Sprite 
	{
		
		/*public function NewParticle() 
		{
			super();
			
		}*/
		public static const UP_DOWN:String = 'up_down';
		
		public var depth:uint;
		//private var bmd:BitmapData;
		//private var cont:Sprite;
		
		//private var list:Array;
		
		//private var _width:Number = 60;
		//private var _height:Number = 60;
		//private var workWidth:Number = 300;
		private var time:Number = 2;
		private var pWidth:Number = 1.65*2;
		private var radius:Number = 20;
		private var blurAmount:Number = 4;
		//private var workIndent:Number = 0.1;
		//private var side:String = "";
		private var color:uint = 0x000000;
		
		//private var maxParticleLength:int = 150;
		private var pSprite:Sprite;
		//private var pShape:Shape;
		public function NParticle(info:Object) 
		{
			//_width = info.width;
			//_height = info.height;
			//side = UP_DOWN;//info.side;
			color = info.color;
			
			if (info.hasOwnProperty('width'))
				pWidth = info.width;
				
			if (info.hasOwnProperty('radius'))
				radius = info.radius;
				
			if (info.hasOwnProperty('blurAmount'))
				blurAmount = info.blurAmount;
				
			if (info.hasOwnProperty('time'))
				time = info.time;
			//workWidth = (_width * (1 - workIndent * 2))
			
			/*var s:Shape = drawStar(5);*/
			pSprite = new Sprite();
			
			if (info.hasOwnProperty('bmap')){
				var bmap:Bitmap = new Bitmap(info.bmap.bitmapData);
				pSprite.addChild(bmap);
			}else{
				var shape:Shape = new Shape();
				shape.graphics.beginFill(color, 0.8);
				shape.graphics.drawCircle(0, 0, pWidth/2);
				shape.graphics.endFill();
				pSprite.addChild(shape);
			}
			pSprite.filters = [new BlurFilter(blurAmount, blurAmount)];
			//this.filters = [new GlowFilter(0xffffff, .6, 10, 10, 2, 3)];
			addChild(pSprite);
			//s.filters = [new BlurFilter(3, 3, 1)];
			
			//bmd = new BitmapData(s.width + 4, s.height + 4, true, 0);
			//bmd.draw(s);
			//addEventListener(Event.REMOVED, dispose);
			init();
		}
		
		private var needScale:Number;
		private var homeCoords:Point;
		private var moveCoords:Point;
		private var timeOut:uint;
		public function init():void {
			//cont = new Sprite();
			//list = new Array();
			//addChild(cont);
			pSprite.alpha = .5 + Math.random() * .5;
			//pSprite.scaleX = .3 + Math.random() * .7;
			//pSprite.scaleY = pSprite.scaleX;
			homeCoords = new Point(0, 0);
			moveCoords = new Point(0, 0);
			
			timeOut = setTimeout(particleMove, 200 + Math.random() * 200);
			//addEventListener(Event.ENTER_FRAME, particleProgress);
		}
		
		public function dispose(e:* = null):void 
		{
			//if (hasEventListener(Event.ENTER_FRAME)) 
				//removeEventListener(Event.ENTER_FRAME, particleProgress);
			if (this.parent)
				this.parent.removeChild(this);
			if (_tween != null)
			{
				_tween.complete(true, true);
				_tween.kill();
				_tween = null;
			}
			clearTimeout(timeOut);
			
			//if(_tween)
			//_tween.kill();
			
			//clearParticles();
			//removeChild(cont);
		}
		
		private var dMove:Boolean = true;
		private var _tween:TweenMax;
		private function particleMove():void
		{
			//var bezierPoints:Array = [];
			//var bezierPoint:Object = {x:moveCoords.x, y:moveCoords.y};
			if(_tween != null){
				_tween.complete(true, true);
				_tween.kill();
				_tween = null;
			}
			var _dx:int;
			var _dy:int;
			var _alpha:Number;
			var _time:Number;
			if (dMove)
			{
				_dx = -radius + Math.random() * radius * 2;
				_dy = -radius + Math.random() * radius * 2;
				//_dx = -radius;
				//_dy = -radius;
				moveCoords.x = _dx;
				moveCoords.y = _dy;
				
				_alpha = .5 + Math.random()*.5;
				//bezierPoints = [];
				//bezierPoint = {x:moveCoords.x, y:moveCoords.y};
				//bezierPoints.push(bezierPoint);
				
				//var borders:Object = {a:point, b:{x:target.x, y:target.y}};
				//var randomCount:int = 1;
				//for (var i:int = 0; i < randomCount; i++) {
				//bezierPoint = new Object();
				
				//bezierPoint['x'] = int((pSprite.x - moveCoords.x - 100) * Math.random()) + moveCoords.x + 50;
				//bezierPoint['y'] = int((pSprite.y - moveCoords.y - 100) * Math.random()) + moveCoords.y + 50;
				//bezierPoints.unshift(bezierPoint);
				//}
			
				//needScale = .3 + Math.random() * .7;
				//_tween = TweenMax.to(pSprite, time, {bezierThrough:bezierPoints, orientToBezier:false, onComplete:particleMove});
				//_time = time * (1 - (((Math.abs(_dx) + Math.abs(_dy)) / 2) / radius));
				dMove = false;
				_tween = TweenMax.to(pSprite, time, {x:moveCoords.x, y:moveCoords.y, alpha:_alpha, ease:Linear.easeNone, /*scaleX:needScale, scaleY:needScale,*/ onComplete:particleMove});
				//TweenLite.to(pShape, 1, { x:moveCoords.x, y:moveCoords.y, scaleX:needScale, scaleY:needScale, ease:Cubic.easeOut, onComplete:particleMove} );
			}else
			{
				moveCoords.x = int(homeCoords.x);
				moveCoords.y = int(homeCoords.y);
				
				_alpha = .5 + Math.random()*.5;
				//_dx = Math.abs(pSprite.x) - homeCoords.x;
				//_dy = Math.abs(pSprite.y) - homeCoords.y;
				 //&& int(pSprite.y) == int(homeCoords.y)
				//bezierPoints = [];
				//bezierPoint = {x:moveCoords.x, y:moveCoords.y};
				//bezierPoints.push(bezierPoint);
				//
				//bezierPoint = new Object();
				//
				//bezierPoint['x'] = int((pSprite.x - moveCoords.x - 100) * Math.random()) + moveCoords.x + 50;
				//bezierPoint['y'] = int((pSprite.y - moveCoords.y - 100) * Math.random()) + moveCoords.y + 50;
				//bezierPoints.unshift(bezierPoint);
				//}
			
				//needScale = .3 + Math.random() * .7;
				//_tween = TweenMax.to(pSprite, time, {bezierThrough:bezierPoints, orientToBezier:false, onComplete:particleMove});
				
				//needScale = .3 + Math.random() * .7;
				//_time = time * (1 - (((Math.abs(_dx) + Math.abs(_dy)) / 2) / radius));
				dMove = true;
				_tween = TweenMax.to(pSprite, time, {x:moveCoords.x, y:moveCoords.y,alpha:_alpha, ease:Linear.easeNone, /*scaleX:needScale, scaleY:needScale,*/ onComplete:particleMove});
			}
		}
		
		/*private function particleProgress(e:Event):void 
		{
			
		}*/
		
		
	}

}