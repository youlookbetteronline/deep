package buttons 
{
	import com.greensock.TweenMax;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.StaticText;
	import flash.text.TextFormat;
	import silin.filters.ColorAdjust;
	
	
	public class AButton extends ImageButton
	{
		public var abitmap:Bitmap;
		public var framesType:String;
		private var framesDirection:int = 1;
		public function AButton(bitmapData:BitmapData, settings:Object = null):void 
		{
			if (settings == null) {
				settings = {};
			}
			
			ax = settings.ax || 0;
			ay = settings.ay || 0;
			super(bitmapData, settings);
			
		}
		
		override protected function drawTopLayer():void {
			if(settings.view != 'empty')
				Load.loading(Config.getSwf('AButton', settings.view), onLoad);
		}
		
		private var textures:Object;
		private var ax:int;
		private var ay:int;
		private function onLoad(data:*):void {
			textures = data;
			abitmap = new Bitmap();
			ax += textures.animation.ax;
			ay += textures.animation.ay;
			addChildAt(abitmap, 0);
			
			framesDirection = 1;
			framesType = 'all';
			animate();
			//framesType = 'empty';
		}
		
		override protected function MouseOver(e:MouseEvent):void {
			if(mode == Button.NORMAL){
				effect(0.1);
			}
			
			framesDirection = 1;
			startAnimation();
		}
		
		override protected function MouseOut(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect(0);
			}
			framesDirection = -1;
			startAnimation();
		}
		
		override protected function MouseDown(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				stop = true;
				effect( -0.1);
				SoundsManager.instance.playSFX(settings.sound);	
				if(onMouseDown != null){
					onMouseDown(e);
				}					
			}
		}
		
		override protected function MouseUp(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect(0.1);
				if(onMouseUp != null){
					onMouseUp(e);
				}
			}
		}	
		
		public function startAnimation(_frameType:String = ''):void {
			
			//if (_frameType == framesType) 
				//return;
				
			//framesType = _frameType;
			//frame = 0;
				
			App.self.setOnEnterFrame(animate);
		}
		
		public function stopAnimation():void {
			App.self.setOffEnterFrame(animate);
		}
		
		private var frame:int = 0;
		private function animate(e:Event = null):void
		{	
			var cadr:uint 			= textures.animation.animations[framesType].chain[frame];
			var frameObject:Object	= textures.animation.animations[framesType].frames[cadr];
				
			abitmap.bitmapData 	= frameObject.bmd;
			abitmap.smoothing 	= true;
			abitmap.x = frameObject.ox+ax;
			abitmap.y = frameObject.oy+ay;
				
			frame += framesDirection;
			if (frame >= textures.animation.animations[framesType].chain.length || frame < 0)
			{
				stopAnimation();
				frame -= framesDirection;
			}
		}
	}
}