package utils 
{
	import adobe.utils.CustomActions;
	import core.Numbers;
	import core.Post;
	import flash.system.Capabilities;
	import wins.ActionInformerWindow;
	import wins.ActionSandWindow;
	import wins.ActionWoodBoxWindow;
	import wins.ActionWoodWindow;
	import wins.BanksWindow;
	import wins.BigsaleWindow;
	import wins.BubbleActionWindow;
	import wins.MaterialActionWindow;
	import wins.PremiumActionWindow;
	import wins.PromoWindow;
	import wins.RoomSetWindow;
	import wins.SaleDecorWindow;
	import wins.SaleGoldenWindow;
	import wins.SaleGoldenWindowExtended;
	import wins.SaleGoldenWinterWindow;
	import wins.SaleLimitWindow;
	import wins.SaleVipWinterWindow;
	import wins.SalesWindow;
	import wins.TemporaryActionWindow;
	import wins.TriggerPromoWindow;
	/**
	 * ...
	 * @author 
	 */
	public class ActionsHelper 
	{
		public static const CURRENCY:int = 1;
		public static const MATERIAL:int = 2;
		public function ActionsHelper() 
		{
			
		}
		
		public static var extraPromos:Array = new Array();
		
		public static function updateActions():void
		{
			var actionsArch:Object = App.user.storageRead('actions', { } );
			App.user.buyActions = App.user.storageRead('buyActions', { } );
			//storageStore('actions', { }, true );
			//return;
			//if (id == '84003280') actionsArch = { };
			if (!App.data.hasOwnProperty('actions')) return;
			
			if (actionsArch is Array) {
				var object:Object = { };
				for (var ind:int = 0; ind < actionsArch.length; ind++) {
					if (actionsArch[ind] != null) object[ind] = actionsArch[ind];
				}
				actionsArch = null;
				actionsArch = object;
			}
			
			// Удалить куки несуществующих акций или акций которые уже не появятся. ОДИН РАЗ ПРИ ЗАПУСКЕ!
			var arch:Object;
			var pID:String;
			if(App.user.promoFirstParse) {
				for (pID in actionsArch) {
					if (pID == '1080') continue;
					if (!App.data.actions.hasOwnProperty(pID)) {
						delete actionsArch[pID];
					}else{
						arch = App.data.actions[pID];
						if (arch.type == 0 
						&& (arch.unlock.level && arch.unlock.level < App.user.level) 
						&& (arch.unlock.quest && App.user.quests.data.hasOwnProperty(arch.unlock.quest) 
						&& App.user.quests.data[arch.unlock.quest].finished > 0)) {
							delete actionsArch[pID];
						}else if (arch.type != 0 && arch.time + arch.duration * 3600 < App.time) {
							delete actionsArch[pID];
						}
					}
				}
			}
			
			// Удаление не подходящих по условиям акций
			/*for (pID in actionsArch) {
				arch = App.data.actions[pID];
				if (arch.unlock.lto > 0 && arch.unlock.lto <= level) {
					delete actionsArch[pID];
				}
			}*/
			
			App.user.promo = {};
			App.user.promos = [];
			App.user.premiumPromos = [];
			App.user.oncePromos = [];
			App.user.boostPromos = [];
			
			var promoNormal:Array = [];
			var promoUnique:Array  = [];
			
			for (var arId:* in actionsArch) 
			{
				if (actionsArch[arId] == null)
					actionsArch[arId] = { };
			}
			
			for (var aID:String in App.data.actions) 
			{
				var action:Object = App.data.actions[aID];
				var open:Boolean = false;
				
				
				// Пропустить если купили
				if (aID == '1665')
					trace();
				if (actionsArch.hasOwnProperty(aID) && actionsArch[aID] != null && App.data.actions.hasOwnProperty(aID) && App.data.actions[aID] != null && !App.data.actions[aID].more && actionsArch[aID].buy) {
					delete actionsArch[aID].time;
					delete actionsArch[aID].prime;
					continue;
				}
				
				if (actionsArch.hasOwnProperty(aID) && actionsArch[aID] != null && App.data.actions.hasOwnProperty(aID) &&
				App.data.actions[aID] != null && App.data.actions[aID].more && App.data.actions[aID].countsell &&
				App.user.buyActions.hasOwnProperty(aID) && App.user.buyActions[aID] >= App.data.actions[aID].countsell)
				{
					delete actionsArch[aID].time;
					delete actionsArch[aID].prime;
					continue;
				}
				// Нет в социальной сети
				if (!action.mprice && (!action.price || !action.price.hasOwnProperty(App.social))) continue;
				
				// Не наступила
				if (App.time < action.time) continue;
				// Платящие акцию не увидят
				if (App.user.pay > 0 && action.hasOwnProperty('pay') && action.pay == 1) continue;
				
				action['pID'] = aID;
				action['buy'] = 0;
				if (!action.hasOwnProperty('prime')) action['prime'] = 0;
				
				// Проверка если есть зона и она открыта
				var alreadyOpened:Boolean = false;
				for (var _sid:* in action.items) {
					if (App.data.storage.hasOwnProperty(_sid)){
						if (action.checkstock && action.checkstock == 1 && Stock.isExist(_sid)){
							alreadyOpened = true;
							break;
						}
						if (App.data.storage[_sid].type == 'Zones') {
							if (World.zoneIsOpen(_sid))
								alreadyOpened = true;
						}
					}
				}
				
				var whileQuestComplete:Boolean = false;
				if (action.hasOwnProperty('whilequest') && action.whilequest != '')
				{
					var parentQuest:int = App.data.quests[action.whilequest].parent

					if (App.user.quests.data[parentQuest] && App.user.quests.data[parentQuest].finished && 
					!App.user.quests.data[action.whilequest].finished){
						whileQuestComplete = true;
						
					}
				}
				if (aID == '2029')
					trace();	
				
				if (action.hasOwnProperty('friendsless') && action.friendsless !="" && App.network.appFriends.length >= action.friendsless)
					continue;
				
				if (alreadyOpened)
					continue;
				if (action.hasOwnProperty('whilequest') && action.whilequest != '' && !whileQuestComplete)
					continue;
				
				if (action.type == 0) { // Обычные
					
					if (action.hasOwnProperty('paygroup'))
					{
						if (!checkPaygroup(action.paygroup))
							continue;
					}//if (((action.unlock.level && level >= action.unlock.level) || (action.unlock.quest && quests.data.hasOwnProperty(action.unlock.quest) && quests.data[action.unlock.quest].finished == 0)) || (actionsArch.hasOwnProperty(aID) && actionsArch[aID] != null && actionsArch[aID].time + action.duration * 3600 > App.time)) {
					if (!(actionsArch.hasOwnProperty(aID) && actionsArch[aID] != null && actionsArch[aID].buy == 1  && actionsArch[aID].time + action.duration * 3600 > App.time) &&
					((action.unlock.level != '' && action.unlock.quest == '' && App.user.level >= action.unlock.level) ||
					 (action.unlock.quest != '' && action.unlock.level == '' && App.user.quests.data.hasOwnProperty(action.unlock.quest)) ||
					 (action.unlock.level != '' && action.unlock.quest != '' && App.user.level >= action.unlock.level && App.user.quests.data.hasOwnProperty(action.unlock.quest))))
					{
						if (action.unlock.lto != '' && App.user.level > action.unlock.lto) {
							continue;
						}
						open = true;
						if (!actionsArch.hasOwnProperty(aID)) {
							action.prime = 1;
							actionsArch[aID] = {
								prime:	1,
								buy:	0,
								time:	App.time
							};
						}else {
							if (actionsArch[aID].prime) actionsArch[aID].prime = 0;
							if (actionsArch[aID].time + action.duration * 3600 < App.time) {
								open = false;
							}
						}
						if (open) {
							action['begin_time'] = actionsArch[aID].time;
							promoNormal.push(action);
						}
					} /*else {
						//if (actionsArch.hasOwnProperty(aID)) delete actionsArch[aID];
					}*/
				} else if (action.type == 1) { // Уникальные
					if (action.hasOwnProperty('paygroup') && action.paygroup)
					{
						if (!checkPaygroup(action.paygroup))
							continue;
					}
					if ((App.time >= action.time && App.time < action.time + action.duration * 3600) &&
					((action.unlock.level != '' && action.unlock.quest == '' && App.user.level >= action.unlock.level) ||
					 (action.unlock.quest != '' && action.unlock.level == '' && App.user.quests.data.hasOwnProperty(action.unlock.quest)) ||
					 (action.unlock.level != '' && action.unlock.quest != ''  && App.user.level >= action.unlock.level && App.user.quests.data.hasOwnProperty(action.unlock.quest))))
					{
						if (action.unlock.lto != '' && App.user.level > action.unlock.lto) {
							continue;
						}
						open = true;
						if (!actionsArch.hasOwnProperty(aID)) {
							action.prime = 1;
							actionsArch[aID] = {
								prime:	1,
								buy:	0,
								time:	App.time
							};
						}else {
							if (actionsArch[aID].prime) actionsArch[aID].prime = 0;
						}
						action['begin_time'] = action.time;
						promoUnique.push(action);
					}else {
						if (actionsArch.hasOwnProperty(aID))
							delete actionsArch[aID];
					}
				}else if (action.type == 2) {//Премиум
					if ((action.duration == 0 || (App.time >= action.time && App.time < action.time + action.duration * 3600)) &&
						(action.unlock.lto != '' && action.unlock.level != '' && action.unlock.lto >= App.user.level && App.user.level >= action.unlock.level) ||
						(action.unlock.level != '' && action.unlock.lto == '' && App.user.level >= action.unlock.level)) {
						
						if (action.unlock.lto != '' && App.user.level > action.unlock.lto) {
							continue;
						}
						if (!actionsArch.hasOwnProperty(aID)) {
							action['first'] = true;
							actionsArch[aID] = {
								shows:	0,
								buy:	0
							};
						}else {
							if (actionsArch[aID].buy == 1)
								continue;
							if (App.user.promoFirstParse) 
								actionsArch[aID].shows ++;
						}
						App.user.premiumPromos.push(action);
						
						action['shows'] = actionsArch[aID].shows;
						for (var sid:String in action.items) break;
						action['sid'] = sid;
					}
				}else if (action.type == 3) {
					if (App.user.triggerOpen == int(aID) && (!actionsArch.hasOwnProperty(aID) || actionsArch[aID].time + action.duration * 3600 < App.time)) 
					{
						if (action.unlock.lto != '' && App.user.level > action.unlock.lto) {
							continue;
						}
						action.prime = 1;
						open = true;
						actionsArch[aID] = {
							prime:	1,
							buy:	0,
							time:	App.time
						};
						action['begin_time'] = App.time;
						promoNormal.push(action);
					}
					else if (App.user.triggerOpen != int (aID) && (!actionsArch.hasOwnProperty(aID) || actionsArch[aID].time + action.duration * 3600 > App.time))
					{
						open = true;
						promoNormal.push(action);
					}
					//oncePromos.push(action);
				}else if (action.type == 4) {
					App.user.boostPromos.push(action);
				}else if (action.type == 5) {
					//
				}else if (action.type == 6) {
					if (!(actionsArch.hasOwnProperty(aID) && actionsArch[aID] != null && actionsArch[aID].time + action.live < App.time) ||
						(action.unlock.level && !action.unlock.quest && App.user.level >= action.unlock.level) ||
						(action.unlock.quest && !action.unlock.level && App.user.quests.data.hasOwnProperty(action.unlock.quest) && App.user.quests.data[action.unlock.quest].finished == 0) ||
						(action.unlock.level && App.user.level >= action.unlock.level && action.unlock.quest && App.user.quests.data.hasOwnProperty(action.unlock.quest) && App.user.quests.data[action.unlock.quest].finished == 0)) {
						
						if (action.unlock.lto != '' && App.user.level > action.unlock.lto) {
							continue;
						}
						open = true;
						var newquest:Boolean = true;
						if (actionsArch.hasOwnProperty(aID) && actionsArch[aID] != null) {
							if (actionsArch[aID].prime) actionsArch[aID].prime = 0;
							if (actionsArch[aID].time + action.live < App.time) {
								open = false;
								if (actionsArch[aID].time + action.hide < App.time) {
									delete actionsArch[aID];
									open = true;
								}
							}else {
								newquest = false;
							}
						}
						
						if (open) {
							if (newquest && Math.random() < 0.8) continue;
							
							if (!actionsArch.hasOwnProperty(aID)) {
								action.prime = 1;
								actionsArch[aID] = {
									prime:	1,
									buy:	0,
									time:	App.time
								};
							}
						}
						
						if(open) {
							action['begin_time'] = actionsArch[aID].time;
							promoNormal.push(action);
						}
					}else {
						if (actionsArch.hasOwnProperty(aID)) delete actionsArch[aID];
					}
				}else if (action.type == 12) { // Уникальные
					if ((App.time >= action.time && App.time < action.time + action.duration * 3600) &&
					((action.unlock.level != '' && action.unlock.quest == '' && App.user.level >= action.unlock.level) ||
					 (action.unlock.quest != '' && action.unlock.level == '' && App.user.quests.data.hasOwnProperty(action.unlock.quest)) ||
					 (action.unlock.level != '' && action.unlock.quest != ''  && App.user.level >= action.unlock.level && App.user.quests.data.hasOwnProperty(action.unlock.quest))))
					{
						if (action.unlock.lto != '' && App.user.level > action.unlock.lto) {
							continue;
						}
						open = true;
						if (!actionsArch.hasOwnProperty(aID)) {
							action.prime = 1;
							actionsArch[aID] = {
								prime:	1,
								buy:	0,
								time:	App.time
							};
						}else {
							if (actionsArch[aID].prime) actionsArch[aID].prime = 0;
						}
						action['begin_time'] = action.time;
						promoUnique.push(action);
					}else {
						if (actionsArch.hasOwnProperty(aID))
							delete actionsArch[aID];
					}
				}
				
				if (open) {
					App.user.promo[aID] = action;
				}
			}
			
			promoNormal.sortOn('order', Array.DESCENDING);
			promoNormal.sortOn('prime', Array.DESCENDING);
			promoUnique.sortOn('order', Array.DESCENDING);
			promoUnique.sortOn('prime', Array.DESCENDING);
			
			if (promoUnique.length > 0) App.user.promos.unshift(promoUnique.shift());
			if (promoNormal.length > 0) App.user.promos.push(promoNormal.shift());
			App.user.promos = App.user.promos.concat(promoUnique);
			App.user.promos = App.user.promos.concat(promoNormal);
			
			if (App.user.promoFirstParse)
			{
				if (App.user.premiumPromos.length > 0)
				{
					action = App.user.premiumPromos[0];
					//App.ui.rightPanel.createPremiumPromo(Boolean(action.first));
					action.first = false;
					//if (action.shows < 3) {
						/*setTimeout(function():void {
							new PremiumWindow( {pID:action.pID} ).show();
						}, 3000);*/
					//}
				}
				
				//if (oncePromos.length > 0) {
					//App.self.addEventListener(AppEvent.ON_STOCK_ACTION, onStockAction);
				//}
			}
			
			App.user.promoFirstParse = false;			
			
			App.user.storageStore('actions', actionsArch);
			
			for (var actId:* in App.user.promo) 
			{
				if (App.user.promo[actId].hasOwnProperty('shenter') && App.user.promo[actId].shenter == 1 && needOpenPromos.indexOf(actId) == -1)
					needOpenPromos.push(actId);
			}
			/*for (var actPId:* in promoNormal) 
			{
				if (promoNormal[actPId].ishow == 1 && needOpenPromos.indexOf(actPId) == -1)
					needOpenPromos.push(actPId);
			}*/
			if(Capabilities.playerType != 'StandAlone')
				App.self.addEventListener(AppEvent.ON_HERO_LOAD, openActions);
			
			if (App.user.triggerOpen > 0 && !App.user.quests.tutorial)
			{
				if (TriggerPromoWindow.showed.indexOf(App.user.triggerOpen) == -1)
					new TriggerPromoWindow( { pID:App.user.triggerOpen } ).show();
				
				App.user.triggerOpen = 0;
			}
		}
		
		public static var needOpenPromos:Array = [];
		public function updateActions():void 
		{
			
			ActionsHelper.updateActions();
		}
		
		public static function openActions(e:* = null):void 
		{
			var actionsArch:Object = App.user.storageRead('actions', { } );
			var timeOffset:int = 15;
			for each(var aID:* in needOpenPromos)
			{
				if (actionsArch.hasOwnProperty(aID) && actionsArch[aID].time && actionsArch[aID].time + timeOffset > App.time)
					ActionsHelper.openAction(aID,  App.data.actions[aID]);
			}
			App.self.removeEventListener(AppEvent.ON_HERO_LOAD, openActions);
		}
		
		public static function openAction(pID:*,promo:*):void
		{
			var action:Object
			
			if (promo.sale == 'bigSale') 
			{
				action =  App.data.bigsale[pID];	
			}else 
			{
				action =  App.data.actions[pID];	
			}
			
			if (promo.hasOwnProperty('additional'))
			{
				action =  promo;
			}
			
			var actionsArch:Object = App.user.storageRead('actions', { } );
			
			switch(action.type)
			{
				case 0:
				case 1:
					if (actionsArch.hasOwnProperty(pID)) 
					{
						if (actionsArch[pID].hasOwnProperty('shows')) 
							actionsArch[pID]['shows'] = actionsArch[pID]['shows'] + 1;
						else
							actionsArch[pID]['shows'] = 1;
							
						App.user.storageStore('actions', actionsArch);
					}
					break;
			}
			
			if (action.bg && action.bg == 'ActionSandWindow')
			{
				new ActionSandWindow( { pID:pID } ).show();
				return;
			}
			
			if (action.bg && action.bg == 'MaterialActionWindow')
			{
				new MaterialActionWindow( { pID:pID } ).show();
				return;
			}
			
			if (action.bg && action.bg == 'TemporaryActionWindow')
			{
				new TemporaryActionWindow( { pID:pID } ).show();
				return;
			}
			
			if (action.bg && action.bg == 'ActionWoodWindow')
			{
				new ActionWoodWindow( { pID:pID } ).show();
				return;
			}
			
			if (action.bg && action.bg == 'ActionWoodBoxWindow')
			{
				new ActionWoodBoxWindow( { pID:pID } ).show();
				return;
			}
			
			if (action.bg && action.bg == 'ActionInformerWindow')
			{
				new ActionInformerWindow( { pID:pID } ).show();
				return;
			}
			
			if (action.bg && action.bg == 'SaleLimitWindow')
			{
				new SaleLimitWindow( { pID:pID } ).show();
				return;
			}
			
			if (action.bg && action.bg == 'BubbleActionWindow')
			{
				new BubbleActionWindow( { pID:pID } ).show();
				return;
			}
			
			if (action.bg && action.bg == 'SaleGoldenWindow')
			{
				new SaleGoldenWindow( { pID:pID } ).show();
				return;
			}
			
			if (action.bg && action.bg == 'SaleGoldenWinterWindow')
			{
				new SaleGoldenWinterWindow( { pID:pID } ).show();
				return;
			}
			
			if (action.bg && action.bg == 'SaleVipWinterWindow')
			{
				new SaleVipWinterWindow( { pID:pID } ).show();
				return;
			}
			
			if (action.bg && action.bg == 'SaleGoldenWindowExtended')
			{
				new SaleGoldenWindowExtended( { pID:pID } ).show();
				return;
			}
			
			if (promo['bg'] == 'RoomSetWindow' && App.data.actions.hasOwnProperty(pID))
			{
				new RoomSetWindow( { pID:pID } ).show();
				App.user.unprimeAction(pID);
				return;
			}
			
			if (promo['bg'] == 'PremiumActionWindow' && App.data.actions.hasOwnProperty(pID))
			{
				new PremiumActionWindow( { pID:pID } ).show();
				App.user.unprimeAction(pID);
				return;
			}
			
			if (promo['sale'] == 'premium')
			{
				new SaleLimitWindow({pID:pID}).show();
				return;
			}
			
			if (promo['sale'] == 'bankSale')
			{
				new BanksWindow().show();
				return; title
			}
			
			if (App.data.actions.hasOwnProperty(pID) && App.data.actions[pID].type == 3)
			{
				new TriggerPromoWindow( { pID:pID } ).show();
				return;
			}
			
			if (promo.hasOwnProperty('additional'))
			{
				new PromoWindow( { pID: -1, additional:true, action:promo} ).show();
			}
			
			if (promo['sale'] == 'promo' && App.data.actions.hasOwnProperty(pID))
			{
				new PromoWindow( { pID:pID } ).show();
				App.user.unprimeAction(pID);
				return;
			}
			
			if (promo['sale'] == 'sales' && App.data.sales.hasOwnProperty(pID))
			{
				new SaleDecorWindow({
					ID:pID,
					action:App.data.sales[pID]
				}).show();
				return;
			}		
			
			if (promo['sale'] == 'bigSale' && App.data.bigsale.hasOwnProperty(pID))
			{
				new BigsaleWindow( { sID:pID } ).show();
				return;
			}
			
			if (pID && App.data.bulks.hasOwnProperty(pID))
			{
				new SalesWindow( {
					action:App.data.bulks[pID],
					pID:pID,
					mode:SalesWindow.BULKS,
					width:670,
					title:Locale.__e('flash:1385132402486')
				}).show();
				return;
			}
		}
		
		public static function viewUserAction(_aID:int):void
		{
			if (App.isSocial('SP'))
				return;
			Post.send({
				ctr		:'Uactions',
				act		:'viewed',
				uID		:App.user.id,
				aID		:_aID
			}, function(error:*, data:*, params:*):void {
				if (error)
					return;
				//if (data.hasOwnProperty('actions'))
				//{
					//
				//}
			});
		}
		
		public static function createUserActions(createNew:Boolean = false):void
		{
			if (App.isSocial('SP'))
				return;
			if (Capabilities.playerType == 'StandAlone')
				return;
			Post.send({
				ctr		:'Uactions',
				act		:'get',
				uID		:App.user.id,
				'new'	:int(createNew)
			}, function(error:*, data:*, params:*):void {
				if (error)
					return;
				if (data.hasOwnProperty('actions'))
				{
					for (var i:int = 0; i < App.user.promos.length; i++)
					{
						if (App.user.promos[i].hasOwnProperty('additional'))
						{
							App.user.promos.splice(i, 1);
							i--;
						}
					}
					extraPromos = new Array();
					for each(var _action:* in data.actions)
					{
						if (_action.time + (_action.duration * 3600) < App.time)
							continue;
						if (Numbers.countProps(_action.items) == 0)
							continue;
						_action['iorder'] = {(int(Numbers.firstProp(_action.items).key)):int(Numbers.firstProp(_action.items).val)};
						_action['additional'] = true;
						_action['started'] = _action.time;
						if(_action['status'] == 0)
							extraPromos.push(_action);
					}
					App.user.promos = App.user.promos.concat(extraPromos);
					App.ui.salesPanel.updateSales();
					App.ui.resize();
				}
			});
		}
		private static function checkPaygroup(group:Array):Boolean 
		{
			var _checkPaygroup:Boolean = false
			for each(var gr:int in group)
			{
				if (gr == App.user.data.user.group)
					_checkPaygroup = true;
			}
			return _checkPaygroup
		}
		
		public static function getActionType(aID:int):int{
			if (App.data.actions[aID].hasOwnProperty('price') && App.data.actions[aID].price.hasOwnProperty(App.social))
				return CURRENCY;
			else 
				return MATERIAL;
		}
		
		public static function priceLable(price:Number):Object 
		{
			var text:String = '';
			switch(App.social) {
				
				case "VK":
				case "DM":
						text = 'flash:1382952379972';
					break;
				case "OK":
						text = '%d ОК';
					break;	
				case "MM":
						text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
					break;
				case "FS":
					text = '%d ФМ'; 
					break;
				case "FB":
						price = price * App.network.currency.usd_exchange_inverse;
						price = int(price * 100) / 100;
						text = price + ' ' + App.network.currency.user_currency;	
					break;
				case "YB":
				case "YBD":
					text = '%d コイン'; 
					break;
				case "MX":
					text = '%d pt.'
					break;
				case "AM":
					text = '%d C';
				case "HV":
					price = int(price) / 100;
					text = '%d €';
					break;
				case "NK":
					text = '%d €GB';
					break;
				case "YN":
					text = '%d USD';
					break;
				case "AI":
					text = '%d コイン';
					break;
				default:
					text = '%d';
			}
			
			return {text:text, price:price};
		}	
	}

}