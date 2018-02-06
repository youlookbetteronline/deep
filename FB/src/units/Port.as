package units 
{
	import api.ExternalApi;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.Cloud;
	import wins.ConstructWindow;
	import wins.DiverHouseWindow;
	import wins.SimpleWindow;
	import wins.TravelWindow;
	import wins.WindowEvent;
	
	public class Port extends Building 
	{		
		public static var inited:Boolean = false;
		public static var shipID:int = 1948;
		public static var openMinimaps:Array = [];
		public static var ports:Object = { };
		
		public static const AQUA_HOME:int = 820;
		public static const DOOR:int = 823;
		public static const ALTAR_OF_LIGHT:int = 937;		
		public static const FROZEN_ARCH:int = 2064;	
		public static const LAZURE_PORT:int = 2871;
		public static const CAVE:int = 3714;
		
		public var ship:Ship;
		public var timerClick:uint;
		public var miniWorldUnits:Object;
		
		public function Port(object:Object) 
		{
			stockable = true;
			super(object);
			moveable = true;
			rotateable = true;
			touchable = true;
			this.flag = false;
			init();
			
			iconSetPosition();
		}
		
		private function getMiniWorldInfo():void 
		{
			if (App.user.worlds.hasOwnProperty(User.AQUA_HERO_LOCATION))
			{
				var postObject:Object = 
				{
					'ctr':'world',
					'act':'mini',
					'uID': App.user.id
				}
				
				postObject['wID'] = User.AQUA_HERO_LOCATION;				
				Post.send(postObject, onGetInfo);
			}
		}
		
		private function onGetInfo(error:*, data:*, params:*):void 
		{
			if (error) 
			{
				return;
			}
			
			var needIcon:Boolean = false;
			miniWorldUnits = data.units;
			
			for each (var unit:Object in miniWorldUnits)
			{
				if (['Golden', 'Tribute'].indexOf(App.data.storage[unit.sid].type) != -1)
				{
					if (unit.crafted <= App.time) 
					{
						needIcon = true;
					}
				}
			}
			
			if (needIcon) 
			{	
				if (Preloader != null) 
				{
					setFlag(Cloud.TRIBUTE, onTakeBonuses);
				}				
			}
		}
		
		private function onTakeBonuses():void
		{
			for each (var unit:Object in miniWorldUnits)
			{
				if (['Golden', 'Changeable'].indexOf(App.data.storage[unit.sid].type) != -1)
				{
					if (unit.crafted <= App.time)
					{
						Post.send({
							ctr:App.data.storage[unit.sid].type,
							act:'storage',
							uID:App.user.id,
							id:unit.id,
							wID:User.AQUA_HERO_LOCATION,
							sID:unit.sid
						}, onMiniStorageEvent);
					}
				}
			}
		}
		
		private function onMiniStorageEvent(error:int, data:Object, params:Object):void
		{
			flag = false;
			var notConvert:Boolean = false;
			
			for (var _sID:Object in data.bonus)
			{
				var sID:uint = Number(_sID);
				for (var _nominal:* in data.bonus[sID])
				{
					notConvert = true;
					break;
				}
			}
			
			if (notConvert) Treasures.bonus(data.bonus, new Point(this.x, this.y));
			else Treasures.bonus(Treasures.convert(data.bonus), new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
		}
		
		public function init():void 
		{
			if (!formed) return;
			
			if (buildFinished) 
			{
				initAnimation();
				startAnimation();
			}
			
			for (var lvl:* in info.instance.devel.open) 
			{
				if (int(lvl) <= level)
				{
					initAnimation();
					startAnimation();
					break;
				}
			}
			
			var portInfo:Object = App.user.storageRead('port', { } );
			
			if (portInfo is Array) 
			{
				var object:Object = { };
				
				for (var i:int = 0; i < portInfo.length; i++)
				{
					if (portInfo[i] != null && App.data.storage[i].type == 'Port')
						object[String(i)] = portInfo[i];
				}
				portInfo = object;
			}
			
			if (!portInfo.hasOwnProperty(sid) || portInfo[sid] != level) 
			{
				portInfo[String(sid)] = level;
				App.user.storageStore('port', portInfo, true);
			}		
			inited = true;	
		}
		
		override public function onLoad(data:*):void 
		{			
			totalLevels = Numbers.countProps(App.data.storage[this.sid].instance.devel[1].obj);
			super.onLoad(data);
			textures = data;
			
			if (info.sID == AQUA_HOME && App.user.worldID == 1437) 
			{
				getMiniWorldInfo();
			}
			if (clearBmaps)
			{
				var bType:String = type;
				var bView:String = view;
				if (skin)
				{
					bType = 'Skin';
					bView = skin;
				}
				Load.clearCache(Config.getSwf(bType, bView));
				data = null;
			}
		}
		
		override public function updateLevel(checkRotate:Boolean = false):void 
		{
            if (textures == null)
                return;
			
			var numInstance:uint = instanceNumber();
			
			var levelData:Object;
			
			if (this.level && 
				info.hasOwnProperty("instance") && 
				info.instance.hasOwnProperty("devel") && 
				info.instance.devel.hasOwnProperty(numInstance) && 
				info.instance.devel[numInstance].hasOwnProperty("req") &&
				info.instance.devel[numInstance].req.hasOwnProperty(this.level) &&
				info.instance.devel[numInstance].req[this.level].hasOwnProperty("s") &&
				textures.sprites[info.instance.devel[numInstance].req[this.level].s])
			{
				usedStage = info.instance.devel[numInstance].req[this.level].s;
			}
			else if (textures.sprites[this.level]) 
			{
				usedStage = this.level;
				if (!formed)
					usedStage = totalLevels;
			}
			
			levelData = textures.sprites[usedStage];
			
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
				
				App.ui.flashGlowing(this, 0xFFF000);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			if (!levelData)
			{
				levelData = textures.sprites[textures.sprites.length-1];
			}
			draw(levelData.bmp, levelData.dx, levelData.dy);
			if (level >= totalLevels) 
				addGround();
			
			checkOnAnimationInit();
			init();
		}
		
		override public function stockAction(params:Object = null):void 
		{
			if (!App.user.stock.check(sid)) 
			{
				return;
			}
			
			App.user.stock.take(sid, 1);
			
			Post.send( {
				ctr:this.type,
				act:'stock',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z,
				level:this.totalLevels
			}, onStockAction);
		}
		
		override public function openConstructWindow(openWindowAfterUpgrade:Boolean = true):Boolean 
		{
			if (_constructWindow != null)
				return true;
			
			if ((level < totalLevels) || (level < totalLevels))
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						var instanceNum:uint = instanceNumber();
						
						_constructWindow = new ConstructWindow( { // Bременно заменен истанс
							title:			info.title,
							upgTime:		info.instance.devel[1].req[level + 1].t,
							request:		info.instance.devel[1].obj[level + 1], //[instanceNum]
							reward:			info.instance.devel[1].rew[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true,
							popup:			false
						});
						
						_constructWindow.addEventListener(WindowEvent.ON_AFTER_CLOSE, onConstructWindowClose);
						_constructWindow.show();
						_openWindowAfterUpgrade = openWindowAfterUpgrade;
						
						return true;
					}
				}
			}
			return false;
		}
		
		override protected function tips():Object
		{
			return {
				title:info.title,
				text:info.description
			};
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST) 
			{
				return false;
			}
			
			var that:Port = this;
			
			if (!Config.admin && this.sid == 1366)
			{
				new SimpleWindow( {
				title:Locale.__e("flash:1474469531767"),
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1481899130563')
				}).show();
				return false;
			}
			
			
			if (buildFinished) 
			{
				if (this.sid != 820)
				{
					new TravelWindow().show();
					return false;
				}
				if (App.user.personages.length > 0)
				var place:Object = findPlaceNearTarget({info:{area:{w:this.cells, h:this.rows}}, coords:{x:coords.x, z:coords.z}}, 2, (App.user.worldID == 1388)? false :true);
				App.user.initPersonagesMove(place.x, place.z);
				if (App.user.id == '1')
				{
					World.openMap(827);
					Travel.goTo(827);
				}
				if (info.lands && info.lands.length > 0) 
				{
					if (this.sid == AQUA_HOME && App.user.worldID == User.LAND_2)
					{
						new DiverHouseWindow({
							target:this,
							confirm:function():void {
								World.openMap(info.lands[0]);
								Travel.goTo(info.lands[0]);
								
							},
							cancel:function():void {
								Travel.callbackFunction = function():void {
									var settings:Object = { sid:that.sid, fromStock:true };
									var unit:Unit = Unit.add(settings);
									unit.move = true;
									App.map.moved = unit;
								};
								that.putCallback = function():void{
									Travel.goTo(User.HOME_WORLD);
								};
								that.stockable = true;
								that.putAction();
							}
						}).show();
					}else{							
							World.openMap(info.lands[0]);
							Travel.goTo(info.lands[0]);
					}
					
				}else{
					new TravelWindow().show();
				}
			}
			
			if (!isReadyToWork()) return true;
			if (isBuilded()) return true;
			if (isPresent()) return true;
			if (info.sID != AQUA_HOME)
			{
				openProductionWindow();
			}
			
			return true;
		}
		
		override public function showIcon():void
		{
			if (!Config.admin &&(this.sid == 1366 || this.sid == 1244))
				return;
			if (App.user.mode == User.GUEST) 
			{	
				return;	
			}
			else
				super.showIcon();
		}
		
		override public function upgraded(hasReset:Boolean = false):void 
		{
			if (isUpgrade())
			{
				App.self.setOffTimer(upgraded);
				
				if (!hasUpgraded) 
				{
					updateLevel();
					instance = 1;
					created = App.time + info.devel.req[1].t;
					App.self.setOnTimer(build);
					addProgressBar();
					addEffect(Building.BUILD);
				}else{
					hasUpgraded = true;
					hasPresent = true;
					finishUpgrade();
					updateLevel();
					fireTechno(1);
					removeProgress();
					timerClick = setTimeout(function():void {
					clickable = true;
						if (level != totalLevels )
						{
							click();
						}else 
						{
							isPresent();
							if (buildFinished && info.sID == AQUA_HOME && App.user.worldID == 806)
							{
								World.openMap(User.AQUA_HERO_LOCATION);								
							}	
						}
					},1000);
				}				
			}
		}
		
		override public function onBuildComplete():void 
		{
			clickable = true;
			if (level == totalLevels && App.user.mode == User.OWNER)
			{
				if (App.social == 'FB') 
				{						
					ExternalApi.og('construct','building');
				}
			}
		}
		
		override public function openProductionWindow():void
		{
			if (!inited) return;
		}
		
		override public function isBuilded():Boolean 
		{
			if (level >= totalLevels ) 
			{
				return false;	
			}
			openConstructWindow();			
			return true;
		}
		
		override public function onRemoveAction(error:int, data:Object, params:Object):void
		{
			super.onRemoveAction(error, data, params);			
			var ports:Object = App.user.storageRead('port', { } );
			
			if (ports.hasOwnProperty(sid)) 
			{
				delete ports[sid];
				App.user.storageStore('port', ports, true);
				inited = false;
			}
		}		
	}
}