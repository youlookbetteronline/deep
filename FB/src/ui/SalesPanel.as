package ui 
{
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import core.CookieManager;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import effects.NewParticle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import units.Character;
	import wins.ActionInformerWindow;
	import wins.BankSaleWindow;
	import wins.BanksWindow;
	import wins.BigsaleWindow;
	import wins.PremiumActionWindow;
	import wins.PromoWindow;
	import wins.SaleDecorWindow;
	import wins.SaleLimitWindow;
	import wins.SalesSetsWindow;
	import wins.SalesWindow;
	import wins.ThematicalSaleWindow;
	import wins.TriggerPromoWindow;
	import wins.Window;
	
	public class SalesPanel extends Sprite
	{
		public var promoIcons:Array = [];
		public var newPromo:Object = { };
		public var promoPanel:Sprite = new Sprite();		
		public var leftPanelItemsX:int = 0;
		public var paginator:PromoPaginator;
		
		public static var iconHeight:uint = 80;		
		
		public function SalesPanel() 
		{
			paginator = new PromoPaginator(App.user.promos, 2, this);
			paginator.drawArrows();			
			addChild(promoPanel);
			setTimeout(initPromo, 100);
		}
		
		public var bankSaleIcons:Array = [];	
		public function addBankSaleIcon():void
		{
			App.ui.upPanel.ribbonSaleSprite.visible = false;	
			
			if ((App.data.money && App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1) || App.user.money > App.time) 
			{
				App.ui.upPanel.ribbonSaleSprite.visible = true;
			}
		}
		
		public function initPromo():void 
		{
			App.user.quests.checkPromo();
		}
		
		private function startGlow(bttn:ImagesButton):void 
		{
			bttn.showPointing("left", 0, promoPanel.y, App.ui.salesPanel, Locale.__e("flash:1382952379795"), {
				color:0xffd619,
				borderColor:0x7c3d1b,
				autoSize:"left",
				fontSize:24
			}, true);
			
			setTimeout(function():void {
				bttn.hidePointing();			
			}, 5000);   
		
		}
		
		public function updateSales():void
		{
			if (App.user.quests.tutorial) return;
			
			numUpIcons = 0;
			iconsPosY = 0;
			iconsHeight = 0;
			leftPanelItemsX = 0;
			
			clearPromoPanel();
			addBankSaleIcon();
			createPremium();
			createBigSales();
			
			if (numUpIcons == 1)
				iconsPosY += 10;
			
			if (iconsPosY == 0)
				iconsPosY = 28;
		}
		
		public var iconsPosY:int = 0;
		public var iconsHeight:int = 0;
		private var numUpIcons:int = 0;
		private var iconsTopLimit:int = 2;
		public function createPromoPanel(isLevelUp:Boolean = false, isPaginatorUpd:Boolean = false):void 
		{
			if (App.user.quests.tutorial)
				return;
				
			updateSales();
				
			var iconY:int = 0;
			var limit:int = 3;
			
			promoPanel.y = 130;
			
			var pos:int = iconsPosY + 164;
			paginator.resize(App.self.stage.stageHeight - pos - ((App.ui.rightPanel.freebieBttn) ? 212 : 140), isLevelUp);
		}
		/*public static var particleSprite:Sprite;
		public function drawParticles():void
		{
			SalesPanel.particleSprite = new Sprite();
			var count:int = 20;
			for (var i:int = 0; i < count; i++)
			{
				var particle:NewParticle = new NewParticle({color:0xffffff, radius:1, time:1});
				particle.x = (Math.random() * 80);
				particle.y = (Math.random() * 80);
				//particle
				SalesPanel.particleSprite.addChild(particle);
			}
		}
		public function clearParticles():void
		{
			while (SalesPanel.particleSprite && SalesPanel.particleSprite.numChildren > 0)
			{
				var _child:* = SalesPanel.particleSprite.getChildAt(0);
				_child.dispose();
			}
		}*/
		
		public function doCreate(isLevelUp:Boolean = false):void
		{
			//drawParticles();
			var iconY:int = 0;
			var limit:int = 3;
			
			iconY = iconsPosY;
			
			App.user.promos.sortOn('order', Array.NUMERIC | Array.DESCENDING);
			
			for (var i:int = paginator.startItem; i < paginator.endItem; i++)
			{
				if (App.user.promos.length <= i) break;
				if	(App.user.promos[i].buy) {
					limit++;
					continue;
				}
				
				var pID:String = App.user.promos[i].pID;
				
				var promo:Object = App.user.promos[i];
				promo['sale'] = 'promo';
				
				if (skipIfNotAvailable(promo.items)) continue;
				if (promo.type == 3) continue;
				
				var bttn:SalesIcon = new SalesIcon(promo, {
					rotateIndex:	i - paginator.startItem
				});
				promoIcons.push(bttn);
				promoPanel.addChildAt(bttn,0);
				
				bttn.y = iconY;
				iconY += bttn.height + 10;
				
				var obj:Object = App.user.promo[pID];
				if (pID && App.user.promo[pID].begin_time + 2 > App.time)
				{
					bttn.startGlowing();
					bttn.showPointing('left', 0, 10, promoPanel);
				}
				
				iconsHeight += bttn.height + 10;
				
				if (isLevelUp && !App.user.promos[i].showed)
				{
					bttn.onClick();
				}
				//bttn.drawParticles();
			}
			
			paginator.setArrowsPosition();
			
			if (promoIcons.length > 0) {
				promoTime();
				App.self.setOnTimer(promoTime);
			}else{
				App.self.setOffTimer(promoTime);
			}
		}
		
		private function promoTime():void 
		{
			for (var pID:* in App.user.promo)
			{
				var promo:Object = App.data.actions[pID];
				
				if (promo.type == 6 && promo.begin_time + promo.live < App.time) {
					App.user.updateActions();
					createPromoPanel();
				}else if (promo.begin_time + promo.duration * 3600 < App.time) {
					App.user.updateActions();
					createPromoPanel();
				}
			}
		}
		
		private function clearPromoPanel():void
		{
			//clearParticles();
			for each(var bttn:* in promoIcons)
			{
				bttn.hidePointing();
				bttn.hideGlowing();
				//bttn.clearParticles();
				if(bttn.parent)
					bttn.parent.removeChild(bttn);
			}
			for each(bttn in premiumIcons)
			{
				bttn.hidePointing();
				bttn.hideGlowing();
				if(bttn.parent)
					bttn.parent.removeChild(bttn);
				//promoPanel.removeChild(bttn);
			}
			
			premiumIcons = [];
			promoIcons = [];
			App.ui.upPanel.ribbonSaleSprite.visible = false;	
		}
		
		private var premiumIcons:Array = [];
		private var premiumLimit:int = 1;
		private function createPremium():void 
		{
			if (App.user.premiumPromos.length == 0 || numUpIcons >= iconsTopLimit) 
				return;
				
			var iconY:int = 0;
			var iconX:int = 34;
				
			var countPrimium:int = 0;
			
			if (bankSaleIcons.length > 0) {
				iconY += 96 * bankSaleIcons.length;
			}
			
			for (var i:int = 0; i < App.user.premiumPromos.length; i++ )
			{
				if (countPrimium >= premiumLimit)
					break;
					
				for (var k:int = 0; k < App.user.arrHeroesInRoom.length; k++ ) {
					if (App.user.arrHeroesInRoom[k] == App.user.premiumPromos[i].sid)
						isDeniy = true;
				}
				
				var isDeniy:Boolean = false;
				for (var j:int = 0; j < App.user.characters.length; j++ ) {
					if (App.user.characters[i].sid == App.user.premiumPromos[i].sid)
						isDeniy = true;
				}
				if (isDeniy)
					continue;
				
				if (App.user.premiumPromos[i].hasOwnProperty('social') && !App.user.premiumPromos[i].social.hasOwnProperty(App.social)) 
				continue;
				
				var sale:Object = App.user.premiumPromos[i];
				if (sale.unlock.level > App.user.level)
					continue;
				if (App.time > sale.time + sale.duration * 3600)
					continue;
					
				var bttn:PromoIcon = new PromoIcon(sale, {
					width:		110,
					height:		110
				});
					
				premiumIcons.push(bttn);
				
				bttn.x = iconX - 50;
				bttn.y = iconY + 13;
				
				promoPanel.addChild(bttn);
				
				promoPanel.y = 130;
				
				countPrimium++;
				numUpIcons++;
				
				iconsPosY += iconHeight + 31;
			}
		}
	
		private function createBigSales():void 
		{
			if (promoPanel.y == 0)
				return;
			
			if (numUpIcons >= iconsTopLimit || App.user.level < 5)
				return;
			
			if (premiumIcons.length > 0)
				iconY += 96 * premiumIcons.length;
			
			var sales:Array = [];
			var sale:Object;
			for (var sID:* in App.data.bigsale)
			{
				sale = App.data.bigsale[sID];
				if(sale.social == App.social)
					sales.push({sID:sID, order:sale.order, sale:sale});
			}
			sales.sortOn('order');
			
			var iconY:int = 0;
			if (premiumIcons.length > 0)
				iconY += 96 * premiumIcons.length;
			
			if (promoIcons.length > 0)
				iconY += 96 * promoIcons.length;
			
			if (bankSaleIcons.length > 0)
				iconY += 96 * bankSaleIcons.length;
			
			for each(sale in sales)
			{
				if (App.time > sale.sale.time && App.time < sale.sale.time + sale.sale.duration * 3600)
				{
					var forLeftPanel:Boolean = false;
					
					if (sale.sale.hasOwnProperty('place') && sale.sale.place != 0)
						forLeftPanel = true;
						
					var spBack:Boolean = false;
					for each(var itemSid:* in sale.sale.items)
					{
						if (itemSid.sID == Stock.FANT) 
							spBack = true;
					}
					
					var promo:Object = sale.sale;
					promo['sale'] = 'bigSale';
					promo['pID'] = sale.sID;
					promo['timer'] = sale.sale;
					
					var bttn:SalesIcon = new SalesIcon(promo, {
						width:		110,
						height:		110
					});
					
					if (forLeftPanel) {
						App.ui.leftPanel.addLeftPromo(bttn);
					}else {
						bttn.x = 34 - bttn.width / 2;
						bttn.y = iconY;
						promoPanel.addChild(bttn);
						promoIcons.push(bttn);
						
						numUpIcons++;
						iconsPosY += iconHeight + 26;
					}
					break;
				}
			}
		}
		
		public function hide():void
		{
			this.visible = false;
		}
		
		public function show():void
		{
			this.visible = true;
		}
		
		public function resize():void
		{
			this.x = App.self.stage.stageWidth - 82;			
			createPromoPanel();
		}
		
		private function skipIfNotAvailable(items:Object = null):Boolean
		{
			if (items) 
			{
				for (var _sid:* in items) 
				{
					if (typeof(_sid) != 'object' && App.data.storage[_sid].type == 'Zones')
					{
						if (!World.allZones.hasOwnProperty(App.map.id) || World.allZones[App.map.id].indexOf(_sid) == -1 || World.zoneIsOpen(int(_sid)))
							return true;
					}
				}
			}
			return false;
		}
	}
}

import buttons.ImageButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import wins.Window;
import ui.UserInterface;
import ui.SalesPanel;

internal class PromoPaginator extends Sprite{
	
	public var startItem:uint = 0;
	public var endItem:uint = 0;
	public var length:uint = 0;
	public var itemsOnPage:uint = 0;
	
	public var _parent:SalesPanel;
	public var data:Array;
	
	public function PromoPaginator(data:Array, itemsOnPage:uint, _parent:SalesPanel)
	{
		this._parent = _parent;
		this.data = data;
		length = data.length;
		startItem = 0;
		this.itemsOnPage = itemsOnPage;
		endItem = startItem + itemsOnPage;
	}
	
	public function up(e:* = null):void
	{
		if (startItem > 0)
		{
			startItem --;
			endItem = startItem + itemsOnPage;
			
			_parent.updateSales();
			change();
		}
	}
	
	public function down(e:* = null):void
	{
		startItem ++;
		endItem = startItem + itemsOnPage;
		
		_parent.updateSales();
		change();
	}
	
	public function change(isLevelUp:Boolean = false):void
	{
		length = App.user.promos.length;
		
		if (startItem == 0){
			arrowUp.visible = false;
		}else{
			arrowUp.visible = true;
		}	
		
		if(startItem + itemsOnPage >= length)
			arrowDown.visible = false;
		else
			arrowDown.visible = true;
		
		_parent.doCreate(isLevelUp);
	}
	
	public var arrowUp:ImageButton;
	public var arrowDown:ImageButton;
	
	public function drawArrows():void
	{
		if (arrowUp == null && arrowDown == null)
		{
			arrowUp = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:1, sound:'arrow_bttn'});
			arrowDown = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:-1, sound:'arrow_bttn'});
			
			_parent.promoPanel.addChild(arrowUp);
			arrowUp.x = 18;
			
			_parent.promoPanel.addChild(arrowDown);
			arrowDown.x = 18;
			
			arrowUp.addEventListener(MouseEvent.CLICK, up);
			arrowDown.addEventListener(MouseEvent.CLICK, down);
			setArrowsVisible();
		}
		
		setArrowsPosition();
	}
	
	public function resize(_height:uint, isLevelUp:Boolean = false):void {
		itemsOnPage = Math.floor(_height / 90);
		startItem = 0;
		endItem = startItem + itemsOnPage;
		setArrowsPosition();
		change(isLevelUp);
	}
	
	public function setArrowsVisible():void 
	{
		if (App.user.promos.length > 1)
		{
			arrowUp.visible = true;
			arrowDown.visible = true;
		}else{
			arrowUp.visible = false;
			arrowDown.visible = false;
		}
	}
	
	public function setArrowsPosition():void 
	{
		arrowUp.y 	= _parent.iconsPosY - arrowUp.height + 7;
		arrowDown.y = _parent.iconsPosY + _parent.iconsHeight + 22;//164;
	}
}