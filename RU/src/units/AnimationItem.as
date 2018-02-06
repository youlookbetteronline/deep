package units
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import ui.UserInterface;
	
	/**
	 * ...
	 * @author 
	 */
	public class AnimationItem extends LayerX
	{
		public var textures:Object
		private var view:String
		private var onLoop:Function;
		private var settings:Object = {
			
		};
		private var shadow:Bitmap;
		private var framesType:String;
		private var direction:*;
		private var flip:Boolean = false;
		public var sid:int = 0;
		public var animated:Boolean = true;
		public var onClick:Function = null;
		public var once:Boolean = false;
		public function AnimationItem(settings:Object = null) {
			
			if (settings == null) 
			{
				return
			}
			view = settings.view;
			framesType = settings.framesType || view;
			touchable = settings.touchable || false;
			onClick = settings.onClick || null;
			
			if (settings.hasOwnProperty('onLoop'))
				onLoop = settings.onLoop;
				
			if (settings.hasOwnProperty('once'))
				once = settings.once;
				
			if (settings.hasOwnProperty('animated'))
				animated = settings.animated;
				
			if (settings.params) {
				if (settings.params.scale)
					this.scaleX = this.scaleY = settings.params.scale;
			}
			
			if (settings.type == 'Personage' || settings.type == 'Character'|| settings.type == 'Techno'){
				direction = settings.direction;
				flip = settings.flip;
			}	
				
			Load.loading(Config.getSwf(settings.type, settings.view), onLoad);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			addEventListener(MouseEvent.CLICK, click);
			
			if (flip)	
				this.scaleX *= -1
		}
		
		public function get bmp():Bitmap {
			return bitmap;
		}
		
		public var touchable:Boolean = false;
		private var _touch:Boolean = false;
		public function set touch(touch:Boolean):void 
		{
			if (!touchable) return;
			
			_touch = touch;
			if (touch) {
				bitmap.filters = [new GlowFilter(0xFFFF00, 1, 6, 6, 7)]; 
			}else {
				bitmap.filters = null;
			}
		}
		
		public function click(e:MouseEvent):void {
			removeEventListener(MouseEvent.CLICK, click);
			if (_touch) {
				if (onClick != null)
					onClick();
			}
		}
		
		private function onLoad(data:*):void {
			textures = data;
			addAnimation();
			animate();
			createShadow();
			if(animated)
				startAnimation('',this.once);
				
			this.dispatchEvent(new Event(Event.COMPLETE));	
		}
		
		public function onRemoveFromStage(e:Event):void {
			stopAnimation();
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		private var ax:int = 0;
		private var ay:int = 0;
		
		public var bitmap:Bitmap;
		public function addAnimation():void
		{
			bitmap = new Bitmap();
			addChild(bitmap);
			
			ax = textures.animation.ax;
			ay = textures.animation.ay;
			
		}
		
		public function startAnimation(_frameType:String = '',_once:Boolean = false):void {
			
			//	onLoop = _onLoop;
			this.once = _once;
			if (_frameType != '') 
			{
				framesType = _frameType;
				frame = 0;
			}	
				
			App.self.setOnEnterFrame(animate);
		}
		public function stopAnimation():void {
			App.self.setOffEnterFrame(animate);
		}
		
		private var frame:int = 0;
		private function animate(e:Event = null):void
		{
			
			var cadr:uint 			= textures.animation.animations[framesType].chain[frame];
			var frameObject:Object
				if(direction != null)
					frameObject	= textures.animation.animations[framesType].frames[direction][cadr];
				else
					frameObject	= textures.animation.animations[framesType].frames[cadr];
					
				bitmap.bitmapData 	= frameObject.bmd;
				bitmap.smoothing 	= true;
				bitmap.x = frameObject.ox+ax;
				bitmap.y = frameObject.oy+ay;
				
			frame++;
			if (frame >= textures.animation.animations[framesType].chain.length)
			{
				
				frame = 0;
				if (onLoop != null) onLoop();
			}
			else 
			{
				if (framesType == 'tut_bend_down' && (frame>=(textures.animation.animations[framesType].chain.length-40))&&!isBendOut) 
					{
						if (App.user.quests.opened[0].id == 119) 
						{
							App.user.quests.readEvent(119, function():void { } );
							isBendOut = true;
						}
					}
			}
		}
		private var isBendOut:Boolean = false;
		public function createShadow():void {
			if (shadow) {
				removeChild(shadow);
				shadow = null;
			}
			
			if (textures && textures.animation.hasOwnProperty('shadow')) {
				shadow = new Bitmap(UserInterface.textures.shadow);
				addChildAt(shadow, 0);
				shadow.smoothing = true;
				shadow.x = textures.animation.shadow.x - (shadow.width / 2);
				shadow.y = textures.animation.shadow.y - (shadow.height / 2);
				shadow.alpha = textures.animation.shadow.alpha;
				shadow.scaleX = textures.animation.shadow.scaleX;
				shadow.scaleY = textures.animation.shadow.scaleY;
			}
		}
		
		public function dispose():void {
			stopAnimation();
			removeEventListener(MouseEvent.CLICK, click);
		}
		
		public static function getParams(type:String, view:String):Object {
			if (type == Building.BUILD) {
				switch(view) {
					case 'ether_mine':
							return { scale:0.6 }
						break;
					case 'storage1':
							return {scale:0.5}
						break;
				}
			}
			
			return { };
		}
	}
}