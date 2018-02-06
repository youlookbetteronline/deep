package effects 
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.data.TweenMaxVars;
	import com.greensock.easing.Cubic;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class NewParticle extends LayerX 
	{
		
		/*public function NewParticle() 
		{
			super();
			
		}*/
		public static const UP_DOWN:String = 'up_down';
		
		//private var bmd:BitmapData;
		//private var cont:Sprite;
		
		//private var list:Array;
		
		//private var _width:Number = 60;
		//private var _height:Number = 60;
		//private var workWidth:Number = 300;
		private var time:Number = 2;
		private var radius:Number = 20;
		//private var workIndent:Number = 0.1;
		//private var side:String = "";
		private var color:uint = 0x000000;
		
		//private var maxParticleLength:int = 150;
		private var pShape:Shape;
		public function NewParticle(info:Object) 
		{
			//_width = info.width;
			//_height = info.height;
			//side = UP_DOWN;//info.side;
			color = info.color;
			
			if (info.hasOwnProperty('radius'))
				radius = info.radius;
				
			if (info.hasOwnProperty('time'))
				time = info.time;
			//workWidth = (_width * (1 - workIndent * 2))
			
			/*var s:Shape = drawStar(5);*/
			pShape = new Shape();
			pShape.graphics.beginFill(color, 0.8);
			pShape.graphics.drawCircle(0, 0, 1.4);
			pShape.graphics.endFill();
			this.filters = [new GlowFilter(0xffffff, .6, 10, 10, 2, 3)];
			addChild(pShape);
			//s.filters = [new BlurFilter(3, 3, 1)];
			
			//bmd = new BitmapData(s.width + 4, s.height + 4, true, 0);
			//bmd.draw(s);
			
			init();
		}
		
		private var needScale:Number;
		private var homeCoords:Point;
		private var moveCoords:Point;
		public function init():void {
			//cont = new Sprite();
			//list = new Array();
			//addChild(cont);
			pShape.alpha = .6 + Math.random() * .4;
			pShape.scaleX = .3 + Math.random() * .7;
			pShape.scaleY = pShape.scaleX;
			homeCoords = new Point(int(pShape.x),int(pShape.y));
			moveCoords = new Point(0, 0);
			particleMove()
			//addEventListener(Event.ENTER_FRAME, particleProgress);
		}
		
		public function dispose():void 
		{
			//if (hasEventListener(Event.ENTER_FRAME)) 
				//removeEventListener(Event.ENTER_FRAME, particleProgress);
			if (this.parent)
				this.parent.removeChild(this);
			if(_tween)
				_tween.kill();
			//clearParticles();
			//removeChild(cont);
		}
		
		private var _tween:TweenMax;
		private function particleMove():void
		{
			if (int(pShape.x) == int(homeCoords.x) && int(pShape.y) == int(homeCoords.y))
			{
				moveCoords.x = -radius + Math.random() * radius*2;
				moveCoords.y = -radius + Math.random() * radius*2;
				needScale = .3 + Math.random() * .7;
				_tween = TweenMax.to(pShape, time, {x:moveCoords.x, y:moveCoords.y, scaleX:needScale, scaleY:needScale, onComplete:particleMove});
				//TweenLite.to(pShape, 1, { x:moveCoords.x, y:moveCoords.y, scaleX:needScale, scaleY:needScale, ease:Cubic.easeOut, onComplete:particleMove} );
			}else
			{
				moveCoords = homeCoords;
				needScale = .3 + Math.random() * .7;
				_tween = TweenMax.to(pShape, time, {x:moveCoords.x, y:moveCoords.y, scaleX:needScale, scaleY:needScale, onComplete:particleMove});
			}
		}
		
		/*private function particleProgress(e:Event):void 
		{
			
		}*/
		
		
	}

}