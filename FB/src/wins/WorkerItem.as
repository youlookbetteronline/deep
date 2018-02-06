package wins{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.Hints;
	import units.Animal;
	import units.Techno;
	import wins.elements.BankMenu;
	import wins.Window;
		
	public class WorkerItem extends Sprite
	{
		public static const IN:int = 1;
		public static const OUT:int = 2;
		public static const READY:int = 1;
		public static const UNREADY:int = 2;
		
		public var background:Bitmap;
		public var title:TextField;
		
		public var countContainer:Sprite = new Sprite;
		public var count_txt:TextField;
		public var vs_txt:TextField;
		public var need_txt:TextField;
		public var inStock:TextField;
		public var inStockLabel:Sprite;
		
		public var need:int;
		public var count:int;
		public var outTip:Boolean = false;
		
		public var sID:uint;
		public var info:Object;
		//public var preloader = null; 
		public var bitmap:Bitmap;
		
		public var coinsBttn:MoneyButton;
		
		public var moneyType:String;
		public var status:int = MaterialItem.READY;
		
		public var buyBttn:MoneyButton;
		//public var giftBttn:ImageButton;
		public var askBttn:Button;
		public var wishBttn:ImageButton;
		public var searchBttn:ImageButton;
		public var cookBttn:Button;
		
		public var type:int;
		public var win:Window;
		public var outCount:int;
		
		public var bitmapDY:int = 0;
		public var wishBtnDY:int = 0;
		
		public var animalLabel:TextField;
		public var thinkBttn:Button;
		
		public var bgItem:Bitmap;
		
		public var titleColor:int;
		public var bttnAskHeight:int;
		public var bttnAskWidth:int;
		public var bttnBuyHeight:int;
		public var bttnBuyWidth:int;
		public var blockBttn:Boolean;
		public var titleBorderColor:int;
		
		private var settings:Object = {};
		
		public function WorkerItem(settings:Object, bg:Bitmap = null){
			
			this.sID = settings.sID || 0;
			this.need = settings.need || 0;
			this.type = settings.type || MaterialItem.IN;
			this.win = settings.window || null;
			this.outCount = settings.outCount || 1;
			this.bitmapDY = settings.bitmapDY || -10;
			this.wishBtnDY = settings.wishBtnDY || 0;
			this.outTip = settings.outTip || false;
			this.settings = settings;
			titleColor = settings.color || 0x6e411e;
			titleBorderColor = settings.borderColor || 0xfaf9ec;
			bttnAskHeight = settings.bttnAskHeight || 40;
			bttnAskWidth = settings.bttnAskWidth || 105;
			bttnBuyHeight = settings.bttnBuyHeight || 40;
			bttnBuyWidth = settings.bttnBuyWidth || 105;
			blockBttn = settings.blockBttn || false;
			info = App.data.storage[sID];
			//App.data.stotage[sID];
			bgItem = bg;
			
			if (sID != 0) init();
		}
		
		public function init():void
		{
			
			App.self.addEventListener(AppEvent.ON_CLOSE_BANK, onCloseBank);
			
			//background = Window.backing(150, 200, 10, "itemBacking");
			
			var backgroundShape:Shape = new Shape();
			backgroundShape.graphics.beginFill(0xe6b685);
			backgroundShape.graphics.drawCircle(50, 50, 50);
			backgroundShape.graphics.endFill();
			
			background = new Bitmap(new BitmapData(100, 100, true, 0));
			background.bitmapData.draw(backgroundShape);
			
			//background = new Bitmap(Window.textures.bgItem);
			addChild(background);
			
			drawBitmap();
			drawTitle();
			
			switch(info.type) {
				
				case "Animal":
						drawAnimalInfo();
					break;
				case "Building":
				case "Guide":
				case "Dock":
				case "Bridge":
				case "Floors":
						drawCount();
						drawBttns();
						askBttn.visible = false;
					break;	
				default:
						if(type ==  WorkerItem.IN){
							drawCount();
						}else{
							drawInfo();
						}
						drawBttns();
					break;
				
			}
		}	
		
		protected function drawTitle():void
		{
			/*var size:Point = new Point(150, 50);
			var pos:Point = new Point(
				(background.width - size.x) / 2,
				 background.y - size.y / 2 - 10
			 );
			
			title = Window.drawTextX(App.data.storage[sID].title, size.x, size.y, pos.x, pos.y, this, {
				color:titleColor,
				borderColor:titleBorderColor,
				fontSize:26,
				
				color:0x000000,
				borderColor:0x000000,
				textLeading: -6
			});*/
			
			title = Window.drawText(App.data.storage[sID].title, {
				color:titleColor,
				borderColor:titleBorderColor,
				fontSize:26,
				multiline:true,
				textAlign:'center',
				wrap:true,
				wordwrap:true,
				width:110
			});
			
			title.x = background.x + (background.width - title.width) / 2;
			title.y = background.y - title.height / 2 - 5;
			addChild(title);
			
			
		}
		
		public var bankBttn:Button;
		protected function drawBttns():void
		{
			if (type == WorkerItem.IN)
			{
				//giftBttn = new ImageButton(new GiftBttn());
				//addChild(giftBttn);
				//giftBttn.y = 156;				
				wishBttn = new ImageButton(Window.textures.wishlistBttn);
				//if (App.data.storage[sID].type != 'Techno') {
				if (!App.user.quests.tutorial && !blockBttn) 
				{
					addChild((wishBttn));
					
				}
				
				//}
				searchBttn = new ImageButton(Window.textures.showMeBttn);
				//if (App.data.storage[sID].type != 'Techno') {
				//addChild(searchBttn);
				
				
				wishBttn.tip = function():Object 
				{ 
					return {
						title:"",
						text:Locale.__e("flash:1382952380013")
					};
				};
				
				wishBttn.scaleX = wishBttn.scaleY = 0.7;
				searchBttn.scaleX = searchBttn.scaleY = 0.7;
				
				if (settings.window is ConstructWindow) 
				{
					wishBttn.y -= 5 + wishBtnDY ;
					wishBttn.x -= 35;
					wishBttn.scaleX = wishBttn.scaleY = 1;
					searchBttn.scaleX = searchBttn.scaleY = 1;
					searchBttn.x = wishBttn.x + 2;
					searchBttn.y = wishBttn.y + wishBttn.height + 10;
				}
				else 
				{
					wishBttn.scaleX = wishBttn.scaleY = .8;
					searchBttn.scaleX = searchBttn.scaleY = .9;
					wishBttn.y = 2;
					wishBttn.x = - 20;
					searchBttn.x = wishBttn.x + 2;
					searchBttn.y = wishBttn.y + wishBttn.height + 27;
				}
				
				
				
				
				askBttn = new Button({
					caption			:Locale.__e("flash:1407231372860"),
					fontSize		:28,
					radius      	:20,
					fontColor		:0xffffff,
					fontBorderColor	:0x085c10,
					bgColor			:[0xc6e215,0x81b631],
					//borderColor		:[0xeafed1, 0x577c2d],
					bevelColor		:[0xeafed1, 0x577c2d],
					width			:bttnAskWidth,
					height			:bttnAskHeight
					
				});
				
				//askBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
				
				
				
			/*	bgColor:[0xbaf76e,0x68af11],
			borderColor:[0xa0d5f6, 0x3384b2],
			fontColor:0xFFFFFF,
			fontBorderColor:0x435060,
			bevelColor:[0xd8e7ae, 0x4f9500],*/
			
			
				askBttn.x = background.x + (background.width - askBttn.width) / 2;
				askBttn.y = background.y + background.height + 8;
				
				buyBttn = new MoneyButton({
					caption		:Locale.__e('flash:1382952379751'),
					width		:bttnBuyWidth,
					height		:bttnBuyHeight,
					fontSize	:22,
					radius		:20,
					countText	:0,
					multiline	:true
				});
				
				buyBttn.updatePos();
				buyBttn.x = /*background.x - 8 + askBttn.x;*/background.x + (background.width - buyBttn.width) / 2;
				buyBttn.y = askBttn.y + askBttn.height + 4;
				//buyBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
				if (!App.user.quests.tutorial) 
				{
					addChild(buyBttn);
				}
				buyBttn.addEventListener(MouseEvent.CLICK, buyEvent);	
				
				if (sID == Stock.FANT || sID == Stock.COINS || sID == Stock.FANTASY) 
				{
					var bttnSettings:Object = { 
						fontSize:24,
						caption:Locale.__e("flash:1382952379751"),
						height:43,
						width:121
					};
					bankBttn = new Button(bttnSettings);
					if (!App.user.quests.tutorial) 
					{
						addChild(bankBttn);
					}
					bankBttn.x = background.width / 2 - bankBttn.width / 2;
					bankBttn.y = 182 - 20;
					bankBttn.addEventListener(MouseEvent.CLICK, showBank);
					buyBttn.alpha = 0;
					
					if (App.social == "FB")
						bankBttn.y -= 20;
					
					switch(sID) {
						case Stock.FANT:
							bankBttn.order = 1;
						break;
						case Stock.COINS:
							bankBttn.order = 2;
						break;
						case Stock.FANTASY:
							bankBttn.order = 3;
						break;
						
					}
				}
				
				addChild(askBttn);
				if (App.user.quests.tutorial) 
				{
					askBttn.y += 10;
					askBttn.name = 'seach_bttn';
					/*if (askBttn.__hasGlowing) 
					{
						askBttn.hideGlowing();
					}
					askBttn.showGlowing();*/
				}
				
				if (App.self.flashVars.social != 'OK')
				{
					//if (App.data.storage[sID].type != 'Techno') {
						if (!App.user.quests.tutorial && !blockBttn) 
						{
							addChild(searchBttn);
						}
					//}
				}
				//buyBttn.y = 165 - 10;
				
				askBttn.addEventListener(MouseEvent.CLICK, searchEvent);
				wishBttn.addEventListener(MouseEvent.CLICK, wishesEvent);
				searchBttn.addEventListener(MouseEvent.CLICK, askEvent);
	
			}
			else
			{
				if (outCount > 1)
				{
					var outCount_txt:TextField = Window.drawText("x "+String(outCount),{
						fontSize		:20,
						color			:0xffdc39,
						borderColor		:0x6d4b15,
						textAlign:"right"
					});
					outCount_txt.width = 140;					
					addChild(outCount_txt);
					
					//outCount_txt.border = true
					outCount_txt.x = 10;
					outCount_txt.y = 125;					
				}						
				
				cookBttn = new Button({
					caption:Locale.__e('flash:1382952380036'),
					width:116,
					height:36,
					radius:25,
					shadow:true
				});
				cookBttn.x = background.width / 2 - cookBttn.width / 2;
				cookBttn.y = 174;
			
				addChild(cookBttn);
			}
			
		wishBttn.tip = function():Object
			{
								
			return {text: Locale.__e('flash:1425981479280')}
				
			}
		searchBttn.tip = function():Object
			{
								
			return {text: Locale.__e('flash:1425981456235')}
				
			}
		askBttn.tip = function():Object
			{
								
			return {text: Locale.__e('flash:1425981432950')}
				
			}
			
		}
		
		public function searchEvent(e:MouseEvent):void 
		{
			if (App.user.quests.tutorial) 
			{
				Window.closeAll();
				//ShopWindow.findMaterialSource(sID, win, 1);
			}else
				ShopWindow.findMaterialSource(sID, win);
		}
		
		public function showBank(e:MouseEvent):void 
		{
			switch(bankBttn.order) {
				case 1:
					BankMenu._currBtn = BankMenu.REALS;
					BanksWindow.history = {section:'Reals',page:0};
					new BanksWindow({popup:true}).show();
				break;
				case 2:
					BankMenu._currBtn = BankMenu.COINS;
					BanksWindow.history = {section:'Coins',page:0};
					new BanksWindow({popup:true}).show();
				break;
				case 3:
					new PurchaseWindow( {
						popup:true,
						width:716,
						itemsOnPage:4,
						content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Energy'}),
						title:Locale.__e("flash:1382952379756"),
						description:Locale.__e("flash:1382952379757"),
						closeAfterBuy:false,
						autoClose:false,
						callback:function(sID:int):void {
							var object:* = App.data.storage[sID];
							App.user.stock.add(sID, object);
						}
					}).show();
				break;
			}
		}
		
		protected var intervalPluck:int;
		public var preloader:Preloader = new Preloader();
		public var sprTip:LayerX = new LayerX();
		public function drawBitmap():void
		{
			
			sprTip.tip = function():Object {
				return {
					title: info.title,
					text: info.description
				};
			}
			
			bitmap = new Bitmap();
			sprTip.addChild(bitmap);
			addChild(sprTip);
			
			if (App.user.stock.count(sID) < need) {
				setTimeout(setPluck, 2000);
			}
			
			addChild(preloader);
			preloader.x = (background.width) / 2;
			preloader.y = (background.height) / 2;
			Load.loading(Config.getIcon(info.type, info.preview), onPreviewComplete);
		}
		
		public function doPluck():void
		{
			if (App.user.stock.count(sID) < need && !sprTip.isPluck) {
				sprTip.pluck(30, sprTip.width / 2, sprTip.height / 2 + 50);
			}
		}
		
		protected function setPluck():void 
		{
			if(!sprTip.isPluck)sprTip.pluck(30, sprTip.width / 2, sprTip.height / 2 + 50);
			if (App.user.stock.count(sID) < need) {
				intervalPluck = setInterval(randomPluck, Math.random()* 5000 + 2000);
			}
		}
		
		private function randomPluck():void
		{
			if (App.user.stock.count(sID) >= need) {
				clearInterval(intervalPluck);
			}
			if (!sprTip.isPluck) {
				sprTip.pluck(30, sprTip.width / 2, sprTip.height / 2 + 50);
			}
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			Size.size(bitmap, 70, 70);
			//bitmap.scaleX = bitmap.scaleY = 0.7;
			sprTip.x = (background.width - bitmap.width)/ 2;
			sprTip.y = (background.height - bitmap.height) / 2 + bitmapDY;
			
			if (bgItem) {
				
				if (settings.bgItemY) 
					sprTip.y = settings.bgItemY;
				if (settings.bgItemX) 
					sprTip.x = settings.bgItemX;
					
				
				
				sprTip.addChildAt(bgItem, 0);
				//bitmap.scaleX = bitmap.scaleY = 0.9;
				bitmap.x = bgItem.x + (bgItem.width - bitmap.width) / 2;
				bitmap.y = (bgItem.height - bitmap.height) / 2;
				//bitmap.width = bgItem.width - 30;
				//bitmap.height = bgItem.height - 30;
			}
			
			/*if (bitmap.bitmapData.height == 471) 
			{
				
			}*/
		}
		
		public function drawAnimalInfo():void {
			animalLabel = Window.drawText(Locale.__e("flash:1382952380225"),{
				fontSize		:18,
				color			:0xee9177,
				borderColor		:0x8c2a24,
				autoSize:"left"
			});
			
			
			addChild(animalLabel);
			animalLabel.x = (background.width - animalLabel.width) / 2;
			animalLabel.y = 136;
			
			thinkBttn = new Button({
				caption		:Locale.__e("flash:1382952380226"),
				width		:104,
				height		:30,	
				fontSize	:22
			});
			thinkBttn.x = (background.width - thinkBttn.width) / 2;
			thinkBttn.y = 160;
			addChild(thinkBttn);
			
			thinkBttn.addEventListener(MouseEvent.CLICK, onThinkEvent);
		}
		
		private function onThinkEvent(e:MouseEvent):void {
			new ShopWindow( { find:[Stock.SPHERE], forcedClosing:true } ).show();
		}
		
		public function drawCount():void
		{
			if (App.data.storage[sID].type != 'Techno') {
				count = App.user.stock.count(sID);
			}else {
				count = Techno.freeTechnoBySID(sID).length;
			}
			
			count_txt = Window.drawText(String(count),{
				fontSize		:30,
				color			:0xffffff,
				borderColor		:0x713f15,
				autoSize:"left"
			});
			
			vs_txt = Window.drawText("/"+" ",{
				fontSize		:30,
				color			:0xffffff,
				borderColor		:0x713f15,
				autoSize:"left"
			});
			
										
			need_txt = Window.drawText(String(need),{
				fontSize		:30,
				color			:0xffffff,
				borderColor		:0x713f15,
				autoSize:"left"
			});							
									
			countContainer.addChild(count_txt)							
			countContainer.addChild(vs_txt)							
			countContainer.addChild(need_txt)							
			countContainer.height = need_txt.textHeight;
			addChild(countContainer)
			refreshCountPosition()
		}
		
		public function drawCountInfo():void {
			
			var countInStock:int = App.user.stock.count(sID);
			
			inStock = Window.drawText(String(countInStock), {
				color:0xfcf5e5,
				fontSize:16,
				borderColor:0x2e3332,
				autoSize:"left"
			});
			
			var width:uint = inStock.width + 4 > 30?inStock.width + 4:30;
			inStockLabel = Window.getBacking(width, 24, 0, 0, 10, {
				bgColor:0xd2c7ac,
				glowColor:0x464338
			});
			inStockLabel.name = 'inStockLabel'
			
			inStock.x = (inStockLabel.width - inStock.width) / 2;
			inStock.y = 0;
			
			inStockLabel.addChild(inStock);
			
			addChild(inStockLabel);
			inStockLabel.x = background.width - inStockLabel.width - 14;
			inStockLabel.y = 36;
			
			if (countInStock == 0) {
				inStock.visible = false
				inStockLabel.visible = false
			}
		}
		
		public function drawInfo():void {
			drawCountInfo();
			
			var text:TextField
				text = Window.drawText(Locale.__e("flash:1382952380227"), {
					color:0x4a401f,
					borderColor:0xfcf5e3,
					borderSize:1,
					autoSize:"left",
					fontSize:11,
					sharpness:0,
					thickness:100
				});
			
			addChild(text);
			text.x = 31;
			text.y = 153;
		
			/*var gold:Bitmap = new Bitmap(new GoldCoinsIcon(), "auto", true);
			gold.scaleX = gold.scaleY = 0.8;
			gold.x = 85;
			gold.y = 155;
			addChild(gold);*/
			
			text = Window.drawText(info.cost, {
				color:0xffdc39,
				borderColor:0x6d4b15,
				autoSize:"left",
				fontSize:14
			});
			
			addChild(text);
			text.x = 108;
			text.y = 151;
		}
			
		
		public function setText(type:String, txt:*):void
		{
			if (App.data.storage[sID].type != 'Techno') {
				switch(type)
				{
					case "count":
						count_txt.text = String(txt)
						count = Number(txt)
						break
					case "need":
						need_txt.text = String(txt)
						need = Number(txt)
						break
				}
			}else {
				switch(type)
				{
					case "count":
						count = Techno.freeTechno().length;
						count_txt.text = String(count)
						//count = Number(txt)
						break
					case "need":
						need_txt.text = String(txt)
						need = Number(txt)
						break
				}
				//count = Techno.freeTechno().length;
				//count_txt.text = String(count);
				//count = Number(txt)
			}

			
			refreshCountPosition()
		}
		
		
		protected function refreshCountPosition():void
		{
			/*if (sID == 2)
			{
				count_txt.y = 4;
			}else
			{*/
			count_txt.y = background.y + background.height - 55;
			//}
			count_txt.x = 0;
			
			vs_txt.x = count_txt.x + count_txt.textWidth;
			vs_txt.y = count_txt.y;
			need_txt.x = vs_txt.x + vs_txt.textWidth;
			need_txt.y = count_txt.y;
			
			countContainer.x = background.width / 2 - countContainer.width / 2;
		}
		
		public function checkStatus():void
		{
			
			if(sID&&App.data.storage[sID].type == 'Techno'){
				count = Techno.freeTechno().length;
			}else{
			count = App.user.stock.count(sID);
			}
			switch(info.type) {
				
				case "Guide":
						if (App.user.stock.count(sID) >= need)
							changeOnREADY();
						else
							changeOnUNREADY();
				break;
				
				case "Bridge":
					if (sID == 776) {
						if (count >= need)
							changeOnREADY();
						else
							changeOnUNREADY();
						break;	
					}
				case "Building":
				case "Dock":
						status = WorkerItem.UNREADY;
						var result:Array = [];
						var i:int = App.map.mSort.numChildren;
						count = 0;
						while (--i >= 0)
						{
							var unit:* = App.map.mSort.getChildAt(i);
							if (info.type == unit.type && sID == unit.sid)
							{
								if(unit.level >= unit.totalLevels)
									count ++;
							}
						}
						
						if (count >= need)
							changeOnREADY();
						else
							changeOnUNREADY();
				break;
				case "Floors":
					status = WorkerItem.UNREADY;
						var _result:Array = [];
						var _i:int = App.map.mSort.numChildren;
						count = 0;
						while (--_i >= 0)
						{
							var _unit:* = App.map.mSort.getChildAt(_i);
							if (sID == _unit.sid)
							{
								if(_unit.info.tower[_unit.floor + 1] == undefined)
									count ++;
							}
						}
						
						if (count >= need)
							changeOnREADY();
						else
							changeOnUNREADY();
					
				default:
					status = WorkerItem.READY;
					if(type == WorkerItem.IN){
						if (count >= need)
							changeOnREADY();
						else
							changeOnUNREADY();
					}else {
						if(count>0){
							inStock.text = String(count);// + ' шт';
							inStock.visible = true;
							inStockLabel.visible = true;
						}else {
							inStock.visible = false;
							inStockLabel.visible = false;
						}
					}
				break
			}
		}
		
		protected function onCloseBank(e:AppEvent):void
		{
			if(buyBttn){
				buyBttn.state = Button.NORMAL;
			}
		}
		
		public function changeOnREADY():void
		{
			clearInterval(intervalPluck);
			
			status = WorkerItem.READY;
			if(App.data.storage[sID].type == 'Techno'){
				count = Techno.freeTechno().length;
			}
			setText("count", count);
			
			var filter:GlowFilter = new GlowFilter(0x6d4115, 1, 4, 4, 2, 1);
			var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90, 0x6d4115,1,1,1,6,1);
			count_txt.filters 	= [filter,shadowFilter];
			vs_txt.filters 		= [filter,shadowFilter];
			need_txt.filters 	= [filter,shadowFilter];
			
			count_txt.textColor = 0xfef6e7;
			vs_txt.textColor 	= 0xfef6e7;
			need_txt.textColor 	= 0xfef6e7;
			
			if(sID == Stock.FANTASY || sID == Stock.COINS || sID == Stock.FANT){
				count_txt.parent.removeChild(count_txt);
				vs_txt.parent.removeChild(vs_txt);
				need_txt.x = 0;
				countContainer.x = background.width / 2 - countContainer.width / 2;
			}
			
			countContainer.y = background.height - countContainer.height - 15;
			
			wishBttn.visible 	= false;
			buyBttn.visible 	= false;
			askBttn.visible 	= false;
			searchBttn.visible = false;
			
			if (bankBttn) bankBttn.visible = false;
		}
		
		public function changeOnUNREADY():void
		{
			if(	App.data.storage[sID].type == 'Techno'){
				count = Techno.freeTechno().length;
			}
			setText("count", count);
			
			status = WorkerItem.UNREADY;
			countContainer.y = background.height - countContainer.height - 30 ;
			var filter:GlowFilter = new GlowFilter(0x713f15, 1, 4, 4, 2, 1);
			var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90, 0x713f15,1,1,1,8,1);
			
			if (!count_txt.parent || !vs_txt.parent) {
				countContainer.addChild(count_txt);
				countContainer.addChild(vs_txt);
				refreshCountPosition();
			}
			
			count_txt.filters 	= [filter, shadowFilter];
			vs_txt.filters 		= [filter, shadowFilter];
			need_txt.filters 	= [filter, shadowFilter];
			
			count_txt.textColor = 0xffffff;
			vs_txt.textColor 	= 0xffffff;
			need_txt.textColor 	= 0xffffff;
			
			if(info.hasOwnProperty('price')){
				buyBttn.count = String((need - count) * info.price[Stock.FANT]);
				buyBttn.visible 	= true;
				if (info.real) info.real = 1;
				if (bankBttn) bankBttn.visible = true;
			}else{
				buyBttn.count = '-1';
				buyBttn.visible 	= false;
				if (bankBttn) bankBttn.visible = false;
			}	
			
			wishBttn.visible 	= true;
			
				
			
			if (/*sID != Stock.FANTASY &&*/
				App.data.storage[sID].type != 'Building' && 
				App.data.storage[sID].type != 'Guide' &&
				App.data.storage[sID].type != 'Bridge' &&
				App.data.storage[sID].type != 'Dock' &&
				App.data.storage[sID].type != 'Floors' &&
				App.data.storage[sID].type != 'Techno' 
				){
				askBttn.visible = true;
				wishBttn.visible = true;
				
				if(!App.isSocial('YB','MX','AI','YN')){  
					searchBttn.visible = true;
				} else {
					searchBttn.visible = false;
				}
			}else{
				askBttn.visible = false;
				wishBttn.visible = false;
				searchBttn.visible = false;
			}	
			
			/*if (WishList.canAddWishList(sID)){
				askBttn.visible = true;
				wishBttn.visible = true;
			}else{
				askBttn.visible = false;
				wishBttn.visible = false;
			}	*/	
			//if (info.real == 0) {
				//buyBttn.visible = false;
			//}
			
			if (info.mtype == 3){
				askBttn.visible 	= false;
				wishBttn.visible 	= false;
				searchBttn.visible = false;
			}
			
			/*if (App.social == 'YB') {
				askBttn.visible = false;
				buyBttn.y -= 20;
			}*/
		}
			
		public function askEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
			
			if (App.social == 'FB')
			{
				e.currentTarget.state = Button.DISABLED;
				Gifts.ask(sID, App.user.id, function():void {
					e.currentTarget.state = Button.NORMAL;
					new SimpleWindow( {
						title:		info.title,
						text:		Locale.__e('flash:1428417517657'),
						popup:		true
					}).show();
					
				});
				return;
			}
			
			new AskWindow(AskWindow.MODE_ASK,  { sID:sID, inviteTxt:Locale.__e("flash:1382952379977"), height:470 } ).show();
		}
		
		public function wishesEvent(e:MouseEvent):void
		{
			App.wl.show(sID, e);
		}
		
		private function giftEvent(e:MouseEvent):void
		{
			
		}
		
		/**
		 * Покупка материала flash:1382952379984 деньги
		 * @param	e
		 */
		public function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (settings.hasOwnProperty('disableAll'))
				settings.disableAll(true);
			
			var def:int = need - count;
			e.currentTarget.state = Button.DISABLED;
			App.user.stock.buy(sID, def, onBuyEvent);
		}
		
		private function onBuyEvent(price:Object):void
		{
			for (var sid:* in price) {
				
				var pnt:Point = App.self.tipsContainer.localToGlobal(new Point(buyBttn.mouseX, buyBttn.mouseY));
				pnt.x += this.x + buyBttn.x; 
				pnt.y += this.y + buyBttn.y - 30; 
				
				Hints.minus(sid, price[sid], pnt, false);
				break;
			}
			
			clearInterval(intervalPluck);
			
			
			count = App.user.stock.count(sID);
			changeOnREADY();
			dispatchEvent(new WindowEvent("onContentUpdate"));
			
			if (settings.hasOwnProperty('disableAll'))
				settings.disableAll(false);
		}
		
		public function disableBtt(value:Boolean = true):void
		{
			if (buyBttn) {
				if(value)
					buyBttn.state = Button.DISABLED;
				else
					buyBttn.state = Button.NORMAL;
			}
		}
		
		public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CLOSE_BANK, onCloseBank);
			
			clearInterval(intervalPluck);
			/*if(type == MaterialItem.IN){
				askBttn.removeEventListener(MouseEvent.CLICK, askEvent);
				wishBttn.removeEventListener(MouseEvent.CLICK, wishesEvent);
				buyBttn.removeEventListener(MouseEvent.CLICK, buyEvent);
			}
			if (thinkBttn != null) {
				thinkBttn.removeEventListener(MouseEvent.CLICK, onThinkEvent);
			}*/
		}
	}
}