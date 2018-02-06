package units 
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import ui.SystemPanel;
	
	public class Anime2 extends Sprite 
	{
		protected var animInfo:Object = { };
		protected var frameTypes:Array = [];;
		protected var ax:Number = 0;
		protected var ay:Number = 0;
		protected var params:Object = { w:0, h:0, backAlpha:0 };
		protected var textures:Object = { };
		protected var bounds:Object;
		protected var animes:Vector.<Bitmap>;
		protected var updateFunction:Function;
		
		private var backing:Shape = new Shape();
		private var base:Bitmap;
		private var animations:Sprite;
		private var animated:Boolean;
		
		override public function get width():Number 
		{
			return backing.width * scaleX;
		}
		override public function get height():Number 
		{
			return backing.height * scaleY;
		}
		
		public function Anime2(swf:*, params:Object = null) 
		{
			updateFunction = updateAnim;
			if (params) 
			{
				for (var s:String in params)
					this.params[s] = params[s];
			}
			
			textures = swf;
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			App.ui.systemPanel.addEventListener(AppEvent.ON_UI_ANIMATION, onAnimation);
			animations = new Sprite();
			
			initAnimation();
			draw();
			positioner();
		}
		
		public function draw():void {
			bounds = Anime2.bounds(textures, params);
			
			backing.graphics.beginFill(0xFF0000, params.backAlpha);
			backing.graphics.drawRect(0, 0, bounds.w, bounds.h);
			backing.graphics.endFill();
			addChild(backing);
			var dy:Number;
			var dx:Number;
			if (textures.hasOwnProperty('sprites') && textures.sprites.length > 0) {
				base = new Bitmap(textures.sprites[textures.sprites.length - 1].bmp, 'auto', true);
				
				base.x = textures.sprites[textures.sprites.length - 1].dx - bounds.x;
				base.y = textures.sprites[textures.sprites.length - 1].dy - bounds.y;
				addChild(base);
			}
			animations.y = dy;
			animations.x = dx;
			
			addChild(animations);
			if(updateFunction != null)
				updateFunction.call(null)
			//updateAnim();
		}
		
		public function positioner():void {
			if (params.w > 0 && params.h > 0) {
				if (backing.width * scaleX > params.w)
					scaleX = scaleY = params.w / backing.width;
				
				if (backing.height * scaleX > params.h)
					scaleX = scaleY = this.scaleX * params.h / (backing.height * scaleX);
			}
		}
		
		protected function updateAnim(e:Event = null):void 
		{
			var index:int = frameTypes.length - 1;
			if (params.animal || params.type == 'Walkgolden' || params.type == 'Walkhero' || params.type == 'Animal')
			{
				index = 0;
				if (params.hasOwnProperty('framesType') && frameTypes.indexOf(params['framesType']) != -1) 
					index = frameTypes.indexOf(params['framesType']);
			}
			var animFrame:Object;
			if (index > -1) {
				if (animes.length <= index) return;
				
				if (animInfo[frameTypes[index]].chain[animInfo[frameTypes[index]].frame] != animInfo[frameTypes[index]].show) 
				{
					animInfo[frameTypes[index]].show = animInfo[frameTypes[index]].chain[animInfo[frameTypes[index]].frame];
					if (animInfo[frameTypes[index]].show == undefined) animInfo[frameTypes[index]].show = 0;
					
					if (params.animal || params.type == 'Walkgolden'|| params.type == 'Walkhero'|| params.type == 'Animal') {
						animFrame = textures.animation.animations[frameTypes[index]].frames[0][animInfo[frameTypes[index]].show];
					}else {
						animFrame = textures.animation.animations[frameTypes[index]].frames[animInfo[frameTypes[index]].show];
					}
					
					animes[index].bitmapData = animFrame.bmd;
					animes[index].smoothing = true;
					animes[index].x = animFrame.ox + ax - bounds.x;
					animes[index].y = animFrame.oy + ay - bounds.y;
				}
				
				animInfo[frameTypes[index]].frame++;
				if (animInfo[frameTypes[index]].frame >= animInfo[frameTypes[index]].chain.length)
				{
					animInfo[frameTypes[index]].frame = 0;
				}
			}
		}
		
		private function onAnimation(e:AppEvent = null):void {
			if (SystemPanel.animate) {
				startAnimation();
			}else{
				stopAnimation();
			}
		}
		
		private function startAnimation():void {
			if (animated) return;
			
			animated = true;
			App.self.setOnEnterFrame(updateFunction);
		}
		
		private function stopAnimation():void {
			if (!animated) return;
			
			animated = false;
			App.self.setOffEnterFrame(updateFunction);
		}
		
		private function initAnimation():void {
			animes = new Vector.<Bitmap>();
			if (!textures.hasOwnProperty('animation')) return;
			
			if (params.hasOwnProperty('framesType') && textures.animation.animations.hasOwnProperty(params.framesType)) {
				frameTypes = [params.framesType];
				animInfo[params.framesType] = {
					frame:0,
					show: -1,
					chain:textures.animation.animations[params.framesType].chain
				};
			}else {
				for (var framesType:String in textures.animation.animations) {
					if (params.animal && framesType != 'rest') continue; 
					
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
		
		public function clearVariables():void {
			var self:* = this;
			var description:XML = describeType(this);
			var variables:XMLList = description..variable;
			for each(var variable:XML in variables) {
				var ss:String = variable.@type;
				if(variable.@type == '*')
				{
					self[variable.@name] = null;
					continue;
				}
				var classType:Class
				try{
					classType = getDefinitionByName(variable.@type) as Class;
				}catch (e:Error){
					self[variable.@name] = null;
					continue;
				}
				switch(classType){
					case Sprite:
						if (self[variable.@name]){
							self[variable.@name].removeChildren();
							self[variable.@name] = null;
						}
						break;
					default:
						self[variable.@name] = null;
				}
			}
		}
		
		private function onRemove(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			App.self.setOffEnterFrame(updateFunction);
			updateFunction = null;
			clearVariables();
			App.self.removeEventListener(AppEvent.ON_UI_ANIMATION, onAnimation);
		}
		
		public static function bounds(texture:Object, params:Object = null):Object {
			var obj:Object = { x:0, y:0, ex:0, ey:0, frameTypes:[] };
			if (params) {
				for (var s:String in params)
					obj[s] = params[s];
			}
			
			if (texture.hasOwnProperty('sprites') && texture.sprites.length > 0) {
				var base:Object = texture.sprites[texture.sprites.length - 1];
				obj.x = base.dx;
				obj.y = base.dy;
				obj.ex = base.dx + base.bmp.width;
				obj.ey = base.dy + base.bmp.height;
			}
			
			if (texture.hasOwnProperty('animation') ) 
			{
				for (var anims:String in texture.animation.animations) 
				{
					obj.frameTypes.push(anims);
					for (var _frame:String in texture.animation.animations[anims].frames) 
					{
						var frame:Object = (params && params.type && (params.type == 'Walkgolden' || params.type == 'Walkhero' || params.type == 'Animal' || params.type == 'Picker')) ? texture.animation.animations[anims].frames[0][_frame] :texture.animation.animations[anims].frames[_frame];
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