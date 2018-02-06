package units 
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import ui.SystemPanel;
	
	public class Anime2v2 extends Sprite 			//D аналог Anime 2 в других проектах
	{
		
		private var backing:Shape = new Shape();
		private var base:Bitmap;
		private var animations:Sprite;
		private var animes:Vector.<Bitmap> = new Vector.<Bitmap>;
		
		private var animated:Boolean = false;
		private var params:Object = { w:0, h:0, backAlpha:0.0 };
		private var textures:Object = { };
		public var bounds:Object;
		public var framesDirection:int = 0;
		
		// sid для возможности пользоваться Map.findUnits
		public var sid:int = 0;
		public var onLoop:Function;
		
		public function Anime2v2(swf:*, params:Object = null) 
		{
			if (params) {
				for (var s:String in params) {
					this.params[s] = params[s];
					
					if (s == 'onLoop' && (params[s] is Function))
						onLoop = params[s];
				}
			}
			
			textures = swf;
			
			//if (textures.hasOwnProperty('animation') && textures.animation.animations.hasOwnProperty(Hero.WALK))
				//this.params['walking'] = true;
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			if (App.ui && App.ui.systemPanel)
				App.ui.systemPanel.addEventListener(AppEvent.ON_UI_ANIMATION, onAnimation);
			
			animations = new Sprite();
			
			initAnimation();
			draw();
			positioner();
			drawShadow();
		}
		
		private function drawShadow():void 
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawEllipse(this.x+9, this.y+this.height-6,	this.width/3, 10);
			shape.graphics.endFill();
			addChild(shape);
			shape.x=(this.width-shape.width)/2
			var blur:BlurFilter = new BlurFilter(); 
			blur.blurX = 10; 
			blur.blurY = 10; 
			blur.quality = BitmapFilterQuality.MEDIUM; 
			shape.filters = [blur];
		}
		
		override public function get width():Number {
			return backing.width * scaleX;
		}
		override public function get height():Number {
			return backing.height * scaleY;
		}
		
		public function draw():void {
			bounds = Anime2v2.bounds(textures, ((params.walking) ? params : null));
			////frameTypes = bounds.frameTypes;
			
			backing.graphics.beginFill(0xFF0000, params.backAlpha);
			backing.graphics.drawRect(0, 0, bounds.w, bounds.h);
			backing.graphics.endFill();
			addChild(backing);
			
			if (textures.sprites.length > 0) {
				var stage:int = textures.sprites.length - 1;
				if (params.hasOwnProperty('stage') && params.stage < textures.sprites.length) {
					stage = params.stage;
				}
				base = new Bitmap(textures.sprites[stage].bmp, 'auto', true);
				base.x = textures.sprites[stage].dx - bounds.x;
				base.y = textures.sprites[stage].dy - bounds.y;
				addChild(base);
			}
			
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
			var obj:Object = { x:0, y:0, ex:0, ey:0, frameTypes:[], singleAnimation:false, framesType:null };
			if (params) {
				for (var s:String in params)
					obj[s] = params[s];
			}
			
			if (texture && texture.hasOwnProperty('sprites') && texture.sprites.length > 0) {
				var stage:* = texture.sprites.length - 1;
				if (obj.hasOwnProperty('stage') && texture.sprites[obj.stage])
					stage = obj.stage;
				
				var base:Object = texture.sprites[stage];
				obj.x = base.dx;
				obj.y = base.dy;
				obj.ex = base.dx + base.bmp.width;
				obj.ey = base.dy + base.bmp.height;
			}
			
			if (texture && texture.hasOwnProperty('animation')) {
				for (var anims:String in texture.animation.animations) {
					if (obj.singleAnimation && anims != obj.framesType) continue;
					
					obj.frameTypes.push(anims);
					for (var _frame:String in texture.animation.animations[anims].frames) {
						if (obj.hasOwnProperty('animation') && obj.animation.length > 0 && obj.animation != anims) continue;
						var frame:Object = ((texture.animation.animations[anims].frames[0] as Array) && texture.animation.animations[anims].frames[0][_frame]) ? texture.animation.animations[anims].frames[0][_frame] : texture.animation.animations[anims].frames[_frame];
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
		
		private var animInfo:Object = { };
		private var frameTypes:Array = [];;
		private var ax:Number = 0;
		private var ay:Number = 0;
		private function update(e:Event = null):void {
			var index:int = frameTypes.length - 1;
			var animFrame:Object;
			while (index > -1) {
				if (animes.length <= index) return;
				
				if (animInfo[frameTypes[index]].chain[animInfo[frameTypes[index]].frame] != animInfo[frameTypes[index]].show) {
					animInfo[frameTypes[index]].show = animInfo[frameTypes[index]].chain[animInfo[frameTypes[index]].frame];
					if (animInfo[frameTypes[index]].show == undefined) animInfo[frameTypes[index]].show = 0;
					
					if (params.walking) {
						animFrame = textures.animation.animations[frameTypes[index]].frames[framesDirection][animInfo[frameTypes[index]].show];
					}else {
						animFrame = textures.animation.animations[frameTypes[index]].frames[animInfo[frameTypes[index]].show];
					}
					
					if (animFrame)
					{
						animes[index].bitmapData = animFrame.bmd;
						animes[index].smoothing = true;
						animes[index].x = animFrame.ox + ax - bounds.x;
						animes[index].y = animFrame.oy + ay - bounds.y;
					}
				}
				
				animInfo[frameTypes[index]].frame++;
				if (animInfo[frameTypes[index]].frame >= animInfo[frameTypes[index]].chain.length) {
					animInfo[frameTypes[index]].frame = 0;
					
					if (onLoop != null) {
						onLoop();
					}
				}
				
				index--;
			}
		}
		
		public function set framesType(value:String):void {
			if (params.framesType == value) return;
			
			params.framesType = value;
			initAnimation();
		}
		public function get framesType():String {
			return params.framesType;
		}
		
		private function onAnimation(e:AppEvent = null):void {
			if (SystemPanel.animate) {
				startAnimation();
			}else{
				stopAnimation();
			}
		}
		public function startAnimation():void {
			if (animated) return;
			
			animated = true;
			App.self.setOnEnterFrame(update);
		}
		public function stopAnimation():void {
			if (!animated) return;
			
			animated = false;
			App.self.setOffEnterFrame(update);
		}
		private function initAnimation():void {
			if (!textures.hasOwnProperty('animation')) return;
			
			var beginFrame:int = 0;
			
			if (params.hasOwnProperty('framesType') && textures.animation.animations.hasOwnProperty(params.framesType)) {
				frameTypes = [params.framesType];
				animInfo[params.framesType] = {
					frame:beginFrame,
					show: -1,
					chain:textures.animation.animations[params.framesType].chain
				};
			}else {
				for (var framesType:String in textures.animation.animations) {
					if (params.walking && framesType != 'rest') continue; 
					
					if (params.random)
						beginFrame = int(textures.animation.animations[framesType].chain.length * Math.random());
					
					frameTypes.push(framesType);
					animInfo[framesType] = {
						frame:beginFrame,
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
		
		private function onRemove(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			App.self.removeEventListener(AppEvent.ON_UI_ANIMATION, onAnimation);
		}
	}

}