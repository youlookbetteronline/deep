package wins.table 
{
	import buttons.Button;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import utils.StyleConstants;
	import wins.PriceFactor;
	import wins.PurchaseWindow;
	import wins.SelectMaterialWindow;
	import wins.ShopWindow;
	import wins.Window;
	import wins.PriceFactor;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SellMaterialWindow extends SelectMaterialWindow 
	{
		private var _textTime:TextField;
		private var _textTimeValue:TextField;
		private var _sellTime:int;
		
		private var _findBttn:Button;
		private var _buyBttn:Button;
		private var _tick:Bitmap;
		
		public function SellMaterialWindow(priceFactors:Vector.<PriceFactor>, limit:int = 0, sellTime:int = 0, settings:Object=null) 
		{
			settings["width"] = 510;
			settings["height"] = 310;
			
			_sellTime = sellTime;
			
			super(priceFactors, limit, settings);
		}
		
		override public function drawTitle():void 
		{
			super.drawTitle();
		}
		
		override public function drawBody():void 
		{
			super.drawBody();
			exit.y -= 20;
			exit.x -= 5;
			shape.x = 169;
			shape.y = 130;
			
			drawMaterialIcon();
			
			_findBttn = new Button(StyleConstants.FIND_BUTTON_STYLE);
			_findBttn.x = 120;
			_findBttn.y = 190;
			bodyContainer.addChild(_findBttn);
			_findBttn.addEventListener(MouseEvent.CLICK, onFindClick);
			
			/*_buyBttn = new Button(StyleConstants.BUY_BUTTON_STYLE);
			_buyBttn.x = _findBttn.x + _findBttn.width + 5;
			_buyBttn.y = 190;
			bodyContainer.addChild(_buyBttn);
			_buyBttn.addEventListener(MouseEvent.CLICK, onBuyClick);*/
			updateCountAndPrice();
			
			/*_tick = new Bitmap(Window.textures["checkMark"]);
			_tick.x = counter.x - (_tick.width * 1.5);
			_tick.y = counter.y - (_tick.height * 0.7);
			_tick.visible = counter.count > 0;
			bodyContainer.addChild(_tick);*/
		}
		
		private function onFindClick(e:MouseEvent):void 
		{
			//App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			Window.closeAll();
			
			/*if (App.user.worldID != User.HOME_WORLD)
			{
				Travel.goTo(User.HOME_WORLD);
			}
			else
			{
				onMapComplete(null);
			}*/
			var sID:int = currentMaterialID;
			var finded:Boolean = false;
			if (App.data.storage[sID].type == 'Material'){
				var resId:uint = 0;
				var craftId:uint = 0;
				var targetId:uint = 0;
				for each(var ssId:* in App.data.crafting){
					if (ssId.out == sID /*&& ssId.outs*/){
						craftId = ssId.ID;
						//var counter:int = 0;
						for each(var build:* in App.data.storage){
							if(build.type == 'Building' && build.devel&& build.devel[1] && build.devel[1].craft){
								for each(var crafts:* in build.devel[1].craft){
									if (crafts == craftId){
										targetId = build.sID;
										var sIDs:Array = [];
										sIDs.push(targetId);
										trace("finded");
										finded = true;
										App.user.quests.findTarget(sIDs, false, null, false, sID, true, '');
										break;
									}
								}
								
							}
							/*resId = Numbers.getProp(ssId.outs, counter).key;
							//trace();
							if(resId == sID){
								//trace(target);
								//shW2 = new ShopWindow( { find:[int(ssId.sID)] } );
								break;
							}
							counter++;*/
						}
						
						break;
						
					}
					
				}
				if(!finded){
					/*var niID:int;
					var niView:String;
					for (var t:* in settings.neededItems){
						niID = t; // получили айдишник того, чего не хватает для добычи ресурса
					}*/
					
					/*for each (var niResource:* in App.data.storage) 
					{
						if (niResource.type == 'Energy') {
							if (niResource.out == sID) {
								niView = niResource.view;
							}
						} 
					}*/
					
					//close();
					/*new PurchaseWindow( {
						width:382,
						itemsOnPage:2,
						content:PurchaseWindow.createContent("Energy", { inguest:0, view:'Feed'}, sID),
						title:App.data.storage[sID].title,
						popup:true,
						find:sID,
						description:Locale.__e("flash:1382952379757"),
						closeAfterBuy:false,
						autoClose:false,
						callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
						//lock = false;
						}
					}).show();*/
			}
					//new ShopWindow( { find:[sID] } );
				
			}
		}
		
		/*private function onBuyClick(e:MouseEvent):void 
		{
			Window.closeAll();
			var sID:int = currentMaterialID;
			
			new PurchaseWindow( {
				width:382,
				itemsOnPage:2,
				content:PurchaseWindow.createContent("Energy", { inguest:0, view:'Table'}, sID),
				title:App.data.storage[sID].title,
				popup:true,
				find:sID,
				description:Locale.__e("flash:1382952379757"),
				closeAfterBuy:false,
				autoClose:false,
				callback:function(sID:int):void {
				var object:* = App.data.storage[sID];
				App.user.stock.add(sID, object);
				}
			}).show();
			
		}*/
		
		private function onMapComplete(e:AppEvent = null):void 
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			ShopWindow.findMaterialSource(currentMaterialID);
		}
		
		override public function drawArrows():void 
		{
			super.drawArrows();
			
			paginator.arrowLeft.scaleX = paginator.arrowLeft.scaleY = 0.75;
			paginator.arrowLeft.x += 60;
			
			paginator.arrowRight.scaleX = paginator.arrowRight.scaleY = 0.75;
			paginator.arrowRight.x -= 205;
		}
		
		override public function drawTitleItem():void 
		{
			super.drawTitleItem();
			
			title.x = 160 - (title.width * 0.5) + 5;
			title.y = 35;
		}
		
		override public function drawCount():void 
		{
			super.drawCount();
			
			if (counter)
			{
				counter.x = 270;
			}
		}
		
		override public function drawCalculator():void 
		{
			super.drawCalculator();
			
			calc.x -= 85;
			calc.y += 55;
			
			minus10Bttn.x -= 85;
			minus10Bttn.y += 42;
			
			minusBttn.x -= 85;
			minusBttn.y += 42;
			
			plusBttn.x -= 85;
			plusBttn.y += 42;
			
			plus10Bttn.x -= 85;
			plus10Bttn.y += 42;
		}
		
		//private var _sellPriceContainer:Sprite;
		private var _sellMaterialRewardIcons:Vector.<RewardItem>;
		private var fishka:Bitmap = new Bitmap();
		private var open:TextField;
		override public function drawSellPrice():void 
		{
			if (!_sellPriceContainer)
			{
				_sellPriceContainer = new Sprite();
			}
			
			if (!_sellMaterialRewardIcons)
			{
				_sellMaterialRewardIcons = new Vector.<RewardItem>();
			}
			
			_priceFactors = priceFactors;
			
			open = Window.drawText(settings.priceTitle, {
				color:0x7e3918,
				borderColor:0xfdf7e9,
				textAlign:"center",
				autoSize:"center",
				fontSize:26,
				multiline:true,
				wrap:true
			});
			_sellPriceContainer.addChild(open);
			open.y = 60;
			var startX:int = 0;
			var startY:int = open.y + open.height + 5;
			var dX:int = 0;
			var dY:int = 5;
			
			var currentMaterialIcon:RewardItem;
			for each (var priceFactor:PriceFactor in _priceFactors) 
			{
				currentMaterialIcon = new RewardItem(priceFactor.materialID, price * priceFactor.factor, null, 40, "", 0.74, 0, 0, true, true);
				currentMaterialIcon.y = startY  + (_sellMaterialRewardIcons.length * (currentMaterialIcon.height + dY));
				
				_sellMaterialRewardIcons.push(currentMaterialIcon);
				_sellPriceContainer.addChild(currentMaterialIcon);
			}
			//var fish:
			fishSID = Numbers.firstProp(App.data.storage[priceFactor.materialID].personages).key;
			Load.loading(Config.getIcon(App.data.storage[fishSID].type, App.data.storage[fishSID].preview), function(data:*):void {
				fishka.bitmapData = data.bitmapData;
				fishka.scaleX = fishka.scaleY = 1;
				Size.size(fishka, 100, 100);
				fishka.x = 50 - (fishka.width) / 2;
				fishka.y = 20 - (fishka.height) / 2;//currentMaterialIcon.y + currentMaterialIcon.height;
			});
			//fishka = new Bitmap(Window.textures.levelUp);
			
			var sprite:LayerX = new LayerX();
			sprite.tip = function():Object { 
				return {
				 title:App.data.storage[fishSID].title,
				 text:App.data.storage[fishSID].description
				};
			};
			
			sprite.addChild(fishka);
			_sellPriceContainer.addChild(sprite);
			
			_textTime = Window.drawText(Locale.__e("flash:1383229215303"), {
				color:0x7e3918,
				borderColor:0xfdf7e9,
				textAlign:"center",
				autoSize:"center",
				fontSize:18,
				multiline:true,
				wrap:true
			});
			_textTime.y = 135;
			//_sellPriceContainer.addChild(_textTime);
			
			_textTimeValue = Window.drawText(TimeConverter.timeToStr(_sellTime * _currentCount), {
				color:0xFCD436,
				borderColor:0x794C2F,
				borderSize:3,
				hasShadow:true,
				shadowColor:0x794C2F,
				shadowSize:4,
				textAlign:"center",
				autoSize:"center",
				fontSize:34,
				multiline:true,
				wrap:false
			})
			_textTimeValue.y = _textTime.y + _textTime.height;
			//_sellPriceContainer.addChild(_textTimeValue);
			
			_sellPriceContainer.x = 315;
			_sellPriceContainer.y = 40;
			
			bodyContainer.addChild(_sellPriceContainer);
		}
		private var fishSID:int = 0;
		
		override protected function updateCountAndPrice():void
		{	
			if (instock == 0){
				_currentCount = 0;
				if(_findBttn){
					_findBttn.visible = true;
				}
			}else{
				if( _findBttn){
					_findBttn.visible = false;
				}
			}
			
			if (_limit > 0 && _currentCount > _limit)
				_currentCount = _limit;
			
			if (_currentCount > instock)
				_currentCount = instock;
			else if (_currentCount <= 0 && instock > 0)
				_currentCount = 1;
				
			//countCalc.text = _currentCount.toString();
			
			
			
			var priceCount:int = (_currentCount > 0) ? _currentCount : 1;
			
			var currentMaterialIcon:RewardItem;
			for (var i:int = 0; i < _sellMaterialRewardIcons.length; i++) 
			{
				currentMaterialIcon = _sellMaterialRewardIcons[i];
				//currentMaterialIcon.count = _currentCount * _priceFactors[i].factor;
				currentMaterialIcon.count = priceCount * _priceFactors[i].factor;//ЖЕСТКО
				currentMaterialIcon.updateMaterial(_priceFactors[i].materialID);
				fishSID = Numbers.firstProp(App.data.storage[_priceFactors[i].materialID].personages).key;
				
				Load.loading(Config.getIcon(App.data.storage[fishSID].type, App.data.storage[fishSID].preview), function(data:*):void {
					
					fishka.bitmapData = data.bitmapData;
					fishka.scaleX = fishka.scaleY = 1;
					Size.size(fishka, 100, 100); 
					fishka.x = 50 - (fishka.width) / 2;
					fishka.y = 20 - (fishka.height) / 2;
					//fishka.x = currentMaterialIcon.x;
					//fishka.y = currentMaterialIcon.y + currentMaterialIcon.height;
				});
			}
			
			
			
			//counter.count = instock - _currentCount;
			
			counter.count = (App.user.stock.data[currentMaterialID]);
			
			/*if (_tick)
			{
				_tick.visible = counter.count > 0;
			}*/
			
			//if (_currentCount > 0)
			//{
				//_textTimeValue.text = TimeConverter.timeToStr(_sellTime * _currentCount);
				_textTimeValue.text = TimeConverter.timeToStr(_sellTime * priceCount);
			//}
			//else
			//{
				//_textTimeValue.text = "-";
			//}
		}
		
		override public function dispose():void 
		{
			_findBttn.removeEventListener(MouseEvent.CLICK, onFindClick);
			//_buyBttn.removeEventListener(MouseEvent.CLICK, onBuyClick);
			super.dispose();
		}
	}
}

import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class RewardItem extends LayerX
{
	private var icon:Bitmap;
	public var text:TextField;
	public var sID:uint;
	private var _count:int;
	private var _size:int;
	public var bg:Bitmap;
	
	private var callBack:Function;
	private var iconScale:Number;
	private var marginTxtX:int;
	private var marginTxtY:int;
	private var hasBackingItem:Boolean;
	private var textIsRight:Boolean;
	private var _preText:String;
	
	public function RewardItem(sID:uint, count:int, _callBack:Function, size:int = 40, preText:String = "x ", iconScale:Number = 0.74, marginTxtX:int = 0, marginTxtY:int = 0, hasBackingItem:Boolean = true, textIsRight:Boolean = false)
	{
		this.marginTxtX = marginTxtX;
		this.marginTxtY = marginTxtY;
		this.iconScale = iconScale;
		this.textIsRight = textIsRight;
		
		_size = size;
		
		this.hasBackingItem = hasBackingItem;
		_preText = preText;
		
		icon = new Bitmap();
		this.sID = sID;
		_count = count;
		callBack = _callBack;
		
		bg = Window.backing(_size, _size, 12, "shopSpecialBacking");
		addChild(bg);
		bg.visible = false;
		
		text = Window.drawText(_preText + String(count),{
			fontSize:_size,
			color	:0xffffff,
			borderColor	:0x7e3e14,
			shadowSize	:1,
			shadowColor	:0x754108,
			autoSize:"left"
		});
			
		text.height = text.textHeight;
		text.width = text.textWidth;
		
		tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			}
		};
		
		text.visible = false;
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad)
	}
	
	public function updateMaterial(sid:int):void
	{
		this.sID = sid;
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
		
		tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			}
		};
	}
	
	private function onLoad(data:Bitmap):void
	{			
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		
		Numbers.size(icon, _size, _size);
		
		//if (icon.width > 80)
		//{
			//icon.width = 80;
			////icon.scaleX = icon.scaleY = iconScale;
		//}
		icon.x = (bg.width - icon.width) * 0.5 + 15;
		icon.y = (bg.height - icon.height) * 0.5 + 75;
		
		text.x = (bg.width - text.width) * 0.5 + 12;
		text.y = bg.height + 75;
		
		if (textIsRight)
		{
			icon.x = 20;
			icon.y = (bg.height - icon.height) * 0.5;
		
			text.x = icon.x + icon.width + 8 + marginTxtX;
			text.y = (bg.height - text.height) * 0.5 + marginTxtY + 4;
		}
		
		text.visible = true;
		
		addChild(icon);
		addChild(text);
		
		if (callBack is Function)
		{
			callBack();
		}
	}
	
	public function get count():int 
	{
		return _count;
	}
	
	public function set count(value:int):void 
	{
		_count = value;
		text.text =  _count.toString();
	}
}