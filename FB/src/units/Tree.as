package units 
{
	import api.ExternalApi;
	import com.greensock.TweenLite;
	import core.Load;
	import core.MD5;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import strings.Strings;
	import ui.Cursor;
	import ui.Hints;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import units.unitEvent.UnitEvent;
	import utils.UnitsHelper;
	import wins.EventWindow;
	import wins.NeedResWindow;
	import wins.SpeedWindow;
	import wins.TreeGuestWindow;
	import wins.TreeWindow;
	import wins.Window;
	
	public class Tree extends Tribute
	{
		public var _free:Object;
		public var _paid:Object;
		public var times:uint = 1;
		
		public var input:Object = {};
		public var output:Object = {};
		public var viewLevel:int = 1;
		public var kick:int = 0;
		
		override public function get started():int 
		{
			return super.started;
		}
		
		override public function set started(value:int):void 
		{
			super.started = value;
		}
		
		public function Tree(object:Object)
		{
			info = App.data.storage[object.sid];
			
			//times = object.times;
			viewLevel = object.animal || 1;
			kick = object.times || 0;
			object.crafted = object.started;
			
			//info['area'] = { w:2, h:2 };
			init();
			
			super(object);
			
			started = object.started;
			checkState();
			showIcon();
			
			clickable = true;
			multiple = true;
			
			
		}
		
		override public function load(hasReset:Boolean = false):void {
			var view:String = info.view;
			try {
				view = info.devel.req[viewLevel].v;
			}catch(e:*) {}
			
			if (textures && animated) {
				stopAnimation(); 
				//clearTextures();
			}
			if (App.user.mode == User.GUEST)
			{
				var hash:String = MD5.encrypt(Config.getSwf(type, info.view));
				if ((Load.cache[hash] != undefined && Load.cache[hash].status == 3) || !open) {
					Load.loading(Config.getSwf(type, info.view), onLoad);
				}else{
					if(SystemPanel.noload)
						clearBmaps = true;
					Load.loading(Config.getSwf(type, info.view), onLoad);
					//onLoad(UnitsHelper.bTexture);
				}
			}else
				Load.loading(Config.getSwf(info.type, view), onLoad);
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			var view:String = info.view;
			try {
				view = info.devel.req[viewLevel].v;
			}catch (e:*) {}
			if(clearBmaps){
				Load.clearCache(Config.getSwf(info.type, view));
				data = null;
			}
		}
		
		override public function get tribute():Boolean {
			if (started > 0 && started + time <= App.time)
				return true;
			
			return false;
		}
		
		override public function work():void 
		{
			if (App.time >= started + time) 
			{
				App.self.setOffTimer(work);
				checkState();
			}
		}
		
		override public function init():void 
		{	
			if (info.hasOwnProperty('devel')) {
				if (info.devel.hasOwnProperty('obj'))
					input = info.devel.obj;
					
				if (info.devel.hasOwnProperty('rew'))
					output = info.devel.rew;
			}
			else
			{
				input = info["in"];
				output = {(int(Numbers.getProp(info["out"],Numbers.countProps(info["out"])-1).key)):Numbers.getProp(info["out"],Numbers.countProps(info["out"])-1).val}
			}
			
			showIcon();
			
			if (App.user.mode == User.OWNER) 
			{
				if (started > 0 && !tribute)
				{
					App.self.setOnTimer(work);
				}
			}
			else 
			{
				if (started > 0 && App.time > started + time) 
				{
					touchableInGuest = false;
					return;
				}
				
				if (kicks > 0) 
				{
					touchableInGuest = true;
					return;
				}
			}
			
			//flag = null;
			tip = function():Object {
				
				if (tribute)
				{
					return {
						title:info.title,
						text: Locale.__e('flash:1382952379960', [kick, kicks]) + "\n" + Locale.__e("flash:1488193073435")
					};
				}
				
				if (started > 0)
				{
					return {
						title:info.title,
						timerText:TimeConverter.timeToCuts((started + time) - App.time, true, true),
						text:Locale.__e('flash:1382952379960', [kick, kicks]) + "\n" + Locale.__e('flash:1488193048644'),
						timer:true
					};
				}
				
				return {
					title:info.title,
					text:Locale.__e('flash:1382952379960', [kick, kicks]) + "\n" + Locale.__e("flash:1488193093076")
				};
			}
		}
		
		override public function click():Boolean {
			if (!clickable) 
				return false;
			
			if (tribute) 
			{
				if (App.user.mode == User.OWNER) 
				{
					if (App.user.addTarget({
						target:this,
						near:true,
						callback:storageEvent,
						event:Personage.HARVEST,
						jobPosition:getContactPosition(),
						shortcutCheck:true
					})) {
						ordered = true;
					}
				}
			} 
			else 
			{
				if (App.user.mode == User.OWNER) 
				{
					if (!tribute && started == 0) 
					{
						showEventWindow();
					} 
					else 
					{
						new SpeedWindow( {
							title		:info.title,
							target		:this,
							info		:info,
							finishTime	:started + time,
							totalTime	:time,
							priceSpeed	:boostPrice,
							doBoost		:onBoostEvent
						}).show();
					}
				}
			}
			
			return true;
		}
		
		override public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, boostPrice)) 
			{
				var that:Tribute = this;
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) 
					{
						started = data.started;
						App.ui.flashGlowing(that);
						checkState();
					}
				});	
			}
		}
		
		public override function storageEvent():void
		{
			if (App.user.mode == User.OWNER) 
			{	
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onStorageEvent);
			} 
			else 
			{
				if(App.user.friends.takeGuestEnergy(App.owner.id)){
					Post.send({
						ctr:this.type,
						act:'gueststorage',
						uID:App.owner.id,
						id:this.id,
						wID:App.owner.worldID,
						sID:this.sid,
						guest:App.user.id
					}, onStorageEvent, {guest:true});
				} else {
					Hints.text(Locale.__e('flash:1382952379907'), Hints.TEXT_RED,  new Point(App.map.scaleX*(x + width / 2) + App.map.x, y*App.map.scaleY + App.map.y));
					App.user.onStopEvent();
					return;					
				}
			}
			
			started = 0;
			checkState();
			App.self.setOffTimer(work);
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void 
		{	
			ordered = false;
			super.onStorageEvent(error, data, params);
			started = 0;
			
			if (data["times"])
			{
				kick = data.times;
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
			}
			
			showIcon();
			
			//if (data.bonus) 
			//{
				////Treasures.bonus(Treasures.convert(data.bonus), new Point(this.x, this.y));
			//}
			
			if (App.data.storage[this.sid].out) 
			{
				Treasures.bonus(Treasures.convert(App.data.storage[this.sid].out), new Point(this.x, this.y));
			}
			
			if (kick >=  kicks)
			{
				uninstall();
			}
			
			if (data['soul'] && data.soul['sid'] && App.data.storage.hasOwnProperty(data.soul.sid)) 
			{
				App.self.setOffTimer(work);
				uninstall();
				
				var unit:Unit = Unit.add(data.soul);
				unit.install();
			}
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void 
		{
			if (textures == null) 
				return;
			
			var levelData:Object = textures.sprites[level];
			if (!levelData) {
				var _level:int = level;
				while (textures.sprites[_level] == null || _level <= 0) {
					_level--;
				}
				levelData = textures.sprites[_level];
			}
			
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
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}, onUpdate:function():void {
					backBitmap.alpha = 1 - bitmap.alpha;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			checkOnAnimationInit();
		}
		
		override public function set state(state:uint):void {
			if (_state == state) 
				return;
			
			switch(state) {
				case OCCUPIED: this.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: this.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: 
					this.filters = [new GlowFilter(0xFFFF00, 1, 6, 6, 7)];
					
					if (Cursor.type == 'default' && tribute) {
						Cursor.type = 'default_small';
						//Cursor.image = Cursor.BACKET;
					}
					break;
				case HIGHLIGHTED: this.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: this.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT:
					this.filters = [];
					
					if (Cursor.type == 'default_small') {
						Cursor.type = 'default';
						//Cursor.image = null;
					}
					break;
			}
			_state = state;
		}
		
		override public function addAnimation():void
		{
			ax = textures.animation.ax;
			ay = textures.animation.ay;
			animationBitmap = new Bitmap();
			addChildAt(animationBitmap, 0);
			addChildAt(bitmap, 0);
		}
		
		private function getPosition():Object
		{
			var Y:int = -1;
			if (coords.z + Y <= 0)
				Y = 0;
			
			return { x:int(info.area.w / 2), y: Y };
		}
		
		
		private function showEventWindow():void {
			if (!formed) 
				uninstall();
			
			if (App.user.stock.checkAll(input)) 
			{
				onWater();
			}
			else
			{
				new NeedResWindow( {
					title:Locale.__e("flash:1435241453649"),
					text:Locale.__e('flash:1489059046572'),
					//text2:Locale.__e('flash:1435244772073'),
					height:230,
					neededItems: App.data.storage[sid]['in'],
					button3:true,
					button2:true
				}).show()
				/*new EventWindow( {
					target:this,
					//sIDs:input[viewLevel],
					sIDs:input,
					description:Locale.__e('flash:1382952379963'),
					onWater:onWater
				} ).show();*/
			}
		}
		
		private function onWater():void 
		{
			waterEvent();
		}
		
		
		private var requestBlock:Boolean = false;
		public function waterEvent():void {
			
			var that:* = this;
			
			/*if (!App.user.stock.checkAll(input, true)) {
				App.user.onStopEvent();
				showEventWindow();
				return;
			}*/
			
			if (App.user.stock.takeAll(input)) {
				
				if (requestBlock) return;
				requestBlock = true;
				if (icon) icon.block = true;
				
				Post.send({
					ctr:this.type,
					act:'water',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					requestBlock = false;
					ordered = false;
					
					if (icon) 
						icon.block = false;
					
					if (error) 
					{
						Errors.show(error, data);
						return;
					}
					
					dispatchEvent(new UnitEvent(UnitEvent.TREE_WATERED));
					
					App.ui.flashGlowing(that, 0xFFFF00);
					started = data.started;
					App.self.setOnTimer(work);
					checkState();
				});
			}
		}
		
		public function alwaysKick(uid:*):Boolean {
			for (var s:String in _free) 
			{
				if (String(uid) == _free[s])
					return true;
			}
			
			return false;
		}
		public function setKick(uid:*):void 
		{
			_free[uid] = App.user.id;
		}
		
		public function checkState():void 
		{
			if (started > 0 && started + time <= App.time) 
			{
				if (level != 2) 
				{
					level = 2;
					updateLevel();
				}
			}
			else if (started > 0 && started + time > App.time) 
			{
				if (level != 1) 
				{
					level = 1;
					updateLevel();
				}
			}
			else 
			{
				if (level != 0) 
				{
					level = 0;
					updateLevel();
				}
			}
			showIcon();
		}
		
		override public function showIcon():void 
		{
			if (App.user.mode == User.GUEST) 
				return;
			
			if (started > 0 && started + time > App.time) 
			{
				drawIcon(UnitIcon.PRODUCTION, output, 0, 
				{
					iconScale:	0.7,
					progressBegin:	started,
					progressEnd:	started + time
				}, 0, 0, -140);
			}
			else if (started > 0 && started + time <= App.time) 
			{
				drawIcon(UnitIcon.REWARD, output, 0, {
					//glow:		true,
					iconScale:	1,
					multiclick:		true
				}, 0, 0, -140);
			}
			else 
			{
				drawIcon(UnitIcon.MATERIAL, input, 0, {
					stocklisten:	true,
					iconScale:		0.7,
					multiclick:		true
				}, 0, 0, -140);
			}
		}
		
		public function sendInvite(fID:String):void
		{
			//Пост на стену
			var message:String = Strings.__e('Tree_makePost', [Config.appUrl]);
			
			var scale:Number = 0.8;
			var bitmapData:BitmapData = textures.sprites[1].bmp;
			
			var bmp:Bitmap = new Bitmap(bitmapData);
			bmp.scaleX = bmp.scaleY = scale;
			var bmd:BitmapData = new BitmapData(bmp.width, bmp.height);
			var cont:Sprite = new Sprite();
			cont.addChild(bmp);
			bmp.smoothing = true;
			bmd.draw(cont);
			
			var _bitmap:Bitmap = new Bitmap(Gifts.generateGiftPost(new Bitmap(bmd), -30));
			
			if (_bitmap != null) 
			{
				ExternalApi.apiWallPostEvent(ExternalApi.OTHER, _bitmap, String(fID), message, sid);
			}
			//End Пост на стену
		}
		
		public function sendKickPost(fID:String, bmp:Bitmap):void
		{
			//Пост на стену
			var message:String = Locale.__e("flash:1382952379965", [Config.appUrl]);
			var _bitmap:Bitmap = new Bitmap(Gifts.generateGiftPost(bmp));
			
			//App.self.addChild(_bitmap);
			
			if (_bitmap != null) {
				ExternalApi.apiWallPostEvent(ExternalApi.OTHER, _bitmap, String(fID), message, sid);
			}
			//End Пост на стену
		}
		
		public function get time():int 
		{			
			return info.time;
		}
		
		public function get kicks():int 
		{	
			return info.capacity;
		}
		
		public function get boostPrice():int 
		{	
			return info.speedup;
		}
		
		override public function set alpha(value:Number):void 
		{
			if (icon) 
				icon.alpha = value;
			super.alpha = value;
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			hasPresent = false;
			started = 0;
			fromStock = false;
			
		}
		
		override public function isPresent():Boolean 
		{
			return false;
		}
		
		override public function finishUpgrade():void {}
	}
}
