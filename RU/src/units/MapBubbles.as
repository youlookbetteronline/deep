package units 
{
	import core.IsoTile;
	import flash.events.Event;
	import ui.SystemPanel;
	/**
	 * ...
	 * @author 
	 */
	public class MapBubbles extends Anime 
	{
		public var layer:String = 'mSort';
		public var type:String = 'Bubbles';
		public var depth:uint = 0;
		public var xx:uint = 0;
		public var yy:uint = 0;
		public var sid:uint = 99996666;
		public var title:String = App.data.storage[578].title;
		
		public function MapBubbles(animation:Object, framesType:String, ax:int = 0, ay:int = 0, scale:Number = 1, setts:Object = 1)
		{
			super(animation, framesType, ax, ay, scale);
			this.x = setts.x || 0;
			this.y = setts.y || 0;
			calcDepth();
		}
		
		public function calcDepth():void
		{
			var left:Object = {x: x - IsoTile.width * 1 * .5, y: y + IsoTile.height * 1 * .5};
			var right:Object = {x: x + IsoTile.width * 1 * .5, y: y + IsoTile.height * 1 * .5};
			depth = (left.x + right.x) + (left.y + right.y) * 100;
		}
		
		override public function startAnimationOnce():void
		{
			if (animated) return;
			
			frameLength = animation.animation.animations[framesType].chain.length;
			
			frame = 0;
			App.self.setOnEnterFrame(animatePlay);
			
			animated = true;
		}
		
		override public function animatePlay(e:Event = null):void
		{
			if (!SystemPanel.animate) return;
			if (animated == false) return;
			
			var cadr:uint 			= animation.animation.animations[framesType].chain[frame];
			var frameObject:Object 	= animation.animation.animations[framesType].frames[0][cadr];
				
			bitmap.bitmapData = frameObject.bmd;
			bitmap.smoothing = true;
			bitmap.x = frameObject.ox + ax;
			bitmap.y = frameObject.oy + ay;
			
			frame ++;
			if (frame >= frameLength)
			{
				App.map.removeUnit(this);
				//stopAnimation();
				animated = false;
				frame = 0;
				//App.self.setOffEnterFrame(animatePlay);
			}
		}
		
	}

}