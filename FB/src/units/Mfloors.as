package units
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.UnitIcon;
	import wins.ConstructWindow;
	import wins.ShareGuestWindow;
	import wins.SimpleWindow;
	import wins.TowerWindow;
	import wins.TowerWindowTwo;

	public class Mfloors extends Building
	{
		public var guests:Object;
		public var kicks:uint;
		public var burst:int = 0;
		public var kicksLimit:int = 0;
		public var floor:int = 0;
		public var totalFloors:int = 0;
		
		public static const ONE_SIDE_KICK:int = 0;
		public static const TWO_SIDE_KICK:int = 1;		
		public static const BURST_ALWAYS:int = 0;
		public static const BURST_ONLY_ON_COMPLETE:int = 1;
		public static const BURST_NEVER:int = 2;
		
		public static const HORN_SMALL:int = 1650;
		public static const HORN_BIG:int = 1651;
		public static const LOVE_TREE:int = 2095;
		public static const LOVE_TREE_BIG:int = 2094;
		public static const TENTACLES_ARRAY:Array = [2351, 2352, 2353, 2354, 2355, 2356, 2357, 2358];
		 
		public function Mfloors(settings:Object)
		{
			super(settings);
			guests = settings.guests || { };
			gloweble = false;
			floor = settings.floor || 0;
			kicks = settings.kicks || 0;
			
			if (settings.hasOwnProperty('level')&&settings['level'] == 0) 
			{
				settings['level'] = App.data.storage[settings.sid].start;	
			}
			
			level = App.data.storage[settings.sid].start;
			totalFloors = Numbers.countProps(info.tower);
			craftLevels = totalLevels;
			kicksLimit = info.tower[totalFloors].c;
			
			if (floor == -1)
			{
				changeOnDecor();
				return;
			}
			
			if (formed && textures)
			{				
				beginAnimation();
			}
			
			clickable = true;
		}
		
		override public function showIcon():void 
		{
			
			if (needQuest != 0 && !App.user.quests.data.hasOwnProperty(needQuest) && App.user.mode == User.OWNER)
				return;
			
			if (!formed || !open) 
				return;
				
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
				coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
			}else{
				if (App.data.storage[sid].hasOwnProperty('cloudoffset') && 
				(App.data.storage[sid]['cloudoffset'].dx != 0 || App.data.storage[sid]['cloudoffset'].dy != 0))
				{
					coordsCloud.x = App.data.storage[sid]['cloudoffset'].dx;
					coordsCloud.y = App.data.storage[sid]['cloudoffset'].dy;
				}else{
					coordsCloud.x = 0;
					coordsCloud.y = -20;
				}
			}
			
			if (App.user.mode == User.OWNER) 
			{
				var min:int = Numbers.firstProp(info.mkicks).val['k'];
				var material:int = Numbers.firstProp(info.mkicks).key;
				for (var mat:* in info.mkicks){
					if (info.mkicks[mat].k < min)
					{
						min = info.mkicks[mat].k;
						material = mat;
					}
				}
				if (info.tower[floor + 1] != undefined && kicks < info.tower[floor + 1].c)
				{
					if (TENTACLES_ARRAY.indexOf(this.sid) != -1)
						return;
					drawIcon(UnitIcon.REWARD, material, 1, {
						glow:		false,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
					
				}else 
				if (info.tower[floor + 1] == undefined) 
				{
					drawIcon(UnitIcon.REWARD, 1071, 1, {
						glow:		false,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
					
				}else{
					
					drawIcon(UnitIcon.REWARD, material, 1, {
						glow:		false,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
				}
			}
			else if (App.user.mode == User.GUEST) 
			{
				if (Friends.isOwnerSleeping(App.owner.id) && App.owner.id != '1') {
					clickable = false;
					return;
				} 
				
				if (level >= totalLevels)
				{
					drawIcon(UnitIcon.REWARD, 1277, 1, {
						glow:		false,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else
					clearIcon();
				
			}
			checkGlowing();
		}
		
		override public function click():Boolean 
		{
			if (locked)
			{
				new SimpleWindow( {
					title:Locale.__e("flash:1474469531767"),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1515744653670', App.data.storage[info.locked].title),
					confirm:function():void
					{
						App.map.focusedOn(Map.findUnits([info.locked])[0], false);
						Map.findUnits([info.locked])[0].showPointing('top', -65, -160);
						setTimeout(function():void 
						{
							Map.findUnits([info.locked])[0].hidePointing();
						}, 3000);
						
					}
				}).show();
				return false;
			}
			if (App.user.mode == User.GUEST && level < totalLevels) 
			{
				new SimpleWindow( {
					title:title,
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1409298573436')
				}).show();
				return true;
			}
			
			if (App.user.useSectors)
			{
				var nodes:Array = [];
				var openedFromSector:Boolean = false;
				if (this.info.area.w > 6 && this.info.area.h > 6)
				{
					nodes.push(App.map._aStarNodes[this.coords.x][this.coords.z + int(info.area.h / 2)]);
					nodes.push(App.map._aStarNodes[this.coords.x + int(info.area.w / 2)][this.coords.z]);
					nodes.push(App.map._aStarNodes[this.coords.x + info.area.w-1][this.coords.z + int(info.area.h / 2)]);
					nodes.push(App.map._aStarNodes[this.coords.x + int(info.area.w / 2)][this.coords.z + info.area.h - 1]);
				}
				else{
					nodes.push(App.map._aStarNodes[this.coords.x][this.coords.z]);
				}
				for each(var _node:* in nodes)
				{
					if (_node.sector.open == true)
					{
						openedFromSector = true;
						break;
					}
				}
				//var node1:AStarNodeVO = App.map._aStarNodes[this.coords.x][this.coords.z];
				
				if (!openedFromSector)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1495607052980') + " " + info.title,
						confirm:function():void
						{
							for each(var _node:* in nodes)
							{
								_node.sector.fireNeiborsReses();
							}
						}
					}).show();
					return false;
				}
			}
			
			if (!clickable || id == 0) return false;
			if (floor > totalFloors) return true;			
			if (!isReadyToWork()) return true;
			
			if (App.user.mode == User.OWNER)
			{
				if (isPresent()) return true;
			}
			
			if (level < totalLevels) 
			{
				if (App.user.mode == User.OWNER)
				{					
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
					new TowerWindowTwo({
						target:this,
						storageEvent:storageAction,
						upgradeEvent:growEvent,
						buyKicks:buyKicks,
						mKickEvent:mKickEvent,
						itemsNum:4
					}).show();
				}
				else
				{
					if (hasPresent)
					{
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
							kickEvent:kickEvent,
							itemsNum:2
						}).show();
					}
				}
			}
			
			return true;
		}
		
		public function kickEvent(mID:uint, callback:Function, type:int = 1, _sendObject:Object = null):void {
			
			var item:Object = App.data.storage[mID];
			switch(type) {
				case 1:
					if (!App.user.friends.takeGuestEnergy(App.owner.id)) 
						return;
					break;
				case 2:
					if (!App.user.stock.take(Stock.FANT, item.price[Stock.FANT])) 
						return;
					break;
				case 3:
					if (!App.user.stock.take(mID, 1))
						return;
					break;
			}
			
			
			var sendObject:Object = {
				ctr:info.type,
				act:'kick',
				uID:App.owner.id,
				wID:App.owner.worldID,
				sID:this.sid,
				id:this.id,
				guest:App.user.id,
				mID:mID
			}
			
			if (_sendObject != null)
				for (var _item:* in _sendObject)
					sendObject[_item] = _sendObject[_item];
		
			Post.send(sendObject, onKickEvent, {callback:callback, type:type, mID:mID});
		}
		
		private function onKickEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			var self:Mfloors = this;
			params.callback();
			
			if (data.hasOwnProperty("energy") && data.energy > 0)
				App.user.friends.updateOne(App.owner.id, "energy", data.energy);
				
			if (data.hasOwnProperty('bonus'))
				Treasures.bonus(data.bonus, new Point(self.x, self.y));
				
			self = null;
			
			if (params.type == 1)
			{
				App.user.friends.giveGuestBonus(App.owner.id);
				guests[App.user.id] = App.time;	
			}
			
			kicks += info.kicks[params.mID].c;				
			if (data.hasOwnProperty('kicks'))
				kicks = data.kicks;
			
			refresh();
		}
		
		public function refresh():void {
			if (kicks >= info.count) {
				//flag = false;
				level = totalLevels +1;
				updateLevel();
				touchableInGuest = false;
			}
		}
		
		public function mKickEvent(mID:uint, callback:Function, type:int = 1, _sendObject:Object = null):void 
		{
			
			var item:Object = App.data.storage[mID];
			switch(type) {
				case 1:
					if (!App.user.friends.takeGuestEnergy(App.owner.id)) 
						return;
					break;
				case 2:
					if (!App.user.stock.take(Stock.FANT, item.price[Stock.FANT])) 
						return;
					break;
				case 3:
					if (!App.user.stock.take(mID, 1))
						return;
					break;
			}
			
			var self:Mfloors = this;
			var sendObject:Object = {
				ctr:info.type,
				act:'mkick',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				mID:mID
			}
			
			if (_sendObject != null)
				for (var _item:* in _sendObject)
					sendObject[_item] = _sendObject[_item];
			
			Post.send(sendObject, onmKickEvent, {callback:callback, type:type, mID:mID});
		}
		
		private function onmKickEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				
				Errors.show(error, data);
				return;
			}
			var self:Mfloors = this;
			params.callback();
			
			if (data.hasOwnProperty("energy") && data.energy > 0)
				App.user.friends.updateOne(App.owner.id, "energy", data.energy);
				
			if (data.hasOwnProperty('bonus'))
				Treasures.bonus(data.bonus, new Point(self.x, self.y));
				
			self = null;
			
			if (params.type == 1)
			{
				App.user.friends.giveGuestBonus(App.owner.id);
				guests[App.user.id] = App.time;	
			}
			
			kicks += info.mkicks[params.mID].c;
			
			
			if (data.hasOwnProperty('kicks'))
				kicks = data.kicks;
			
			refresh();
		}
		
		public function growEvent(params:Object):void 
		{
			gloweble = true;
			var self:Mfloors = this;
			
			Post.send( {
				ctr:this.type,
				act:'grow',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},function(error:int, data:Object, params:Object):void {
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
				guests = { };
				floor = data.floor;
				load();
				
				if (data.hasOwnProperty('bonus'))
				{
					Treasures.bonus(data.bonus, new Point(self.x, self.y));
				}
			});
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void 
		{
			if (!textures) return;
			
			var levelData:Object;
			var smaller:int = 0;
			if (floor < 0) {
				totalFloors = Numbers.countProps(info.tower);
				floor = 1;
			}
			while (!textures.sprites[level + floor + smaller]) smaller--;
			levelData = textures.sprites[level + floor + smaller];
			
			if (checkRotate && rotate == true) 
			{
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
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void 
				{
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			initAnimation();
			beginAnimation();
		}
		
		//private var view:String;
		override public function load(hasReset:Boolean = false):void {
			if (textures) {
				stopAnimation();
				//clearTextures();
			}
			
			view = info.view;
			if (info.hasOwnProperty('start') && level == 0) {
				level = info.start;
			}
			
			if (info.hasOwnProperty('tower') && info.tower.hasOwnProperty(this.floor+1)) 
			{
				var viewLevel:int = this.floor + 1;
				while (true) 
				{
					if (info.tower[viewLevel].hasOwnProperty('v') && String(info.tower[viewLevel].v).length > 0) 
					{
						if (info.tower[viewLevel].v == '0') 
						{
							if (viewLevel > 0) 
							{
								viewLevel --;
							}
							else 
							{
								break;
							}
						} 
						else 
						{
							view = info.tower[viewLevel].v;
							break;
						}
					}
					else if (viewLevel > 0) 
					{
						viewLevel --;
					}
					else 
					{
						break;
					}
				}
			}else{
				if (info.hasOwnProperty('tower') && info.tower.hasOwnProperty(this.floor) && this.floor >= Numbers.countProps(info.tower)) 
				{
					view = info.tower[this.floor].v;
				}
			}
			
			Load.loading(Config.getSwf(type, view), onLoad);
		}
		
		override public function beginAnimation():void
		{
			startAnimation(true);
			
			if (info.view == 'cauldron') {
				if (level >= totalLevels)
				{					
					startSmoke();
				}
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
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
				
				if (data.hasOwnProperty(Stock.FANT))
				{					
					App.user.stock.put(Stock.FANT, data[Stock.FANT]);
				}
				
				kicks = data.kicks;
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
						for (var i:int = 0; i < length; i++) 
						{
							chain.push(0);
						}
					}
				}
			}	
			
			super.onLoad(data);
			if (level == totalLevels)
				touchableInGuest = true;
				
			if (kicks >= info.count){
				level ++;
				updateLevel();
				
				if (App.user.mode == User.OWNER){
					//flag = "hand"; 
				}else
					touchableInGuest = false;
			}else{
			}
			
			//Load.clearCache(Config.getSwf(this.type, view));
			//data = null;
		}		
		
		public function storageAction(boost:uint, callback:Function):void {
			
			var self:Mfloors = this;
			var sendObject:Object = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}
			
			Post.send(sendObject,onStorageAction, {callback:callback, boost:boost});
		}
		
		private function onStorageAction(e:int, data:Object, params:Object):void{
			if (e) 
			{
				Errors.show(e, data);
				return;
			}
			
			params.callback(Stock.FANT, params.boost);
			
			if (data.hasOwnProperty(Stock.FANT))
				App.user.stock.data[Stock.FANT] = data[Stock.FANT];
			
			if (data.hasOwnProperty('bonus'))
			{
				for (var materOnSt:* in data.bonus)
				{
					App.user.stock.add(materOnSt, Numbers.firstProp(data.bonus[materOnSt]).key * Numbers.firstProp(data.bonus[materOnSt]).val, true);
				}
				
				var matSID:int = Numbers.firstProp(data.bonus).key
				var place:Boolean = false;
				for (var mater:* in data.bonus)
				{
					if (App.data.storage[mater].type == 'Walkgolden' || App.data.storage[mater].type == 'Golden' || App.data.storage[mater].type == 'Animal' || App.data.storage[mater].mtype == 6)
					{
						matSID = mater;
						break;
					}
					if (App.data.storage[mater].mtype != 3 && (App.data.storage[matSID].type != 'Walkgolden' || App.data.storage[matSID].type != 'Golden'))
						matSID = mater;
				}
				
				Treasures.wauEffect(matSID);
				
			}
		
			
			if (info.burst == BURST_ONLY_ON_COMPLETE)
			{	
				removable = true;
				free();
				changeOnDecor();
				take();
			}else{
			
				uninstall();
			}
		}
		
		private function changeOnDecor():void 
		{
			uninstall();
			
		}
		
		override public function setCraftLevels():void
		{
			craftLevels = totalLevels;
		}
		
		private function get locked():Boolean
		{
			if (info.hasOwnProperty('locked') && info.locked != "" && Map.findUnits([info.locked]).length > 0)
				return true;
			else
				return false;
		}
		
		override public function set touch(touch:Boolean):void 
		{
			if (floor > totalFloors)
			{
				if (Cursor.type == 'default') {
					return;
				}
			}
			super.touch = touch;
		}
		
		/*override public function putAction():void 
		{
			if (level < totalLevels || floor <= totalFloors) return;
			super.putAction();
		}

		override public function set touch(touch:Boolean):void 
		{
			if (floor <= totalFloors && Cursor.type == 'stock') {
				return;
			}
			if (floor > totalFloors && Cursor.type == 'default') {
				return;
			}   
			super.touch = touch;
		}*/
	}
}