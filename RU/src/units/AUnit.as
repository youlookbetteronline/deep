package units
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import core.Load;
	import core.Numbers;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import strings.Strings;
	import ui.Cloud;
	import ui.SystemPanel;
	import units.Unit;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class AUnit extends Unit 
	{
		public var framesType:String = "work";
		
		public var framesTypes:Array = [];
		public var multipleAnime:Object = { };
		public var bitmaps:Vector.<Bitmap> = new Vector.<Bitmap>;
		
		protected var frame:uint = 0;
		protected var frameLength:uint = 0;
		
		private var chain:Object;
		
		public var ax:int = 0;
		public var ay:int = 0;
		public var _flag:* = false;
		public var cloud:Cloud = null;
		public var multiBitmap:Bitmap;

		
		public var animeTouch:Bitmap;
		public var loader:Preloader = new Preloader();
		public var hasLoader:Boolean = true;
		public var firstDraw:Boolean = false;
		
		protected var _cloudY:Number = 0;
		protected var _cloudX:Number = 0;
		//protected var animateFunction:Function;

		public var animSource:String = 'animations';
		
		public function AUnit(object:Object)
		{
			//animateFunction = animate;
			super(object);
			loader.scaleX = loader.scaleY = 0.67;
			if (object.hasOwnProperty('hasLoader'))
			hasLoader = object.hasLoader;
			if (this.parent)
				tempParent = this.parent;
			if(hasLoader)
				addChild(loader);
				
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			App.self.addEventListener(AppEvent.ON_MAP_REDRAW, checkDrawMode);
		}
		
		private var tempParent:*;
		override public function calcState(node:AStarNodeVO):int
		{
			return EMPTY;
			if (info.base != null && info.base == 1) 
			{
				for (var i:uint = 0; i < cells; i++) {
					for (var j:uint = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						//if (node.b != 0 || node.open == false) {
						if (node.w != 1 || node.object != null || node.open == false) { // 
							return OCCUPIED;
						}
					}
				}
				return EMPTY;
			}
			else
			{
				return super.calcState(node);
			}
		}
		
		public function setFlag(value:*, callBack:Function = null, settings:Object = null):void
		{
			if (!touchableInGuest && App.user.mode == User.GUEST) return;
			
			_flag = value;
			
			if (cloud != null)
			{
				if (cloud.parent) cloud.parent.removeChild(cloud);
				cloud.dispose();
				cloud = null;
			}
			
			if (_flag)
			{
				cloud = new Cloud(_flag, settings, _rotate, callBack);
				cloud.y = dy + _cloudY/* -20 */;
				cloud.x = - (cloud.bg.width) / 2 + _cloudX -10;
				addChild(cloud);
				
			}
		}
		
		public function get flag():*
		{
			return _flag;
		}
		
		public function set flag(value:*):void 
		{
			if (!touchableInGuest && App.user.mode == User.GUEST) return;
			
			_flag = value;
			
			if (cloud != null)
			{
				if(cloud.parent)cloud.parent.removeChild(cloud);
				cloud = null;
			}
			
			if (_flag)
			{
				cloud = new Cloud(_flag, {target:this}, _rotate);
				cloud.y = dy + _cloudY;
				cloud.x = - cloud.width / 2 + _cloudX;
				if (type == 'Tree') 
				{
					cloud.x	+= 20;
					cloud.y	+= 30;
				}
				addChild(cloud);
			}
		}
		
		public function setCloudPosition(dX:Number, dY:Number):void
		{
			_cloudY = dY;
			_cloudX = dX + 10;
			if (cloud != null)
			{
				cloud.y = dy + _cloudY;
				cloud.x = - cloud.width / 2 + _cloudX;
			}
		}
		
		public function onRemoveFromStage(e:Event):void {
			//if (animated) {
				//stopAnimation();
			//}
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		/*public function onLoad(data:*):void {
			textures = data;
			
			startAnimation();
			
			
		}*/
		
		public function onLoad(data:*):void 
		{
			textures = data;
			
			startAnimation();
			
			if (loader && loader.parent)
			{
				loader.parent.removeChild(loader);
				loader = null;
			}
			if (!open && formed) {
				applyFilter();
			}
		}
		
		override public function get bmp():Bitmap {
			if (multiBitmap && multiBitmap.bitmapData && multiBitmap.bitmapData.getPixel(multiBitmap.mouseX, multiBitmap.mouseY) != 0)
				return multiBitmap;
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
				
			return bitmap;
		}
		
		public function initAnimation():void {
			framesTypes = [];
			if (textures && textures.hasOwnProperty('animation') && Numbers.countProps(textures.animation.animations) > 0) {
				for (var frameType:String in textures.animation.animations) {
					framesTypes.push(frameType);
				}
				addAnimation()
				//animateFunction.call(null);
				animate();
			}
		}
		public var onHideAnim:Array = [486 , 532, 796, 1257, 1258, 1679, 1685, 1686, 2129/*, 1546*/];
		public function addAnimation():void
		{
			multiBitmap = new Bitmap();
			addChild(multiBitmap);
			//if (onHideAnim.indexOf(this.sid) != -1)
			multiBitmap.visible = false;
			
			ax = textures.animation.ax;
			ay = textures.animation.ay;
			
			clearAnimation();
			
			var arrSorted:Array = [];
			for each(var nm:String in framesTypes) {
				arrSorted.push(nm); 
			}
			arrSorted.sort();
			
			for (var i:int = 0; i < arrSorted.length; i++ ) {
				var name:String = arrSorted[i];
				multipleAnime[name] = { bitmap:new Bitmap(), cadr: -1 };
				bitmapContainer.addChild(multipleAnime[name].bitmap);
				
				if (textures.animation.animations[name]['unvisible'] != undefined && textures.animation.animations[name]['unvisible'] == true) {
					multipleAnime[name].bitmap.visible = false;
				}
				if (onHideAnim.indexOf(this.sid) != -1)
					multipleAnime[name].bitmap.visible = false;
				
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name]['frame'] = 0;
				multipleAnime[name]['bid'] = i;
				
			}
			
			firstDraw = false;
		}

		public function startAnimation(random:Boolean = false):void
		{
			if (animated) return;
				
			for each(var name:String in framesTypes) {
				if (!textures.animation.animations.hasOwnProperty(name))
					continue;
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name].bitmap.visible = true;
				multipleAnime[name]['frame'] = 0;
				if (random) {
					multipleAnime[name]['frame'] = int(Math.random() * multipleAnime[name].length);
				}
			}
			
			App.self.setOnEnterFrame(animate);
			animated = true;
		}
		
		public function stopAnimation():void
		{
			App.self.setOffEnterFrame(animate);
			animated = false;
		}
		
		public function clearAnimation():void 
		{
			stopAnimation();
			if (!SystemPanel.animate) return;
			for (var _name:String in multipleAnime) 
			{
				var btm:Bitmap = multipleAnime[_name].bitmap;
				if (btm && btm.parent)
					btm.parent.removeChild(btm);
			}
		}
		
		private function multipleAnimation(name:String, cadr:int):void
		{
			if (multipleAnime == null)
			{
				multiBitmap.bitmapData = null;
				return;
			}
			var frameObject:Object 	= textures.animation.animations[name].frames[cadr];
			if (frameObject == null) return;
			multiBitmap.scaleX = bitmap.scaleX;
			multiBitmap.bitmapData = frameObject.bmd;
			multiBitmap.x = frameObject.ox + ax;
			multiBitmap.y = frameObject.oy + ay;  //-30 Denis
		}
		
		public var drawMode:Boolean = true;
		public function checkDrawMode(e:Event = null):void
		{
			if (!animated || !App.map)
				return;
				
			if ((App.map.x + (this.x + this.width / 2) * App.map.scaleX < 0 || App.map.x + (this.x - this.width / 2)*App.map.scaleX > App.self.stage.stageWidth)
			 ||(App.map.y + (this.y + this.height / 2) * App.map.scaleY < 0 || App.map.y + (this.y - this.height / 2)*App.map.scaleY > App.self.stage.stageHeight))
			{
				//trace(info.title +' changed to no draw mode');
				drawMode = false;
				//this.visible = false;
				/*if (this.parent)
				{
					tempParent = this.parent;
					this.parent.removeChild(this);
				}*/
				//this.visible = false;
			}
			else{
				/*if (!this.parent)
				{
					tempParent.addChild(this);
					App.map.sorted.push(this);
				}*/
				//this.visible = true;;
				drawMode = true;
				
			}
		}
		
		override public function animate(e:Event = null):void
		{
			if (!textures) return;
			if (!SystemPanel.animate && firstDraw) return;
			
			firstDraw = true;
			for each(var name:String in framesTypes) 
			{
				if (!textures.animation.animations)
				{
					return;
				}this.sid
				var frame:* 			= multipleAnime[name].frame;
				var cadr:uint 			= textures.animation.animations[name].chain[frame];
				
				if (!drawMode && multipleAnime[name].bitmap.bitmapData)
				{
					multipleAnime[name].frame++;
					if (multipleAnime[name].frame >= multipleAnime[name].length)
					{
						multipleAnime[name].frame = 0;
					}
					continue;
				}
				//this.visible = true;
				if (multipleAnime[name].cadr != cadr) 
				{
					multipleAnime[name].cadr = cadr;
					var frameObject:Object 	= textures.animation.animations[name].frames[cadr];
					multipleAnime[name].bitmap.bitmapData = frameObject.bmd;
					//multipleAnime[name].bitmap.smoothing = true;
					multipleAnime[name].bitmap.x = frameObject.ox + ax;
					multipleAnime[name].bitmap.y = frameObject.oy + ay;
					
					animeTouch = multipleAnime[name].bitmap;
					multipleAnimation(name, cadr);
					
					
				}
				
				multipleAnime[name].frame++;
				if (multipleAnime[name].frame >= multipleAnime[name].length)
				{
					multipleAnime[name].frame = 0;
				}
			}
		}
		
		public var smoke_animated:Boolean = false;
		public var smokeAnimations:Array = [];
		public function startSmoke():void {
			smoke_animated = true;
			if (smokeAnimations.length > 0) {
				for each(var anime:Anime in smokeAnimations) {
					//anime.startAnimation(true);
					anime.alpha = 1;
					addChild(anime);
				}
			}else{
				if (textures && textures.hasOwnProperty('smokePoints')) {
					
					Load.loading(Config.getSwf('Smoke', 'smoke'), function(data:*):void {
						var animation:Object = data;
						
						
						for each(var point:Object in textures.smokePoints) {
						var anime:Anime = new Anime(animation, 'smoke', point.dx, point.dy, point.scale || 1);
						anime.startAnimation(true);
							anime.alpha = 1;
							addChild(anime);
							smokeAnimations.push(anime);
						}
						
						if (smoke_animated == false)
							stopSmoke();
					});
					
				}
			}
		}
		
		public function stopSmoke():void {
			smoke_animated = false;
			if (info.view == 'mine'){
				//trace('stopSmoke ' + info.view + " " + id);
			}	
			if (smokeAnimations.length == 0) return;
			
			for each(var anime:Anime in smokeAnimations) {
				//anime.stopAnimation();
				if(this.contains(anime)) removeChild(anime);
			}
			
		}
		
		override public function uninstall():void 
		{
			//App.self.setOffEnterFrame(animateFunction);
			App.self.setOffEnterFrame(this.animate);
			//animateFunction = null;
			App.self.removeEventListener(AppEvent.ON_MAP_REDRAW, checkDrawMode);
			super.uninstall();
		}
		
		public function makePost(e:* = null):void
		{
			if (App.user.quests.tutorial /*|| App.self.stage.displayState == StageDisplayState.FULL_SCREEN || App.self.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE*/)
				return;
			
			WallPost.makePost(WallPost.BUILDING, { sid:sid } ); 
		}
		
	}
	
}