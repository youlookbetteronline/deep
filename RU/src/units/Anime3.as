package units 
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import ui.SystemPanel;
	
	public class Anime3 extends LayerX 
	{
		
		public var onLoop:Function;
		
		private var backing:Shape = new Shape();
		private var base:Bitmap;
		private var animations:Sprite;
		private var animes:Vector.<Bitmap> = new Vector.<Bitmap>;
		
		private var animated:Boolean = false;
		private var params:Object = { w:0, h:0, backAlpha:0, onMap:false};
		private var textures:Object = { };
		private var bounds:Object;
		private var animInfo:Object;
		private var frameTypes:Array;
		private var ax:Number = 0;
		private var ay:Number = 0;
		private var __paused:Boolean;
		private var _bmp:Bitmap;
		
		public var settings:Object = {};
		
		override public function get width():Number {
			return backing.width * scaleX;
		}
		override public function get height():Number {
			return backing.height * scaleY;
		}
		public function get bmp():Bitmap {
			if(!_bmp){
				return new Bitmap(new BitmapData(50, 50, true));
			}
			return _bmp;
		}
		
		public function Anime3(swf:*, params:Object = null) 
		{
			if (params) {
				for (var s:String in params)
					this.params[s] = params[s];
			}
			
			if (swf is String) {
				Load.loading(swf, onload)
			}else {
				onload(swf);
			}
		}
		
		private function onload(swf:*):void {
			textures = swf;
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			//App.self.addEventListener(AppEvent.ON_ANIMATION, onAnimation);
			animations = new Sprite();
			
			initAnimation();
			draw();
			positioner();
			if (onLoop != null)
				onLoop();
		}
		
		
		public function draw():void {
			bounds = Anime.bounds(textures, ((params.walking) ? params : null));
			////frameTypes = bounds.frameTypes;
			
			backing.graphics.beginFill(0xFF0000, params.backAlpha);
			backing.graphics.drawRect(0, 0, bounds.w, bounds.h);
			backing.graphics.endFill();
			addChild(backing);
			var dy:Number;
			var dx:Number;
			if (textures.sprites.length > 0) {
				base = new Bitmap(textures.sprites[textures.sprites.length - 1].bmp, 'auto', true);
				
				//if (base.width > params.w)
				//{
					//dx = (base.width / 2 - params.w / 2);
					//base.x += (base.width / 2 - params.w / 2);
				//}
				//else
				//{
					//dx = (params.w - base.width) / 2;
					//base.x = (params.w - base.width) / 2;
				//}
				//if (base.height < params.h)
				//{
					//dy = (params.h - base.height) / 2;
					//base.y = (params.h - base.height) / 2;
				//}
				//else
				//{
					//dy = (base.height / 2 - params.h / 2);
					//base.y += (base.height / 2 - params.h / 2);
				//}
				base.x = textures.sprites[textures.sprites.length - 1].dx - bounds.x;
				base.y = textures.sprites[textures.sprites.length - 1].dy - bounds.y;
				addChild(base);
			}/*else{
				dx = textures.animation.ax;
				dy = textures.animation.ay;
				trace('ax: ' + dx + ' ay: ' + dy);
			}*/
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
		
		
		private function update(e:Event = null):void {
			var index:int = 0;// frameTypes.length - 1;
			var animFrame:Object;
			while (index > -1) {
				if (animes.length <= index) return;
				if (animInfo[frameTypes[index]].chain[animInfo[frameTypes[index]].frame] != animInfo[frameTypes[index]].show) {
					animInfo[frameTypes[index]].show = animInfo[frameTypes[index]].chain[animInfo[frameTypes[index]].frame];
					if (animInfo[frameTypes[index]].show == undefined) animInfo[frameTypes[index]].show = 0;
					
					if (textures.animation.animations[frameTypes[index]].frames[0] is Array) {
						animFrame = textures.animation.animations[frameTypes[index]].frames[0][animInfo[frameTypes[index]].show];
					}else {
						animFrame = textures.animation.animations[frameTypes[index]].frames[animInfo[frameTypes[index]].show];
					}
					
					animes[index].bitmapData = animFrame.bmd;
					animes[index].smoothing = true;
					
					_bmp = animes[index];
					
					if(params.onMap){
						animes[index].x = animFrame.ox + ax /*- bounds.x*/;
						animes[index].y = animFrame.oy + ay /*- bounds.y*/;
					}else{
						animes[index].x = animFrame.ox + ax - bounds.x;
						animes[index].y = animFrame.oy + ay - bounds.y;
					}
				}
				
				animInfo[frameTypes[index]].frame++;
				if (animInfo[frameTypes[index]].frame >= animInfo[frameTypes[index]].chain.length) {
					animInfo[frameTypes[index]].frame = 0;
					if (onLoop != null)
						onLoop();
				}
				
				index--;
			}
		}
		
		public function renew():void {
			if (!frameTypes)
				return;
			animInfo[frameTypes[0]].frame = 0;
		}
		
		private function onAnimation(e:AppEvent = null):void {
			if (SystemPanel.animate) {
				startAnimation();
			}else{
				stopAnimation();
			}
		}
		private function startAnimation():void {
			if (animated || __paused) return;
			
			animated = true;
			App.self.setOnEnterFrame(update);
		}
		private function stopAnimation():void {
			if (!animated) return;
			
			animated = false;
			App.self.setOffEnterFrame(update);
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
			
			onAnimation();
		}
		
		public function changeFramesType(_frameType:String):void {
			
			textures.animation.animations.hasOwnProperty(_frameType)
			{
				stop();
				frameTypes = [_frameType];
				animInfo[_frameType] = {
					frame:0,
					show: -1,
					chain:textures.animation.animations[_frameType].chain
				};
				frameTypes = [_frameType]
				start();
			}
		}
		
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
		
		public function dispose():void {
			stop();
			if (parent)
				parent.removeChild(this);
		}
		
		private function onRemove(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			//App.self.removeEventListener(AppEvent.ON_ANIMATION, onAnimation);
		}
		
		public static function bounds(texture:Object, params:Object = null):Object {
			var obj:Object = { x:0, y:0, ex:0, ey:0, frameTypes:[] };
			if (params) {
				for (var s:String in params)
					obj[s] = params[s];
			}
			
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
	}

}