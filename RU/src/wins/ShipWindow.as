package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import buttons.UpgradeButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import units.Decor;
	import units.Port;
	
	public class ShipWindow extends Window 
	{
		
		public var hold:StockList;		// Трюм // Backpack
		public var stock:StockList;		// Склад
		public var contentSprite:Sprite;
		public var items:Array;
		private var upgradeBttn:Button;
		private var moveAllBttn:Button;
		private var holdDescLabel:TextField;
		public var infoBttn:ImageButton;
		private var preloader:Preloader = new Preloader();
		
		public static var shipID:int = 1948;
		
		public var upArrowIcon:Bitmap;
		
		public var block:Boolean = false;
		
		public function ShipWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			settings['width'] = settings['width'] || 790;
			settings['height'] = settings['height'] || 600;
			settings['hasTitle'] = false;
			settings['hasPaginator'] = false;
			settings['background'] = 'workerHouseBacking';
			
			super(settings);
		}
		
		/*override public function drawBackground():void {
			//
		}*/
		
		override public function contentChange():void 
		{
			clearItems();
			
			items = new Array();
			//contentSprite = new Sprite();
			hold = new StockList( {
				title:		Locale.__e('flash:1408027518943'),
				window:		this,
				content:	getHold(),
				prebacking:	'paperClear',
				find:       (settings.hasOwnProperty('findEvent') && settings.findEvent != 'load')?settings.find:null,
				itemsCount:	9,
				contY:		106,
				type:		ShipTransferWindow.TO_STOCK,
				hasButtons:	false
			});
			hold.y = (settings.height - hold.height) / 2 + 10;
			hold.x = settings.width / 2 - hold.width - 10;
			bodyContainer.addChildAt(hold,0);
	
			
			stock = new StockList( {
				title:		(User.inExpedition)?App.data.storage[Decor.STOCKHOUSE].title:Locale.__e('flash:1382952379767'),
				window:		this,
				content:	getStock(),
				prebacking:	'paperClear',
				find:       (settings.hasOwnProperty('findEvent') && settings.findEvent == 'load')?settings.find:null,
				titleDecor:	true,
				itemsCount:	12,
				contY:		60,
				type:		ShipTransferWindow.FROM_STOCK,
				hasButtons:	true
			} );
			stock.y = (settings.height - stock.height) / 2 + 10;
			stock.x = settings.width / 2 + 10;
			bodyContainer.addChildAt(stock, 0);
			items.push(hold);
			items.push(stock);
			//items.push(holdDescLabel);
		}
		
		public function clearItems():void 
		{
			for each(var _itm:* in items)
			{
				if (_itm.parent)
					_itm.parent.removeChild(_itm);
			}
				
		}
		
		override public function drawBody():void {
			exit.y -= 15;
			
			contentChange();
			
			holdDescLabel = drawText(Locale.__e('flash:1418642098384'), {
				fontSize:		27,
				color:			0xffffff,
				borderColor:	0x885631,
				textAlign:		'center',
				multiline:		true,
				wrap:			true,
				width:			300
			});
			holdDescLabel.wordWrap = true;
			holdDescLabel.x = hold.x + (hold.width - holdDescLabel.width) / 2;
			holdDescLabel.y = hold.y + (hold.height - holdDescLabel.height) / 2;
			bodyContainer.addChild(holdDescLabel);
			
			moveAllBttn = new Button( {
				caption:		Locale.__e('flash:1419257349967'),
				width:			120,
				height:			42,
				fontSize:		21,
				radius:			12
			});
			
			moveAllBttn.x = hold.x + moveAllBttn.width;
			moveAllBttn.y = hold.y + hold.height - 125;
			bodyContainer.addChild(moveAllBttn);
			moveAllBttn.addEventListener(MouseEvent.CLICK, onMoveAll);
			
			upgradeBttn = new Button({  
				caption: Locale.__e("flash:1393580216438"),
				width:110,
				height:36,
				fontBorderColor:0x2b4a84,
				countText:"",
				fontSize:24,
				radius:12,
				color: 0xcaebfc,
				bgColor : [0x97c9fe, 0x5e8ef4],
				bevelColor : [0xb3dcfc, 0x376dda],
				fontColor : 0xffffff
			});
			
			upgradeBttn.addEventListener(MouseEvent.CLICK, upgradeAction);
			
			upgradeBttn.x = hold.x + upgradeBttn.width + 80; 
			upgradeBttn.y = hold.y + upgradeBttn.height + 30;
			
			// стрелочка для кнопки "Улучшить"
			/*upArrowIcon = new Bitmap(Window.textures.upgradeArrow, "auto", true);
			upArrowIcon.scaleX = upArrowIcon.scaleY = 0.8;
			upArrowIcon.x = upgradeBttn.x + 4;
			upArrowIcon.y = upgradeBttn.y;
		
			bodyContainer.addChild(upArrowIcon);*/
			bodyContainer.addChild(upgradeBttn);	
			updateStocks();
			createInfoIcon();
			
		}
		
		private function createInfoIcon():void {
			
			infoBttn = new ImagesButton(Window.textures.infoBttnPink);
			
			infoBttn.tip = function():Object { 
				return {
					title:Locale.__e("flash:1382952380254"),
					text:''
				};
			};
			
			infoBttn.addEventListener(MouseEvent.CLICK, onInfo);
			
			/*bodyContainer.addChild(preloader);
			preloader.x = 35;
			preloader.y = 35;*/
			//preloader.scaleX = preloader.scaleY = 0.5;
			
			
			infoBttn.x = 15;
			infoBttn.y = 15;
			
			bodyContainer.addChild(infoBttn);	
		}
		
		private function onInfo (e:Event = null):void 
		{
			var hintWindow:ExpeditionHintWindow = new ExpeditionHintWindow( {
				popup: true,
				hintsNum:3,
				hintID:4,
				height:575
			}
			);
			hintWindow.show();
		}
			
		public function upgradeAction(e:MouseEvent):void {
			upgradeShip(updateStocks);
		}
		
		private var upgradeCallback:Function;
		public function upgradeShip(callback:Function = null):void {
			upgradeCallback = callback;
			
			//var target:Object = { sid:shipID, level:App.user.ministock.level - 1, viewID:id, totalLevels:Numbers.countProps(App.data.storage[shipID].devel.obj), type:type, info: App.data.storage[shipID]};
			var target:Object = { 
				sid			:shipID, 
				level		:App.user.ministock.level , 
				viewID		:id, 
				totalLevels	:Numbers.countProps(App.data.storage[shipID].devel.obj), 
				info		:App.data.storage[shipID]
			};
			//target.info.devel.req[level + 1] = { t:0, l:0 };
			//target.info.devel.skip[level + 1] = 0;
		
			new SimpleConstructWindow( {
				title			:App.data.storage[shipID].title,
				upgTime			:0,
				request			:target.info.devel.obj[App.user.ministock.level + 1],
				target			:target,
				useRequires		:true,
				win				:null,
				onUpgrade		:actionShipUpgrade,
				height			:420,
				hasDescription	:true,
				bttnTxt			:Locale.__e('flash:1396963489306'),
				noSkip			:true,
				mode			:ConstructWindow.ALL_IN_LINE
			}).show();
	
		}
		
		public function actionShipUpgrade(require:Object):void {
			if (!App.user.stock.checkAll(require)) return;
			App.user.stock.takeAll(require);
			
			Post.send( {
				ctr:	'user',
				act:	'ship',
				sID:	Port.shipID,
				uID:	App.user.id,
				wID:    App.user.worldID
			}, onShipUpgrade);
		}
		
		private function onShipUpgrade(error:int, data:Object, params:Object):void {
			if (error) return;
			
			App.user.ministock.level++;
			
			if (upgradeCallback != null) {
				upgradeCallback();
				upgradeCallback = null;
			}
		}
		
		private function onMoveAll(e:MouseEvent = null):void {
			moveAll();
		}
		
		private function moveAll():void {
			if (Numbers.countProps(App.user.ministock.items) > 0) {
				var list:Array = [];
				for (var s:* in App.user.ministock.items) {
					if (App.user.ministock.items[s] == 0) continue;
					list.push( { sid:int(s), count:App.user.ministock.items[s], order:App.data.storage[s].order } );
				}
				
				list.sortOn('order', Array.NUMERIC);
				
				var items:Object = { };
				var volume:int = 0;
				for (var i:int = 0; i < list.length; i++) {
					var count:int = list[i].count;
					items[list[i].sid] = count;
				}
				
				unloadHold(items);
			}
		}
		
		override public function drawFader():void {
			super.drawFader();
			this.y -= 40;
			fader.y += 40;
		}
		
		private function getHold():Array {
			var list:Array = [];
			
			if (App.user.ministock && App.user.ministock['items']) {
				for (var s:* in App.user.ministock.items) {
					if (App.user.ministock.items[s] == 0) continue;
					
					list.push( { sid:int(s), count:App.user.ministock.items[s], order:App.data.storage[s].order } );
				}
			}
			
			return list;
		}
		
		private function getStock():Array {
			var list:Array = [];
			/*if (User.inExpedition)
			{
				for (var es:* in App.user.ministock.items)
				{
					list.push({sid:int(es), count:App.user.ministock.items[es], order:App.data.storage[es].order});
				}
			}*/
			/*else
			{*/
				for (var s:* in App.user.stock.data) {
					if (App.user.stock.data[s] == 0) continue; 
					
					switch(App.data.storage[s].type) {
						case 'Material':
							if (App.data.storage[s].mtype == 4) 
							continue;
							if (App.data.storage[s].mtype != 3) {
								list.push({sid:int(s), count:App.user.stock.data[s], order:App.data.storage[s].order});
							}
							break;
						case 'Firework':
						case 'Decor':
						case 'Energy':
						case 'Golden':
						case 'Tribute':
						case 'Box':
						case 'Walkgolden':
						case 'Zoner':
							list.push( { sid:int(s), count:App.user.stock.data[s], order:App.data.storage[s].order } );
							break;
					}
					
				}
			/*}*/
			list.sortOn('order', Array.NUMERIC);
			return list;
		}
		
		public function loadHold(items:Object = null):void {
			if (Numbers.countProps(items) > 0 && App.user.stock.checkAll(items)) {
				block = true;
				
				Post.send( {
					ctr:		'user',
					act:		'load',
					uID:		App.user.id,
					wID:		App.map.id,
					items:		JSON.stringify(items)
				}, function (error:int, data:Object, params:Object):void {
					block = false;
					
					if (error) return;
					
					for (var s:* in items) {
						if (!App.user.ministock) App.user.ministock = { };
						if (!App.user.ministock['items']) App.user.ministock['items'] = { };
						if (!App.user.ministock.items.hasOwnProperty(s)) App.user.ministock.items[s] = 0;
						App.user.ministock.items[s] += items[s];
					}
					App.user.stock.takeAll(items);
					
					hold.data = getHold();
					stock.data = getStock();
					hold.contentChange();
					stock.contentChange();
					
					updateStocks();
				});
			}
		}
		
		public function unloadHold(items:Object):void {
			if (Numbers.countProps(items) > 0) {
				block = true;
				
				Post.send( {
					ctr:		'user',
					act:		'unload',
					uID:		App.user.id,
					wID:		App.map.id,
					items:		JSON.stringify(items)
				}, function (error:int, data:Object, params:Object):void {
					block = false;
					
					if (error) return;
					
					for (var s:* in items) {
						App.user.ministock.items[s] -= items[s];
						if (App.user.ministock.items[s] == 0) {
							delete App.user.ministock.items[s];
						}
					}
					App.user.stock.addAll(items);
					
					hold.data = getHold();
					stock.data = getStock();
					hold.contentChange();
					stock.contentChange();
					
					updateStocks();
				});
			}
		}
		
		public function exchange(type:*, sid:int, count:int):void {
			new ShipTransferWindow( {
				callback:		onExchange,
				parent:			this,
				type:			type,
				sID:			sid,
				count:			count,
				popup:			true,
				max:			getMax()
			}).show();
			
			function getMax():int {
				if (type == ShipTransferWindow.FROM_STOCK) {
					return limitMinistock - countMinistock;
				}else{
					return countMinistock;
				}
				
				return 0;
			}
		}
		
		public function onExchange(type:*, sid:int, count:int):void {
			var items:Object = { };
			items[sid] = count;
			
			switch(type) {
				case ShipTransferWindow.FROM_STOCK:
					loadHold(items);
					break;
				case ShipTransferWindow.TO_STOCK:
					unloadHold(items);
					break;
			}
		}
		
		public function updateStocks():void {
			if (countMinistock > 0) {
				holdDescLabel.visible = false;
			}else {
				holdDescLabel.visible = true;
			}
			
			hold.countLabel.text = Locale.__e('flash:1499675729573') +' ' + String(countMinistock) + '/' + String(limitMinistock);
			
			if (App.data.storage[App.user.worldID].size == World.MINI) {
				stock.countLabel.text = '';//String(Stock._value);
			}else{
				stock.countLabel.text = '';// String(Stock._value) + '/' + String(Stock.limit);
			}
			
			if (upgradeBttn) {
				if (App.data.storage[Port.shipID].devel.req.hasOwnProperty(App.user.ministock.level+1)) {
					upgradeBttn.settings.tips = makeTips();
					//hold.paginator.y = 575; // убрать, когда кнопку "Улучшить" сделают видимой, в каком-нибудь из апдейтов
				}else {
					upgradeBttn.visible = false;
					//upArrowIcon.visible = false;
					hold.paginator.y = 563;
				}
			}
		}
		
		public static function get limitMinistock():int {
			var value:int = 0;
			for (var lvl:* in App.data.storage[Port.shipID].devel.req) {
				if (int(lvl) <= App.user.ministock.level) 
					value += App.data.storage[Port.shipID].devel.req[lvl].c;
			}
			return value;
		}
		
		public static function get countMinistock():int {
			var value:int = 0;
			for (var s:* in App.user.ministock.items) {
				value += App.user.ministock.items[s];
			}
			return value;
		}
		
		private function mainStockFull():Boolean {
			if (countMinistock > Stock.limit - Stock._value) {
				new SimpleWindow( {
					title:		Locale.__e('flash:1382952379767'),
					text:		Locale.__e('flash:1419259351177'),
					popup:		true,
					dialog:		true,
					confirmText:Locale.__e('flash:1419257349967'),
					confirm:	function():void {
						moveAll();
					}
				}).show();
				return true;
			}
			
			return false;
		}
		
		private function makeTips():Object
		{
			if (App.user.ministock.level != App.self.getLength(App.data.storage[Port.shipID].devel.req))
			{
				return { title:App.data.storage[Port.shipID].title, text:Locale.__e('flash:1418228835967', [App.data.storage[Port.shipID].devel.req[App.user.ministock.level + 1].c]) };
			} else {
				return { title:App.data.storage[Port.shipID].title, text:Locale.__e('flash:1418228835967', [App.data.storage[Port.shipID].devel.req[App.user.ministock.level].c]) };
			}
		}
		
		override public function dispose():void 
		{
			hold = null;
			stock = null;
			if (upgradeBttn) 
				upgradeBttn.removeEventListener(MouseEvent.CLICK, upgradeAction);
			super.dispose();
		}
	}
}


import com.greensock.TweenMax;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.text.TextField;
import silin.filters.ColorAdjust;
import wins.elements.ShipWindowSearchPanel;
import wins.ShipWindow;
import wins.Window;
import wins.Paginator;
import wins.WindowEvent;
import wins.SimpleWindow;
import wins.elements.ShipWindowSearchPanel;

internal class StockList extends Sprite {
	
	public var titleLabel:TextField;
	public var background:Bitmap;
	public var paginator:Paginator;
	public var container:Sprite;
	
	public var data:Array;
	public var items:Vector.<MaterialItem> = new Vector.<MaterialItem>;
	public var window:ShipWindow;
	public var type:*;
	public var countLabel:TextField;
	public var separator:Bitmap;
	public var item:MaterialItem
	public var params:Object = { };
	public var sections:Object = { };
	public var settings:Object = { };
	public var history:Object = { section:"all", page:0 };
	private var _searchPanel:ShipWindowSearchPanel;
	
	public function StockList(params:Object):void {
		sections = {
			"all":{'items':new Array(), page:0}
		}
		settings['section'] = "all";
		
		for (var s:* in params)
			this.params[s] = params[s];
		
		window = params.window as ShipWindow;
		data = params.content || [];
		type = params.type;
	/*	
		background = Window.backing(400, 630, 50, params.backing);
		addChild(background);
		*/
		
		background = Window.backing(345, 535, 30, params.prebacking);
		background.x = 0;
		background.y = 0;
		addChild(background);

		titleLabel = Window.drawText(params['title'], {
			fontSize:		46,
			color:			0xfaff78,
			borderColor:	0x9f6e46,
			autoSize:		'center'
		});
		titleLabel.filters = titleLabel.filters.concat([new DropShadowFilter(4, 90, 0x8a572a, 1, 0, 0)]);
		titleLabel.x = background.x + (background.width - titleLabel.width) / 2;
		titleLabel.y = background.y - 30;
		addChild(titleLabel);
		
		countLabel = Window.drawText('', {
			fontSize:		34,
			color:			0xffffff,
			borderColor:	0x6e411e,
			textAlign:		'center',
			width:			200
		});
		//countLabel.filters = countLabel.filters.concat([new DropShadowFilter(4, 90, 0x8a572a, 1, 0, 0)]);
		countLabel.x = 0;
		countLabel.y = 60;
		addChild(countLabel);
		
		container = new Sprite();
		
		addChild(container);
		drawPaginator();
		contentChange();
		findTargetPage(params);

		_searchPanel = new ShipWindowSearchPanel( {
				win			:this, 
				callback	:showFinded,
				stop		:onStopFinding,
				hasIcon		:false,
				caption		:Locale.__e('flash:1382952380300')
			});
		_searchPanel.x = (background.width - _searchPanel.width) / 2 - 22;
		_searchPanel.y = background.y + 15;
		this.addChild(_searchPanel);
	}
	
	
	private function findTargetPage(settings:Object):void {
		paginator.onPageCount = params.itemsCount
		for (var section:* in sections) {
			for (var i:* in sections[section].items) {
				
				var sid:int = sections[section].items[i].sid;
				if (settings.find != null && settings.find.indexOf(sid) != -1) {
					
					history.section = section;
					history.page = int(int(i) / paginator.onPageCount);
					
					settings.section = history.section;
				//	settings.page =
					paginator.page =  history.page;
					contentChange();
					return;
				}
			}
		}
		if (settings.hasOwnProperty('find')&&settings.find !=null) 
		{
		//	setTimeout(function():void {
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1425555522565', [App.data.storage[settings.find[0]].title]),
				title:Locale.__e('flash:1382952379725'),
				popup:true,
				buttonText:Locale.__e('flash:1382952380298')
			}).show();
		}
		
	}
		
	private function onStopFinding():void {
		data = params.content || [];
		contentChange();
	}
	
	private function showFinded(contents:Array):void {
		data = contents;
		//data.length = contents.length;
		paginator.itemsCount = contents.length;
		paginator.update();
		contentChange();
	}
	

	public function contentChange(e:WindowEvent = null):void {
		clear();
		paginator.onPageCount = params.itemsCount
		/*if (data.length < params.itemsCount)
			params.itemsCount = data.length*/
		paginator.itemsCount = data.length;
		paginator.update();
		var X:int = 0;
		var Y:int = 0;
		for (var i:int = 0; i < params.itemsCount; i++) {
			var index:int = i + paginator.page * paginator.onPageCount;
			
			if (data.length <= index) continue;
			item = new MaterialItem( {
				sid:		data[index].sid,
				count:		data[index].count,
				window:this
			});
			trace(index);
			container.addChild(item);
			item.x = X;
			item.y = Y;
			/*item.x = (i % 2) * (item.background.width + 14);
			item.y = Math.floor(i / 2) * (item.background.height + 14);*/
			if ((i+1) % 3 == 0){
				Y += item.background.height + 5;
				X = 0;
			}
			else{
				X += item.background.width + 5;
			}
			items.push(item);
			item.addEventListener(Event.CHANGE, onMaterialItemChange);
		}
		/*for ( i = 0; i < paginator.pages * paginator.onPageCount; i++) {
			 index = i + paginator.page * paginator.onPageCount;
			if (data.length <= index) continue;
			item = new MaterialItem( {
				sid:		data[index].sid,
				count:		data[index].count,
				window:this
			});
			sections['all'].items.push(item);
		}*/
		container.x = 15;
		container.y = params.contY;
	}
	
	public function onMaterialItemChange(e:Event = null):void {
		if (window.block) return;
		
		var item:MaterialItem = e.currentTarget as MaterialItem;
		window.exchange(type, item.sid, item.count);
	}
	
	public function onMaterialItem(e:Event = null):void {
		if (window.block) return;
		
		var item:* = e.target.parent.item;
		window.exchange(type, item.sid, App.user.stock.count(item.sid));
	}
	
	private function clear():void {
		while (items.length > 0) {
			var item:MaterialItem = items.shift();
			item.removeEventListener(Event.CHANGE, onMaterialItemChange);
			item.dispose();
		}
		//sections['all'].items = [];
	}
	
	private function drawPaginator():void {
		
		paginator = new Paginator(data.length, 6, 3, params);
		
		paginator.x = (background.width - paginator.width) / 2;
		
		paginator.y = background.height - 35; //55
		paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, contentChange);
		paginator.update();
		addChild(paginator);
		
		paginator.drawArrow(this, Paginator.LEFT,  0, 0, { scaleX: -0.55, scaleY:0.55 } );
		paginator.drawArrow(this, Paginator.RIGHT, 0, 0, { scaleX:0.55, scaleY:0.55 } );
		
		paginator.arrowLeft.x = 80; //20
		paginator.arrowLeft.y = background.height - paginator.arrowRight.height - 13; // 26
		
		paginator.arrowRight.x = background.width - paginator.arrowRight.width - 25; // 8
		paginator.arrowRight.y = background.height - paginator.arrowRight.height - 13; // 26
		
		paginator.pointsLeft.x += 3;
		paginator.pointsRight.x -= 7;
		
		
	}
	
	public function dispose():void {
		clear();
		paginator.removeEventListener(WindowEvent.ON_PAGE_CHANGE, contentChange);
		paginator.dispose();
	}
}


internal class MaterialItem extends LayerX {
	
	public static var checked:MaterialItem;
	
	public var sid:int;
	public var count:int = 0;
	public var info:Object;
	public var title:String;
	public var order:int;
	
	public var background:Bitmap;
	public var layer:LayerX;
	public var bitmap:Bitmap;
	public var countLabel:TextField;
	private var preloader:Preloader;
	
	public function MaterialItem(params:Object):void {
		
		background = Window.backing(100, 100, 50, 'itemBacking');
		background.smoothing = true;
		addChild(background);
		
		sid = params['sid'];
		count = params['count'];
		if (!App.data.storage.hasOwnProperty(sid)) return;
		info = App.data.storage[sid];
		title = info.title;
		order = info.order;
		layer = new LayerX();
		addChild(layer);
		layer.tip = function():Object {
			return {
				title:	info.title,
				text:	info.description
			}
		}
		
		bitmap = new Bitmap();
		layer.addChild(bitmap);
		
		Load.loading(Config.getIcon(info.type, info.preview), onLoad);
		if (!bitmap.bitmapData) {
			preloader = new Preloader();
			preloader.x = background.width / 2;
			preloader.y = background.height / 2;
			addChild(preloader);
		}
		
		countLabel = Window.drawText(String(count), {
			fontSize:		24,
			color:			0xf8ffff,
			borderColor:	0x88542d,
			textAlign:		'right',
			width:			95
		});
		countLabel.x = 0;
		countLabel.y = background.height - countLabel.height - 6;
		addChild(countLabel);
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
		
		if (params.window.params.find != null && params.window.params.find.indexOf(int(sid)) != -1) {
			glowing();  
		}
			
	}
	
	private function glowing():void {
		customGlowing(background, glowing);
	}
	
	
	private function customGlowing(target:*, callback:Function = null,colorGlow:uint = 0xFFFF00):void {
		TweenMax.to(target, 1, { glowFilter: { color:colorGlow, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:colorGlow, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null) {
					callback();
				}
			}});	
		}});
	}	
	
	public function onLoad(data:Bitmap):void {
		if (preloader) {
			removeChild(preloader);
			preloader = null;
		}
		
		bitmap.bitmapData = data.bitmapData;
		Size.size(bitmap, 76, 76);
		bitmap.smoothing = true;
		bitmap.x = background.x + (background.width - bitmap.width) / 2;
		bitmap.y = background.y + (background.height - bitmap.height) / 2;
		
	}
	
	private function onClick(e:MouseEvent):void {
		if (checked != this) {
			if (MaterialItem.checked) MaterialItem.checked.uncheck();
			MaterialItem.checked = this;
		}
		
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	private function onOver(e:MouseEvent):void {
		effect(0.1);
	}

	private function onOut(e:MouseEvent):void {
		effect(0);
	}
	public function effect(count:Number = 0, saturation:Number = 1):void {
		var mtrx:ColorAdjust;
		mtrx = new ColorAdjust();
		mtrx.saturation(saturation);
		mtrx.brightness(count);
		this.filters = [mtrx.filter];
		if (count == 0)
			this.filters = [];
	}
	
	public function uncheck():void {
		background.filters = null;
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		if (parent) parent.removeChild(this);
	}
	
}