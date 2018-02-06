package wins.elements 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import wins.Window;
	
	public class MaterialBox extends LayerX 
	{		
		private var preloader:Preloader;
		public var background:Bitmap;
		private var image:Bitmap;
		private var countLabel:TextField;
		private var currentLabel:TextField;
		private var minus10Bttn:ImageButton;
		private var minusBttn:ImageButton;
		private var plusBttn:ImageButton;
		private var plus10Bttn:ImageButton;
		private var bttnsCont:Sprite;
		private var stockCont:Sprite;
		private var sprite:LayerX;
		
		private var params:Object = {
			backing:	'textSmallBacking',
			width:		100,
			height:		100,
			min:		1,
			max:		0,
			bttnAsLine:	false,					// Кнопки счетцика расположены в линию
			light:		false					// Без счетчика и склада
		}
		
		protected var current:int = 0;
		public var sid:*;
		public var info:Object;
		
		public function MaterialBox(sid:*, params:Object = null) 
		{
			super();
			
			if (params) 
			{
				for (var value:* in params)
					this.params[value] = params[value];
			}
			
			this.sid = sid;
			this.info = Storage.info(sid);
			current = min;
			draw();
			tips();
		}
		
		// Update
		public function update():void
		{
			countLabel.text = App.user.stock.count(sid).toString();
			
			if (App.user.stock.count(sid) < current) {
				current = App.user.stock.count(sid);
				if (current <= 0) current = 1;
			}
			
			currentLabel.text = current.toString();
			
			if (App.user.stock.count(sid) == 0) {
				block = true;
			}else {
				block = false;
			}
		}
		
		private function tips():void 
		{
			tip = function():Object {
				return {
					title:		info.title,
					text:		info.description
				}
			}
		}
		
		public var circle:Shape = new Shape();
		public var currentBack:Shape = new Shape();
		private function draw():void {
			background = Window.backing(params.width, params.height, 20, params.backing);
			addChild(background);
			image = new Bitmap();
			addChild(image);
			
			//Stock count
			stockCont = new Sprite();
			stockCont.x = -10;
			stockCont.y = -6;
			addChild(stockCont);
			
			circle.graphics.lineStyle(1, 0xb88a3f);
			circle.graphics.beginFill(0xd9bf82);
			circle.graphics.drawCircle(100, 20, 16);
			stockCont.addChild(circle);
			
			countLabel = Window.drawText('0', {
				width:			circle.width,
				textAlign:		'center',
				fontSize:		25,
				color:			0xeFFFFFF,
				borderColor:	0x875435
			});
			countLabel.x = circle.x + 82;
			countLabel.y = circle.y + 7;
			stockCont.addChild(countLabel);
			
			//Current count
			bttnsCont = new Sprite();
			addChild(bttnsCont);
			
			currentBack.graphics.lineStyle(1, 0xb88a3f);
			currentBack.graphics.beginFill(0xd9bf82);
			currentBack.graphics.drawCircle(16, 17, 16);
			bttnsCont.addChild(currentBack);
			
			currentLabel = Window.drawText('0', {
				width:			currentBack.width + 10,
				textAlign:		'center',
				fontSize:		23,
				color:			0xeFFFFFF,
				borderColor:	0x875435,
				input:			true
			});
			currentLabel.maxChars = 3;
			currentLabel.restrict = '0123456789';
			currentLabel.addEventListener(TextEvent.TEXT_INPUT, onText);
			bttnsCont.addChild(currentLabel);
			
			minus10Bttn = new ImageButton(UserInterface.textures.coinsMinusBttn10);
			minus10Bttn.addEventListener(MouseEvent.CLICK, onChange);
			minusBttn = new ImageButton(UserInterface.textures.coinsMinusBttn);
			minusBttn.addEventListener(MouseEvent.CLICK, onChange);
			plusBttn = new ImageButton(UserInterface.textures.coinsPlusBttn2);
			plusBttn.addEventListener(MouseEvent.CLICK, onChange);
			plus10Bttn = new ImageButton(UserInterface.textures.coinsPlusBttn10);
			plus10Bttn.addEventListener(MouseEvent.CLICK, onChange);
			bttnsCont.addChild(minusBttn);
			bttnsCont.addChild(plusBttn);
			
			minus10Bttn.x = 0;
			minus10Bttn.y = 0;
			minusBttn.x = 0;
			minusBttn.y = 0;
			currentBack.x = minusBttn.x + minusBttn.width;
			currentBack.y = -6;
			currentLabel.x = currentBack.x + currentBack.width * 0.5 - currentLabel.width * 0.5;
			currentLabel.y = currentBack.y + currentBack.height * 0.5 - currentLabel.height * 0.5 + 3;
			plusBttn.x = currentBack.x + currentBack.width - 1;
			plusBttn.y = 0;
			plus10Bttn.x = plusBttn.x + plusBttn.width;
			plus10Bttn.y = 0;
			
			bttnsCont.x = background.x + background.width * 0.5 - bttnsCont.width * 0.5;
			bttnsCont.y = background.y + background.height - bttnsCont.height + 14;
			
			preloader = new Preloader();
			preloader.x = background.x + background.width * 0.5;
			preloader.y = background.y + background.height * 0.5;
			
			Load.loading(Config.getIcon(info.type, info.preview), function(data:Bitmap):void {
				if (preloader && preloader.parent)
					removeChild(preloader);
				
				image.bitmapData = data.bitmapData;
				image.smoothing = true;
				
				Size.size(image, background.width * 0.6, background.height * 0.6);
				
				image.x = background.x + background.width * 0.5 - image.width * 0.5;
				image.y = background.y + background.height * 0.5 - image.height * 0.5;
			});
			
			if (params.light == true) {
				stockCont.visible = false;
				bttnsCont.visible = false;
			}
			
			update();
		}
		
		private function onChange(e:MouseEvent):void {
			var bttn:ImageButton = e.currentTarget as ImageButton;
			if (bttn.mode == Button.DISABLED) return;
			
			switch(bttn) {
				case plus10Bttn: change(10); break;
				case plusBttn: change(1); break;
				case minusBttn: change(-1); break;
				case minus10Bttn: change(-10); break;
			}
		}
		public function change(value:int):void {
			var onStock:int = App.user.stock.count(sid);
			
			if (onStock < min) {
				block = true;
			}else {
				block = false;
				
				if (current + value > onStock) {
					current = onStock;
				}else if (current + value < min) {
					current = min;
				}else {
					current += value;
				}
				
				currentLabel.text = current.toString();
			}
		}
		
		private function onText(e:TextEvent):void {
			
			e.preventDefault();
			
			if (currentLabel.selectionBeginIndex < currentLabel.selectionEndIndex) {
				currentLabel.text = '';
			}
			
			var result:String = currentLabel.text + e.text;
			var value:int = int(result);
			
			if (isNaN(value)) return;
			
			if (value < min) {
				if (all == 0) {
					value = 0;
				}else{
					value = min;
				}
			}else if (value > all) {
				value = all;
			}
			
			currentLabel.text = value.toString();
			current = value;
			update();
			
			currentLabel.setSelection(currentLabel.length, currentLabel.length);
		}
		
		private var __block:Boolean = false;
		public function get block():Boolean {
			return __block;
		}
		public function set block(value:Boolean):void {
			if (value) {
				plus10Bttn.state = Button.DISABLED;
				minusBttn.state = Button.DISABLED;
				plusBttn.state = Button.DISABLED;
				plus10Bttn.state = Button.DISABLED;
			}else {
				plus10Bttn.state = Button.NORMAL;
				minusBttn.state = Button.NORMAL;
				plusBttn.state = Button.NORMAL;
				plus10Bttn.state = Button.NORMAL;
			}
		}
		public function get min():int {
			if (params.min < 1)
				return 1;
			
			return params.min;
		}
		public function get max():int {
			if (params.max < min)
				return min;
			
			return params.max;
		}
		public function set min(value:int):void {
			params.min = value;
			update();
		}
		public function set max(value:int):void {
			params.min = value;
			update();
		}
		
		public function get count():int {
			return current;
		}
		
		public function get all():int {
			return App.user.stock.count(sid);
		}
		
		public function dispose():void {
			currentLabel.removeEventListener(TextEvent.TEXT_INPUT, onText);
			
			minus10Bttn.dispose();
			minusBttn.dispose();
			plus10Bttn.dispose();
			plusBttn.dispose();
		}		
	}
}