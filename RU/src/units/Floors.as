package units
{
	import com.greensock.TweenLite;
	import core.Post;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import ui.Cursor;
	import wins.BuildingConstructWindow;
	import wins.ConstructWindow;
	import wins.ShareGuestWindow;
	import wins.SimpleWindow;
	import wins.TowerWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Floors extends Share
	{
		public var kicksLimit:int = 0;
		public var floor:int = 0;
		public var totalFloors:int = 0;
		
		public static const ONE_SIDE_KICK:int = 0;
		public static const TWO_SIDE_KICK:int = 1;
		
		public static const BURST_ALWAYS:int = 0;
		public static const BURST_ONLY_ON_COMPLETE:int = 1;
		public static const BURST_NEVER:int = 2;
		 
		public function Floors(settings:Object)
		{
			gloweble = false;
			floor = settings.floor || 0;
			if (floor == -1)
				settings['area'] = { w:4, h:4 };
			
			super(settings);
			
			for (var flr:* in info.tower) {
				//if (!(flr is Number)) continue;
				totalFloors++;
			}
			
			//craftLevels = totalFloors;
			craftLevels = totalLevels;
			
			kicksLimit = info.tower[totalFloors].c;
			
			if (floor == -1){
				changeOnDecor();
				return;
			}
			
			if (formed && textures)
				beginAnimation();
			
			clickable = true;
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST && level < totalLevels) {
				new SimpleWindow( {
					title:title,
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1409298573436')
				}).show();
				return true;
			}
			
			if (!clickable || id == 0) return false;
			if (floor > totalFloors) return true;
			
			if (!isReadyToWork()) return true;
			
			if(App.user.mode == User.OWNER){
				if (isPresent()) return true;
			}
			
			if (level < totalLevels) {
				if(App.user.mode == User.OWNER){
					//new BuildingConstructWindow({
						//title:info.title,
						//level:Number(level),
						//totalLevels:Number(totalLevels),
						//devels:info.devel[level+1],
						//bonus:info.bonus,
						//target:this,
						//upgradeCallback:upgradeEvent
					//}).show();
					new ConstructWindow( {
						title			:info.title,
						upgTime			:info.devel.req[level + 1].t,
						request			:info.devel.obj[level + 1],
						target			:this,
						onUpgrade		:upgradeEvent,
						hasDescription	:true
					}).show();
				}
			}
			else
			{
				if (App.user.mode == User.OWNER)
				{
					new TowerWindow({
						target:this,
						storageEvent:storageAction,
						upgradeEvent:growEvent,
						buyKicks:buyKicks
					}).show();
				}
				else
				{
					if (hasPresent) {
						new SimpleWindow( {
							title:title,
							label:SimpleWindow.ATTENTION,
							text:Locale.__e('flash:1409297890960')
						}).show();
						return true;
					}
					
					if (info.tower[floor + 1] == undefined) 
					{
						var text:String = Locale.__e('flash:1382952379909',[info.title]);
						var title:String = Locale.__e('flash:1382952379908');
						if (info.burst == BURST_NEVER) 
						{
							text = Locale.__e('flash:1384786087977', [info.title]);
							title = Locale.__e('flash:1384786294369');
						}
						// Больше стучать нельзя
						new SimpleWindow( {
							title:title,
							label:SimpleWindow.ATTENTION,
							text:text
						}).show();
						return true;
					}
					
					if (kicks >= info.tower[floor+1].c)
					{
						// Больше стучать нельзя
						new SimpleWindow( {
							label:SimpleWindow.ATTENTION,
							title:Locale.__e('flash:1382952379908'),
							text:Locale.__e('flash:1382952379910',[info.title])
						}).show();
					}
					else
					{
						new ShareGuestWindow({
							target:this,
							kickEvent:kickEvent
						}).show();
					}
				}
			}
			
			return true;
		}
		
		public function growEvent(params:Object):void 
		{
			gloweble = true;
			var self:Floors = this;
			//flag = false;
			
			Post.send( {
				ctr:this.type,
				act:'grow',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				guests = { };
				floor = data.floor;
				updateLevel(true);
				
				if(data.hasOwnProperty('bonus'))
					Treasures.bonus(data.bonus, new Point(self.x, self.y));
			});
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void {
			
			if (!textures) return;
			var levelData:Object
			if(this.floor == 0)
				levelData = textures.sprites[this.level];
			else
				levelData = textures.sprites[this.floor + this.level];
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (floor == -1 || ((level + floor) > (totalLevels + totalFloors) && animationBitmap == null && totalFloors != 0)){
				initAnimation();
				beginAnimation();
			}
		}
		
		override public function beginAnimation():void
		{
			startAnimation(true);
				
			if (info.view == 'cauldron') {
				if(level >= totalLevels)
					startSmoke();
			}	
		}
		
		public function buyKicks(params:Object):void {
			
			var callback:Function = params.callback;
			
			Post.send( {
				ctr:this.type,
				act:'boost',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (data.hasOwnProperty(Stock.FANT))
					App.user.stock.put(Stock.FANT, data[Stock.FANT]);
				
				kicks = data.kicks;
				//flag = Cloud.TRIBUTE;
				callback();
			});
		}
		
		override public function onLoad(data:*):void
		{
			if (data.hasOwnProperty('animation'))
			{
				for (var type:* in data.animation.animations)
				{
					if (data.animation.animations[type].hasOwnProperty('pause')) 
					{
						var length:int = int(data.animation.animations[type].pause * Math.random());
						var chain:Array = data.animation.animations[type].chain;
						//var lastFrame:int = chain.pop();
						for (var i:int = 0; i < length; i++) 
						{
							chain.push(0);
						}
					}
				}
			}	
			
			super.onLoad(data);
			/*setCloudPosition(18, -58);
			touchableInGuest = true;
			flag = false;
			
			if (App.user.mode == User.GUEST) {
				touchableInGuest = true;
				flag = false;
				if(level == totalLevels){
					if (info.tower[floor + 1] != undefined) {
						flag = Cloud.HAND;
						if (kicks < info.tower[floor + 1].c){
							flag = Cloud.PICK;
						}
					}	
				}
			}
			else
			{
				flag = Cloud.TRIBUTE;
				if (floor > totalFloors || floor<0)
					flag = false;
					
				if (info.tower[floor + 1] != undefined){
					if (kicks < info.tower[floor + 1].c)
						flag = false;
				}
				else {
					if(level == totalLevels){
						if (info.tower[floor + 1] != undefined) {
							flag = false;
							if (kicks < info.tower[floor + 1].c){
								flag = Cloud.TRIBUTE;
							}
						}	
					}
				}
				
				if(hasPresent)
					setFlag("hand", isPresent, { target:this, roundBg:false, addGlow:false } );
			}*/
		}
		
		
		override public function storageAction(boost:uint, callback:Function):void {
			
			var self:Share = this;
			var sendObject:Object = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}
				
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				callback(Stock.FANT, boost);
				
				if (data.hasOwnProperty(Stock.FANT))
					App.user.stock.data[Stock.FANT] = data[Stock.FANT];
				
				if (data.hasOwnProperty('bonus'))
					Treasures.packageBonus(data.bonus, new Point(self.x, self.y));
				
				if (info.burst == BURST_ONLY_ON_COMPLETE)
				{
					free();
					changeOnDecor();
					take();
				}else{
					uninstall();
				}
				
				self = null;
			});
		}
		
		private function changeOnDecor():void 
		{
			floor = totalFloors + 1;
			if(textures && textures.sprites[level + floor]){
				var levelData:Object = textures.sprites[level + floor];
				draw(levelData.bmp, levelData.dx, levelData.dy);
			}
			
			initAnimation();
			beginAnimation();
		}
		
		override public function refresh():void {
			//touchableInGuest = false;
		}
		
		override public function setCraftLevels():void
		{
			craftLevels = totalLevels;
			//craftLevels = totalFloors;
		}
		
		override public function set touch(touch:Boolean):void {
			if(floor >totalFloors){
				if (Cursor.type == 'default') {
					return;
				}
			}
			super.touch = touch;
		}
	}
}