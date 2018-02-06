package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MixedButton2;
	import buttons.UpgradeButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import units.Animal;
	import units.Tribute;
	public class TributeWindow extends Window
	{
		
		public var item:Object;
		
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		
		private var progressBar:ProgressBar;
		private var buyBttn:MixedButton2;
		
		private var leftTime:int;
		private var started:int;
		private var totalTime:int;
		
		public var leftLabel:TextField;
		
		protected var upgradeBttn:UpgradeButton;
		protected var neddLvlBttn:MixedButton2 = null;
		
		private var _startTime:int = 0; // test
		private var _itemsCreated:int = 0;//test
		
		private var _firstUpd:Boolean = true;
		
		private var _boostPrice:int;
		
		//private var _capacity:int;
		
		private var _boostLabel:TextField
		private var _timer:Bitmap;
		
		public var _itemsPerTime:int;
		public var _isBoost:Boolean;
		
		private var _itemsKoef:int;
	
		public function TributeWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 366;
			settings["height"] = 402;
			settings["popup"] = true;
			settings["fontSize"] = 36;
			settings["fontBorderSize"] = 1;
			settings["fontBorderGlow"] = 1;
			settings["callback"] = settings["callback"] || null;
			settings["hasPaginator"] = false;
			
			settings['notChecks'] = settings.notChecks || false;
			
			started = settings.started;
			totalTime = settings.time;
			capasity = settings.capasity;
			_isBoost = settings.boost;
			
			_itemsKoef = settings.info.count
			_itemsPerTime = settings.itemsPerTime;
			//_itemsCreated = Math.floor((App.time - started) / totalTime) * _itemsPerTime;
			
			leftTime = settings.leftTime;
			_itemsCreated = settings.created;
			
			super(settings);
			
			//acsLayerX.tip = function():Object {
				//return {
					//title: 'Увеличение добычи',
					//text: 'Вы можете увеличить добываемый эфир в два раза'
				//};
			//}
		}
		
		public function progress():void
		{
			if (_firstUpd) {
				_firstUpd = false;
				updateItemInfo();
			}
		
			leftTime--;// = totalTime - (App.time - started - _itemsCreated / _itemsPerTime * totalTime);
			
			if (leftTime <= 0) {
				_itemsCreated += _itemsPerTime;
				leftTime = totalTime;
			}
		
			progressBar.time = leftTime;
			progressBar.progress =  (totalTime - (leftTime)) / totalTime;
			
			if (_itemsCreated >= capasity) {
				progressBar.progress = 1;
				_itemsCreated = capasity;
				App.self.setOffTimer(progress);
				App.tips.hide();
				buyBttn.tip = null;
				
			}
			
			checkBoost();
			updateItemInfo();
		}
		
		public function checkBoost():void
		{
			if (_isBoost && !settings.target.checkBoost()) {
				boostDescription = false;
				_itemsPerTime /= _itemsKoef;
			}
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 40, "questBacking");
			layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		
		private var preloader:Preloader = new Preloader();
		override public function drawBody():void {
			
			titleLabel.y -= 6;
			drawMirrowObjs('diamondsTop', titleLabel.x/* + 120*/,titleLabel.x + titleLabel.width/* - 120*/, -45, true, true);
			
			background = Window.backing(296, 260, 10, "dialogueBacking");
			bodyContainer.addChild(background);
			background.x = (settings.width - background.width)/2;
			background.y = 2;
			
			var lvlLbg:Bitmap = Window.backingShort(210, "yellowRibbon");
			bodyContainer.addChild(lvlLbg);
			lvlLbg.x = background.x + (background.width - lvlLbg.width)/2;
			lvlLbg.y = -12;
			
			var lvlTxt:String = Locale.__e("flash:1396608622333", [settings.target.level - (settings.target.totalLevels - settings.target.craftLevels)]);
			if (settings.target.level < settings.target.totalLevels - settings.target.craftLevels)
				lvlTxt = Locale.__e("flash:1404217046736", [settings.target.level]);
			
			var lvlLabel:TextField = Window.drawText(lvlTxt,{
					fontSize:24,
					autoSize:"left",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0x814f31	
				});
			bodyContainer.addChild(lvlLabel);
			lvlLabel.x = lvlLbg.x + (lvlLbg.width - lvlLabel.textWidth) / 2;
			lvlLabel.y = -4;
			
			bitmap = new Bitmap();
			
			
				bitmap.bitmapData = settings.target.bitmap.bitmapData;//data.bitmapData;
				bitmap.smoothing = true;	
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = 130 - bitmap.height / 2;
			
			bodyContainer.addChild(bitmap);
			
			
			var progressBacking:Bitmap = Window.backingShort(310, "prograssBarBacking3");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = 283;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar( { win:this, width:315, typeLine:'yellowProgBarPiece' } );
			progressBar.x = (settings.width - 300) / 2 - 7;
			progressBar.y = 282;
			progressBar.bar.visible = true
			
			bodyContainer.addChild(progressBar);
			
			drawDescription();
			
			progressBar.visible = true;
					
			drowBttns();
			
			progress();
			
			boostDesc();
			
			if (!settings.full) {
				App.self.setOnTimer(progress);
				progressBar.start();
			}else {
				_itemsCreated = capasity;
				updateItemInfo();
			}
		}
		
		private var acsLayerX:LayerX = new LayerX();
		public function drowBttns():void
		{
			var timer:Bitmap = new Bitmap(Window.textures.timerDark, "auto", true);
			
			buyBttn = new MixedButton2(timer, {
				title		:'x2',
				width		:100,
				height		:55,	
				fontSize	:34,
				radius		:30,
				countText	:settings.target.info.skip,
				multiline	:true,
				bgColor:[0xf5d058, 0xeeb331],
				bevelColor:[0xfeee7b, 0xbf7e1a],
				fontBorderColor:0x814f31,
				iconScale:0.8,
				isIconFilter:true,
				iconFilter:0x814f31,
				notCheck:true
			});
			
			buyBttn.tip = function():Object {
				return {
					title: Locale.__e('flash:1393584620277'),
					text: Locale.__e('flash:1393584640717')
				};
			}
		
			buyBttn.x = settings.width - buyBttn.width - 26;
			buyBttn.y = settings.height - buyBttn.height;
			
			buyBttn.coinsIcon.x += 28;
			buyBttn.coinsIcon.y -= 2;
			buyBttn.textLabel.x += 42;
			buyBttn.textLabel.y += 2;
			
			
			buyBttn.addEventListener(MouseEvent.CLICK, onBoostEvent);
			
			if (_isBoost) buyBttn.state = Button.DISABLED;
			
			if (settings.target.level >= settings.target.totalLevels) {
				buyBttn.x = (settings.width - buyBttn.width) / 2;
			}else {
				drawUpgradeBttn();
			}/*else if(settings.target.info.devel.req[settings.target.level + 1].l <= App.user.level)
				drawUpgradeBttn();
			else 
				drawNeedLvlBttn();*/
			
				
			bodyContainer.addChild(buyBttn);
			
			
			//if (settings.target.level >= settings.target.totalLevels) upgradeBttn.visible = false;
		}
		
		private function drawNeedLvlBttn():void 
		{
			var icon:Bitmap = new Bitmap(Window.textures.star, "auto", true);
			
			neddLvlBttn = new MixedButton2(icon,{
				title: Locale.__e("flash:1393579961766"),
				width:196,
				height:55,
				countText:settings.target.info.devel.req[settings.target.level + 1].l,
				hasText2:true,
				fontSize:20,
				iconScale:0.95,
				radius:20,
				bgColor:[0xe4e4e4, 0x9f9f9f],
				bevelColor:[0xfdfdfd, 0x777777],
				fontColor:0xffffff,
				fontBorderColor:0x575757,
				fontCountColor:0xffffff,
				fontCountBorder:0x575757
				
			})
			
			bodyContainer.addChild(neddLvlBttn);
			neddLvlBttn.x = 31;
			neddLvlBttn.y = settings.height - neddLvlBttn.height;
			
			neddLvlBttn.textLabel.x += 16;
			
			neddLvlBttn.coinsIcon.x += 164;
			neddLvlBttn.coinsIcon.y -= 4;
			neddLvlBttn.countLabel.x += 218; neddLvlBttn.countLabel.y += 8;
			neddLvlBttn.textLabel.x = 6;
		}
		
		private function drawUpgradeBttn():void 
		{
			upgradeBttn = new UpgradeButton(UpgradeButton.TYPE_ON,{
				caption: Locale.__e("flash:1396963489306"),
				width:236,
				height:55,
				icon:Window.textures.upgradeArrow,
				fontBorderColor:0x002932,
				countText:"",
				fontSize:28,
				iconScale:0.95,
				radius:30,
				textAlign:'left',
				autoSize:'left',
				widthButton:230
			});
			upgradeBttn.textLabel.x += 18;
			upgradeBttn.coinsIcon.x += 18;
			
			bodyContainer.addChild(upgradeBttn);
			upgradeBttn.x = 15;
			upgradeBttn.y = settings.height - upgradeBttn.height + 60;
			upgradeBttn.addEventListener(MouseEvent.CLICK, onUpgradeEvent);
		}
		
		private var boostCont:LayerX = new LayerX();
		private var underBoost:Bitmap;
		public function boostDesc():void 
		{
			bodyContainer.addChild(boostCont);
			
			boostCont.tip = function():Object {
				return {
					title: Locale.__e('flash:1393584528120'),
					text:Locale.__e('flash:1393584555700') + " " + TimeConverter.timeToStr(settings.target._boostStarted-App.time),
					timer:true
				};
			}
			
			underBoost = new Bitmap(textures.boost);
			boostCont.addChild(underBoost);
			//bodyContainer.addChild(underBoost);
			//underBoost.x = 5;
			//underBoost.y = -32;
			
			_timer = new Bitmap(Window.textures.timerYellow, "auto", true);
			_timer.smoothing = true;
			_timer.scaleX = _timer.scaleY = 0.8;
			boostCont.addChild(_timer);
			//bodyContainer.addChild(_timer);
			_timer.x = underBoost.x + 16;
			_timer.y = underBoost.y + 24;
			
			
			var filterIcon:GlowFilter = new GlowFilter(0x814f31, 1, 2, 2, 10, 1);
			_timer.filters = [filterIcon];	
			
			_boostLabel = Window.drawText("x2",{
					fontSize:26,
					autoSize:"left",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0x814f31,
					
					bgColor:[0xf5d058, 0xeeb331],
					bevelColor:[0xfeee7b, 0xbf7e1a],
					fontBorderColor:0x814f31,
					iconScale:1,
					isIconFilter:true,
					iconFilter:0x814f31
				});
			boostCont.addChild(_boostLabel);
			//bodyContainer.addChild(_boostLabel);
			_boostLabel.x = _timer.x + _timer.width + 1;
			_boostLabel.y = _timer.y + 2;
			
			boostCont.x = 5;
			boostCont.y = -13;
			
			if (!_isBoost) {
				//_boostLabel.visible = false;
				//_timer.visible = false;
				//underBoost.visible = false;
				boostCont.visible = false;
			}
		}
		
		private var _capasityLabel:TextField;
		private var capasity:int;
		
		public function drawDescription():void 
		{
			Load.loading(Config.getIcon(App.data.storage[settings.target.info.out].type, App.data.storage[settings.target.info.out].preview), onLoadIcon);
		}
		
		private function onLoadIcon(obj:Object):void 
		{
			var container:Sprite = new Sprite();
			
			var efirIcon:Bitmap = new Bitmap(obj.bitmapData);
			efirIcon.scaleX = efirIcon.scaleY = 0.46;
			efirIcon.smoothing = true;
			//efirIcon.y = -10;
			container.addChild(efirIcon);
			
			var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,0x453059,1,2,4,2,1);
			efirIcon.filters = [shadowFilter];	
			
			_capasityLabel = Window.drawText(Locale.__e(String(_itemsCreated) + "/" + capasity),{
					fontSize:36,
					autoSize:"left",
					textAlign:"center",
					multiline:true,
					color:0xffdb65,
					borderColor:0x775002
				});
			container.addChild(_capasityLabel);
			_capasityLabel.x = efirIcon.width + 6;
			_capasityLabel.y = 10/*-5*/;
			
			
			bodyContainer.addChild(container);
			
			container.x = (settings.width - container.width) / 2;
			container.y = settings.height - container.height - 114;
		}
		
		public function set boostDescription(value:Boolean):void
		{
			_isBoost = value;
			//_boostLabel.visible = value;
			//_timer.visible = value;
			//underBoost.visible = value;
			boostCont.visible = value;
		}
		
		private function updateItemInfo():void
		{
			if(_capasityLabel)
				_capasityLabel.text = Locale.__e(String(_itemsCreated) + "/" + capasity);
		}
		
		private function onBoostEvent(e:MouseEvent = null):void
		{
			if (!_isBoost) {
				var timeB:int = 2;
				new BoostWindow( {
					desc:Locale.__e("flash:1396596128937", [timeB]),
					title:Locale.__e("flash:1382952380104"),
					request:settings.info.boost,
					target:settings.target,
					win:this,
					onUpgrade:doBoost,
					bttnTxt:Locale.__e('flash:1393584580526') + " "
				}).show();
			}
		}
		
		private function doBoost():void
		{
			var price:Object = { }
			price[Stock.FANT] = settings.info.boost;
			if (!App.user.stock.checkAll(price))	return;
			
			settings.target.boostEvent();
			_itemsPerTime *= _itemsKoef;
			boostDescription = true;
			buyBttn.state = Button.DISABLED;
			buyBttn.tip = function():Object { 
				return {
					title:""
			}};
			buyBttn.tip = null;
		}
		
		private function onUpgradeEvent(e:MouseEvent):void 
		{
			new ConstructWindow( {
				title:settings.target.info.title,
				upgTime:settings.upgTime,
				request:settings.target.info.devel.obj[settings.target.level + 1],
				target:settings.target,
				win:this,
				onUpgrade:onUpgradeAction,
				hasDescription:true,
				notChecks:settings.notChecks
			}).show();
		}
		
		private function onUpgradeAction(val:Object, count:int = 0):void
		{
			settings.target.upgradeEvent(settings.info.devel.obj[settings.target.level + 1], count);
			close();
		}
		
		override public function dispose():void
		{
			progressBar.dispose();
			buyBttn.removeEventListener(MouseEvent.CLICK, onBoostEvent);
			App.self.setOffTimer(progress);
			super.dispose();
		}
	
	}		

}