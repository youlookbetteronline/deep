package units 
{

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;

	public class Explode extends Sprite
	{
		private var textures:Object = null;
		private var _parent:*;
		
		public function Explode(textures:Object) 
		{
			this.textures = textures;
			frame = 0;
			addAnimation();
			startAnimation();
			App.map.mTreasure.addChild(this);
		}
		
		private var frameLength:int = 0;
		private var framesType:String = 'anim';
		private var bitmap:Bitmap;
		
		public function addAnimation():void
		{
			frameLength = textures.animation.animations[framesType].chain.length;
			bitmap = new Bitmap();
			addChild(bitmap);
		}
		
		public function startAnimation(random:Boolean = false):void
		{
			frameLength = textures.animation.animations[framesType].chain.length;
			
			if (random) {
				frame = int(Math.random() * frameLength);
			}
			
			App.self.setOnEnterFrame(animate);
			animated = true;
		}
		
		public var animated:Boolean = false;
		
		public function stopAnimation():void
		{
			animated = false;
			App.self.setOffEnterFrame(animate);
		}
		
		public var frame:int = 0;
		public function animate(e:Event = null):void
		{
			//if (!SystemPanel.animate) return;
			var cadr:uint 			= textures.animation.animations[framesType].chain[frame];
			var frameObject:Object 	= textures.animation.animations[framesType].frames[cadr];
					
			bitmap.bitmapData = frameObject.bmd;
			bitmap.x = frameObject.ox;
			bitmap.y = frameObject.oy;
			bitmap.smoothing = true;
			
			frame ++;
			if (frame >= frameLength)
				dispose();
		}
		
		public function dispose():void {
			stopAnimation();
			App.map.mTreasure.removeChild(this);
		}
	}
}