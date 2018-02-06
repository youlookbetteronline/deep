package wins
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import units.Techno;
	import wins.elements.BankMenu;
	
	/**
	 * ...
	 * @author 
	 */
	public class RequiresList extends Sprite 
	{
		public var bonus:Object;
		public var settings:Object = {
			hasTitle:true,
			//titleText:Locale.__e('flash:1471267640746'),
			background:'shopSpecialBacking',
			backingShort:false,
			titleX:10,
			titleY:15,
			bgX:0,
			bgY:0,
			titleColor:0x70401d,
			titleBorderColor:0xfff4e4,
			size:40,
			separatorWidth: 100
		}
		public var items:Array = [];
		private var separator:Bitmap;
		
		public function RequiresList(data:Object, hasBacking:Boolean = true, _settings:Object = null)
		{
			if (_settings != null) {
				for (var _item:String in _settings)
					this.settings[_item] = _settings[_item];
			}
			
			var X:int = 0;
			if(settings.hasTitle){
				var title:TextField = Window.drawText(
					settings.titleText, 
					{
						fontSize	:24,
						color		:settings.titleColor,
						borderColor	:settings.titleBorderColor,
						autoSize	:"left",
						borderSize	:2
					}
				);
				
				title.x = settings.titleX;
				title.y = settings.titleY;
				addChild(title);
				
				/*separator = Window.backingShort(settings.separatorWidth, 'dividerNew', false);
				separator.x = - 52;
				separator.y = title.y + title.height + 8;
				separator.alpha = 1;
				addChild(separator);*/
				
				X = title.x + title.textWidth + 15;
			}
			
			for (var sID:* in data)
			{
				var item:InternalRequiresItem = new InternalRequiresItem(this, sID, data[sID], settings.size, settings);

				addChild(item);
				item.x = X;
				item.y = 0;
				items.push(item);
				X+=item.text.textWidth + 48 + 20;
			}
			var bg:Bitmap;
			if (!settings.backingShort) {
				bg = Window.backing(X, 60, 12, settings.background);
			}else {
				bg = Window.backingShort(X, settings.background);
			}
			
			if(hasBacking){
				addChildAt(bg, 0);
				bg.x = settings.bgX; bg.y = settings.bgY;
			}
		}
		
		public function doPluck():void
		{
		
			for (var i:int = 0; i < items.length; i++ ) {
				if (items[i].sID == App.data.storage[App.user.worldID].techno[0]){
					if ((App.user.techno.length - Techno.getBusyTechno()) < items[i].count&& !settings.dontCheckTechno){
						//items[i].doPluck();			
					
							new PurchaseWindow( {
								width:560,
								height:320,
								itemsOnPage:3,
								useText:true,
								//shortWindow:true,
								cookWindow:true,
								columnsNum:3,
								scaleVal:1,
								noDesc:true,
								closeAfterBuy:false,
								autoClose:false,
								description:Locale.__e('flash:1422628646880'),
								content:PurchaseWindow.createContent("Energy", {view:['slave']}),
								title:Locale.__e('flash:1422628903758'), // 
								//description:Locale.__e("flash:1382952379757"),
								popup: true,
								//find:Stock.TECHNO,
								callback:function(sID:int):void {
										var object:* = App.data.storage[sID];
										App.user.stock.add(sID, object);
									}
									
							}).show();
						
						
						break;
					}
				}else{
					if (items[i].count > App.user.stock.count(items[i].sID)) {
						switch(items[i].sID) {
							case Stock.COINS:
								App.ui.upPanel.onCoinsEvent();
							break;
							case Stock.FANTASY:
								App.ui.upPanel.onEnergyEvent();
							break;
							case App.data.storage[App.user.worldID].cookie[0]:
								new PurchaseWindow( {
								width:560,
								height:320,
								itemsOnPage:3,
								useText:true,
								//shortWindow:true,
								cookWindow:true,
								columnsNum:3,
								scaleVal:1,
								noDesc:false,
								closeAfterBuy:false,
								autoClose:false,
								description:Locale.__e('flash:1393599816743'),
								content:PurchaseWindow.createContent("Energy", {view:['Cookies']}),
								title:App.data.storage[150].title, // 
								//description:Locale.__e("flash:1382952379757"),
								popup: true
								//find:Stock.COOKIE
								}).show();
							break;
						}
					}
				}
			}
				if (settings.dontCheckTechno == true) {
				/*new SimpleWindow( {
				//label:SimpleWindow.BUILDING,
				title:Locale.__e("flash:1410185780958"),
				popup: true,
				text:Locale.__e("flash:1410185707092")
				}).show();*/
			}
		}
		
		public function checkOnComplete():Boolean {
			for (var i:int = 0; i < items.length; i++) {
				if (items[i].complete == false)
					return false;
			}
			
			return true;
		}
		
		public function take():void{
			/*var childs:int = numChildren;
			
			while(childs--) {
				if(getChildAt(childs) is InternalRequiresItem){
					var reward:InternalRequiresItem = getChildAt(childs) as InternalRequiresItem;
								
					var item:BonusItem = new BonusItem(reward.sID, reward.count);
				
					var point:Point = Window.localToGlobal(reward);
					item.cashMove(point, App.self.windowContainer);
				}
			}*/
		}
		
		public function dispose():void
		{
			for (var i:int = 0; i < items.length; i++ ) {
				items[i].dispose();
				items[i] = null;
			}
			items.splice(0, items.length);
		}
	}
}

import core.Load;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import flash.utils.setTimeout;
import units.Techno;
import wins.RequiresList;
import wins.Window;
import wins.PurchaseWindow;
internal class InternalRequiresItem extends LayerX
{
	private var icon:Bitmap;
	public var text:TextField;
	public var sID:uint;
	public var count:int;
	public var size:Number;
	
	public var settings:Object = {
			bonusTextColor:0xFFFFFF,
			bonusBorderColor:0x252a38
		}
		
	public var deficitSettings:Object = {
			color:0xef7563,
			borderColor:0x623126
		}	
		
	public var complete:Boolean = true;	
	private var reqList:RequiresList;
	public function InternalRequiresItem(reqList:RequiresList, sID:uint, count:int, size:Number, _settings:Object = null)
	{
		if (_settings != null) {
			for (var _item:String in _settings)
				this.settings[_item] = _settings[_item];
		}
		
		this.size = size;
		icon = new Bitmap();
		this.sID = sID;
		this.count = count;

		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad)
		
		var color:int;
		var borderColor:int;
		
		color		= Window.getTextColor(sID).color;
		borderColor	= Window.getTextColor(sID).borderColor;
		
		if (sID == App.data.storage[App.user.worldID].techno[0]){
			if ((App.user.techno.length - Techno.getBusyTechno()) < count && !reqList.settings.dontCheckTechno){
				complete = false;
				color = deficitSettings.color;
				borderColor = deficitSettings.borderColor;
				setTimeout(setPluck, 2000);
			}
		}else{
			if (count > App.user.stock.count(sID)) {
				complete = false;
				color = deficitSettings.color;
				borderColor = deficitSettings.borderColor;
				setTimeout(setPluck, 2000);
			}
		}
		
		text = Window.drawText(String(count),
				{
					fontSize	:28,
					color		:color,
					borderColor	:borderColor,
					//borderSize  :3,
					autoSize	:"left"
				}
			);
			
		text.height = text.textHeight;
		
		//addChild(icon);
		addChild(text);
		text.y = 68/2 - text.textHeight/2;
		text.x = 48;
		
		if (count == 0)
			text.visible = false;
			
		//stip = function():Object {
			//return {
				//title:App.data.storage[this.sID].title,
				//text:App.data.storage[this.sID].description
			//};
		//}
			
		tip = function():Object {
			return {
				title:App.data.storage[this.sID].title,
				text:App.data.storage[this.sID].description
			};
		}
		
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (complete) return;
		switch(sID) {
			case Stock.FANTASY:
				App.ui.upPanel.onEnergyEvent(e);
			break;
		case App.data.storage[App.user.worldID].techno[0]:
			
				new PurchaseWindow( {
				width:560,
				height:320,
				itemsOnPage:3,
				useText:true,
				//shortWindow:true,
				cookWindow:true,
				columnsNum:3,
				scaleVal:1,
				noDesc:false,
				closeAfterBuy:false,
				autoClose:false,
				description:Locale.__e('flash:1393599816743'),
				content:PurchaseWindow.createContent("Energy", {view:['slave']}),
				title:Locale.__e('flash:1422628903758'), // 
				//description:Locale.__e("flash:1382952379757"),
				popup: true
				//find:Stock.TECHNO
			}).show();
			
			

			break;
			case Stock.COINS:
				App.ui.upPanel.onCoinsEvent(e);
			break;
			case Stock.FANT:
				App.ui.upPanel.onRealEvent(e);
			break;
		}
	}
	
	private var intervalPluck:int;
	public function setPluck():void
	{
		if(pluckCont && !pluckCont.isPluck)pluckCont.pluck(30, 25, 25);
		intervalPluck = setInterval(function():void { if(pluckCont && !pluckCont.isPluck)pluckCont.pluck(30, 25, 25)}, Math.random()* 5000 + 4000);
	}
	
	public function doPluck():void
	{
		if(!pluckCont.isPluck)pluckCont.pluck(30, 25, 25);
	}
	
	private var pluckCont:LayerX = new LayerX();
	private function onLoad(data:Bitmap):void
	{
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		var scale:Number = size / icon.height;
		icon.scaleX = icon.scaleY = scale;
		if(pluckCont){
			pluckCont.addChild(icon);
			pluckCont.y = 68 / 2 - pluckCont.height / 2;
			addChild(pluckCont);
		}
	}
	
	public function dispose():void
	{
		removeEventListener(MouseEvent.CLICK, onClick);
		
		clearInterval(intervalPluck);
		if(pluckCont && contains(pluckCont))removeChild(pluckCont);
		pluckCont = null;
	}
}
