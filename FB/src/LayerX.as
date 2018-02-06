package  
{
	import com.demonsters.debugger.MonsterDebuggerConnectionMobile;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import units.Building;
	import units.Resource;
	import wins.Window;

	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.display.Sprite;
	
	public class LayerX extends Sprite
	{
		
		public function LayerX() 
		{

		}
		
		public var tip:*;
		
		private var __tween:TweenMax;
		private var __tween2:TweenMax;
		private var __tween3:TweenMax;
		public var __arrow:Bitmap;
		private var __position:String;
		private var __container:Sprite = null;
		
		public var __hasGlowing:Boolean = false;
		public var __hasPointing:Boolean = false;
		public var __hasAlphaEff:Boolean = false;

		private var inner:Boolean = false;
		public function showGlowing(color:* = null):void
		{
			if (__hasGlowing) return;
			__hasGlowing = true;
			startGlowing(color);
		}
	
		public var _glowingColor:* = 0xFFFF00;
		public function startGlowing(color:* = null,inner:Boolean = false):void
		{
			this.inner = inner;
			if(color!= null)
				glowingColor = color;
			__tween = TweenMax.to(this, 0.8, { glowFilter: { color:glowingColor, alpha:1, strength: 4, blurX:4, blurY:4, inner:inner }, onCompleteParams:[0.1, 6, 12, 12, inner], onComplete:function(...args):void {
				// args[0].dispose();
				 restartGlowing(0.1, 6, 12, 12, inner)
				}} );
		
			if (App.user.quests.tutorial) 
			{
				addEventListener(MouseEvent.MOUSE_OVER,restartGlowingTut);
			
			}
		}
		
		public function showGlowingOnce(color:* = null , delay:int = 1.8):void
		{
			if (color != null) glowingColor = color;
			__hasGlowing = true;
			__tween = TweenMax.to(this, delay/2, { glowFilter: { color:glowingColor, alpha:1, strength: 4, blurX:15, blurY:15 }, onComplete: nullGlowing } );
		}
		
		public function startMoreGlowing(color:* = null):void
		{
			if (color != null) glowingColor = color;
			__hasGlowing = true;
			__tween = TweenMax.to(this, 0.8, { glowFilter: { color:glowingColor, alpha:1, strength: 4, blurX:20, blurY:20}, onComplete:restartGlowing} );
		}
		
		public function nullGlowing():void
		{
			if (!this.parent) return;
			__tween = TweenMax.to(this, .8, { glowFilter: { color:glowingColor, alpha:0, strength: 1, blurX:1, blurY:1 }, onComplete:hideGlowing } );	
		}
		private function restartGlowingTut(e:MouseEvent):void 
		{
			
			restartGlowing(0.1, 10, 25, 25);
		}
		
		public function restartGlowing(time:Number =0.8,str:int=4,blrX:int=6, blrY:int=6, inner:Boolean = false):void
		{
			__tween = TweenMax.to(this, 0.8, { glowFilter: { color:glowingColor, alpha:0.8, strength: str, blurX:blrX, blurY:blrY,inner:inner },onCompleteParams:[0.1,10,25,25,inner], onComplete:function(...args):void {
				// args[0].dispose();
				 startGlowing(null,inner)
				}} );
		}
		
		public function hideGlowing():void
		{
			__hasGlowing = false;
			if(__tween != null){
				__tween.complete(true, true);
				__tween.kill();
				__tween = null;
				
			if (App.user.quests.tutorial) 
			{
				removeEventListener(MouseEvent.MOUSE_OVER,restartGlowingTut);
			
			}	
			}
			this.filters = null;
		}
		
		
		private var _alphaDelay:Number;
		private var _minAlpha:Number;
		public function startAlphaEff(color:* = null, minAlpha:Number = 0, delay:Number = 1):void
		{
			_alphaDelay = delay;
			_minAlpha = minAlpha;
			__hasAlphaEff = true;
			__tween = TweenMax.to(this, _alphaDelay, { alpha:1, onComplete:restartAlphaEff} );
		}
		
		private function startAgainAlphaEff():void {
			__tween = TweenMax.to(this, _alphaDelay, { alpha:1, onComplete:restartAlphaEff} );
		}
		
		public function restartAlphaEff():void
		{
			var that:* = this;
			setTimeout(function():void {
				__tween = TweenMax.to(that, _alphaDelay, { alpha:_minAlpha , onComplete:startAgainAlphaEff} );		
			}, 1000);
		}
		
		public function hideAlphaEff():void
		{
			__hasAlphaEff = false;
			if(__tween3 != null){
				__tween3.complete(true, true);
				__tween3.kill();
				__tween3 = null;
			}
			this.filters = null;
		}
		
		
		private var __y:int = 0;
		private var __x:int = 0;
		private var __deltaX:int = 0;
		private var __deltaY:int = 0;
		
		private var __arrowSprite:Sprite = new Sprite();
		
		public function set arrowVisible(value:Boolean):void {
			if (value == false) {
				__arrowSprite.visible = false;
			}else {
				__arrowSprite.visible = true;	
			}
		}
		
		public function get glowingColor():* 
		{
			return _glowingColor;
		}
		
		public function set glowingColor(value:*):void 
		{
			_glowingColor = value;
		}
		public var currPointingSetts:Object = new Object();
		public function showPointing(position:String = "top", deltaX:int = 0, deltaY:int = 0, container:* = null, text:String = '', textSettings:Object = null, isQuest:Boolean = false, light:Boolean = false):void
		{
			if (__hasPointing)
				return;
				
			currPointingSetts['position'] = position;
			currPointingSetts['deltaX'] = deltaX;
			currPointingSetts['deltaY'] = deltaY;
			currPointingSetts['container'] = container;
			
			__hasPointing = true;
			
			if (this.hasOwnProperty('loader') && this['loader'] != null && (this is Building /*|| this is Resource*/))
				return;
			
			__arrowSprite = new Sprite();
			__arrowSprite.mouseChildren = __arrowSprite.mouseEnabled = false;
			
			__deltaX = deltaX;
			__deltaY = deltaY;
			if (App.user.quests.tutorial)
			{
				__arrow = new Bitmap(UserInterface.textures.arrow);
			}
			else{
				if (isQuest){
					//__arrow = new Bitmap(Window.textures.tutorialArrow);
					__arrow = new Bitmap(UserInterface.textures.progressArrow);
				}else if (position == "targeting"){
					__arrow = new Bitmap(UserInterface.textures.progressYellowArrow);
					__arrowSprite.visible = false;
				}else if (light){
					__arrow = new Bitmap(UserInterface.textures.progressYellowArrow);
					//__arrowSprite.visible = false;
				}else{
					__arrow = new Bitmap(UserInterface.textures.arrow);
					//__arrow = new Bitmap(UserInterface.textures.progressArrow);
				}
			}
			
			__arrow.smoothing = true;
			 
			var textLabel:TextField;
			if (text != '') {
				textLabel = Window.drawText(text, textSettings);
			}
			
			this.__position = position;
			
			if (__position == "bottom") {
				__arrow.rotation = -90;
				__arrow.scaleX = -1;
				
				__arrow.x = -__arrow.width / 2;
				__arrowSprite.addChild(__arrow);
				__arrowSprite.y = y + __deltaY + 10;
				__arrowSprite.x = x + this.width / 2 + __deltaX - 4;
				this.height
			}else if(__position == "right"){//left
				
				__arrowSprite.addChild(__arrow);
				
				__arrow.y = -__arrow.height / 2 - 5;
				
				__arrowSprite.x = int(x + width + __deltaX);
				__arrowSprite.y = int(y + height / 2 + __deltaY - 4);
				
				if (textLabel) {
					__arrow.y = -__arrow.height / 2;
					__arrowSprite.addChild(textLabel);;
					textLabel.x = __arrow.x + __arrow.width + 4 + __arrow.width/2 - 115;
					textLabel.y = - textLabel.textHeight / 2;
				}
			}else if(__position == "left"){//right
				
				__arrowSprite.addChild(__arrow);
				__arrow.rotation = -180;
				__arrow.y = __arrow.height / 2;
				
				__arrowSprite.x = int(x + __deltaX);
				__arrowSprite.y = int(y + height / 2 + __deltaY - 4);
				
				if (textLabel) {
					__arrow.rotation = 180;
					__arrowSprite.addChild(textLabel);
					textLabel.x = __arrow.x - textLabel.width - 40;
					textLabel.y =  textLabel.height / 2 - 30;
				}
				
			}else if (__position == "top") {
				__arrow.rotation = -90;
				__arrowSprite.addChild(__arrow);
				__arrow.x = -__arrow.width / 2;
				__arrow.y = -5;
				
				__arrowSprite.x = x + this.width / 2 + __deltaX - 4;
				__arrowSprite.y = y - 10 + __deltaY;
			
			}else if (__position == "targeting") {
				__arrow.rotation = -90;
				__arrowSprite.addChild(__arrow);
				__arrow.x = -__arrow.width / 2;
				__arrow.y = -10;
				//__arrow.x = 0;
				//__arrow.y = 0;
				
				__arrowSprite.x = x + this.width / 2 + __deltaX - 4;
				__arrowSprite.y = y - 10 + __deltaY;
			
			}else if (__position == "none") {
				//__arrow.rotation = -90;
				//__arrowSprite.addChild(__arrow);
				//__arrow.x = -__arrow.width / 2;
				//__arrow.y = -10;
				//__arrow.x = 0;
				//__arrow.y = 0;
				
				//__arrowSprite.x = x + this.width / 2 + __deltaX - 4;
				//__arrowSprite.y = y - 10 + __deltaY;
			
			}else {
				__arrowSprite.addChild(__arrow);
				__arrowSprite.x = x + __deltaX;
				__arrowSprite.y = y - 10 + __deltaY;
			}
			
			__x = __arrowSprite.x;
			__y = __arrowSprite.y;
			
			if(container == null){
				App.map.mTreasure.addChild(__arrowSprite);
			}else {
				__container = container;
				__container.addChild(__arrowSprite);
			}
			
			startPointing();
		}
		
		private var targetingArrowY:Number = __y;
		public function startPointing():void
		{
			if (this == null)
				trace("не вижу цели свечения!!!");
			if (__position == "right") {//left
				__tween2 = TweenMax.to(__arrowSprite, 0.6, {x:__x + 40, onComplete:restartPointing, ease:Strong.easeInOut  } );
			}else if (__position == "left") {//right
				__tween2 = TweenMax.to(__arrowSprite, 0.6, { x:__x - 40, onComplete:restartPointing, ease:Strong.easeInOut  } );	
			}else if (__position == "targeting") { // targeting personage move 1
				__arrowSprite.alpha = 0;
				__tween2 = TweenMax.to(__arrowSprite, 1.2, {y:__y - 90, onComplete:targetingArrowMove1, ease:Linear.easeNone,  scaleX:1, scaleY:1, alpha:0});
			}else {
				__tween2 = TweenMax.to(__arrowSprite, 0.6, { y:__y -30, onComplete:restartPointing, ease:Strong.easeInOut  } );
			}
		}
		
		private function targetingArrowMove1():void // targeting personage move 2
		{
			__tween2 = TweenMax.to(__arrowSprite, 0.6, { y:__y + 25, onComplete:targetingArrowMove2, ease:Linear.easeNone,  scaleX:1, scaleY:1, alpha:0.85} );		
		}
		private function targetingArrowMove2():void // targeting personage move 3
		{
			__tween2 = TweenMax.to(__arrowSprite, 0.25, { y:__y + 50, onComplete:startPointing, ease:Linear.easeNone,  scaleX:1, scaleY:1, alpha:0} );		
		}

		
		public function restartPointing():void
		{
			if (__position == "right") {//left
				__tween2 = TweenMax.to(__arrowSprite, 0.6, { x:__x, onComplete:startPointing } );	
			}else if (__position == "left") {//right
				__tween2 = TweenMax.to(__arrowSprite, 0.6, { x:__x, onComplete:startPointing } );	
			}else {
				__tween2 = TweenMax.to(__arrowSprite, 0.6, { y:__y, onComplete:startPointing } );	
			}
		}
		
		public function hidePointing():void
		{
			__hasPointing = false;
			
			if(__tween2 != null){
				__tween2.complete(true, true);
				__tween2 = null;
				if (__container == null ) {
					if(App.map.mTreasure.contains(__arrowSprite))
						App.map.mTreasure.removeChild(__arrowSprite);
				}else 
				{
					if (__container.numChildren > 0)
					{
						__container.removeChild(__arrowSprite);
						__container = null;
					}
				}
			}
		}
		
		public var isPluck:Boolean = false;
		private var pluckY:Number;
		private var pluckX:Number;
		public function pluck(delay:uint = 0, xPos:int = 0, yPos:int = 0):void 
		{
			pluckY = yPos;
			pluckX = xPos;
			if (delay > 0)
				setTimeout(pluckIn, delay);
			else
				pluckIn();
		}
		 
		private var plackTween:TweenLite;
		private var tweenPlugin:TweenPlugin;
		private var sclKoef:int = 1;
	
		private function pluckIn():void {
			TweenPlugin.activate([TransformAroundPointPlugin]);
			TweenLite.plugins
			isPluck = true;
			
			sclKoef = this.scaleX;
			
			var cslX:Number = sclKoef * 1.2;
			
			plackTween = TweenLite.to(this, 0.3, { transformAroundPoint: { point:new Point(pluckX, pluckY), scaleX:cslX, scaleY:0.8 }, ease:Strong.easeOut} );//1.2 0.8
			setTimeout(function():void {
				pluckOut();
			}, 200);
		}
		
		
		private var plackOutTween:TweenLite;
		private function pluckOut():void 
		{
			var cslX:Number = sclKoef;
			plackOutTween = TweenLite.to(this, 1, { transformAroundPoint: { point:new Point(pluckX, pluckY), scaleX:cslX, scaleY:1 }, ease:Elastic.easeOut, onComplete:function():void { isPluck = false; } }  );
		}
		
		public function pluckDispose():void
		{
			//TweenPlugin.activate(
			//tweenPlugin.onComplete
			
			if (plackTween && plackTween.active)
			{
				
				plackTween.kill();
			}
			if (plackOutTween && plackOutTween.active)
			{
				plackOutTween.kill();
			}
			
			tweenPlugin = null;
			plackTween = null;
			plackOutTween = null;
		}
		
		private var _blinkTween:TweenLite;
		private var _parent:Sprite;
		
		public function startBlink(/*parent:Sprite*/):void
		{
			//stopBlink();
			TweenPlugin.activate([ColorMatrixFilterPlugin]);
			_parent = this;
			saturationIn();
		}
		
		public function stopBlink():void
		{
			if (_blinkTween)
			{
				_blinkTween.kill();
				_blinkTween = null;
			}
			if (_parent != null)
			{
				_parent.filters = [];
			}
			_parent = null;
		}
		
		private function saturationIn():void
		{
			if (_parent == null)
			{
				stopBlink();
				return;
			}
			_blinkTween = TweenLite.to(_parent, 0.5, {colorMatrixFilter:{/*saturation:0,*/ brightness:1.5}, onComplete:saturationOut});
		}
		
		private function saturationOut():void
		{
			if (_parent == null)
			{
				stopBlink();
				return;
			}
			_blinkTween = TweenLite.to(_parent, 0.5, {colorMatrixFilter:{/*saturation:1,*/ brightness:1}, onComplete:saturationIn});
		}
	}
}
