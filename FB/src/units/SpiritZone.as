package units 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	/**
	 * ...
	 * @author 
	 */
	public class SpiritZone extends Personage 
	{
		private var targetBridge:Bridge
		public var shady:int = 0;
		public var smartShadow:Bitmap = new Bitmap();
		
		public function SpiritZone(object:Object, view:String='') 
		{
			targetBridge = object.target;
			super(object, view);
			if (this.sid == 1713)
				velocity = 0.01;
			tip = function():Object 
			{
				return {
					title:App.data.storage[sid].title,
					text:App.data.storage[sid].description
				}
			}
		}
		
		override public function click():Boolean 
		{
			if (targetBridge)
			{
				targetBridge.fromSpirit = true;
				targetBridge.click();
				return true;
			}else{
				return false;
			}
		}
		override public function generateStopCount():uint 
		{
			return int(Math.random() * 1) + 1;
		}
		public function goHome(_movePoint:Object = null):void
		{
			loopFunctionn = onLoop;
			var place:Object;
			var homeRad:int = 5;
			if (this.sid == 1713)
				homeRad = 2;
			if(_movePoint == null)
				place = findOldPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:targetBridge.coords.x, z:targetBridge.coords.z}}, homeRad, true);
			else	
				place = _movePoint;
			framesType = WALK;	
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
		}
		private var timerHome:int = 0
		private var stopCount:int = 5;
		override public function generateRestCount():uint 
		{
			return  int(Math.random() * 2) + 1;
		}
		
		override public function stopRest():void 
		{
			if (framesType != Personage.STOP)
			{
				framesType = Personage.STOP;
			}
			stopCount--;
			if (stopCount <= 0){
				restCount = generateRestCount();
				loopFunctionn = setRest;
			}else
				loopFunctionn = stopRest;
		}
		
		override public function setRest():void 
		{
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			
			framesType = randomRest;
			startSound(randomRest);
			
			restCount--;
			if (restCount <= 0){
				stopCount = (1+Math.random() * 1);// generateStopCount();
				loopFunctionn = beforeGoHome;
			}else
				loopFunctionn = setRest;
				
				
			//var randomID:int = int(Math.random() * rests.length);
			//var randomRest:String = rests[randomID];
			//restCount = generateRestCount();
			//framesType = randomRest;
			//startSound(randomRest);
		}
		
		public function beforeGoHome():void
		{
			if (framesType != Personage.STOP)
			{
				framesType = Personage.STOP;
			}
			stopCount--;
			if (stopCount <= 0){
				loopFunctionn = goHome;
			}else
				loopFunctionn = beforeGoHome;
		}
		
		override public function createShadow():void
		{
			if (shadow) 
			{
				removeChild(shadow);
				shadow = null;
			}
			
			if (textures && textures.animation.hasOwnProperty('shadow'))
			{
				shadow = new Bitmap(UserInterface.textures.shadow);
				addChildAt(shadow, 0);
				shadow.smoothing = true;
				shadow.x = textures.animation.shadow.x - (shadow.width / 2);
				shadow.y = textures.animation.shadow.y - (shadow.height / 2);
				shadow.alpha = 0.3;
				shadow.scaleX = textures.animation.shadow.scaleX * .7;
				shadow.scaleY = textures.animation.shadow.scaleY * .7;
			}
			
			if (textures && textures.animation.hasOwnProperty('shadow'))
			{
				//shadow = new Bitmap();
				var shadBitmap:BitmapData = textures.animation.animations.walk.frames[0][0].bmd.clone();
				var invertTransform:ColorTransform = new ColorTransform(0, 0, 0, 1, 0, 0, 0, 1);
				shadBitmap.colorTransform(shadBitmap.rect, invertTransform);
				shadow.bitmapData = shadBitmap;
				shadow.filters = [new BlurFilter(15, 15, BitmapFilterQuality.HIGH)];
				shadow.x = shadow.x - (shadow.width / 2);
				shadow.y = shadow.y - (shadow.height / 2);
				shady = shadow.y;
				
				if (textures)
				{
					ax = textures.animation.ax;
					ay = textures.animation.ay - 180;// позиция битмапки персонажа над тенью
				}
			}
		}
		
		override public function update(e:* = null):void 
		{
			super.update(e);
			
			if (framesDirection == FACE)
			{
				if (shadow.scaleY < 0)
				{
					shadow.scaleY = Math.abs(shadow.scaleY);
					shadow.y = shady - (shadow.height / 2);
				}
			}
			if (framesDirection == BACK)
			{
				if (shadow.scaleY > 0)
				{
					shadow.scaleY = shadow.scaleY * -1;
					shadow.y = shady + (shadow.height / 2);
				}
			}		
			if (framesFlip == RIGHT)
			{
				if (shadow.scaleX > 0)
				{
					shadow.scaleX = shadow.scaleX * -1;
					shadow.x = shadow.x + shadow.width;
				}
			}
			if (framesFlip == LEFT)
			{
				if (shadow.scaleX < 0)
				{
					shadow.scaleX = Math.abs(shadow.scaleX); 
					shadow.x = shadow.x - shadow.width;
				}
			}
		}
		
		public function createSuperShadow():void
		{
			var smartShadowBMD:BitmapData = textures.animation.animations.rest.frames[0][0].bmd;			
			var invertTransform:ColorTransform = new ColorTransform(0, 0, 0, 1, 0, 0, 0, 1);
			smartShadowBMD.colorTransform(smartShadowBMD.rect, invertTransform);
			
			smartShadow.bitmapData = smartShadowBMD;
			smartShadow.alpha = 0.65;
			
			var bFilter:BitmapFilter = new BlurFilter(10, 10, BitmapFilterQuality.HIGH);
			var pEffects:Array = new Array();
			pEffects.push(bFilter);

			smartShadow.filters = pEffects;			
			
			addChild(smartShadow);
			smartShadow.x -= 20;
			smartShadow.y += 40;
		}
		
		public function findOldPlaceNearTarget(target:*, radius:int = 1, infront:Boolean = false):Object
		{
			var places:Array = [];
			
			var targetX:int = target.coords.x;
			var targetZ:int = target.coords.z;
			
			var startX:int = targetX - radius;
			var startZ:int = targetZ - radius;
			
			if (startX <= 0) startX = 1;
			if (startZ <= 0) startZ = 1;
			
			var finishX:int = targetX + radius + target.info.area.w;
			var finishZ:int = targetZ + radius + target.info.area.h;
			
			if (finishX >= Map.cells) finishX = Map.cells - 1;
			if (finishZ >= Map.rows) finishZ = Map.rows - 1;
			
			if (!App.map._aStarNodes)
				return null;
			
			for (var pX:int = startX; pX < finishX; pX++)
			{
				for (var pZ:int = startZ; pZ < finishZ; pZ++)
				{
					if (coords && (coords.x <= pX && pX <= targetX +target.info.area.w) &&
					(coords.z <= pZ && pZ <= targetZ +target.info.area.h)){
						continue;
					}
					
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].isWall) 
						continue;
						
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].open == false) 
						continue;
						
					if(info && info.base == 1){
						if (App.map._aStarNodes[pX][pZ].w != 1 || App.map._aStarNodes[pX][pZ].open == false )
						continue;
					}
					
					if(info && info.base == 0){
						if  ((App.map._aStarNodes[pX][pZ].b != 0) || App.map._aStarNodes[pX][pZ].open == false|| App.map._aStarNodes[pX][pZ].object != null) 
						continue;
					}
					
					places.push( { x:pX, z:pZ} );
				}
			}
			
			if (places.length == 0) 
			{
				places.push( { x:coords.x, z:coords.z } );
			}
			
			var random:uint = int(Math.random() * (places.length - 1));
			return places[random];
		}
		
		override public function uninstall():void 
		{
			clearTimeout(timerHome);
			super.uninstall();
		}
		
	}

}