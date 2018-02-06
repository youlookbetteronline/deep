package effects 
{
	import astar.BinaryHeap;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author
	 */
	public class Particles 
	{
		
		private var particlesArr:Array;
		
		public function Particles() 
		{
			
		}
		
		public function init(cont:Sprite, coords:Point, _params:Object = null):void 
		{
			particlesArr = [];
			particlesArr.push( new ParticlesStars(coords.x, coords.y, null) );
			cont.addChildAt( particlesArr[particlesArr.length - 1], 0 );
			
			App.self.setOnEnterFrame(pUpdate);
		}
		public function pUpdate(e:Event):void {
			for (var i:int = 0; i < particlesArr.length; i++) 
			{
				particlesArr[i].update();
				if (particlesArr[i].deleted){
					particlesArr[i] = null;
					particlesArr.splice(i, 1);
				}
			}
			
			if (particlesArr.length == 0)
				App.self.setOffEnterFrame(pUpdate);
		}
	}

}