package 
{
	import api.ExternalApi;
	import core.Load;
	import core.Log;
	import core.Post;
	import flash.geom.Point;
	import ui.UpPanel;
	import units.Techno;
	import units.Unit;
	import wins.BankSaleWindow;
	import wins.BanksWindow;
	import wins.BonusBankWindow;
	import wins.DaylicWindow;
	import com.junkbyte.console.Cc;
	import wins.elements.BankMenu;
	import wins.ErrorWindow;
	import wins.LevelUpWindow;
	import wins.LuckybagContentWindow;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;
	import wins.WindowEvent;

	public class Stock 
	{
		public static const EXP:uint = 1;
		public static const COINS:uint = 2;
		public static const FANT:uint = 3;
		public static const FANTASY:uint = 7;
		public static const JAM:uint = 16;
		public static const SPHERE:uint = 54;
		public static const GUESTFANTASY:uint = 349;
		public static const TECHNO:uint = 8;
		public static const COOKIE:uint = 150;
		public static const CHAIR:uint = 1367;
		public static const BASKET:uint = 1489;
		public static const MOXIE:uint = 1684;
		public static const STOPWATCH:uint = 2024;
		public static const AMULET_EARTH:uint = 2305;
		public static const AMULET_FIRE:uint = 2306;
		public static const COUNTER_GUESTFANTASY:uint = 725;
		public static const ENERGY_CAPACITY_BOSUT:uint = 509000;
		
		static public const TENT:uint = 759;
		static public const GIFT_EXTENDER:uint = 785;
		public static const PENKNIFE:uint = 709;
		public static const MINEPICK:uint = 271;
		public static const KEY:uint = 1136;
		public static const FERTILIZER:uint = 345;
		public static const SEA_STONE:uint = 1159;
		public static const EVENT_COIN:uint = 1767;
		public static const LIGHT_RESOURCE:uint = 1226;
		public static const LIGHT:uint = 404;
		
		
		// исключение необходимых объектов, акционки
		public static const HAPPY_EASTER:uint = 520; 	// пасхокролик
		public static const HAPPY_BALLOON:uint = 767;	// воздушное шаро
		public static const HAPPY_CHO:uint = 1051;		// шоколад
		public static const HAPPY_ASTRO:uint = 1488;	// Алтарь небесных светил
		public static const CHRISTMAS_TREE:uint = 1857;	// Ёлка
		
		//Жиробасы
		public static const NORD_FATMAN:uint = 1776;	// Серверный рынок
		
		//Vip
		public static const MORE_ENERGY:uint = 114448888;
		public static const ENERGY_BOOM:uint = 1852;
		
		public var data:Object = null;
		public var blockPurchaseWindow:Boolean = true;
		public var blockSubrtactInformer:Boolean = false;
		public static var energyRestoreSettings:int =0;
	
		public static var _efirLimit:int = 0;
		public static var _limit:int = 0;
		public static var _value:int = 0;
		
		public static var _limit_mag:int = 0;
		public static var _limit_desert:int = 0;
		public static var _value_mag:int = 0;
		public static var _value_desert:int = 0;
		
		public var socialEnergyBonus:uint = 0;
		
		public var bonus:int = 0;
		/**
		 * Инициалиflash:1382952379984ция склада пользователя
		 * @param	data	объект склада
		 */
		public function Stock(data:Object)
		{
			
			var sID:String;
			for (sID in data) {
				if (App.data.storage[sID] == null)
				{
					delete data[sID];
					continue;
				}
				data[sID] = int(data[sID]);
			}
			
			
		
			
			this.data = data;
			energyRestoreSettings = App.data.options['EnergyRestoreTime'];
			maxEnergyOnLevel = App.data.levels[App.user.level].energy + socialEnergyBonus + ((data[Stock.ENERGY_CAPACITY_BOSUT]) ? data[Stock.ENERGY_CAPACITY_BOSUT] : 0);
	
			checkValue();
		}
		
		// Booster / Vip
		// Насколько ускорен получаемый sID
		public function boosted(sID:int, count:int):int 
		{
			for (var s:String in data) {
				if (App.data.storage[s].type == 'Vip' && data[s] > App.time && App.data.storage[s].outs.hasOwnProperty(sID)&&sID!=Stock.FANTASY){
					return Math.round(count * (App.data.storage[s].outs[sID] + 100) / 100);
				}
			}
			
			return count;
		}
		
		public static function set efirLimit(value:int):void {
			_efirLimit = value;
			App.ui.upPanel.updateEnergy();
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_FANTASY));
		}
		
		public static function get efirLimit():int {
			return _efirLimit;
		}
		
		public static function set limit(value:int):void {
			_limit = value;
		}
		public static function get limit():int {
			return _limit;
		}
		public static function set diffTime(value:int):void {
			_diffTime = value;
		}
		public static var _diffTime:int = 0;
		
		public static function get diffTime():int {
			return _diffTime;
		}
		//public var diffTime:int = energyRestoreSettings;
		public var maxEnergyOnLevel:int = 0;
		public function checkEnergy():void 
		{
			diffTime++;			
			if (diffTime >= energyRestoreSettings)
			{
				var energies:int = int(diffTime / energyRestoreSettings);				
				diffTime = diffTime % energyRestoreSettings;
				checkSystem();
			}
		}
		
		public static function get value():int {
			return _value;
		}
		
		public function checkValue():void {
			_value = 0;
			_value_mag = 0;
			_value_desert = 0;
			
			for (var sid:* in data) {
				
				if (App.data.storage[sid].type == 'Vip') continue;
				
				if (App.data.storage[sid].artifact) {
					switch(App.data.storage[sid].artifact) {
						case 1:
							_value_mag += data[sid];
							break;
						case 2:
							if(consider(sid))
								_value_desert += data[sid];
							break;	
					}
					continue;
				}	
				
				if(consider(sid))
					_value += data[sid];
			}
		}	
		
		/**
		 * Обновление склада
		 * @param	data	объект склада
		 */	
		
		public function bulkPost(needItems:Object, callBack:Function = null):void
		{
			Post.send({
				ctr:'stock',
				act:'bulk',
				uID:App.user.id,
				items:JSON.stringify(needItems)
			}, function(error:int, data:Object, params:Object):void {
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				if (callBack != null)
					callBack();
			});
		}
		 
		private function reinit(data:Object):void
		{
			this.data = data;
			App.ui.upPanel.update();
		}
		
		public function put(sID:uint, count:uint):void
		{
			data[sID] = count;
			App.ui.upPanel.update();
		}
		
		/**
		 * Возвращает кол-во текущего объекта на складе
		 * @param	sID	идентификатор объекта
		 * @return	uint	кол-во текущего объекта
		 */
		public function count(sID:uint):uint
		{
			return data[sID] == null ? 0 : data[sID]; 
		}
		
		/**
		 * Возвращает кол-во все виды варенья
		 * @return	Object	list:{sID:count}, totalCount
		 */
		public function jam(view:String = 'jam'):Object
		{
			var result:Object = {
				totalCount:0,
				list:{}
				}
			for (var sID:* in data)
			{
				if (App.data.storage[sID] == undefined) continue;
				
				var count:uint = count(sID)
				if (App.data.storage[sID].type == "Jam"){
					if (App.data.storage[sID].view == view) {
						if(count > 0){
							result.totalCount += count;
							result.list[sID] = count;
						}
					}
				}
			}
			
			return result;
		}
		
		/**
		 * Проверка кол-ва объекта на складе
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 * @return	true, если есть требуемое кол-во, false, если нет
		 */
		public function check(sID:uint, count:uint = 1):Boolean{
			if (data[sID] != null && data[sID] >= count) {
				return true;
			}
			
			if (sID == COINS || sID == FANT) {
				if (sID == COINS) {
					BankMenu._currBtn = BankMenu.COINS;
					BanksWindow.history = {section:'Coins',page:0};
				} else {
					BankMenu._currBtn = BankMenu.REALS;
					BanksWindow.history = {section:'Reals',page:0};
				}
				
				var text:String;
				switch(App.social) {
					case "PL":
						if (sID == COINS) {
							text = Locale.__e("flash:1382952379746");
						} else {
							text = Locale.__e("flash:1382952379749");
						}
						
						new SimpleWindow( {
							label:SimpleWindow.ATTENTION,
							text:text,
							buttonText:Locale.__e('flash:1382952379751'),
							confirm:function():void {
								if (sID == COINS) {
									ExternalApi.apiBalanceEvent('coins');
								} else {
									ExternalApi.apiBalanceEvent('reals');
								}
							}
						}).show();
						break;
						
					case 'YB':
					case 'MX':
						text = Locale.__e("flash:1382952379749");
						new SimpleWindow( {
							label:SimpleWindow.ATTENTION,
							text:text,
							forcedClosing:true,
							popup:true,
							buttonText:Locale.__e('flash:1382952379751'),
							confirm:function():void {
								new BanksWindow().show();
							}
						}).show();
						break;
						
					default:
						if (!Window.hasType(BanksWindow))
							new BanksWindow().show();
						break;
				}
			} else if(sID == FANTASY) {
				
				new PurchaseWindow( {
					width:600,
					itemsOnPage:3,
					content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Energy'}, Stock.FANTASY),
					title:Locale.__e("flash:1382952379756"),
					popup:true,
					closeAfterBuy:false,
					autoClose:false,
					description:Locale.__e("flash:1382952379757")
				}).show();
				
				App.user.onStopEvent();
				if (App.social == 'FB')
					ExternalApi._6epush([ "_event", { event: "achievement", achievement: "out_of_fantasy" } ]);
			} else if (sID == GUESTFANTASY) {
				
				new PurchaseWindow( {
					width:600,
					height: 390,
					itemsOnPage:3,
					content:PurchaseWindow.createContent("Energy", {view:'guestActionGold'}, 349),
					title:Locale.__e("flash:1396252152417"),
					useText:true,
					popup:true,
					//shortWindow:true,
					closeAfterBuy:false,
					autoClose:false,
					offsetY: 55,
					description:Locale.__e('flash:1382952379734')
				}).show();
				
				App.user.onStopEvent();
			} else if (sID == COOKIE) {
				
				new PurchaseWindow( {
				width:600,
				height:320,
				itemsOnPage:3,
				useText:true,
				cookWindow:true,
				columnsNum:3,
				scaleVal:1,
				noDesc:true,
				closeAfterBuy:false,
				autoClose:false,
				description:Locale.__e('flash:1393599816743'),
				content:PurchaseWindow.createContent("Energy", {view:['Cookies']}),
				title:App.data.storage[150].title,
				popup: true
			}).show();
			
				Techno.stopBusyTechno();
			}else if (sID == BASKET) {
				new PurchaseWindow( {
					width:600,
					itemsOnPage:3,
					content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Basket'}, Stock.BASKET),
					title:Locale.__e("flash:1491903407686"),
					description:Locale.__e("flash:1382952379757"),
					popup: true,
					closeAfterBuy:false,
					autoClose:false,			
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
				}).show();
			} /*else if (App.data.storage[sID].type == "Material" && !blockPurchaseWindow) {
				new PurchaseWindow( {
					width:550,
					itemsOnPage:3,
					closeAfterBuy:false,
					autoClose:false,
					content:PurchaseWindow.createContent("Energy", {view:'knife'}),
					popup:true
				}).show();
			
				App.user.onStopEvent();
			}*//* else if (sID == MINEPICK&&User.inExpedition) {
				new PurchaseWindow( {
					width:550,
					itemsOnPage:3,
					closeAfterBuy:false,
					autoClose:false,
					content:PurchaseWindow.createContent("Energy", {view:'picker'}),
					title:App.data.storage[271].title,
					popup:true
				}).show();
				
				App.user.onStopEvent();
			}*/
			return false;
		}
		
		public function checkAll(items:Object):Boolean {
			for(var sID:* in items) {
				if (!check(sID, items[sID])) return false;
			}
			return true;
		}
		
		/**
		 * Добавление объекта на склад в кол-ве count
		 * @param	sID	идентификатор объекта
		 * @param	count	его кол-во
		 */
		public function add(sID:uint, count:uint, update:Boolean = true):void
		{
			if (data[sID] == null) data[sID] = 0;
			data[sID] = int(data[sID]);
			//data[sID] += int(boosted(sID, count));
			data[sID] += int(count);
			if (consider(sID))	
			{
				value += count;
			}
			switch(sID) {
				case Stock.EXP:
						var currentLevel:int = App.user.level;
						while (App.data.levels[App.user.level + 1] && data[sID] >= App.data.levels[App.user.level + 1].experience) {
							App.user.level++;
							//TODO выдаем тихо бонусы, чтобы не показывать кучу окон
							for (var _sID:* in App.data.levels[App.user.level].bonus)
							{
								App.user.stock.add(_sID, App.data.levels[App.user.level].bonus[_sID]);
							}
						}
						
						if (currentLevel < App.user.level) {
							App.self.dispatchEvent(new AppEvent(AppEvent.ON_LEVEL_UP));
							//TODO показываем окно с ревардами и текущим новым уровнем
							
							var bonus:int = 0;
							if (App.social == 'PL' && App.data.options['PlingaEnergyPlus'] != undefined) {
								bonus = App.data.options['PlingaEnergyPlus'];
							}
							if (App.social == 'FB' && App.data.options['FBEnergyPlus'] != undefined) {
								bonus = App.data.options['FBEnergyPlus'];
							}
							
							Post.addToArchive('level ' + App.user.level);
							Cc.log('Level: ' + App.user.level);
							var energy:int = App.data.levels[App.user.level].energy + bonus;
							if (data[FANTASY] < energy) { 
								data[FANTASY] = energy;
								App.ui.upPanel.update(['energy']);
							}
							Post.addToArchive(data[FANTASY] + ' > ' + energy);
							App.user.quests.checkPromo(true);
							
							//делаем push в _6e
							if (App.social == 'FB') 
							{
								ExternalApi.og('reach','level');
							}
							
							//App.ui.rightPanel.addFreebie();
							Log.alert('ACHIEVED_LEVEL - 1')
							ExternalApi.logEvent('ACHIEVED_LEVEL','',{Level:App.user.level})
							var win:LevelUpWindow = new LevelUpWindow( { } );
							win.show();						
							
							if (App.user.level >= 5) 
							{
								App.ui.leftPanel.createAhappyIcon();
							}
							win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpening);
							function onAfterOpening(e:WindowEvent):void
							{
								win.removeEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpening);
								SoundsManager.instance.playSFX('levelup');
							}
							
							for (var i:int = 0; i < App.user.promos.length; i++ ) {
								App.user.promos[i]['showed'] = true;
							}
							
							//App.user.quests.checkPromo(true);
							
							var checkMoneyLevel:Function = function(l:*, s:*) : Boolean {
								for each(var value:* in l)
									if(value == s)	return true;
								return false;
							}
														
							if (checkMoneyLevel(App.data.money.level, App.user.level) && App.user.money < App.time) {
								Post.send( {
									ctr:		'user',
									act:		'money',
									uID:		App.user.id,
									enable:		1
								}, function(error:int, data:Object, params:Object):void {
									if (error)
									{
										Errors.show(error, data);
										return;
									}
									App.user.money = App.time + (App.data.money.duration || 24) * 3600;
									
									App.ui.salesPanel.addBankSaleIcon();
									App.ui.upPanel.addBankSaleIcon();
									App.ui.upPanel.updateTimeAction();
								});	
							}
						}
					break;
					
				case Stock.ENERGY_CAPACITY_BOSUT:
					maxEnergyOnLevel = App.data.levels[App.user.level].energy + socialEnergyBonus + ((data[Stock.ENERGY_CAPACITY_BOSUT]) ? data[Stock.ENERGY_CAPACITY_BOSUT] : 0);
					break
				case Stock.FANTASY:
					App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_FANTASY));
					break;
				case Stock.GUESTFANTASY:
					App.ui.leftPanel.showGuestEnergy();
					break;
				case Stock.CHAIR:
					App.ui.upPanel.update(['chair']);
				case Stock.MOXIE:
					App.ui.upPanel.update(['moxie']);
					break;
				case Stock.BASKET:
					App.ui.upPanel.update(['basket']);
					break;
				default:
					if(App.data.storage[sID].type == 'Vip')
						data[sID] = App.time + App.data.storage[sID].time;
					break;
			}
			if (App.data.options.bonusBankItem && sID == App.data.options.bonusBankItem)
			{
				App.ui.upPanel.update(['discount']);
				new BonusBankWindow({
					description: Locale.__e('flash:1512743369259')
				}).show();
			}	
			
			if(update&&App.ui.upPanel)
				App.ui.upPanel.update();
			if (App.ui.rightPanel) 
			{
			App.ui.rightPanel.update();	
			}	
			
			if (sID == Stock.FANTASY) {
				Cc.log("Energy(add): +"+count+"  total:"+App.user.stock.data[Stock.FANTASY]);
			}
			
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_STOCK));		
		}
		
		public function checkDaylics(sID:uint):void 
		{			
			for (var dID:String in Quests.daylicsList) 
			{
				var missions:* = Quests.daylicsList[dID].missions;
				
				if (Quests.daylicsList[dID].finished == 0) 
				{
					for (var mID:String in missions) 
					{
						if (Quests.daylicsList[dID].missions[mID].target 
							&& Quests.daylicsList[dID].missions[mID].target['0'] == sID 
							&& !Quests.daylicsList[dID].missions[mID].readyInformerWasShown 
							&& Quests.daylicsList[dID].missions[mID].func == "subtract" 
							&& App.user.stock.count(Quests.daylicsList[dID].missions[mID].target['0']) >= Quests.daylicsList[dID].missions[mID].need) 
						{	
							new SimpleWindow( {
								text:Locale.__e('flash:1450003984376'),
								label:SimpleWindow.ATTENTION,
								hasExit:false
							}).show();
							
							Quests.daylicsList[dID].missions[mID].readyInformerWasShown = true;
						}
					}					
					return;
				}				
			}
		}
		
		public function isOverlimitMaterial(sID:int):Boolean 
		{
			if (sID == 540)
				return true;
			
			return false;
		}
		
		public function addAll(items:Object):void 
		{
			for (var sID:* in items) 
			{
				add(sID, items[sID]);
			}
		}
		
		/**
		 * Удаление объекта со склада в укаflash:1382952379984нном кол-ве
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 * @return	true, если смогли взять, false, если не смогли
		 */
		public function take(sID:uint, count:uint, callback:Function = null):Boolean
		{
			if (check(sID, count))
			{
				switch(sID) {
					case Stock.FANTASY:
							data[sID] -= count;
							if (consider(sID))	value -= count;
							App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_FANTASY));
							//App.ui.upPanel.update(['fants']);
						break;
					case Stock.FANT:						
						data[sID] -= count;
						if (consider(sID))	value -= count;	
						ExternalApi.logEvent('SPENT_CREDITS', count, { ContentType:App.data.storage[sID].title, ContentID:sID } );
						break;
					case Stock.GUESTFANTASY:
							data[sID] -= count;
							if (consider(sID))	value -= count;
							App.ui.leftPanel.showGuestEnergy();
							if (App.user.stock.data.hasOwnProperty(COUNTER_GUESTFANTASY)&&App.user.stock.data[COUNTER_GUESTFANTASY]<=App.ui.upPanel.rel[App.ui.upPanel.rel.length-1].count) 
							{
								add(COUNTER_GUESTFANTASY, count);	
							}
							
							App.ui.upPanel.updateGuestBar();
						break;
					 default:
						data[sID] -= count;
						if (consider(sID))	value -= count;
				}
				
				
				App.ui.upPanel.update();
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_STOCK));
				return true;
			}		
			
			return false;
		}
		
		public function takeAll(items:Object):Boolean {
			if (!checkAll(items)) 
			return false;
			for (var sID:* in items) {
				if (!take(sID, items[sID])) 
				return false;
			}
			return true;
		}
		
		public function checkRequired(items:Object):Boolean {
			
			for (var sID:* in items) {
				if (data[sID] == null || data[sID] < items[sID])
				{
					return false;
				}
			
			}
			return true;
		}
		
		/**
		 * Покупка объекта
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 */
		public function buy(sID:uint, count:uint, callback:Function = null, sett:Object = null):void {
			
			var object:Object = App.data.storage[sID];
			var params:Object = { };
			var price:Object = {};
			var settings:Object = { 
					ctr:'stock',
					act:'buy',
					uID:App.user.id,
					sID:sID,
					count:count,
					wID:App.user.worldID
					
				};
				
			if (sett) {
				for (var it:* in sett) {
					settings[it] = sett[it];
				}
			}
			params[sID] = this.count(sID);
			
			for (var _sid:* in object.price) {
				price[_sid] = object.price[_sid] * count;
			}
			if (sett&&sett.ac) {
			price = App.data.storage[sID].currency;	
			}
			if (!takeAll(price)) return;
			
			add(sID, count);
				
			if (callback != null)
			{
				params['callback'] = callback;
				params['price'] = price;
			}
				
				Post.send(settings, onBuyEvent, params);
		}
		
		public function buyAll(items:Object):void
		{
			for (var itm:* in items)
				buy(itm, items[itm]);
		}
		
		/**
		 * Покупка пакета материалов
		 * @param	sID	идентификатор объекта
		 */
		public function pack(sID:uint, callback:Function = null, fail:Function = null, sett:Object = null):void 
		{
			var object:Object = App.data.storage[sID];
			var price:Object;
			
			var settings:Object = { 
					ctr:'stock',
					act:'pack',
					uID:App.user.id,
					sID:sID
				};
				
			if (sett) {
				for (var it:* in sett) {
					settings[it] = sett[it];
				}
			}
			
			if (object.hasOwnProperty('price')) price = object.price;
			else {
				var _price:int;
				object['count'] = Stock.efirLimit - App.user.stock.count(Stock.FANTASY);
				if (object['count'] > 0) _price = Math.ceil(object['count'] / 30);
				else _price = 0;
				
				settings['price'] = _price;
				settings['count'] = object['count'];
				
				price = { };
				price[Stock.FANT] = _price;
			}
			
			if (takeAll(price)) {
				
				if (!object.hasOwnProperty('out')){
					object['out'] = object.sID;
					object['count'] = 1;
				}	
					
				if(settings.ctr == "stock")add(object.out, object.count);
				
				Post.send(settings, function(error:*, result:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (callback != null) {
						callback(object.out, result);
					}
					
					App.self.dispatchEvent(new AppEvent(AppEvent.ON_AFTER_PACK));
				});
				
			}else {
				if (fail != null) {
					fail();
				}
			}
		}
		
		//Распаковка паков из банка
		public function unpack(sID:uint, callback:Function = null, fail:Function = null, sett:Object = null):void {
			//var object:Object = App.data.storage[sID];
			var settings:Object = { 
				ctr:'stock',
				act:'sets',
				uID:App.user.id,
				sID:sID,
				count:1
			};
			
			Post.send(settings, function(error:*, result:*, params:*):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (callback != null) {
					callback(result.bonus);
				}
			});
		}
		
		public function unpackArcane(sID:int):void{
			Post.send({
				ctr:'stock',
				act:'arcane',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:sID
			}, function(error:*, result:*, params:*):void {
				if (error) {
					Errors.show(error, result);
					return;
				}
				App.user.stock.takeAll(result.__take);
				App.map.focusedOn(App.user.hero);
				Treasures.bonus(result.bonus, new Point(App.user.hero.x, App.user.hero.y));
			});
		}
		
		public function packFree(sID:uint, callback:Function = null, fail:Function = null, sett:Object = null):void 
		{
			var object:Object = App.data.storage[sID];
			var settings:Object = { 
					ctr:'stock',
					act:'charge',
					uID:App.user.id,
					mID:sID
					//count:1
				};
				
			if (sett) {
				for (var it:* in sett) {
					settings[it] = sett[it];
				}
			}
			
					
				if(settings.ctr == "stock") add(object.out, object.count);
				take(sID, 1);
				Post.send(settings, function(error:*, result:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (callback != null) {
						callback(object.out, result);
					}
					
					App.self.dispatchEvent(new AppEvent(AppEvent.ON_AFTER_PACK));
				});
				
			
		}
		
		public function unpackLuckyBag(sID:uint, callback:Function = null, fail:Function = null):void 
		{
			var object:Object = App.data.storage[sID];
			var settings:Object = { 
				ctr:'stock',
				act:'luckybag',
				uID:App.user.id,
				sID:sID
			};
			
			take(sID, 1);
			
			Post.send(settings, function(error:*, result:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (callback != null) {
					
					new LuckybagContentWindow({ 
						popup: true,
						targetContent: result.bonus	
					}).show();
					
					callback(result.bonus);	
				}
			});
		}
		
		public function checkCollection(sID:uint):Boolean {
			var collection:Object = App.data.storage[sID];
			var materials:Object = { };
			for each(var mID:* in collection.materials){
				materials[mID] = 1;
			}
			return checkAll(materials);
		}
		
		public function exchange(sID:uint, callback:Function, count:int = 1):Boolean {
			
			var collection:Object = App.data.storage[sID];
			var materials:Object = { };
			for each(var mID:* in collection.materials){
				materials[mID] = count;
			}
			
			if (checkAll(sID)) {
				takeAll(materials);
			}else {
				return false;
			}
			
			Post.send( {
				ctr:'stock',
				act:'exchange',
				uID:App.user.id,
				sID:sID,
				count:count
			},onExchangeEvent, { sID:sID, callback:callback, count:count } );
			
			return true;
		}
		
		private function onExchangeEvent(error:int, data:Object, params:Object):void {
			
			var mID:*;
			var collection:Object = App.data.storage[params.sID];
			
			params.callback();
			
			if (error) {
				Errors.show(error, data);
				for each(mID in collection.materials){
					add(mID, 1);
				}
				return;
			}
			//Выдаем бонусы
			for (mID in collection.reward) {
				add(mID, collection.reward[mID]*params.count);
			}
			
		}
		
		/**
		 * flash:1382952380091 объекта
		 * @param	sID	идентификатор объекта
		 * @param	count	требуемое кол-во
		 */
		public function sell(sID:uint, count:uint, callback:Function = null):void {
			
			var object:Object = App.data.storage[sID]; 
			var price:int = object.cost * count;
			
				add(COINS, price);
				take(sID, count);
				
			var params:Object = { }
			params['callback'] = callback;
				
				Post.send({
					ctr:'stock',
					act:'sell',
					uID:App.user.id,
					sID:sID,
					count:count
				},onSellEvent, params);
		}
		
		private function onSellEvent(error:int, data:Object, params:Object):void {
			var id:*;
			
			if (error) {
				Errors.show(error, data);
				if (data) reinit(data);
				if (params) params.callback()
				return;
			}
			
			for (id in data) {
				if (this.data[id] != data[id]) {
					this.data[id] = data[id];
				}
				
				if (params && params.callback != null) params.callback();
			}
		}
		
		
		
		private function onBuyEvent(error:int, data:Object, params:Object):void {
			var id:*;
			
			if (error) {
				Errors.show(error, data);
				//Возвращаем как было
				for (id in params) {
					this.data[id] = params[id];
				}
				if (data) reinit(data);
				return; 
			}
			
			for (id in data) {
					if (App.data.storage[id] && App.data.storage[id].type == 'Vip' && this.data[id] > App.time) {
						App.user.activeBooster();
					}
				if (this.data[id] != data[id]) {
					//TODO втихаря меняем на актуальное значение, которое пришло от сервера
					//или как-то иначе обрабатываем несоотвествие
					this.data[id] = data[id];
				}
			}
			
			if (params.hasOwnProperty('callback')) {		//Denis
				params.callback(/*params['money'],*/params.price);
			}
		}
		
		public function checkSystem(energyRestoreReset:Boolean = false):void
		{
			Post.send( {
				ctr:		'stock',
				act:		'system',
				uID:		App.user.id,
				r:			int(energyRestoreReset)
			},
			function(error:*, data:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				if (data == null) return;
				
				if(data.hasOwnProperty('gifts')){
					var hasGift:Boolean = false;
					
					for (var gID:String in data.gifts) {
					Gifts.addGift(gID, data.gifts[gID]);
						hasGift = true;
					}
					if (hasGift) {
					}
					
					App.user.gifts.sortOn("time", Array.DESCENDING);
					if (App.user.gifts.length > (App.data.options['GiftsLimit']+((App.user.stock.check(Stock.GIFT_EXTENDER))?App.user.stock.data[Stock.GIFT_EXTENDER]:0))) {
						App.user.gifts.splice((App.data.options['GiftsLimit']+((App.user.stock.check(Stock.GIFT_EXTENDER))?App.user.stock.data[Stock.GIFT_EXTENDER]:0)), App.user.gifts.length - (App.data.options['GiftsLimit']+((App.user.stock.check(Stock.GIFT_EXTENDER))?App.user.stock.data[Stock.GIFT_EXTENDER]:0)));
						if(App.ui) App.ui.rightPanel.update();
					}
				}
				
				if(data.hasOwnProperty(Stock.FANTASY)){
					App.user.stock.data[Stock.FANTASY] = data[Stock.FANTASY];
					Post.addToArchive("server addOnTime  total:"+data[Stock.FANTASY]);
				}
				
				if(data.hasOwnProperty('restore')){
					App.user.energy = data.restore;
					if (data[FANTASY] < maxEnergyOnLevel) diffTime = App.time - data.restore;
					if (diffTime > energyRestoreSettings) diffTime = diffTime % energyRestoreSettings;
				
				}	
				
				if(App.ui != null && App.ui.upPanel != null){
					App.ui.upPanel.update();
				}
			});
		}	
		
		public function setFantasy(count:uint):void
		{
			Cc.log("Energy(set): " + App.user.stock.data[Stock.FANTASY] + " -> " + count);
			Post.addToArchive("take: " + App.user.stock.data[Stock.FANTASY] + " -> " + count);
			if (data[Stock.FANTASY] >= maxEnergyOnLevel && count < maxEnergyOnLevel) diffTime = energyRestoreSettings;
			data[Stock.FANTASY] = count;
			if (App.user.energy == 0) {
				App.user.energy = App.time;
			}
				
			App.ui.upPanel.update(['energy']);
			if (data[Stock.FANTASY] == 0) {
					App.user.onStopEvent();
					Post.clear();
					
					new PurchaseWindow( {
						width:600,
						itemsOnPage:3,
						content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Energy'}, Stock.FANTASY),
						title:Locale.__e("flash:1382952379756"),
						description:Locale.__e("flash:1382952379757"),
						popup: true,
						closeAfterBuy:false,
						autoClose:false,			
						callback:function(sID:int):void {
							var object:* = App.data.storage[sID];
							App.user.stock.add(sID, object);
						}
					}).show();
			}
		}
		
		//Trigger
		public function get countFG():int
		{
			var re:int = 0;
			for (var _sid:String in data)
			{
				if ( App.data.storage[_sid].free )
					re += data[_sid];
			}
			return re;
		}
		
		
		public function charge(sID:uint, count:uint = 1):void {
			
			if (!take(sID, count)) return;
			
			if (App.data.storage[sID].type == 'Vip') {
				Post.send( {
					ctr:'stock',
					act:'recharge',
					sID:sID,
					uID:App.user.id,
					count:count
				},function(error:int, data:Object, params:Object):void {
					if (error) {
						Errors.show(error, data);
						App.user.boostCompleteTime = 0;
						return;
					}
					
					if (!App.user.stock.data[sID]) App.user.stock.data[sID] = 0;
					if (data[sID]) App.user.stock.data[sID] = data[sID];
					App.user.activeBooster();
				});
			}else{
				Post.send( {
					ctr:'stock',
					act:'charge',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:sID,
					count:count
				},function(error:*, result:*, params:*):void {
					
					if (error) {
						Errors.show(error, result);
						return;
					}
					add(App.data.storage[sID].out, App.data.storage[sID].count, true);
					
					
					if (App.data.storage[sID].out == Stock.ENERGY_CAPACITY_BOSUT) {
						add(Stock.ENERGY_CAPACITY_BOSUT, (App.data.storage[sID].count+data[Stock.ENERGY_CAPACITY_BOSUT]));
					}
					App.ui.upPanel.update(['energy','cookie']);
				
					
					App.user.activeBooster();
				});
			}
			
		
		}
		
		public static function set value(count:int):void 
		{
			_value = count;
			// Показываем прогресс в upPanel
		}	
		
		public static function notAvailableItems():Array 
		{
			var updtItems:Array = [];
			if(App.data.updatelist.hasOwnProperty(App.social)) {
				for (var s:String in App.data.updatelist["DM"]) {
					if (!App.data.updates[s].social.hasOwnProperty(App.social)) {
						for(var sidItem:* in App.data.updates[s].items){
							updtItems.push(sidItem);
						}
					}
				}
			}
			return updtItems;
		}
		
		public static function checkBuyEnergy(sid:int):Boolean
		{
			for each (var itm:* in App.data.storage)
			{
				if (itm.type == 'Energy' && itm.out == sid)
				{
					return true
				}
			}
			return false;
		}
		
		public static function consider(sid:int):Boolean 
		{
			switch(sid) {
				case EXP:
				case COINS:
				case FANT:
				case FANTASY:
				case GUESTFANTASY:
				case JAM:
					return false;
				break;	
			}
			
			var item:Object = App.data.storage[sid];
			
			switch(item.type){
				case 'Material':
					if (item.mtype == 3 || item.mtype == 4)
						return false;
					else
						return true;
						
					break;
				case 'Jam':
				case 'Clothing':
				case 'Lamp':
				case 'Animal':
				case 'Guide':
				return false;
					break;
				default:
						return true;
					break;	
			}
			
			return true;
		}		
		
		public static function isExist(sid:*):Boolean 
		{
			var vvb:* = App.user.stock.data[sid];
			if(vvb != null)
				return true;
			
			return false
		}
		
		public function canTake(obj:*):Boolean 
		{
			return true;			
		}
		
		public function takeValue(sid:int, count:int):void {
			var item:Object = App.data.storage[sid];
			
			if (App.data.storage[sid].type == 'Vip') return;
			if (item.artifact) {
				switch(item.artifact) {
					case 1:
						_value_mag -= count;
						break;
					case 2:
						if (consider(sid))
							_value_desert -= count;
						break;	
				}
				return;
			}	
			if (consider(sid))
				_value -= count;
		}
		
		public function addValue(sid:int, count:int):void {
			var item:Object = App.data.storage[sid];
			
			if (App.data.storage[sid].type == 'Vip') return;
			if (isOverlimitMaterial(sid)) return;
			
			
			if (item.artifact) {
				switch(item.artifact) {
					case 1:
						_value_mag += count;
						break;
					case 2:
						if (consider(sid))
							_value_desert += count;
						break;	
				}
				return;
			}
		}
		
		public function remove(sID:uint, count:int = 0):void {
			
			var countD:int = data[sID];
			
			if (countD - count <= 0)
				delete data[sID];
			else
				data[sID] -= count;
			
			value -= count;
			Post.send( {
				ctr:'stock',
				act:'remove',
				uID:App.user.id,
				sID:sID,
				count:count
			},function(error:*, result:*, params:*):void 
			{
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}		
		
		public static function isHarvest(sid:int):Boolean 
		{
			for each(var itm:* in App.data.storage)
			{
				if (itm.type == 'Plant')
				{
					if (itm.outs && itm.outs.hasOwnProperty(sid))
					{
						return true;
						
					}
					
				}
					
				
			}
			return false;
		}
		
		public static function canBuySell(sid:int):Boolean
		{
			var item:Object = App.data.storage[sid]
			if (item.mtype == 3 || item.mtype == 4 || item.mtype == 6 || item.mtype == 8)
				return false
			return true;
		}
	}	
}