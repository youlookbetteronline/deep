package units 
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import ui.SystemPanel;

	public class Anime extends LayerX
	{
		public var animation:Object;
		public var framesType:String;
		public var bitmap:Bitmap;
		public var frameLength:int = 0;
		public var frame:int = 0;
		public var once:Boolean = true;
		public var animated:Boolean;
		public var callback:Function;
		public var ax:int = 0;
		public var ay:int = 0;
		
		private var hidde:Boolean;
		
		public function Anime(animation:Object, framesType:String, ax:int = 0, ay:int = 0, scale:Number = 1)
		{
			bitmap = new Bitmap()
			this.ax = (ax == 0?animation.ax:ax);
			this.ay = (ay == 0?animation.ay:ay);
			
			this.animation = animation;
			this.framesType = framesType;
			addChild(bitmap);
			
			if (scale != 1)
				this.scaleX = this.scaleY = scale;
		}
		
		
		public function startAnimation(random:Boolean = false):void
		{
			if (animated) return;
			
			once = false;
			
			frameLength = animation.animation.animations[framesType].chain.length;
			
			frame = 0;
			if (random) {
				frame = int(Math.random() * frameLength);
			}
			
			App.self.setOnEnterFrame(animate);
			
			animated = true;
		}
		
		public function startAnimationOnce(hide:Boolean = false):void
		{
			if (animated) return;
			hidde = hide;
			frameLength = animation.animation.animations[framesType].chain.length;
			
			frame = 0;
			App.self.setOnEnterFrame(animatePlay);
			
			animated = true;
		}		
		
		public function startAnimationReverce():void
		{
			if (animated) return;
			
			frameLength = animation.animation.animations[framesType].chain.length;
			
			frame = frameLength-1;
			App.self.setOnEnterFrame(animatePlayReverce);
			
			animated = true;
		}
		public function addAnimation():void
		{
			if (animated) return;
			
			//frameLength = animation.animation.animations[framesType].chain.length;
			
			/*if (random) {
				frame = int(Math.random() * frameLength);
			}*/
			var frameObject:Object 	= animation.animation.animations[framesType].frames[0];
			bitmap.bitmapData = frameObject.bmd;
			bitmap.x = frameObject.ox + ax;
			bitmap.y = frameObject.oy + ay;
			//App.self.setOnEnterFrame(animatePlay);
			
			//animated = true;
		}
		
		public function addAnimationOnce():void
		{
			if (animated) return;
			
			//frameLength = animation.animation.animations[framesType].chain.length;
			frameLength = animation.animation.animations[framesType].chain.length;
			frame = 0;
			/*if (random) {
				frame = int(Math.random() * frameLength);
			}*/
			var frameObject:Object 	= animation.animation.animations[framesType].frames[0][0];
			bitmap.bitmapData = frameObject.bmd;
			bitmap.x = frameObject.ox + ax;
			bitmap.y = frameObject.oy + ay;
			animated = true;
			App.self.setOnEnterFrame(animatePlayOnce);
			
			
		}
		
		public function stopAnimation():void
		{
			animated = false;
			App.self.setOffEnterFrame(animate);
		}
		
		public function animate(e:Event = null):void
		{
			if (!SystemPanel.animate) return;
			
			var cadr:uint 			= animation.animation.animations[framesType].chain[frame];
			var frameObject:Object 	= animation.animation.animations[framesType].frames[cadr];
				
			bitmap.bitmapData = frameObject.bmd;
			bitmap.smoothing = true;
			bitmap.x = frameObject.ox + ax;
			bitmap.y = frameObject.oy + ay;
			
			frame ++;
			if (frame >= frameLength)
			{
				frame = 0;
				onLoop();
			}
		}
		
		public function animatePlay(e:Event = null, hide:Boolean = false):void
		{
			if (!SystemPanel.animate) return;
			if (animated == false) return;
			
			var cadr:uint 			= animation.animation.animations[framesType].chain[frame];
			var frameObject:Object 	= animation.animation.animations[framesType].frames[cadr];
				
			bitmap.visible = true;
			bitmap.bitmapData = frameObject.bmd;
			bitmap.smoothing = true;
			bitmap.x = frameObject.ox + ax;
			bitmap.y = frameObject.oy + ay;
			
			frame ++;
			if (frame >= frameLength)
			{
				frame = 0;
				
				if (once){
					animated = false;
					//startAnimation();
					App.self.setOffEnterFrame(animatePlay);
					if (hidde)
						bitmap.visible = false;
				}
			}
		}
		
		public function animatePlayOnce(e:Event = null):void
		{
			if (!SystemPanel.animate) return;
			if (animated == false) return;
			
			var cadr:uint 			= animation.animation.animations[framesType].chain[frame];
			var frameObject:Object 	= animation.animation.animations[framesType].frames[cadr];
				
			bitmap.bitmapData = frameObject.bmd;
			bitmap.smoothing = true;
			bitmap.x = frameObject.ox + ax;
			bitmap.y = frameObject.oy + ay;
			
			frame ++;
			if (frame >= frameLength)
			{
				//stopAnimation();
				animated = false;
				frame = 0;
				App.self.setOffEnterFrame(animatePlayOnce);
				
				//App.self.setOffEnterFrame(animatePlay);
			}
		}
		
		public function animatePlayReverce(e:Event = null):void
		{
			if (!SystemPanel.animate) return;
			if (animated == false) return;
			
			var cadr:uint 			= animation.animation.animations[framesType].chain[frame];
			var frameObject:Object 	= animation.animation.animations[framesType].frames[cadr];
				
			bitmap.bitmapData = frameObject.bmd;
			bitmap.smoothing = true;
			bitmap.x = frameObject.ox + ax;
			bitmap.y = frameObject.oy + ay;
			
			frame --;
			if (frame <=0)
			{
				//stopAnimation();
				animated = false;
				frame = frameLength;
				App.self.setOffEnterFrame(animatePlayReverce);
			}
		}
		
		
		public static function bounds(texture:Object, params:Object = null):Object {
			var obj:Object = { x:0, y:0, ex:0, ey:0, frameTypes:[] };
			if (params) {
				for (var s:String in params)
					obj[s] = params[s];
			}
			
			if (texture.sprites.length > 0) {
				var base:Object = texture.sprites[texture.sprites.length - 1];
				obj.x = base.dx;
				obj.y = base.dy;
				obj.ex = base.dx + base.bmp.width;
				obj.ey = base.dy + base.bmp.height;
			}
			
			if (texture.hasOwnProperty('animation')) {
				for (var anims:String in texture.animation.animations) {
					obj.frameTypes.push(anims);
					for (var _frame:String in texture.animation.animations[anims].frames) {
						var frame:Object = (obj.walking) ? texture.animation.animations[anims].frames[_frame][0] : texture.animation.animations[anims].frames[_frame];
						if (obj.x > frame.ox + texture.animation.ax) obj.x = frame.ox + texture.animation.ax;
						if (obj.y > frame.oy + texture.animation.ay) obj.y = frame.oy + texture.animation.ay;
						if (obj.ex < frame.ox + texture.animation.ax + frame.bmd.width) obj.ex = frame.ox + texture.animation.ax + frame.bmd.width;
						if (obj.ey < frame.oy + texture.animation.ay + frame.bmd.height) obj.ey = frame.oy + texture.animation.ay + frame.bmd.height;
					}
				}
			}
			
			obj['w'] = obj.ex - obj.x;
			obj['h'] = obj.ey - obj.y;
			
			return obj;
		}
		
		public function onLoop():void {
			if (callback != null)
				callback();
		}
		
	}

}