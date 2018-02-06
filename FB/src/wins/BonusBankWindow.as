package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class BonusBankWindow extends Window 
	{
		
		private var _starBacking:Bitmap;
		private var _starItem:Bitmap;
		private var _sID:int = App.data.options.bonusBankItem;
		private var _description:TextField;
		private var _back:Shape;
		private var _coinBttn:Button;
		private var _fantBttn:Button;
		private var _settings:Object;
		public function BonusBankWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = {};
			}

			settings["width"]				= 500;
			settings["height"] 				= 305;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= true;
			settings["hasArrows"]			= false;
			settings['exitTexture'] 		= 'closeBttnMetal';
			settings['background	'] 		= 'capsuleWindowBacking';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x116011;
			settings['borderColor'] 		= 0x116011;
			settings['shadowBorderColor']	= 0x116011;
			settings['fontSize'] 			= 50;
			settings['title'] 				= Locale.__e('flash:1382952379973');
			
			super(settings);
			_settings = settings;
		}
		
		override public function drawBody():void 
		{
			drawRibbon();
			drawBack();
			drawImages();
			drawDescription();
			drawButtons();
			build();
		}
		
		private function drawBack():void 
		{
			_back = new Shape();
			_back.graphics.beginFill(0xffffff, .7);
			_back.graphics.drawRect(0, 0, settings.width - 130, 170)
			_back.graphics.endFill()
			_back.filters = [new BlurFilter(30, 0, 5)];
		}
		
		private function drawImages():void 
		{
			_starBacking = new Bitmap(Window.textures.starBacking);
			_starBacking.filters = [new DropShadowFilter(5, 90, 0x000000, .1, 2, 4, 4, 2)];
			Load.loading(Config.getIcon(App.data.storage[_sID].type, App.data.storage[_sID].view), function(data:Bitmap):void{
				_starItem = new Bitmap();
				_starItem.bitmapData = data.bitmapData;
				_starItem.filters = [new DropShadowFilter(3, 90, 0x000000, .3, 3, 3, 1, 1)];
				Size.size(_starItem, 75, 75)
				_starItem.smoothing = true;
				_starItem.x = _starBacking.x + (_starBacking.width - _starItem.width) / 2;
				_starItem.y = _starBacking.y + (_starBacking.height - _starItem.height) / 2;
				bodyContainer.addChild(_starItem);
			});
		}
		
		private function drawDescription():void 
		{
			_description = Window.drawText(_settings.description,{
				fontSize		:26,
				textAlign		:'center',
				color			:0x6e411e,
				border			:false,
				borderSize		:2,
				width			:200,
				multiline		:true,
				wrap			:true
			});
		}
		
		private function drawButtons():void 
		{
			_fantBttn = new Button({
				caption			:App.data.storage[Stock.FANT].title,
				fontColor		:0xffffff,
				width			:153,
				height			:50,
				fontSize		:30,
				bgColor			:[0x66b9f0, 0x567ace],
				bevelColor		:[0xa6d7f6, 0x4465b6],
				fontBorderColor	:0x2b4a84,
				mode			:BanksWindow.REALS
			});
			
			_coinBttn = new Button({
				caption			:App.data.storage[Stock.COINS].title,
				fontColor		:0xffffff,
				width			:153,
				height			:50,
				fontSize		:30,
				bgColor			:[0xfed131, 0xf8ab1a],
				bevelColor		:[0xfaed73, 0xcb6b1e],
				fontBorderColor	:0x6e411e,
				mode			:BanksWindow.COINS
			});
			
			_fantBttn.addEventListener(MouseEvent.CLICK, onBttnClick);
			_coinBttn.addEventListener(MouseEvent.CLICK, onBttnClick);
		}
		
		private function onBttnClick(e:MouseEvent):void 
		{
			
			Window.closeAll();
			new BanksWindow( { section:e.currentTarget.settings.mode } ).show();
		}
		
		private function build():void
		{
			exit.y -= 20;
			titleLabel.y += 14;
			titleBackingBmap.y += 5;
			
			_back.x = (settings.width - _back.width) / 2;
			_back.y = (settings.height - _back.height) / 2 - 33;
			
			_starBacking.y = 50;
			_starBacking.x = 55;
			
			_description.y = _starBacking.y + (_starBacking.height - _description.height) / 2;
			_description.x = _starBacking.x + _starBacking.width + 25;
			
			_fantBttn.x = settings.width / 2 - _fantBttn.width - 5;
			_fantBttn.y = settings.height - _fantBttn.height - 33;
			
			_coinBttn.x = settings.width / 2 + 5;
			_coinBttn.y = settings.height - _coinBttn.height - 33;
			
			bodyContainer.addChild(_back);
			bodyContainer.addChild(_starBacking);
			bodyContainer.addChild(_description);
			bodyContainer.addChild(_fantBttn);
			bodyContainer.addChild(_coinBttn);

			
			if (_starItem)
			{
				_starItem.x = _starBacking.x + (_starBacking.width - _starItem.width) / 2;
				_starItem.y = _starBacking.y + (_starBacking.height - _starItem.height) / 2;
				bodyContainer.addChild(_starItem);
			}
			
			
			
			
		}
		
	}

}