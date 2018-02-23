package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getQualifiedClassName;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import ui.SalesIcon;

	public class AddWindow extends Window 
	{
		
		public var action:Object;
		private var wName:String = getQualifiedClassName(this).split(':').pop();
		
		public function AddWindow(settings:Object=null) 
		{
			action = settings.action; // работает только так
			
			if (!settings.exitTexture)
				settings['exitTexture'] = 'closeBttnMetal';
			switch(wName) {
				case 'PromoWindow':
					settings['promoPanelPosY'] = 45;
					break;
				case 'MaterialActionWindow':
					settings['promoPanelPosY'] = 50;
					break;
				case 'SalesWindow':
					settings['promoPanelPosY'] = 0;
					break;
				case 'SaleDecorWindow':
					settings['promoPanelPosY'] = 10;
					break;
				case 'SaleLimitWindow':
					settings['promoPanelPosY'] = 10;
					break;
				case 'ThematicalSaleWindow':
					settings['promoPanelPosY'] = 10;
					break;
				default:
					settings['promoPanelPosY'] = 10;
					break;
			}
			
			if (!action && settings['pID'] && App.data.actions.hasOwnProperty(settings.pID)) {
				action = App.data.actions[settings.pID];
				action.id = settings.pID;
			}
			
			if (settings['additional'] == true)
			{
				action = settings['action'];
			}
			
			super(settings);
			
			addEventListener('onAfterOpen', onOpen);
		}
		
		override public function drawFader():void {
			super.drawFader();
			
			if (settings['promoPanel']) {
				this.y -= settings.promoPanelPosY;
				fader.y += settings.promoPanelPosY;
			}
		}
		
		private var promoPanel:Sprite;
		private var promoBack:Bitmap;
		private var promoPaginator:Paginator;
		private const PROMOS:int = 8;
		private var promoBegin:int = 0;
		public function drawPromoPanel():void {
			promoPanelClear();
			
			if (!promoPanel) {
				promoBack = new Bitmap();
				if (wName != 'SaleLimitWindow' && wName != 'RoomSetWindow')
					bodyContainer.addChild(promoBack);
				
				promoPanel = new Sprite();
				if (wName != 'SaleLimitWindow' && wName != 'RoomSetWindow')
					bodyContainer.addChild(promoPanel);
			}
			var promoCount:int = 0;
			for (var i:int = 0; i < App.user.promos.length; i++) 
			{
				if (i >= PROMOS || App.user.promos.length <= i + promoBegin||App.user.promos[i].buy) continue;
				
				var promoInfo:Object = App.user.promos[i + promoBegin];
				promoInfo['sale'] = 'promo';
				
				var promo:SalesIcon = new SalesIcon(App.user.promos[i + promoBegin], { rotateIndex:i } );
				promo.x = promoCount * (promo.width + 30) - promo.backing.x;
				promoPanel.addChild(promo);
				
				//if (settings['pID'] == App.user.promos[i + promoBegin].pID) {
					//promo.startGlowing();
				//}
				promoCount++
			}
			
			promoPanel.x = (settings.width - promoPanel.width) / 2 + 20;
			promoPanel.y = settings.height + settings.promoPanelPosY - 60;
			
			if (!promoBack.bitmapData) {
				promoBack.bitmapData = Window.backing(promoPanel.width - 4, 94, 30, 'tipMini').bitmapData;
				promoBack.x = promoPanel.x + (promoPanel.width - promoBack.width) / 2 - 24;
				promoBack.y = promoPanel.y - 4;
				promoBack.alpha = 0.5;
			}
			
			if (App.user.promos.length - PROMOS > 0 && !promoPaginator) {
				promoPaginator = new Paginator(App.user.promos.length - PROMOS + 1, 1, 0, {
					hasButtons:		false
				});
				promoPaginator.drawArrow(bodyContainer, Paginator.LEFT, promoBack.x - 0, promoBack.y + 27, { scaleX: -0.6, scaleY:0.6 } );
				promoPaginator.drawArrow(bodyContainer, Paginator.RIGHT, promoBack.x + promoBack.width, promoBack.y + 27, { scaleX:0.6, scaleY:0.6 } );
				promoPaginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPaginatorPageChange);
			}
		}
		private function onPaginatorPageChange(e:WindowEvent = null):void {
			promoBegin = promoPaginator.page;
			drawPromoPanel();
		}
		private function promoPanelClear():void {
			while (promoPanel != null && promoPanel.numChildren > 0) {
				var promo:SalesIcon = promoPanel.getChildAt(0) as SalesIcon;
				promo.dispose();
			}
		}
		private function onOpen(e:WindowEvent = null):void {
			if (wName != 'SaleLimitWindow' && wName != 'RoomSetWindow')
				drawPromoPanel();
		}
		
		// Buy Promo Event
		private var buyBttn:*;
		public function buyEvent(e:MouseEvent):void
		{
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			buyBttn = e.currentTarget as Button;
			
			for (var _sid:* in action.items) {
				if (App.data.storage.hasOwnProperty(_sid)){
					if (action.checkstock && action.checkstock == 1 && Stock.isExist(_sid)){
						return;
					}
				}
			}
			var self:* = this;
			//onBuyComplete();
			
			switch(App.social) {
				case 'PL':
				//case 'AI':
					if(App.user.stock.take(Stock.FANT, action.price[App.social])){
						Post.send({
							ctr:'Promo',
							act:'buy',
							uID:App.user.id,
							pID:action.id,
							ext:App.social
						},function(error:*, data:*, params:*):void {
							onBuyComplete();
						});
					}else {
						close();
					}
					break;
				case 'AM':
					//if(App.user.stock.take(Stock.FANT, action.price[App.social])){
					Post.send({
						ctr:'Orders',
						act:'createOrder',
						uID:App.user.id,
						type:"promo", 
						pos: action.id
						//pID:action.id,
						//ext:App.social
					}, function(error:*, data:*, params:*):void {
						navigateToURL(new URLRequest(data.transactionUrl),"_parent");
						//onBuyComplete();
					});
					//}else {
						//close();
					//}
					break;
				case 'SP':
					if(App.user.stock.take(Stock.FANT, action.price[App.social])){
						Post.send({
							ctr:'Promo',
							act:'buy',
							uID:App.user.id,
							pID:action.id,
							ext:App.social
						},function(error:*, data:*, params:*):void {
							if (!error)
								onBuyComplete();
						});
					}else {
						close();
					}
					break;
				default:
					var object:Object;
					
					if (action.hasOwnProperty('mprice') && action.mprice.hasOwnProperty(App.social) && (!action.hasOwnProperty('price') || !action.price.hasOwnProperty(App.social)))
					{
						if (App.user.stock.takeAll(action.mprice[App.social]))
						{
							Post.send({
								ctr:'Promo',
								act:'buy',
								uID:App.user.id,
								pID:action.id,
								ext:App.social
							}, function(error:*, data:*, params:*):void {
								if (error){
									self.close();
									return;
								}
								onBuyComplete();
							});
							buyBttn.state = Button.DISABLED;
						}
						
						return;
					}
					if (App.social == 'FB') {
						ExternalApi.apiNormalScreenEvent();
						object = {
							id:		 		action.id,
							type:			'promo',
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback:		onBuyComplete
						};
					}else{
						object = {
							count:			1,
							money:			'promo',
							type:			'item',
							item:			'promo_' + action.id,
							//sid:			action.id,
							votes:			action.price[App.social],
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback: 		onBuyComplete,
							icon:			getIconUrl(action)
						}
						if (action.hasOwnProperty('additional'))
							object['item'] = 'person_' + action.id;
						//ExternalApi.apiPromoEvent(object);
					}
					buyBttn.state = Button.DISABLED;
					ExternalApi.apiPromoEvent(object);
			}
		}
		
		public function onBuyComplete(e:* = null):void 
		{
			//if(buyBttn)
			buyBttn.state = Button.DISABLED;
			
			App.user.stock.addAll(action.items);
			App.user.stock.addAll(action.bonus);
			
			if (App.user.promo.hasOwnProperty(action.id) && !action.hasOwnProperty('additional'))
			{
				App.user.promo[action.id].buy = 1;
				App.user.buyPromo(action.id);
			}
			if (action.hasOwnProperty('additional'))
			{
				if (App.user.promos.indexOf(action) != -1)
				{
					App.user.promos.splice(App.user.promos.indexOf(action), 1);
				}
			}
			App.ui.salesPanel.createPromoPanel();
			
			//Window.closeAll();
			close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952379990")
			}).show();
		}
		
		
		override public function dispose():void {
			if (promoPaginator) {
				promoPaginator.removeEventListener(WindowEvent.ON_PAGE_CHANGE, onPaginatorPageChange);
				promoPaginator.dispose();
			}
			
			removeEventListener(WindowEvent.ON_AFTER_OPEN, onOpen);
			promoPanelClear();
			super.dispose();
		}
		
		/*
		public function get action():Object 
		{
			return _action;
		}
		
		public function set action(value:Object):void 
		{
			_action = value;
		}*/
		
		public function getIconUrl(promo:Object):String {
			if (promo.hasOwnProperty('iorder')) {
				var _items:Array = [];
				for (var sID:* in promo.items) {
					_items.push( { sID:sID, order:promo.iorder[sID] } );
				}
				_items.sortOn('order');
				sID = _items[0].sID;
			}else {
				sID = promo.items[0].sID;
			}
			var url:String = Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
			switch(sID) {
				case Stock.COINS:
					url = Config.getIcon("Coins", "gold_02");
				break;
				case Stock.FANT:
					url = Config.getIcon("Reals", "crystal_03");
				break;
			}
			
			return url;
		}
		
		override public function clearVariables():void 
		{
		}
	}
}	