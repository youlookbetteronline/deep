package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class ZoneTimeWindow extends Window 
	{
		private var _description:TextField;
		private var _boostBttn:Button;
		private var _okBttn:Button;
		private var _openBttn:Button;
		private var _progressBacking:Bitmap;
		private var _progressBar:ProgressBar;
		private var _leftTime:int;
		
		private var _zID:int;
		
		private var _components:Array = new Array();
		
		public function ZoneTimeWindow(settings:Object=null) 
		{
			settings = settingsInit(settings);
			super(settings);
			this._zID = settings.zID;
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			settings["width"]				= 380;
			settings["height"] 				= 275;
			settings['fontColor'] 			= 0x6e411e;
			settings['fontBorderColor'] 	= 0xfdf3cb;
			settings['fontBorderSize'] 		= 4;
			settings['fontSize'] 			= 46;
			settings['exitTexture'] 		= 'yellowClose';
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings["title"]				= Locale.__e('flash:1521450870908');
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = Window.backing4(settings.width, settings.height, 0, "backingYellowTL", "backingYellowTR", "backingYellowBL", "backingYellowBR");
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			drawDescription();
			drawProgress();
			drawButtons();
			build();
		}
		
		private function drawDescription():void 
		{
			var text:String = Locale.__e('flash:1521449809069');
			if (App.user.world.currentOpenZones[_zID] - App.time <= 0)
				text = Locale.__e('flash:1521459876206');
			_description = Window.drawText(text, {
				color			:0xffffff,
				borderColor		:0x6e411e,
				borderSize		:3,
				fontSize		:30,
				width			:settings.width - 30 ,
				textAlign		:'center',
				multiline		:true,
				wrap			:true
			});
			
			_components.push(_description);
			_description.x = (settings.width - _description.width) / 2;
			_description.y = 50;
			bodyContainer.addChild(_description);
		}
		
		private function drawProgress():void 
		{
			_progressBacking = Window.backingShort(254, "newBrownBacking");
				
			var barSettings:Object = {
				typeLine		:'newBlueSlider',
				width			:252,
				win				:this.parent
			};
			
			_progressBar = new ProgressBar(barSettings);
			_progressBar.start();
			_leftTime = App.user.world.currentOpenZones[_zID] - App.time;
			if (_leftTime < 0)
				_leftTime = 0;
			_progressBar.progress 	= 1 - _leftTime/App.data.storage[_zID].openingtime.time;
			_progressBar.time		= _leftTime;
			App.self.setOnTimer(progress);
			
		}
		
		private function progress():void 
		{
			_leftTime 				= App.user.world.currentOpenZones[_zID] - App.time;
			if (_leftTime <= 0)
			{
				_progressBar.progress 	= 1
				_leftTime 				= 0;
				_progressBar.time		= _leftTime;
				App.self.setOffTimer(progress);
				redrawBody();
			}
			_progressBar.progress 	= 1 - _leftTime/App.data.storage[_zID].openingtime.time;
			_progressBar.time		= _leftTime;
		}
		
		private function drawButtons():void 
		{
			if (_leftTime > 0)
			{
				var price:Object = {
					count:	Math.ceil(_leftTime/App.data.storage[_zID].openingtime.boostoption.bi) * App.data.storage[_zID].openingtime.boostoption.bc,
					mID:	App.data.storage[_zID].openingtime.boostoption.bm
				}
			
				_boostBttn = new MoneyButton({
					caption			: Locale.__e('flash:1382952380104') + '\n',
					width			:155,
					height			:55,
					fontSize		:26,
					fontCountSize	:26,
					countText		:price.count,
					boostsec		:1,
					mID				:price.mID, 
					multiline		:false,
					wrap			:false,
					notChangePos	:true,
					radius			:30,
					iconDY			:2,
					bevelColor		:[0xcce8fa, 0x3b62c2],
					bgColor			:[0x65b7ef, 0x567ed0]
				})
				
				_okBttn = new Button({
					caption			:Locale.__e('flash:1382952380242'),
					fontColor		:0xffffff,
					width			:155,
					height			:55,
					fontSize		:32,
					radius			:30,
					bgColor			:[0xfed131, 0xf8ab1a],
					bevelColor		:[0xf7fe9a, 0xcb6b1e],
					fontBorderColor	:0x6e411e
				})
				
				_boostBttn.addEventListener(MouseEvent.CLICK, onBoostEvent);
				_okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
				
				_boostBttn.x = settings.width / 2 - _boostBttn.width - 10;
				_boostBttn.y = settings.height - 110;
				
				_okBttn.x = settings.width / 2 + 10;
				_okBttn.y = settings.height - 110;
				
				bodyContainer.addChild(_boostBttn);
				bodyContainer.addChild(_okBttn);
				
				_components.push(_boostBttn);
				_components.push(_okBttn);
				
				if (App.user.stock.count(price.mID) < price.count)
					_boostBttn.state = Button.DISABLED;
			}
			
			else
			{
				_openBttn = new Button({
					caption			:Locale.__e('flash:1382952379890'),
					fontColor		:0xffffff,
					width			:155,
					height			:55,
					fontSize		:32,
					radius			:30,
					bgColor			:[0xfed131, 0xf8ab1a],
					bevelColor		:[0xf7fe9a, 0xcb6b1e],
					fontBorderColor	:0x6e411e
				})
				
				_openBttn.x = (settings.width - _openBttn.width) / 2;
				_openBttn.y = settings.height - 110;
				bodyContainer.addChild(_openBttn);
				_components.push(_openBttn);
				_openBttn.addEventListener(MouseEvent.CLICK, onOpenEvent);
			}
			
			
		}
		
		private function redrawBody():void 
		{
			disposeChilds(_components);
			drawDescription();
			drawButtons();
		}
		
		private function onBoostEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			e.currentTarget.state = Button.DISABLED;
			_leftTime = 0;
			App.user.world.boostZone(_zID, redrawBody);
		}
		
		private function onOpenEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			e.currentTarget.state = Button.DISABLED;
			close();
			App.user.world.currentOpen(_zID);
		}
		
		private function onOkBttn(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			e.currentTarget.state = Button.DISABLED;
			close();
		}
		
		private function build():void 
		{
			exit.x -= 15;
			exit.y += 15;
			titleLabel.y += 40;
			
			_progressBacking.x = (settings.width - _progressBacking.width) / 2;
			_progressBacking.y = _description.y + _description.height + 5;
			_progressBar.x = _progressBacking.x - 17;
			_progressBar.y = _progressBacking.y - 13;
			
			bodyContainer.addChild(_progressBacking);
			bodyContainer.addChild(_progressBar);
			
		}
		
	}

}