package enixan 
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Anime extends Sprite 
	{
		
		private var backing:Shape = new Shape();
		private var base:Bitmap;
		private var animations:Sprite;
		private var animes:Vector.<Bitmap> = new Vector.<Bitmap>;
		
		private var animated:Boolean = false;
		private var params:Object = { w:0, h:0, backAlpha:0.0, autoDispose:true };
		private var textures:Object = { };
		private var bounds:Object;
		
		public function Anime(swf:*, params:Object = null) 
		{
			if (params) {
				for (var s:String in params)
					this.params[s] = params[s];
			}
			
			if (swf is String) {
				Util.load(swf, onload)
			}else {
				onload(swf);
			}
		}
		
		private function onload(swf:*):void {
			textures = swf;
			
			if (params.autoDispose)
				addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			animations = new Sprite();
			
			if(!params.hasOwnProperty('stage') || params.stage >= textures.sprites.length - 1)
				initAnimation();
			
			draw();
			positioner();
		}
		
		override public function get width():Number {
			return backing.width * scaleX;
		}
		override public function get height():Number {
			return backing.height * scaleY;
		}
		
		public function draw():void {
			if (params && params.stage) {
				delete params.stage;
			}
			
			bounds = Anime.bounds(textures, ((params.walking) ? params : params));
			
			backing.graphics.beginFill(0xFF0000, params.backAlpha);
			backing.graphics.drawRect(0, 0, bounds.w, bounds.h);
			backing.graphics.endFill();
			addChild(backing);
			
			var dy:Number;
			var dx:Number;
			if (textures.sprites.length > 0){
				if (!params.hasOwnProperty('stage')) {
					base = new Bitmap(textures.sprites[textures.sprites.length - 1].bmp, 'auto', true);
					base.x = textures.sprites[textures.sprites.length - 1].dx - bounds.x;
					base.y = textures.sprites[textures.sprites.length - 1].dy - bounds.y;
					addChild(base);
				} else {
					base = new Bitmap(textures.sprites[params.stage].bmp, 'auto', true);
					base.x = textures.sprites[params.stage].dx - bounds.x;
					base.y = textures.sprites[params.stage].dy - bounds.y;
					addChild(base);
				}
			}
			animations.y = dy;
			animations.x = dx;
			
			addChild(animations);
			
			update();
		}
		public function positioner():void {
			if (params.w > 0 && params.h > 0) {
				if (backing.width * scaleX > params.w)
					scaleX = scaleY = params.w / backing.width;
				
				if (backing.height * scaleX > params.h)
					scaleX = scaleY = this.scaleX * params.h / (backing.height * scaleX);
			}
		}
		
		public static function bounds(texture:Object, params:Object = null):Object {
			var obj:Object = { x:0, y:0, ex:0, ey:0, frameTypes:[] };
			if (params) {
				for (var s:String in params)
					obj[s] = params[s];
			}
			
			if (texture.hasOwnProperty('sprites')) {
				if (texture.sprites.length > 0) {
					var stage:* = texture.sprites.length - 1;
					if (obj.hasOwnProperty('stage') && texture.sprites[obj.stage])
						stage = obj.stage;
					
					var base:Object = texture.sprites[stage];
					obj.x = base.dx;
					obj.y = base.dy;
					obj.ex = base.dx + base.bmp.width;
					obj.ey = base.dy + base.bmp.height;
				}
			}
			
			if (texture.hasOwnProperty('animation')) {
				for (var anims:String in texture.animation.animations) {
					obj.frameTypes.push(anims);
					for (var _frame:String in texture.animation.animations[anims].frames) {
						if (obj.hasOwnProperty('animation') && obj.animation.length > 0 && obj.animation != anims) continue;
						var frame:Object = texture.animation.animations[anims].frames[_frame];
						if (frame is Array) frame = texture.animation.animations[anims].frames[_frame][0];
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
		
		private var animInfo:Object;
		private var frameTypes:Array;
		private var ax:Number = 0;
		private var ay:Number = 0;
		private function update(e:Event = null):void {
			var index:int = 0;// frameTypes.length - 1;
			var animFrame:Object;
			while (index > -1) {
				if (animes.length <= index) return;
				
				if (animInfo[frameTypes[index]].chain[animInfo[frameTypes[index]].frame] != animInfo[frameTypes[index]].show) {
					animInfo[frameTypes[index]].show = animInfo[frameTypes[index]].chain[animInfo[frameTypes[index]].frame];
					if (animInfo[frameTypes[index]].show == undefined) animInfo[frameTypes[index]].show = 0;
					
					if (textures.animation.animations[frameTypes[index]].frames[0] is Array) {
						animFrame = textures.animation.animations[frameTypes[index]].frames[int(params.framesDirection)][animInfo[frameTypes[index]].show];
					}else {
						animFrame = textures.animation.animations[frameTypes[index]].frames[animInfo[frameTypes[index]].show];
					}
					
					animes[index].bitmapData = animFrame.bmd;
					animes[index].smoothing = true;
					animes[index].x = animFrame.ox + ax - bounds.x;
					animes[index].y = animFrame.oy + ay - bounds.y;
				}
				
				animInfo[frameTypes[index]].frame++;
				if (animInfo[frameTypes[index]].frame >= animInfo[frameTypes[index]].chain.length) {
					animInfo[frameTypes[index]].frame = 0;
				}
				
				index--;
			}
		}
		
		/*private function onAnimation(e:AppEvent = null):void {
			if (SystemPanel.animate) {
				startAnimation();
			}else{
				stopAnimation();
			}
		}*/
		private function startAnimation():void {
			if (animated || __paused) return;
			
			animated = true;
			addEventListener(Event.ENTER_FRAME, update);
		}
		private function stopAnimation():void {
			if (!animated) return;
			
			animated = false;
			removeEventListener(Event.ENTER_FRAME, update);
		}
		private function initAnimation():void {
			if (!textures.hasOwnProperty('animation')) return;
			
			frameTypes = [];
			animInfo = { };
			
			if (params.hasOwnProperty('framesType') && textures.animation.animations.hasOwnProperty(params.framesType)) {
				frameTypes = [params.framesType];
				animInfo[params.framesType] = {
					frame:0,
					show: -1,
					chain:textures.animation.animations[params.framesType].chain
				};
			}else {
				for (var framesType:String in textures.animation.animations) {
					if (params.walking && framesType != 'rest') continue; 
					
					frameTypes.push(framesType);
					animInfo[framesType] = {
						frame:0,
						show: -1,
						chain:textures.animation.animations[framesType].chain
					};
				}
			}
			ax = textures.animation.ax;
			ay = textures.animation.ay;
			
			while (animes.length > 0) animations.removeChild(animes.shift());
			
			for (var s:String in textures.animation.animations) {
				var bitmap:Bitmap = new Bitmap(null, 'auto', true);
				animations.addChild(bitmap);
				animes.push(bitmap);
			}
			
			startAnimation();
		}
		
		private var __paused:Boolean;
		public function start():void {
			if (!__paused) return;
			
			__paused = false;
			startAnimation();
		}
		public function stop():void {
			if (animated && __paused) return;
			
			__paused = true;
			stopAnimation();
		}
		
		private function onRemove(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		}
	}

}