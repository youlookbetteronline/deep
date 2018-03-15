package units 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.IsoConvert;
	import core.Load;
	import core.MD5;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Cloud;
	import ui.CloudsMenu;
	import ui.SystemPanel;
	import ui.UnitIcon;
	import ui.UserInterface;
	import units.unitEvent.UnitEvent;
	import utils.Locker;
	import utils.UnitsHelper;
	import wins.ApothecaryWindow;
	import wins.BarterWindow;
	import wins.BuildingSkinWindow;
	import wins.CapsuleWindow;
	import wins.ConstructWindow;
	import wins.RecipePoolWindow;
	import wins.RecipeWindow;
	import wins.RewardWindow;
	import wins.ShopWindow;
	import wins.SpeedWindow;
	import wins.WindowEvent;
	import ui.Hints;
	import ui.Cursor;
	import wins.ProductionWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Building extends AUnit
	{
		public static const BUILD:String = 'build';
		public static const BOOST:String = 'boost';
		public static const ALWAYS_ANIMATED:Array = [183, 306, 500, 988, 1722, 1884, 1891, 1890, 1889, 1888, 2081, 2315, 2207, 2399, 2622, 2739, 2799, 2804, 2957, 3061, 3067, 3264, 3265, 3317, 3516];	// Постоянная анимация при окончании постройки
		
		public static const TRAVEL_COURTS:Array = [1679, 1685, 1686];	// Молянки для походной локи
		public static const CHANK_ARRAY:Array = [1687]
		
		public static const PET_CAGE_SID:int = 236;
		public static const GIRL_IN_TRAP_SID:int = 282;
		public static const CAPSULE:int = 500;
		public static const APOTHECARY:int = 602;
		public static const BARTER:int = 1078;
		private static const PERMANENT_ANIMATED:Array = [1837, 2887, 3211, 3252, 3266, 3317, 3397]
		public var pest:Pest;
		//public static pestAlive:Boolean = false;
		
		public static const NOT_TOUCHABLE_IN_GUEST:Array = [PET_CAGE_SID, GIRL_IN_TRAP_SID];
		
		private var _level:uint = 0;
		public function get level():uint 
		{
			return _level;
		}
		public function set level(value:uint):void 
		{			
			_level = value;
		}
		
		protected var _constructWindow:*;
		public function get constructWindow():ConstructWindow 
		{
			return _constructWindow;
		}
		
		/*private var _productionWindow:ProductionWindow;
		public function get productionWindow():ProductionWindow 
		{
			return _productionWindow;
		}*/
		
		private static var _freeBoostsFor:Array = [];
		static public function get freeBoostsFor():Array 
		{
			return _freeBoostsFor;
		}
		static public function set freeBoostsFor(value:Array):void 
		{
			_freeBoostsFor = value;
		}
		
		public var totalLevels:uint = 0;
		public var formula:Object;
		public var fID:uint			= 0;
		public var crafted:uint		= 0;
		public var instance:uint	= 1;
		public var needQuest:int	= 0;
		public var helpers:Object	= { };
		public var craftsLimit:Object	= { };
		
		public var hasProduct:Boolean = false;
		
		public var _crafting:Boolean = false;
		public var gloweble:Boolean = false;
		public var _cloud:CloudsMenu;
		
		public var hasBuilded:Boolean = false;
		public var hasUpgraded:Boolean = false;
		
		public var upgradedTime:int;
	
		public var hasPresent:Boolean = false;
		
		public var completed:Array = [];// Завершенные крафты
		public var began:int = 0;
		public var queue:Array = [];
		public var openedSlots:int;
		public var numInstance:uint;
		public var skin:String;
		public var booster:Booster;
		public var craftNeed:Object = null;
		
		public function Building(object:Object)
		{
			technos = [];
			if(layer == null)
				layer = Map.LAYER_SORT;
			
			helpers = object.helpers || { };
			
			if (object.hasOwnProperty('craftNeed'))
				craftNeed = object.craftNeed;
				
			if (object.hasOwnProperty('craftsLimit'))
				craftsLimit = object.craftsLimit;
				
			if (object.hasOwnProperty('skin'))
				skin = object.skin;
				
			if (object.hasOwnProperty('level'))
				level = object.level;
			else
				addEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			
			super(object);
			
			if (object.hasOwnProperty('pcount') && object.pcount == 0) 
			{
				if (info.pest.sid != "")
					addPest(info.pest.sid);
			}
			
			touchableInGuest = NOT_TOUCHABLE_IN_GUEST.indexOf(sid) == -1;
			
			
			setCraftLevels();
			
			if (info.type != 'Wigwam')
			{
				var numInstance:uint = instanceNumber();
				if (info.instance && info.instance.devel && info.instance.devel[numInstance] && info.instance.devel[numInstance].req) 
				{
					for each(var obj:* in info.instance.devel[numInstance].req)
					{
						totalLevels++;
					}
				}
			}
			if (info.type == 'Port')
			{
				totalLevels = Numbers.countProps(App.data.storage[this.sid].instance.devel[1].obj);
			}
			if (info.type == 'Mfloors')
			{
				totalLevels = Numbers.countProps(App.data.storage[this.sid].devel.obj);
			}
			
			if (object.sid == BARTER && !object.hasOwnProperty('buy')) // Недострой на острове
			{
				touchableInGuest = false;
				//level = 0;
				
				/*if (open)
				{
					level = 1;
				} else {
					App.self.addEventListener(AppEvent.ON_ZONE_OPEN, levelThisUp);
				}*/
				
				//cantClick = true;
				//flagable = false;
			}
			
			initProduction(object);
			
			if (object.hasOwnProperty("quest")) 
			{
				needQuest = object.quest;
			}
			
			if (this.sid == 1700)
			{
				needQuest = 414;
			}
			
			if (this.sid == 1722)
			{
				needQuest = 431;
			}
			
			if (object.hasOwnProperty("slots")) 
			{
				openedSlots = object.slots;
			}
			else 
			{
				for each(var slot:* in info.slots) 
				{
					if (slot.status == 1) 
					{
						openedSlots++;
					}
				}
			}
			
			upgradedTime = object.upgrade;
			created = object.created;
			
			if (formed) 
			{
				
				hasBuilded = true;
				hasUpgraded = true;
				
				if (upgradedTime > 0)
				{
					hasUpgraded = false;
					upgraded();
					if (!hasUpgraded) {
						App.self.setOnTimer(upgraded);
						addEffect(Building.BUILD);
					}	
				}
			}
			
			if (level < totalLevels)
				App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, changeIcon);
			
			load();
			if (!(object.hasOwnProperty('died') && object.died == 1))
				showIcon();
			
			tip = tips;
			
			/*if (!formed && info.base == 1) {
				showHelp(Locale.__e('flash:1435843230961'));
			}*/
			
			/*if (sid == 223)
			{
				removable = false;
			}
			
			if (sid == 540)
			{*/
				//removable = true;
				//moveable = true;
				//rotateable = true;
				//stockable = false;
			/*}*/
			if (this.sid == 2622)
				stockable = true;
		}
		/*private function maxInstance():uint
		{
			var numInstance:uint = instanceNumber();
				
			var iterator:int = 0;
			for (var dd:* in info.instance.devel)
			{
				iterator++;
			}			
			
			if (numInstance > iterator)
				numInstance = iterator;
				
			return numInstance
		}*/
		
		protected function tips():Object
		{
			if (App.user.mode == User.GUEST)
			{
				return {
					title:info.title,
					text:info.description
				};
			}
			
			var open:Boolean = App.map._aStarNodes[coords.x][coords.z].open;
			if (!open || !clickable || sid == PET_CAGE_SID || sid == GIRL_IN_TRAP_SID) 
			{
				return {
					title:info.title,
					text:info.description,
					timer:false
				};
			}
			else if (level < totalLevels)
			{
				return {
					title:info.title,
					text:Locale.__e("flash:1461569023187"),//Нажми чтобы достроить
					timer:false
				};
			}
			else if (hasProduct) 
			{
				var text:String = '';
				if (formula)
					text = App.data.storage[formula.out].title;
				
				return {
					title:info.title,
					text:Locale.__e("flash:1382952379845", [text]),
					timer:false
				};
			} 
			else if (created > 0 && !hasBuilded) 
			{
				return {
					title:info.title,
					text:Locale.__e('flash:1395412587100'),
					timerText:TimeConverter.timeToCuts(created - App.time, true, true),
					timer:true
				}
			} 
			else if (upgradedTime > 0 && !hasUpgraded) 
			{
				return {
					title:info.title,
					text:Locale.__e('flash:1395412562823'),
					timerText:TimeConverter.timeToCuts(upgradedTime - App.time, true, true),
					timer:true
				}
			} 
			else if (crafting) 
			{
				return {
					title:info.title,
					text:Locale.__e('flash:1395853416367'),
					timerText:TimeConverter.timeToCuts(crafted - App.time, true, true),
					timer:true
				}
			}
			
			var defText:String = '';
			var prevItm:String;
			if (this.info.type == 'Building') 
			{
				if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('craft')) {
					for (var itm:String in this.info.devel.craft[totalLevels]) {
						if (App.data.crafting[this.info.devel.craft[totalLevels][itm]])
						{
							if (prevItm && prevItm == App.data.storage[App.data.crafting[this.info.devel.craft[totalLevels][itm]].out].title) break;
							if (!User.inUpdate(App.data.crafting[this.info.devel.craft[totalLevels][itm]].out)) break;
							if (defText.length > 0) defText += ', ';
							defText += App.data.storage[App.data.crafting[this.info.devel.craft[totalLevels][itm]].out].title;
							prevItm = App.data.storage[App.data.crafting[this.info.devel.craft[totalLevels][itm]].out].title;
						}
					}
				}
			}
			
			if (defText.length > 0) 
			{
				return {
					title:info.title,
					text:Locale.__e('flash:1404823388967', [defText]),
					timer:false
				};
			} 
			else 
			{
				return {
					title:info.title,
					text:info.description
				};
			}
			
		}
		
		private static const sizes:Object = { "90":1, '180':3, '240':5, '320':6 };
		private static const padding:uint = 3;
		private static const fontSize:uint = 17;
		private static var textLabel:TextField;
		private var prompt:Sprite = new Sprite();
		private function showHelp(text:String):void {
			var iconScale:Number;
			
			var text:String = text;
			var sprite:Sprite;
			
			for (var w:String in sizes) {
				var textWidth:int = int(w);
				var lineCount:int = Math.round((text.length * fontSize) / textWidth);
			}
			textLabel = Window.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize,
				textLeading:-5
			});
			
			textLabel.wordWrap = true;
			textLabel.text = text;
			textLabel.autoSize = TextFieldAutoSize.LEFT;
			textLabel.width = textWidth;
			

			var maxWidth:int = Math.max(textLabel.textWidth) + padding * 2;
			textLabel.width = maxWidth + 5;
			
			var maxHeight:int = textLabel.height + 10;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(maxWidth + padding * 2, maxHeight + padding, (Math.PI / 180) * 90, 0, 0);
			
			var shape:Shape = new Shape();
			shape.graphics.beginGradientFill(GradientType.LINEAR, [0xeed4a6, 0xeed4a6], [1, 1], [0, 255], matrix);  //[0xe9e0ce, 0xd5c09f]
			shape.graphics.drawRoundRect(0, 0, maxWidth + padding * 2, maxHeight + padding, 15);
			shape.graphics.endFill();
			shape.filters = [new GlowFilter(0x4c4725, 1, 4, 4, 3, 1)];
			shape.alpha = 0.8;
			prompt.addChild(shape);
			
			textLabel.x = padding;
			//textLabel.y = titleLabel.height;
			
			if (sprite) {
				prompt.addChild(sprite);
			}
			
			textLabel.y = padding;
			
			prompt.addChild(textLabel);
			
			this.x -= 20;
			
			this.addChild(prompt);
		}
		
		public function getFormula(fID:*):Object {
			return (App.data.crafting[fID] != null) ? App.data.crafting[fID] : null;
		}
		
		public function initProduction(object:Object):void {
			
			if (object.hasOwnProperty('fID')) {
				
				/*var willCrafted:int;
				
				if (object.fID is Number && getFormula(object.fID) && object.crafted) {
					formula = getFormula(object.fID);
					fID = object.fID;
					began = object.crafted - formula.time;
					crafted = object.crafted;
					queue.push( {
						order:		0,
						fID:		object.fID,
						crafted:	crafted
					});
					
					willCrafted = crafted;
					
					checkProduction();
				}else if (typeof(object.fID) == 'object') {
					queue = [];
					willCrafted = object.crafted;
					for (var id:String in object.fID) {
						
						if(id != "0")
							willCrafted += getFormula(object.fID[id]).time;
							
						queue.push( {
							order:		int(id),
							fID:		object.fID[id],
							crafted:	willCrafted//_crafted
						});
					}
					queue.sortOn('order', Array.NUMERIC);
					
					checkProduction();
				}*/
				
				queue = [];
				
				//if (object.hasOwnProperty('crafted') && object.crafted > 0) {
					//queue.push( {
						//order:		int(id),
						//fID:		object.c,
						//crafted:	object.crafted
					//});
					//queue.sortOn('order', Array.NUMERIC);
				//}
				crafted = object.crafted;
				fID = object.fID;
				
				checkProduction();
			}
			
			if (Map.ready)
				setTechnoesQueue();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, setTechnoesQueue);
			
		}
		
		private function setTechnoesQueue(e:AppEvent = null):void 
		{
			for (var i:int = 0; i < queue.length - 1; i++ ) 
			{
				if (technos != null && technos.length > 0 && technos[0].capacity >= 0 && queue[i].crafted > App.time ) 
				{
					rentTechno();
				}
			}
		}
		
		public var isTechnoWork:Boolean;
		public var technos:Array;
		
		public function rentTechno(e:AppEvent = null):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, rentTechno);			
			
			if (needTechno > 0 && (technos.length == 0 || technos[0].capacity >= 0))
			{
				var bots:Array = Techno.takeTechno(needTechno, this);
				
				for (var i:int = 0; i < bots.length; i++) 
				{
					var bot:Techno = bots[i].bot;
					technos.push(bot);
					bot.goToJob(this, i);
				}
			}
		}
		
		public function checkProduction():void 
		{
			completed = [];
			crafting = false;
			
			if (crafted > 0)
			{
				if (crafted <= App.time) 
				{
					hasProduct = true;
					formula = getFormula(fID);
					showIcon();
				}
				else 
				{
					beginCraft(fID, crafted);
				}
			}
			
			checkOnAnimationInit();
		}
		
		protected var view:String;
		public function load(hasReset:Boolean = false):void {
			if (textures) {
				stopAnimation();
				//clearTextures();
			}
			view = info.view;
			
			if (info.hasOwnProperty('start') && level == 0 && !hasReset) {
				level = info.start;
			}
			
			if (info.hasOwnProperty('instance') && info.instance.hasOwnProperty('devel') && info.instance.devel[instance].hasOwnProperty('req')) 
			{
				var viewLevel:int = level;
				while (true) 
				{
					if (info.instance.devel[instance].req.hasOwnProperty(viewLevel) && info.instance.devel[instance].req[viewLevel].hasOwnProperty('v') && String(info.instance.devel[instance].req[viewLevel].v).length > 0) 
					{
						if (info.instance.devel[instance].req[viewLevel].v == '0') 
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
							view = info.instance.devel[instance].req[viewLevel].v;
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
			}
			var bType:String = type;
			var bView:String = view;
			if (skin)
			{
				bType = 'Skin';
				bView = skin;
			}
			if (App.user.mode == User.GUEST)
			{
				var hash:String = MD5.encrypt(Config.getSwf(bType, bView));
				if ((Load.cache[hash] != undefined && Load.cache[hash].status == 3) || !open) {
					Load.loading(Config.getSwf(bType, bView), onLoad);
				}else{
					if(SystemPanel.noload)
						clearBmaps = true;
					Load.loading(Config.getSwf(bType, bView), onLoad);
					//onLoad(UnitsHelper.bTexture);
				}
			}else
				Load.loading(Config.getSwf(bType, bView), onLoad);
		}
		
		public function isBuilded():Boolean 
		{
			if (created == 0) return false;
			
			var curLevel:int = level + 1;
			if (curLevel >= totalLevels)
			{
				curLevel = totalLevels;
				App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, changeIcon)
			}
			if (created <= App.time) {
				if (level == 0) level = 1;
				hasBuilded = true;
				return true;
			}
			
			return false;
		}
		
		public function build():void 
		{
			updateProgress(created - info.instance.devel[1].req[level+1].l, created);
			if (isBuilded())
			{
				App.self.setOffTimer(build);
				showIcon();
				hasPresent = true;
				updateLevel();
				fireTechno();
				hasUpgraded = true;
				onBuildComplete();
			}
		}
		
		public function onBuildComplete():void 
		{
			dispatchEvent(new UnitEvent(UnitEvent.UNIT_UPGRADE));
			
			if (_openWindowAfterUpgrade)
			{
				openConstructWindow();
			}
		}
		
		public function isUpgrade():Boolean 
		{
			if (upgradedTime <= App.time) 
			{
				hasUpgraded = true;
				//moveable = true;
				return true;
			}
			
			return false;
		}
		
		public function upgraded(hasReset:Boolean = false):void 
		{	
			if (isUpgrade())
			{
				App.self.setOffTimer(upgraded);
				if (!hasUpgraded)
				{
					instance = 1;
					created = App.time + info.instance.devel[1].req[1].l;
					App.self.setOnTimer(build);
					addEffect(Building.BUILD);
				}
				else
				{
					hasUpgraded = true;
					hasPresent = true;
					//this.level++;
					/*if (fromStock ) 
					{
						if (!(this is Hut)) 
							this.level = this.totalLevels;
					}*/
					finishUpgrade();
					load(hasReset);
					fireTechno();
					fromStock = false;
					
					dispatchEvent(new UnitEvent(UnitEvent.UNIT_UPGRADE));
					
					if (_openWindowAfterUpgrade && !App.user.quests.tutorial)
					{
						openConstructWindow();
					}
				}
			}
		}		
		
		override public function moveAction():void {
			super.moveAction();
			addGround();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			
			showIcon();
			
			
			hasUpgraded = false;
			hasBuilded = true;
			
			if (info.instance && info.instance.devel && (info.type == 'Building' || info.type == 'Barter')) {
				openConstructWindow();
			}
			
			App.user.addInstance(info.sid);
			makeOpen();
			hasUpgraded = true;
			
			dispatchEvent(new UnitEvent(UnitEvent.UNIT_SHOP_ACTION));
			//App.user.stock.takeAll(data.__take);
			//checkGlowing();
			World.tagUnit(this);
			
		}
		
		override public function onRemoveAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				this.visible = true;
				return;
			}
			uninstall();
			if (params.callback != null) {
				params.callback();
			}
			App.user.dellInstance(info.sid);
		}
		
		public function onAfterBuy(e:AppEvent):void
		{
			if(textures != null){
				var levelData:Object = textures.sprites[this.level];
				removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
				App.ui.flashGlowing(this, 0xFFF000);
				addGround();
			}
			
			hasUpgraded = true;
			hasBuilded = true;
			
			if (prompt) prompt.visible = false;
			
			//Делаем push в _6e
			if (App.social == 'FB') {
				ExternalApi.og('place','building');
			}
			
			SoundsManager.instance.playSFX('building_1');
		}
		
		override public function onLoad(data:*):void 
		{		
			textures = data;
			updateLevel();
			
			
			countBounds('', usedStage);
			if (icon != null)
				showIcon();
			
			if (!formed) 
			{
				if (prompt) prompt.x += 30;
			} 
			else 
			{
				if (prompt) prompt.visible = false;
			}
			
			if (loader != null) 
			{
				removeChild(loader);
				loader = null;
			}
			
			if (!open && formed) 
			{
				applyFilter();
			}
			
			if (__hasPointing)
			{
				hidePointing();
				showPointing(currPointingSetts['position'],currPointingSetts['deltaX'],currPointingSetts['deltaY'],currPointingSetts['container']);
			}
			if(level == totalLevels)
				checkBoosters();
				
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
			
			
			calcDepth();
				
			App.map.allSorting()
		}
		
		override public function buyAction(setts:*=null):void
		{
			if (!setts)
				setts = {};
			
			SoundsManager.instance.playSFX('build');
			
			var price:Object = Payments.itemPrice(sid);
			
			if (App.user.stock.takeAll(price)) {
				
				//World.addBuilding(this);
				if(App.user.hero)
					Hints.buy(this);
				
				if (info.hasOwnProperty('instance')) {
					var instances:int = World.getBuildingCount(sid);
					//params['iID'] = 1 + (Numbers.countProps(info.instance) < instances) ? Numbers.countProps(info.instance) : instances;
				}
				
				
				var params:Object = {
					ctr:	this.type,
					act:	'buy',
					uID:	App.user.id,
					ac:		(ShopWindow.currentBuyObject.currency)?1:0,
					wID:	(setts.hasOwnProperty('wID'))?setts.wID:App.user.worldID,
					sID:	this.sid,
					iID:	instances,
					x:		coords.x,
					z:		coords.z
				};
				
				if (this.fake && this.fake == true)
				{
					trace ("you are FAKE!");
					var _id:int = 1;
					if (Map.resourcesID.hasOwnProperty(this.type))
					{
						Map.resourcesID[this.type] = Map.resourcesID[this.type] + 1;
						_id = Map.resourcesID[this.type];
					}else{
						Map.resourcesID[this.type] = _id;
					}
						
					onBuyAction(0,{id:_id},{});
				}else{
					Post.send(params, onBuyAction);
				}
				
				if (this.type == "Resource") {
					this.open = true;
				}
			} else {
				ShopWindow.currentBuyObject.type = null;
				ShopWindow.currentBuyObject.currency = null;
				uninstall();
			}
			
			isBuyNow = false;
		}
		
		public function instanceNumber():uint
		{
			var allInstances:Array = Map.findUnits([sid]);
			allInstances = allInstances.sortOn("id", Array.NUMERIC);
			
			var instanceNum:int = allInstances.indexOf(this) + 1;
			
			var numInstance:uint = instanceNum;
				
			var iterator:int = 0;
			
			if (info.instance) 
			{
				for (var dd:* in info.instance.devel)
				{
					iterator++;
				}
			}
			
			if (numInstance > iterator)
				numInstance = iterator;
				
			return numInstance;
		}
		
		protected var usedStage:int = 0;
		public function updateLevel(checkRotate:Boolean = false):void 
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
			if ( levelData && levelData.bmp)
				draw(levelData.bmp, levelData.dx, levelData.dy);
			if (level >= totalLevels) 
				addGround();
			
			checkOnAnimationInit();
		}
		
		public var ground:Bitmap;
		public function addGround():void {
			if (!formed) return;
			if (textures.hasOwnProperty('ground')) 
			{
				if (!ground) {
					ground = new Bitmap(textures.ground.bmp);
					App.map.mLand.addChildAt(ground, 0);
				}
				
				ground.scaleX = scaleX;
				ground.x = this.x + textures.ground.dx - ((rotate) ? (textures.ground.dx * 2) : 0);
				ground.y = this.y + textures.ground.dy;
			}
			
		}
		
		public function removeGround():void 
		{
			if (!formed) 
				return;
			if (ground) 
			{
				App.map.mLand.removeChild(ground);
				ground = null;
			}
		}
		
		public function checkOnAnimationInit():void 
		{
			if (!textures || !textures.hasOwnProperty('animation') || Numbers.countProps(textures.animation.animations) == 0)
				return;
			//if (sid == 533) 
			//{
				//if (textures && textures['animation']) 
				//{	
					//switch(level) 
					//{
						//case 0:
							//clearMountainAnimation();
							//initMountainAnimation();
							//startAnimation();
							//break;
						//case 1:
							//clearMountainAnimation();
							//initMountainAnimation(false, 'techno');
							//startAnimationMountain('techno');
							//break;
						//case 2:
							//clearMountainAnimation();
							//initMountainAnimation(false, 'techno');
							//startAnimationMountain('techno');
							//break;
						//case 3:
							//App.self.setOffEnterFrame(animateMountain);
							//finishAnimation();
							//clearMountainAnimation();
							//break;
					//}
				//}
				//return;
			//}
			if (textures && textures['animation'] && ((level >= totalLevels || permanentAnimated /*- craftLevels*/) /*|| this.sid == 236*/)) 
			{
				initAnimation();
				if (crafted > 0 || this.type == 'Hippodrome' || this.type == 'Booster' || this.type == 'Buildgolden' || this.type == 'Postman' || ALWAYS_ANIMATED.indexOf(sid) != -1) 
				{
					beginAnimation();
				}
				else
				{
					finishAnimation();
				}
			}
			
			if (sid == 1235 && textures)
			{
				initAnimation();
				beginAnimation();
				startAnimation();
			}
			
			if (sid == 28 && textures && level == 0)
			{
				initAnimation();
				beginAnimation();
				startAnimation();
			}
		}
		
		override public function startAnimation(random:Boolean = false):void 
		{
			super.startAnimation(random);
			for(var name:String in multipleAnime)
			{
				if (!textures.sprites.hasOwnProperty('0'))
				{
					multipleAnime[name].bitmap.visible = true;
				}
				else if (!textures.sprites[0].anime || textures.sprites[0].anime != name)// было if (!textures.sprites[level].anime || textures.sprites[level].anime != name)
				{
					//multipleAnime[name].bitmap.visible = false;
				}
				multipleAnime[name].bitmap.visible = true;
			}
		}
		
		public function clearMountainAnimation():void {
			stopAnimation();
			//if (!SystemPanel.animate) return;
			for (var _name:String in multipleAnime) {
				var btm:Bitmap = multipleAnime[_name].bitmap;
				if (btm && btm.parent)
					btm.parent.removeChild(btm);
			}
			multipleAnime = { };
			framesTypes = [];
		}
		
		public function initMountainAnimation(all:Boolean = true, name:String = ''):void {
			if (all) {
				framesTypes = [];
				if (textures && textures.hasOwnProperty('animation')) {
					for (var frameType:String in textures.animation.animations) {
						framesTypes.push(frameType);
					}
					addAnimation()
					animate();
				}
			} else {
				framesTypes.push(name);
				addAnimation()
				animate();
			}
		}
		
		private var currentAnimName:String;
		private function startAnimationMountain(name:String):void
		{
			if (animated) return;
			
			//for each(var name:String in framesTypes) {
				
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name].bitmap.visible = true;
				multipleAnime[name]['frame'] = 0;
				/*if (random) {
					multipleAnime[framesTypes[name]]['frame'] = int(Math.random() * multipleAnime[framesTypes[name]].length);
				}*/
			//}
			
			currentAnimName = name;
			App.self.setOnEnterFrame(animateMountain);
			animated = true;
		}
		
		private function animateMountain(e:Event = null):void 
		{
			//if (!SystemPanel.animate && !(this is Lantern)) return;
			
			//for each(var name:String in framesTypes) {
				var frame:* 			= multipleAnime[currentAnimName].frame;
				var cadr:uint 			= textures.animation.animations[currentAnimName].chain[frame];
				if (multipleAnime[currentAnimName].cadr != cadr) 
				{
					multipleAnime[currentAnimName].cadr = cadr;
					var frameObject:Object 	= textures.animation.animations[currentAnimName].frames[cadr];
					
					multipleAnime[currentAnimName].bitmap.bitmapData = frameObject.bmd;
					multipleAnime[currentAnimName].bitmap.smoothing = true;
					multipleAnime[currentAnimName].bitmap.x = frameObject.ox+ax;
					multipleAnime[currentAnimName].bitmap.y = frameObject.oy+ay;
				}
				multipleAnime[currentAnimName].frame++;
				if (multipleAnime[currentAnimName].frame >= multipleAnime[currentAnimName].length)
				{
					multipleAnime[currentAnimName].frame = 0;
				}
			//}
		}
		
		private var cantClick:Boolean = false;
		public var helpTarget:int = 0;
		
		override public function click():Boolean
		{
			/*if (this.sid == 3288 && this.level == 6 && !Config.admin)
			{
				Locker.availableUpdate();
				return false;
			}*/
			if (pest && pest.alive)//Вредитель
				return false;
			hidePointing();
			stopBlink();
			
			if (App.user.useSectors)
			{
				var node1:AStarNodeVO = App.map._aStarNodes[this.coords.x][this.coords.z];
				if (this.sid == 602)
					node1 = App.map._aStarNodes[this.coords.x + this.cells -1][this.coords.z + this.rows - 1];
				
				if (!node1.sector.open)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1495607052980') + " " + info.title,
						confirm:function():void
						{
							node1.sector.fireNeiborsReses();
						}
					}).show();
					return false;
				}
			}
			
			if (needQuest != 0 && App.user.mode == User.OWNER)
			{
				if (!App.user.quests.data.hasOwnProperty(needQuest))
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1481879219779"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1481878959561', App.data.quests[needQuest].title)
					}).show();
					return false;
				}
			}
			
			if(this.sid == 1078) //Хлам
			{
				this.removable = true;
				this.onApplyRemove();
			}
			/*if (level == totalLevels && sid == BARTER)
			{
				if (App.user.mode == User.OWNER) 
				{
					new BarterWindow({target:this}).show();
					return true;
				}
			}*/
			/*if (!clickable)
			{
				if (App.user.mode == User.OWNER && sid == PET_CAGE_SID)
				{
					new SimpleWindow( { 
						hasTitle:	true,
						title:		info.title,
						text:		Locale.__e("flash:1465981318630") 
					} ).show();
				}
				
				return false;
			}*/
			
			if (!super.click() || this.id == 0)
			{
				return false;
			}			
			
			if (App.user.mode == User.GUEST) 
			{
				guestClick();
				return true;
			}
			
			if (!isReadyToWork()) 
				return true;
			
			if (isPresent()) 
				return true;
			
			if (isProduct()) 
				return true;
			
			if (openConstructWindow()) 
				return true;
			
			if (sid == CAPSULE)
			{
				openCapsuleWindow();	
			}
			/*if (sid == APOTHECARY)
			{
				new ApothecaryWindow( {
				} ).show();
				return true;
			}*/
			
			openProductionWindow();			
			
			return true;
		}
		
		protected var _openWindowAfterUpgrade:Boolean = false;
		
		public function openConstructWindow(openWindowAfterUpgrade:Boolean = true):Boolean 
		{
			if (_constructWindow != null)
				return true;
			
			if ((level < totalLevels) || (level < totalLevels))
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						/*if (this.sid == 3288 && this.level == 6 && !Config.admin)
						{
							Locker.availableUpdate();
							return false;
						}*/
						/*if (this.sid == Unit.BATHYSCAPHE)
						{
							if (level == 8 && !Config.admin)
							{
								//Locker.availableUpdate();
								return false;
							}
						}*/
						var instanceNum:uint = instanceNumber();
						
						_constructWindow = new ConstructWindow( { // Bременно заменен истанс
							title:			info.title,
							upgTime:		info.instance.devel[instanceNum].req[level + 1].l,
							request:		info.instance.devel[instanceNum].obj[level + 1],
							reward:			info.instance.devel[instanceNum].rew[level + 1],
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
		
		protected function onConstructWindowClose(e:WindowEvent):void 
		{
			_constructWindow.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onConstructWindowClose);
			_constructWindow = null;
		}
		
		public var guestDone:Boolean = false;
		public function guestClick():void 
		{
			if (level < totalLevels)
				return;
			if (guestDone) return;
			
			if(App.user.addTarget({
				target:this,
				near:true,
				callback:onGuestClick,
				event:Personage.GATHER,
				jobPosition:getContactPosition(),
				shortcut:true
			})) {
				ordered = true;
			}else {
				ordered = false;
			}
		}
		
		public function onGuestClick():void {
			
			if (App.user.friends.takeGuestEnergy(App.owner.id))
			{
				guestDone = true;
				flag = false;
				clearIcon();
				
				var that:* = this;
				Post.send({
					ctr:'user',
					act:'guestkick',
					uID:App.user.id,
					sID:this.sid,
					fID:App.owner.id
				}, function(error:int, data:Object, params:Object):void {
					if (error)
					{
						Errors.show(error, data);
						return;
					}	
					
					if (data.hasOwnProperty("bonus"))
					{
						Treasures.bonus(data.bonus, new Point(that.x, that.y));
					}
					
					ordered = false;
					
					if (data.hasOwnProperty('energy'))
					{
						if (App.user.friends.data[App.owner.id].energy != data.energy)
						{
							App.user.friends.data[App.owner.id].energy = data.energy;
							App.ui.leftPanel.update();
						}
					}
					
					if (data.hasOwnProperty('437')) 
					{
						App.user.stock.data['437'] = data['437'];
						App.ui.upPanel.updateGuestBar();
					}
					
					if (data.hasOwnProperty('guestBonus')) 
					{
						if (App.self.getLength(data.guestBonus) == 0) 
						{
							return;
						}
						
						var bonus:Object = { };
						
						for (var sID:* in data.guestBonus) 
						{							
							var item:Object = data.guestBonus[sID];
							for(var count:* in item)
							bonus[sID] = count * item[count];							
						}
						
						App.user.stock.addAll(bonus);
						
						new RewardWindow( { bonus:bonus } ).show();
					}
					
					App.user.friends.giveGuestBonus(App.owner.id);
				});
			}else {
				ordered = false;
			}
		}
		
		public function isPresent():Boolean
		{
			if (hasPresent) 
			{
				hasPresent = false;
				
				if (level >= totalLevels - craftLevels + 1) 
				{
					makePost();
				}
				
				//Post.send({
					//ctr:this.type,
					//act:'reward',
					//uID:App.user.id,
					//id:this.id,
					//wID:App.user.worldID,
					//sID:this.sid
				//}, onBonusEvent);
				
				return true;
			}
			return false;
			
		}
		
		public function checkBoosters():void
		{
			for each(var _booster:* in Booster.boosters)
			{
				_booster.checkBuildings();
			}
		}
		
		public function isReadyToWork():Boolean
		{
			var finishTime:int = -1;
			var totalTime:int = -1;
			if (created > 0 && !hasBuilded)
			{ // еще строится
				var curLevel:int = level + 1;
				if (curLevel >= totalLevels) curLevel = totalLevels;
				finishTime = created;
				totalTime = App.data.storage[sid].devel.req[1].t;
			}else if (upgradedTime >0 && !hasUpgraded) { // еще апграйдится
				finishTime = upgradedTime;
				totalTime = App.data.storage[sid].instance.devel[1].req[level+1].l;
			}	
			
			if(finishTime >0){
				new SpeedWindow( {
					title:info.title,
					target:this,
					info:info,
					finishTime:finishTime,
					totalTime:totalTime,
					priceSpeed: info.skip
				}).show();
				return false;	
			}		
			
			return true;
		}
		
		//private var fromStock:Boolean = false;
		override public function stockAction(params:Object = null):void 
		{
			if (!App.user.stock.check(sid)) 
			{
				//TODO показываем окно с ообщением, что на складе уже нет ничего
				return;
			}/*else if (!World.canBuilding(sid)) 
			{
				uninstall();
				return;
			}*/
			
			App.user.stock.take(sid, 1);
			
			Post.send( {
				ctr:this.type,
				act:'stock',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z,
				level:this.level
			}, onStockAction);
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			
			showIcon();
			
			hasUpgraded = false;
			hasBuilded = true;
			
			if (info.instance && info.instance.devel && (info.type == 'Building' || info.type == 'Barter')) 
			{
				openConstructWindow();
			}
			
			checkBoosters();
			
			App.user.addInstance(info.sid);
			makeOpen();
			hasUpgraded = true;
			
			dispatchEvent(new UnitEvent(UnitEvent.UNIT_SHOP_ACTION));
			
			if (data.hasOwnProperty('level'))
			{
				level = data['level'];
				load();
				showIcon();
			}
			
			World.tagUnit(this);
		}
		
		override public function onAfterStock():void 
		{
			showIcon();
			addGround();
		}
		
		public function updateProgress(startTime:int, endTime:int):void
		{
			if (!progressContainer) return;			
			progressContainer.visible = true;
			var totalTime:int = endTime-startTime;
			var curTime:int = endTime - App.time;
			if (curTime < 0) curTime = 0;
			var timeForSlider:int = totalTime - curTime;
			
			if (timeForSlider < 0) timeForSlider = 0;
			UserInterface.slider(slider, timeForSlider, totalTime, "productionProgressBarGreen", true);
		}
		
		public var progressContainer:Sprite = new Sprite();
		public var slider:Sprite = new Sprite();
		private var bgProgress:Bitmap;
		
		public function addProgressBar():void 
		{
			bgProgress = new Bitmap(Window.textures.productionProgressBarBacking);
			progressContainer.addChild(bgProgress);
			progressContainer.addChild(slider);
			slider.scaleY;
			slider.x = 4; slider.y = 1;
			
			addChild(progressContainer);
			
			if(rotate)
				progressContainer.scaleX = -1
			
			/*if (progressPositions.hasOwnProperty(info.view))
			{
				progressContainer.y = progressPositions[info.view].y;
				progressContainer.x = progressPositions[info.view].x;
			}else{
				progressContainer.y = -60;
				progressContainer.x = -40;
			}*/
			
			if (progressContainer.scaleX == -1)
			{
				progressContainer.x += progressContainer.width/2;
			}
			
			progressContainer.visible = false;
		}
		
		public function removeProgress():void
		{
			if (slider && slider.parent) 
			{
				slider.parent.removeChild(slider);
			}
			
			if (bgProgress && bgProgress.parent)
			{
				bgProgress.parent.removeChild(bgProgress);
			}
			
			if (progressContainer && progressContainer.parent)
			{
				progressContainer.parent.removeChild(progressContainer);
			}
		}
		
		public function isProduct():Boolean
		{
			if (level < totalLevels)
				return false;
			if (hasProduct)
			{
				if (App.user.quests.tutorial && App.user.quests.data.hasOwnProperty("135")) 
				{
					App.user.quests.finishQuest(135, 2);
				}
				
				var price:Object = getPrice();
				
				var out:Object = { };
				out[formula.out] = formula.count;
				if (!App.user.stock.checkAll(price))	return true;  // было false
				
				// Отправляем персонажа на сбор
				storageEvent();
				
				return true; 
			}
			return false;
		}
		
		public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			removeEffect();
			showIcon();
			
			if (info.devel.hasOwnProperty('rew')) 
			{
				Treasures.bonus(Treasures.convert(info.devel.rew[level]), new Point(this.x, this.y));
			}
		}
		
		
	//D Western	
		// Составные прибыльные домики
		private var component:Object = {
			//1561: [1545,1546,1547,1548,1550,1551,1552,1553],
			//1869: [1870,1871,1872,1873,1874,1875,1876,1877]
		}
	
		public function get componentMainID():int 
		{
			if (component.hasOwnProperty(sid))
				return sid;
			
			for (var comp:String in component) 
			{
				if (component[comp].indexOf(sid) != -1)
					return int(comp);
			}
			
			return 0;
		}
		
		public function get permanentAnimated():Boolean
		{
			if (Building.PERMANENT_ANIMATED.indexOf(this.sid) != -1 || this is Buildgolden)
				return true;
			else
				return false;
		}
	
			// Мультисбор
		public var multistorage:Object = [
			//[1545,1546,1547,1548,1550,1551,1552,1553]
		]
		
		public function startMultistorage():Boolean 
		{
			if (App.user.mode == User.GUEST) return false;
			
			for (var i:int = 0; i < multistorage.length; i++) 
			{
				if (multistorage[i].indexOf(sid) != -1) 
				{
					var list:Array = Map.findUnits(multistorage[i]);
					
					for each(var unit:* in list) 
					{
						// Существует, не ожидает ответа от сервера, достроен, готов, есть фантазия для сбора
						if (unit && !unit.ordered && unit.level == unit.totalLevels && unit.tribute /*&& App.user.stock.check(Stock.FANTASY, 1)*/)
							unit.storageEvent();
					}
					
					return true;
				}
			}
			
			return false;
		}
		
		
		public function get componentChildsReady():Boolean 
		{
			if (componentFirstUnreadyChild)
				return false;
			
			return true;
		}
			
		private function get componentFirstUnreadyChild():* 
		{
			var childs:Array = Map.findUnits(component[componentMainID]);
			var index:int = childs.length;
			
			while (--index && index >= 0) 
			{
				if (childs[index].level <= level && childs[index].level < childs[index].totalLevels)
					return childs[index];
			}
			
			return null;
		}
		
			public function get componentIsMain():Boolean {
			if (component.hasOwnProperty(sid))
				return true;
			
			return false;
		}
	
		private function get componentChildsUnready():Array 
		{
			var childs:Array = Map.findUnits(component[componentMainID]);
			var index:int = childs.length;
			
			while (index > 0) 
			{
				--index;
				if (childs[index].level >= childs[index].totalLevels)
					childs.splice(index, 1);
			}
			
			childs.sortOn('level', Array.NUMERIC);
			
			return childs;
		}
		
		protected function get componentBuildable():Boolean 
		{
			if (componentable) 
			{
				
				var list:Array;
				
				// Если составная постройка главная
				if (componentIsMain) 
				{					
					// Если дочерние компоненты не готовы
					if (!componentChildsReady) 
					{
						var locale1:String = 'flash:1454767850835';						
						var locale2:String = 'flash:1454767883977';
						
						new SimpleWindow( {
							title:		info.title,
							text:		(level == totalLevels - 1) ? Locale.__e(locale1) : Locale.__e(locale2),
							confirm:function():void
							{
								list = componentChildsUnready;
								if (list.length > 0) 
								{
									App.map.focusedOn(list[0], true);
								}
							}
						}).show();
						
						return false;
					}
				}else {
					list = Map.findUnits([componentMainID]);
					
					for each(var unit:* in list) 
					{
						
						// Если найдена главная постройка, ее уровень ниже чем у текущей дочерней постройки, уровень главной не предпоследний
						if (unit && unit.sid == componentMainID && unit.level < level && unit.level != unit.totalLevels - 1) 
						{
							list = componentChildsUnready;
							
							var locale3:String = 'flash:1454767883977';
							
							new SimpleWindow( {
								title:		info.title,
								text:		(minimumLevel(list) > unit.level) ? Locale.__e('flash:1454768360946') : Locale.__e(locale3),
								confirm:function():void 
								{
									if (minimumLevel(list) > unit.level) 
									{
										App.map.focusedOn(unit, true);
									}else if (list.length > 0) {
										App.map.focusedOn(list[0], true);
									}
								}
							}).show();
							
							//App.map.focusedOn(unit, true);
							return false;
						}
					}
				}
			}
			
			return true;
			
			function minimumLevel(list:Array):int 
			{
				var level:int = 999;
				for each(var unit:* in list) 
				{
					if (unit && unit.level < level)
						level = unit.level;
				}
				return level;
			}
		}
		
		public function get componentable():Boolean 
		{
			if (componentMainID != 0)
				return true;
			
			return false;
		}
		
		
		//D Western	
		
		public function showPostWindow():void {
			
			var text:String = 'flash:1382952379896';//Поздравляем! Вы закончили строительство здания!
			
			if (level > 1)
				text = 'flash:1395849886254';//Поздравляем! Вы улучшили здание!
			new SimpleWindow( {
				title:info.title,
				label:SimpleWindow.BUILDING,
				text:Locale.__e("flash:1382952379896"),
				sID:sid,
				ok:(App.social == 'PL')?null:makePost
			}).show();
		}
		
		public function findJobPosition():Object
		{
			var _y:int = -1;
			if (coords.z + _y < 0)
				_y = 0;
				
			var _x:int = int(info.area.w / 2);
			var _direction:int = 0;
			var _flip:int = 0;
				
			return {
				x:_x,
				y:_y,
				direction:_direction,
				flip:_flip
			}		
		}
		
		private var _scaleBeforeWindow:Number;
		
		public function openProductionWindow():void 
		{
			if (sid == CAPSULE) return;
			
			if (TRAVEL_COURTS.indexOf(this.sid) != -1)
			{
				if (crafted > App.time) 
				{
					var priceSpeed:int = Math.ceil((crafted - App.time) / App.data.options['SpeedUpPrice']);
					//boostBttn.count = String(priceSpeed);
					new SpeedWindow( {
						title			:info.title,
						priceSpeed		:priceSpeed,
						target			:this,
						info			:info,
						finishTime		:crafted,
						totalTime		:App.data.crafting[info.devel[1].craft[0]].time,
						btmdIconType	:info.type,
						btmdIcon		:info.preview,
						doBoost			:onBoostEvent
					}).show();
					return;
				}else{
					for each(var wSid:int in Wigwam.TENTS)
					{
						var wigwam:Object = App.data.storage[wSid];
						if (Numbers.firstProp(App.data.crafting[this.info.devel[1].craft[0]].items).key == App.data.crafting[wigwam.dlist[0]].out)
						{
							var building:Wigwam = Map.findUnits([wSid])[0];
							if (!building.checkBusy())
							{
								building.click();
								return;
								break;
							}
							//building.onCraftAction(this.info.devel[1].craft[0]);
							
						}
					}
					new SimpleWindow( {
						title	:Locale.__e("flash:1474469531767"),
						label	:SimpleWindow.ATTENTION,
						text	:Locale.__e('flash:1495783904609'),
						popup	:true
					}).show();
					return;
				} 
			}
			
			if (level < totalLevels)
			{
				return;
			}
			if (Building.CHANK_ARRAY.indexOf(this.sid) != -1)
			{
				if (crafted > App.time) 
				{
					var priceSpeed1:int = Math.ceil((crafted - App.time) / App.data.options['SpeedUpPrice']);
					//boostBttn.count = String(priceSpeed);
					new SpeedWindow( {
						title			:info.title,
						priceSpeed		:priceSpeed1,
						target			:this,
						info			:info,
						finishTime		:crafted,
						totalTime		:App.data.crafting[info.devel[1].craft[0]].time,
						btmdIconType	:info.type,
						btmdIcon		:info.preview,
						doBoost			:onBoostEvent
					}).show();
					return;
				}else{
					if (craftNeed == null || (craftNeed && !craftNeed.hasOwnProperty(info.devel[1].craft[0])))
					{
						var sendObject:Object = {
							ctr:this.type,
							act:'getCraftNeed',
							uID:App.user.id,
							id:this.id,
							wID:App.user.worldID,
							sID:this.sid,
							fID:info.devel[1].craft[0]
						}
						
						Post.send(sendObject, onCraftNeed);
						Window.closeAll();
						return;
					}
					//Window.closeAll();
					new RecipePoolWindow( {
						title			:Locale.__e("flash:1382952380065"),
						fID				:info.devel[1].craft[0],
						onCook			:onCraftAction,
						craftData		:info.devel[1].craft,
						fromBuild		:true,
						materials		:craftNeed[info.devel[1].craft[0]],
						prodItem		:this,
						queue			:[],
						sID				:sid,
						openedSlots		:0,
						target			:this
					}).show();
					return;
				}
			}
			if (info.devel) 
			{				
				if (info.devel[1].craft)
				{
					if (craftNeed == null || craftNeed.hasOwnProperty(info.devel[1].craft[0]) || (craftNeed && !craftNeed.hasOwnProperty(info.devel[1].craft[0])))
					{
						for each(var crft:* in info.devel[1].craft)
						{
							var ssendObject:Object = {
								ctr:this.type,
								act:'getCraftNeed',
								uID:App.user.id,
								id:this.id,
								wID:App.user.worldID,
								sID:this.sid,
								fID:crft
							}
							if (App.data.crafting[crft].hasOwnProperty('rcount') && App.data.crafting[crft].rcount != "" && craftNeed == null)
								Post.send(ssendObject, onCraftNeedAll);
						}
						new ProductionWindow( {
							title:			info.title,
							crafting:		info.devel[1].craft,
							target:			this,
							onCraftAction:	onCraftAction,
							hasPaginator:	true,
							hasButtons:		true,
							find:			helpTarget
						}).focusAndShow();
						//Window.closeAll();
						//return;
					}
					
				}
			}
		}
		
		private var _arrCraft:Array;
		private var lvlRec:int;
		
		public function openCapsuleWindow():void 
		{
			if (level < totalLevels)
				return;
				
			if (crafted > App.time) 
			{
				Hints.text(Locale.__e('flash:1474033228388'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Нельзя!
				return;
			}
			var counter:int = 0;
			_arrCraft = [];
			if (info.hasOwnProperty('devel') ) 
			{
				for (var _id:String in info.devel[1].craft)
				{
					var obj:Object = info.devel[1].craft[_id];
					lvlRec = 0;
					
					_arrCraft.push( { fid:obj, lvl:lvlRec, order:counter } );
					counter++;
				}
			}
			_arrCraft.sortOn(['order'], Array.NUMERIC);
			
			//Узнаём какой рецепт показывать
			var craftCounter:int = 0;
			//var
			for (var bbw:* in _arrCraft)
			{
				for (var key:* in _arrCraft[bbw]) 
				{
					if (key == 'fid' ) 
					{
						var resepSid:int  = _arrCraft[bbw][key];
						var outSid:int  = App.data.crafting[resepSid].out;
						
						if (Stock.isExist(outSid)/*App.user.stock.count(outSid) > 0*/) 
						{
							craftCounter++
						}
					}
				}
			}
			
			if (craftCounter == _arrCraft.length) 
			{
				//Hints.text(Locale.__e('flash:1474037570702'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Нельзя!
				if (App.social != 'FB')
					onSkinEvent(null);
				return;
			}
			
			var queue:Array = [];
			new CapsuleWindow( {
				title			:info.title /*Locale.__e("flash:1382952380065")+':'*/,
				fID				:_arrCraft[craftCounter].fid,
				onCook			:onCraftAction,
				craftData		: _arrCraft,
				prodItem		:this,
				queue			:queue,
				sID				:sid,
				openedSlots		:0,
				target			:this
			}).show();
		}
		
		protected function onSkinEvent(e:MouseEvent):void
		{
			//if (!Config.admin)
			//{
				/*new SimpleWindow( {
					title	:Locale.__e("flash:1474469531767"),
					label	:SimpleWindow.ATTENTION,
					text	:Locale.__e('flash:1481899130563'),
					popup	:true
				}).show();
				return;*/
				//Hints.text(Locale.__e('flash:1474037570702'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Нельзя!
				//return;
			//}
			new BuildingSkinWindow({
				title		:info.title,
				target		:this,
				popup		:true
			}).show();
		}
		
		protected var wigwamSID:int;
		protected var wigwamID:int;
		public function onCraftAction(fID:uint):void
		{
			var isBegin:Boolean = true;
			var formula:Object = App.data.crafting[fID];
			var technoSID:int = 0;
			var bTime:int = 0;
			
			if(booster){
				bTime = (formula.time / 100) * booster.info.target[this.sid];
			}
			
			if(formula.time > 0){
				beginCraft(fID, App.time - bTime + formula.time);
				
				checkOnAnimationInit();
				
				Window.closeAll();
			}
			if (craftNeed && craftNeed[fID])
			{
				for (var itm:* in craftNeed[fID]){
					if (App.data.storage[itm].type != "Techno")
						App.user.stock.take(itm, craftNeed[fID][itm]);
					else{
						technoSID = sID;
					}
				}
			}
			else
			{
				for (var sID:* in formula.items)
				{
					if (App.data.storage[sID].type != "Techno")
					{
						App.user.stock.take(sID, formula.items[sID]);
					}else{
						technoSID = sID;
					}
				}
			}
			
			var technoFinded:Boolean = false;
			if (technoSID != 0)
			{
				var technoArr:Array = Map.findUnitsByType(['Techno']);
				for each(var _techno:* in technoArr)
				{
					if (technoSID == _techno.sid && !_techno.fake)
					{
						//wigwamSID = _techno.sid;
						//wigwamID = _techno.id;
						technoFinded = true;
						break;
					}
				}
				
				if (!technoFinded)
				{
					var wigwamArr:Array = Map.findUnitsByType(['Wigwam']);
					for each(var obj:* in wigwamArr)
					{
						if (technoSID == obj.workers[0] && obj.wigwamIsBusy == 0)
						{
							wigwamSID = obj.sid;
							wigwamID = obj.id;
							obj.wigwamIsBusy = formula.ID;
							break;
						}
					}
				}
			}		
			
			var sendObject:Object = {
				ctr:this.type,
				act:'crafting',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fID:fID
			}
			
			if (booster)
			{
				sendObject['bSID'] = booster.sid;
				sendObject['bID'] = booster.id;
			}
			
			if (technoSID != 0)
			{
				if (obj)//если домашний рабочий
				{
					sendObject.wigwam = JSON.stringify({"sID": wigwamSID, "id": wigwamID});
				
					//Скрываем рабочего на время крафта
					var technoToHide:Unit = Map.findUnit(obj.workerSID, obj.workerID);
					obj.removable = false;
					if (technoToHide)
						technoToHide.visible = false;
				}else{//если бездомный рабочий 
					
					//убиваем рабочего
					_techno.removable = true;
					_techno.onApplyRemove();
				}
				
			}
			
			Post.send(sendObject, onCraftEvent);
			
			
		}
		
		protected function onCraftNeed(error:int, data:Object, params:Object):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			if (data.hasOwnProperty('craftNeed'))
			{
				this.craftNeed = data.craftNeed;
			}
			openProductionWindow();
		}
		
		protected function onCraftNeedAll(error:int, data:Object, params:Object):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			if (data.hasOwnProperty('craftNeed'))
			{
				this.craftNeed = data.craftNeed;
			}
			//openProductionWindow();
		}
		
		protected function onCraftEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				cancelCraft();
				return;
			}
			
			if (data.hasOwnProperty('craftsLimit'))
				this.craftsLimit = data.craftsLimit;
			
			
			if (data.hasOwnProperty('crafted')) {
				this.crafted = data.crafted;
			}else {
				ordered = false;
				hasProduct = false;
				queue = [];
				crafted = 0;
				onStorageEvent(error, data, params);
			}
			
			//Создание ресурса в OG
			if (App.social == 'FB') 
			{
				ExternalApi.og('create','resource');
			}			
			
			if (data.hasOwnProperty('pcount') && data.pcount == 0) 
			{
				addPest(info.pest.sid)
			}
		}
		
		public function addPest(pestSid:int):void
		{
			Window.closeAll();
			
			var _pestSid:int = pestSid;			
			var place:Object = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:coords.x, z:coords.z}}, 5);
			
			pest = new Pest( { id:999999, sid:_pestSid, x:place.x, z:place.z, gift:false, buildingType:info.type, buildingSid:info.sID, buildingID:id } );;
			//pest.buyAction();
			App.map.focusedOn(pest, true);
			//pestAlive = true;
		}
		
		/*public function findPlaceNearTarget(target:*, radius:int = 3, lookOnWater:Boolean = false, infront:Boolean = false):Object
		{
			var places:Array = [];			
			var targetX:int = target.coords.x;
			var targetZ:int = target.coords.z;
			var startX:int;
			var startZ:int;
			if(infront == true){
				startX = targetX;
				startZ = targetZ;
			}else{
				startX = targetX - radius;
				startZ = targetZ - radius;
			}
			
			if (startX <= 0) startX = 1;
			if (startZ <= 0) startZ = 1;
			
			var finishX:int = targetX + radius + target.info.area.w;
			var finishZ:int = targetZ + radius + target.info.area.h;
			
			if (finishX >= Map.cells) finishX = Map.cells - 1;
			if (finishZ >= Map.rows) finishZ = Map.rows - 1;
			
			for (var pX:int = startX; pX < finishX; pX++)
			{
				for (var pZ:int = startZ; pZ < finishZ; pZ++)
				{
					if ((coords.x <= pX && pX <= targetX +target.info.area.w) && (coords.z <= pZ && pZ <= targetZ +target.info.area.h))
					{
						continue;
					}
					
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].isWall) 
						continue;
					
					if (App.map._aStarNodes && App.map._aStarNodes[pX][pZ].open == false) 
						continue;	
					
					places.push( { x:pX, z:pZ} );
				}
			}
			
			if (places.length == 0)
			{
				places.push( { x:coords.x, z:coords.z } );
			}
			
			var random:uint = int(Math.random() * (places.length - 1));
			return places[random];
		}*/
		
		protected function addToQueue(fID:int, order:* = null):void {
			// Выбираем самое позднее окончание производства
			var _crafted:int = 0;
			var _order:int = 0;
			for (var i:int = 0; i < queue.length; i++) {
				if (queue[i].crafted > _crafted)
					_crafted = queue[i].crafted;
				
				if (order === null && queue[i].order > _order)
					_order = queue[i].order;
			}
			if (_crafted == 0) _crafted = App.time;
			if (order === null) order = _order;
			
			queue.push( {
				order:		int(order),
				fID:		fID,
				crafted:	_crafted + getFormula(fID).time
			});
		}
		
		public function onBoostEvent(count:int = 0):void {
			var boostSid:int = Stock.FANT;
			if (this.info.mboost != Stock.FANT && App.user.stock.count(this.info.mboost) > 0)
			{
				boostSid = this.info.mboost;
				count = 1;
			}
				
			if (App.user.stock.count(boostSid) < count) 
				return;
				
				
				ordered = true;
				
				var postObject:Object = {
					ctr	:this.type,
					act	:'boost',
					uID	:App.user.id,
					id	:this.id,
					wID	:App.user.worldID,
					sID	:this.sid
				};
				if (boostSid != Stock.FANT)
				{
					postObject["m"] = boostSid;
					count = 1;
				}
				
				if (freeBoostsFor.length > 0 && freeBoostsFor.indexOf(fID) >= 0)
				{
					postObject["t"] = 1;
				}
				else
				{
					App.user.stock.take(boostSid, count);
				}
				var self:Building = this;
				Post.send(postObject, function(error:*, data:*, params:*):void {
					
					ordered = false;
					//cantClick = false;
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					App.self.setOffTimer(production);
					
					crafted = App.time;
					onProductionComplete();
					if(data.bonus)
						Treasures.bonus(data.bonus, new Point(self.x, self.y));
					//cantClick = true;
					//crafted = data.crafted;
					
					
					//if (data) {
						//for (var i:int = 0; i < queue.length; i++) {
							//if (crafted == queue[i].crafted) {
								//var delta:int = crafted - App.time;
								//for (var j:int = 0; j < queue.length; j++) {
									//queue[j].crafted -= delta;
								//}
								//break;
							//}
						//}
						//checkProduction();
						//
						//cantClick = false;
					//}
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		public function getPrice():Object
		{
			var price:Object = { }
			price[Stock.FANTASY] = 0;
			return price;
		}
		
		public function storageEvent():void
		{
			var technoSID:int = -10;
			var out:Object = { };
			out[formula.out] = formula.count;
			hasProduct = false;
			
			for (var sID:* in formula.items)
			{
				if (App.data.storage[sID].type == "Techno")
				{
					technoSID = sID;
				}
			}
			
			if (technoSID != 0)
			{
				var wigwamArr:Array = Map.findUnitsByType(['Wigwam']);
				
				for each(var obj:* in wigwamArr)
				{
					if (technoSID == obj.workers[0] && obj.wigwamIsBusy == formula.ID)
					{
						wigwamSID = obj.sid;
						wigwamID = obj.id;
						break;
					}
				}
			}
			var instances:int = instanceNumber();
			var sendObject:Object = {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				iID:instances
			}
			
			if (technoSID != -10 && wigwamSID != 0)
			{
				sendObject.wigwam = JSON.stringify({"sID": wigwamSID, "id": wigwamID});
			}
			
			Post.send(sendObject, onStorageEvent);
			
			if (technoSID != -10 && wigwamSID != 0) 
			{
				if(obj.info.capacity != 0)
					obj.capacity--;
					
				//Раздеваем рабочего
				obj.changeWorker(obj.workerSID);
				obj.removable = true;
				obj.wigwamIsBusy = 0;
				
				//Удаляем домик, если нужно
				obj.checkCapacity();
				
				var technoToShow:Unit = Map.findUnit(obj.workerSID, obj.workerID);
				if (technoToShow)
					technoToShow.visible = true;
			}
			
			
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				//Errors.show(error, data);
				return;
			}
			
			if (App.user.quests.tutorial)
			{
				try {
					if (data.bonus.hasOwnProperty('228')) {
						App.user.stock.addAll(data.bonus);
						App.user.stock.add(234, 1);
						App.user.stock.data[234] = -1;
						data.bonus = { 234:1 };
					}
				}catch(e:*) {}
			}
			
			if (data.hasOwnProperty('craftNeed')) 
			{
				this.craftNeed = data.craftNeed;
			}
			
			if (data.hasOwnProperty('bonus')) 
			{
				var that:* = this;
				Treasures.bonus(data.bonus, new Point(that.x, that.y));
			}
			
			if (data.hasOwnProperty('level')) 
			{
				multipleAnime[Numbers.firstProp(multipleAnime).key].bitmap.visible = false;
				_openWindowAfterUpgrade = false;
				level = data.level;
				hasUpgraded = false;
				hasBuilded = true;
				upgradedTime = data.upgrade;
				App.self.setOnTimer(upgraded);
				
				addEffect(Building.BUILD);
				showIcon();
			}
			
			clearIcon();
			
			ordered = false;
			hasProduct = false;
			queue = [];
			crafted = 0;
		}
		
		public var needTechno:uint = 0;
		protected function beginCraft(fID:uint, crafted:uint):void
		{
			formula = getFormula(fID);
			if (crafted == 0) crafted = App.time + formula.time;
			
			this.fID = fID;
			this.crafted = crafted;
			began = crafted - formula.time;
			crafting = true;
			open = true;
			showIcon();
			
			App.self.setOnTimer(production);
		}
		
		protected function cancelCraft():void 
		{
			this.fID = 0;
			this.crafted = 0;
			began = 0;
			crafting = false;
			showIcon();
			
			App.self.setOffTimer(production);
		}
		
		public var countLabel:TextField;
		public var title:TextField;
		protected function onOutLoad(data:*):void
		{
			//
		}
		
		public function set material(value:Boolean):void 
		{
			if (countLabel == null) 
				return;
			
			if (value) 
			{
				if (crafted > App.time)
				{
					countLabel.text = TimeConverter.timeToStr(crafted - App.time);
					countLabel.x = (icon.width - countLabel.width) / 2;
				}
			}
			//popupBalance.visible = toogle;
		}
		
		protected var timeID:uint;
		protected var anim:TweenLite;
		override public function set touch(touch:Boolean):void 
		{
			if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate'))
			{
				return;
			}
			
			super.touch = touch;	
			if (touch) 
			{
				if (Cursor.type == 'default' && crafted && App.user.mode == User.OWNER)
				{
					timeID = setTimeout(function():void
					{
						material = true;
					},400);
				}
			}else 
			{
				clearTimeout(timeID);
				if (anim)
				{
					anim.complete(true);
					anim.kill();
					anim = null;
				}
				material = false;
			}
		}
		
		protected function production():void 
		{
			if (progress)
			{
				checkOnAnimationInit();
				App.self.setOffTimer(production);
			}
		}
		
		public function get progress():Boolean {
			
			if (fID == 0 || began + formula.time <= App.time)
			{
				onProductionComplete();
				//if (queue.length - completed.length <= 0) return true;
				if (crafted <= App.time) return true;
			}
			
			if(countLabel != null){
				countLabel.text = TimeConverter.timeToStr(crafted - App.time);
			}
			
			return false;
		}
		
		public function set crafting(value:Boolean):void
		{
			_crafting = value;
		}
		public function get crafting():Boolean
		{
			//return _crafting;
			return crafted > App.time;
		}
		
		public function onProductionComplete():void {
			fireTechno();
			checkProduction();
		}
		
		public function upgradeEvent(params:Object, fast:int = 0):void {
			
			if (level  > totalLevels) 
			{
				return;
			}
			
			var price:Object = { };
			for (var sID:* in params) {
				if (sID == Techno.TECHNO) {
					//needTechno = params[sID];
					//delete params[sID];
					continue;
				}
				price[sID] = params[sID];
			}
			
			// Забираем материалы со склада
			if (fast == 0) 
			{
				if (!App.user.stock.takeAll(price)) return;
			}
			else 
			{
				if (!App.user.stock.take(Stock.FANT,fast)) return;
			}
			
			gloweble = true;
			//level++;
			
			//var instances:int = World.getBuildingCount(sid);
			var instances:int = instanceNumber();

			Post.send( {
				ctr:this.type,
				act:'upgrade',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fast:fast,
				iID:instances
			},onUpgradeEvent, params);
			
			ordered = true;
		}
		
		public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			else 
			{
				/*for each(var obj:* in App.user.data.units){
					if (obj.level && obj.id == this.id && obj.sid == this.sid){
						trace("Level = " + obj.level);
						trace("ID = " + obj.id);
						//vahave = obj.level;
						break;
					}
				}*/
				//moveable = false;
				level = data.level;
				hasUpgraded = false;
				hasBuilded = true;
				upgradedTime = data.upgrade;
				App.self.setOnTimer(upgraded);
				
				addEffect(Building.BUILD);
				showIcon();
				
				if (data.bonus)
				{
					Treasures.bonus(Treasures.convert(data.bonus), new Point(this.x, this.y));
				}
				
				/*if (App.social == 'FB') 
				{
					ExternalApi.og('improve','building');
				}
				*/
				ordered = false;
			}
		}
		
		public function get buildFinished():Boolean 
		{
			return (level == totalLevels);
		}
		
		
		public function finishUpgrade():void
		{
			/*if (level == totalLevels && App.user.mode == User.OWNER) {
				new SimpleWindow( {
					title:info.title,
					label:SimpleWindow.BUILDING,
					text:Locale.__e("flash:1382952379896"),
					sID:sid,
					ok:null
				}).show();
			}*/
			if (level == totalLevels && App.social == 'FB' && !App.user.quests.tutorial) {
				ExternalApi.og('construct','building');
			}
			
			if (level == totalLevels) 
			{
				checkBoosters();
			}
			
			if (App.user.mode == User.OWNER) {
				isPresent();
				showIcon();
			}
			
			// Отправляем события о том что клетка открыта, питомец может показаться
			//if ((sid == PET_CAGE_SID) && level == totalLevels)
			//{
				//App.self.dispatchEvent(new AppEvent(AppEvent.PET_RELEASED));
				//onApplyRemove();
			//}
			
			//if ((sid == GIRL_IN_TRAP_SID) && level == totalLevels)
			//{
				//App.self.dispatchEvent(new AppEvent(AppEvent.GIRL_RELEASED));
				//onApplyRemove();
			//}
		}
		
		public function accelerateEvent(count:int):void
		{
			if (!App.user.stock.check(Stock.FANT, count)) return;
			
			Post.send( {
				ctr:this.type,
				act:'speedup',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},onAccelerateEvent);
		}
		
		public function onAccelerateEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			var minusFant:int = App.user.stock.count(Stock.FANT) - data[Stock.FANT];
			
			var price:Object = { };
			price[Stock.FANT] = minusFant;
			
			if (!App.user.stock.takeAll(price))	return;
			
			if(!App.user.quests.tutorial)
				Hints.minus(Stock.FANT, minusFant, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
			
			upgradedTime = data.upgrade;
			created = data.created;
		}
		
		/*
		 * Изменяем помощников
		 */ 
		public function changeHelpers(role:String, data:String):void
		{
			if (helpers == null) return;
			
			if (data == "rent")
				helpers[role] = 0;
			else if (data == "remove")
				delete helpers[role];
			else
				helpers[role] = data;
		}
		
		
		public function beginAnimation():void 
		{
			if (this.type == 'Booster' || this.type == 'Hippodrome' || crafting == true || ALWAYS_ANIMATED.indexOf(sid) != -1 || (textures.animation != null && textures.animation.hasOwnProperty('infinityAnimation') && textures.animation.infinityAnimation))
			{
				startAnimation();
			}
			
			if (crafting == true) 
			{
				if (animationBitmap != null && animationBitmap.visible == false) 
					animationBitmap.visible = true;
					
				//startSmoke();
			}
			
			if (animationBitmap != null) 
			{
				if (crafting == true)
				{
					animationBitmap.visible = true;
				}
				else
				{
					if (info.view == 'firefactory')
						animationBitmap.visible = false;
				}
			}
		}
		
		public function finishAnimation():void 
		{
			if (App.user.mode == User.GUEST)
				return;
			
			if (textures && textures.hasOwnProperty('animation'))
			{
				if (textures.animation != null && textures.animation.hasOwnProperty('infinityAnimation') && textures.animation.infinityAnimation)
				{
					stopSmoke();
					return;
				}
				stopAnimation();
				
			}
			
			//stopSmoke();
			
			if(animationBitmap != null){
				if (info.view == 'firefactory') 
				{
					animationBitmap.visible = false;
				}
			}
		}
		
		//public var isTechnoWork:Boolean = false;
		
		public function fireTechno(minusCapasity:int = 0):void 
		{
			if (technos.length > 0)
			{
				technos[0].fire(minusCapasity);
				technos.splice(0, 1);
			}
			
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, rentTechno);
			needTechno = 0;
		}
		
		public var workerPath:Object = {
			
		}
		public function generateWorkerPath(pos:int):void 
		{
			var _workerPath:Object = { };
			var path:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var path_reverse:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			var node:AStarNodeVO;
			var _z:int = coords.z;
			var _x:int = coords.x;
			switch(pos) 
			{
				case 0:
					_z = coords.z - 1;
					for (_x = coords.x; _x < coords.x + cells; _x++) {
						if(App.map.inGrid({x:_x, z:_z})){
							node = App.map._aStarNodes[_x][_z];
							path.push(node);
						}
					}
					_x = coords.x + cells;
					for (_z = coords.z + 1; _z < coords.z + rows / 2; _z++) {
						if(App.map.inGrid({x:_x, z:_z})){
							node = App.map._aStarNodes[_x][_z];
							path.push(node);
						}	
					}
					break;	
				case 1:
					_x = coords.x - 1;
					for (_z = coords.z + 1; _z< coords.z + rows; _z++) {
						node = App.map._aStarNodes[_x][_z];
						path.push(node);
					}
					_z = coords.z + rows;
					for (_x = coords.x; _x< coords.x + rows/2; _x++) {
						node = App.map._aStarNodes[_x][_z];
						path.push(node);
					}
					break;	
				case 2:
					_x = coords.x - 1;
					for (_z = coords.z + 1; _z< coords.z + rows; _z++) {
						node = App.map._aStarNodes[_x][_z];
						path.push(node);
					}
					_z = coords.z + rows;
					for (_x = coords.x; _x< coords.x + rows; _x++) {
						node = App.map._aStarNodes[_x][_z];
						path.push(node);
					}
					break;		
			}
			
			path_reverse = path_reverse.concat(path);
			path_reverse.reverse();
			
			_workerPath = {
				0:path,
				1:path_reverse
			}
			
			workerPath[pos] = _workerPath;
		}
		
		public function getTechnoPosition(pos:int = 0):Object 
		{
			var workType:String = Personage.HARVEST;
			var direction:int = 0;
			var flip:int = 0;
			
			if (!crafting){
				workType = Personage.HARVEST;
				direction = 1;
			}
			
			generateWorkerPath(pos);
			
			var firstPlace:AStarNodeVO = workerPath[pos][1][0];
			return {
				x:firstPlace.position.x,//coords.x + info.area.w - 1,
				z:firstPlace.position.y,//coords.z + int(info.area.h / 2) + 2*id,
				direction:direction,
				flip:flip,
				workType:workType
			}
		}
		
		override public function flip():void {
			super.flip();
			isStreaming = false;
			showIcon();
		}
		
		public function clearTextures():void
		{
			if (textures){
				var _bmd:*;
				if(textures.animation && textures.animation.animations){
					for (var _anim1:* in textures.animation.animations)
					{
						for each(var _bmd1:* in textures.animation.animations[_anim1].frames){
							_bmd1.bmd.dispose();
							_bmd1.bmd = null;
						}
					}
					textures.animation.animations = null;
				}
				if(textures.sprites){
					for (_bmd in textures.sprites){
						textures.sprites[_bmd].bmp.dispose();
						textures.sprites[_bmd].bmp = null;
					}
					textures.sprites = null;
				}
				textures = null;
			}
			if (multiBitmap && multiBitmap.bitmapData)
			{
				multiBitmap.bitmapData.dispose();
				multiBitmap.bitmapData = null;
			}
			for each(var _anime:* in multipleAnime)
			{
				if (_anime.bitmapData)
				{
					_anime.bitmapData.dispose();
					_anime.bitmapData = null;
				}
			}
		}
		
		override public function uninstall():void {
			if(clearBmaps)
				clearTextures();
			if (!hasEventListener(AppEvent.ON_MAP_COMPLETE))
				App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, setTechnoesQueue);
			App.self.setOffTimer(production);
			if (icon)
				icon.filters = null;
			
			fireTechno();
			removeGround();
			
			super.uninstall();
			//if (clearVars)
				//clearVariables();
		}	
		
		override public function free():void {
			super.free();
			if (ground) ground.visible = false;
		}
		
		override public function take():void {
			super.take();
			if (ground) ground.visible = true;
		}
		
		private var effect:AnimationItem;
		public function addEffect(type:String):void 
		{
			return;
			var layer:int = 0;
			if (type == BUILD) {
				effect = new AnimationItem( { type:'Effects', view:type, params:AnimationItem.getParams(type, info.view) } );
				effect.blendMode = BlendMode.HARDLIGHT;
				layer = 1;
			}else if (type == BOOST) {
				effect = new AnimationItem( { type:'Effects', view:type, params:AnimationItem.getParams(type, info.view) } );
			}
			addChildAt(effect, layer);
			var pos:Object = IsoConvert.isoToScreen(int(cells / 2), int(rows / 2), true, true);
			effect.x = pos.x;
			effect.y = pos.y - 5;
		}
		
		public function removeEffect():void {
			if (effect){
				if(effect.parent)effect.parent.removeChild(effect);
				effect.stopAnimation();
				effect.dispose();
			}	
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			if (App.self.fakeMode)
				return EMPTY;
			//return EMPTY;
			if (App.user.quests.tutorial)
			{
				
				if ((coords.x > 84 && coords.x < 90) && (coords.z > 118 && coords.z < 125))
					return EMPTY;
				else
					return OCCUPIED;
			}
			//return EMPTY;
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (App.data.storage[sid].base == 1) {
						//trace(node.b, node.open, node.object);
						if ((node.b != 0 || node.open == false || node.object != null) && node.w != 1) {
							return OCCUPIED;
						}
						if (node.w != 1 || node.open == false || node.object != null) {
							return OCCUPIED;
						}
					} else {
						if (node.b != 0 || node.open == false || (node.object != null /*&& (node.object is Stall)*/)) {
							return OCCUPIED;
						}
					}
				}
			}
			return EMPTY;
		}
		
		public var craftLevels:int = 0;
		public function setCraftLevels():void
		{
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('craft')) {
				for each(var obj:* in info.devel.craft) {
					craftLevels++;
				}
			}else if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('open')) {
				for each(obj in info.devel.open) {
					craftLevels++;
				}
			}
		}
		
		override public function makeOpen():void 
		{
			super.makeOpen();
			showIcon();
		}
		
		public function changeIcon(e:AppEvent):void 
		{
			checkGlowing();
		}
		
		public function checkGlowing():void
		{
			if (level >= totalLevels || icon == null)
				return;
			if (!info.hasOwnProperty('instance'))
				return;
			var inst:int = instanceNumber();
			var needOnLevel:Object;
			if (info.instance.devel[inst].hasOwnProperty('obj'))
				needOnLevel = info.instance.devel[inst].obj[level + 1];
				
			if (needOnLevel != null && App.user.stock.checkRequired(needOnLevel))
			{
				icon.stopGlowing = false;
				icon.glowing();
			}else
			{
				icon.stopGlowing = true;
				//removeGlow();
			}
		}
		
		
		public var coordsCloud:Object = new Object();
		public function showIcon():void 
		{
			
			if (needQuest != 0 && !App.user.quests.data.hasOwnProperty(needQuest) && App.user.mode == User.OWNER)
				return;
			
			if (App.user.quests.tutorial && App.user.quests.data.hasOwnProperty("135") && App.user.quests.data[135].finished == 0) 
			{
				var crill:Building = Map.findUnit(499, 4);
				 if (crill)
				 {
					crill.startBlink();
					crill.showPointing('top', -88, -95);
				 }
			}
			
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
				/*if (App.user.mode == User.GUEST) {
					if (rotate == true){
						if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
					{
					coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
					coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
					}else{
					coordsCloud.x = 0;
					coordsCloud.y = -20;
						}
					}
				}*/
			
			if (App.user.mode == User.OWNER) 
			{
				if (this.sid == 2789 && level == 2)
					clearIcon()
				else if (/*completed.length > 0*/crafted > 0 && crafted <= App.time && hasProduct && formula) {
					drawIcon(UnitIcon.BUILDING_REWARD, formula.out, 1, {
						glow:		true,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else if (crafted > 0 && crafted >= App.time && formula) 
				{
					drawIcon(UnitIcon.PRODUCTION, formula.out, 1, {
						progressBegin:	crafted - formula.time,
						progressEnd:	crafted,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else if (hasPresent) 
				{
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		true,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else if (hasBuilded && upgradedTime > 0 && upgradedTime > App.time && level < totalLevels) 
				{
					drawIcon(UnitIcon.BUILDING, null, 0, {
						level: level,
						totalLevels: totalLevels,
						clickable:		false,
						boostPrice:		info.instance.devel[1].req[level + 1].f,
						progressBegin:	upgradedTime - info.instance.devel[1].req[level + 1].l,
						progressEnd:	upgradedTime,
						onBoost:		function():void {
							accelerateEvent(info.devel.skip[level + 1]);
						}
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1)) 
				{
					drawIcon(UnitIcon.BUILD, null, 0, {
						level: level,
						totalLevels: totalLevels
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else 
				{
					//removeGlow();
					clearIcon();
				}
			}
			else if (App.user.mode == User.GUEST) 
			{
				if (Friends.isOwnerSleeping(App.owner.id) && App.owner.id != '1' && App.social != 'SP') {
					clickable = false;
					return;
				} 
				
				if (level >= totalLevels && this.type != 'Bridge')
				{
					drawIcon(UnitIcon.REWARD, Stock.COINS, 1, {
						glow:		false,
						iconScale: .64
					}, 0, coordsCloud.x, coordsCloud.y);
				}
				else
					clearIcon();
				
			}
			checkGlowing();
		}
		
		public var cloudPositions:Object = {
			//Oracle
			'turtle_oracle':{
				x:0,
				y:0
			},'mailbox':{
				x:-10,
				y:-90
			},
			//Fatman
			'tobias_fatman':{
				x:0,
				y:-62
			},
			//Golden
			'amphora':{
				x:-2,
				y:30
			},
			'bogomol':{
				x:0,
				y:-0
			},
			'easel_one':{
				x:0,
				y:-80
			},
			'octopus_lamp':{
				x:0,
				y:-20
			},
			'danger_girl':{
				x:-11,
				y:-20
			},
			'dolphin':{
				x:-0,
				y:20
			},
			//Мосты
			'bridge_deep':{
				x:-280,
				y:180
			},
			'goaf_second':{
				x:-100,
				y:-95
			},
			//Building
			'well':{
				x:-15,
				y:-115
			},
			'electro_station':{
				x:35,
				y:30
			},
			'capsule':{
				x:8,
				y:15
			},
			'work_shop':{
				x:-10,
				y:-5
			},
			'weaving_workshop':{
				x:3,
				y:-10
			},
			'kitchen':{
				x:-10,
				y:-15
			},
			'workshop_squid':{
				x:-40,
				y:-15
			},
			'jeyzer_mill':{
				x:-65,
				y:-15
			},
			'sinoptic':{
				x:0,
				y:90
			},
			'plancton':{
				x:0,
				y:-15
			},
			'bridge_deep':{
				x:0,
				y:-15
			},
			'aqua_house':{
				x:-40,
				y:-15
			},
			'clay_mine':{
				x:0,
				y:10
			},
			'radar':{
				x:-10,
				y:20
			},
			'drug_store':{
				x:5,
				y:-120
			},
			'water_mill':{
				x:-15,
				y:50
			},
			'krill_tribute':{
				x:20,
				y:35
			},
			'flowerbed':{
				x:-5,
				y:-45
			},
			'flowerbed_2':{
				x:-5,
				y:-45
			},
			'table_with_pots':{
				x:-5,
				y:50
			},
			//Ctribute
			'big_whale':{
				x:-220,
				y:35
			},
			//Tribute
			'tribute_eat':{
				x:15,
				y:-75
			},'refrigerator':{
				x:20,
				y:-90
			},'plumbus_1':{
				x:0,
				y:-90
			},'plumbus_2':{
				x:0,
				y:-70
			},'bluebush_1':{
				x:0,
				y:-70
			},'bluebush_2':{
				x:0,
				y:-70
			},'bluebush_3':{
				x:0,
				y:-70
			},
			//Mfloors
			'ice_fish_1':{
				x:-5,
				y:-90
			},
			'fishbird':{
				x:-15,
				y:-70
			},
			'shell_ice':{
				x:-5,
				y:-70
			},
			'shell_ice':{
				x:0,
				y:-64
			},
			'egg_mfloors':{
				x:4,
				y:-64
			},
			//Gamble
			'lottery':{
				x:0,
				y:-130
			},
			//Booster
			'maniken':{
				x:0,
				y:-100
			},
			'icecream_booster':{
				x:0,
				y:-100
			},
			'dino_booster':{
				x:0,
				y:-70
			}
			
		}
	}
}