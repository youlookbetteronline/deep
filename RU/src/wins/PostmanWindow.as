package wins 
{
	import api.com.odnoklassniki.sdk.share.Share;
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import models.PostmanModel;
	import flash.filters.DropShadowFilter;
	import units.Postman;
	/**
	 * ...
	 * @author ...
	 */
	public class PostmanWindow extends Window 
	{
		private var _target:Postman;
		private var _model:PostmanModel;
		private var _imageBack:Bitmap;
		private var _image:Bitmap;
		private var _description:TextField;
		private var _sendBttn:Button;
		private var _takeBttn:Button;
		public function PostmanWindow(settings:Object=null) 
		{
			_model = settings.model;
			_target = settings.target;
			
			settings = settingsInit(settings);
			super(settings);
			
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			
			drawDescription();
			settings["width"]				= 495;
			settings["height"] 				= 415 + _description.height;
			settings['fontColor'] 			= 0x004762;
			settings['fontBorderColor'] 	= 0xffffff;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 40;
			settings['exitTexture'] 		= 'blueClose';
			settings['title'] 				= _target.info.title;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing4(settings.width, settings.height, 160, 'blueBackingTL', 'blueBackingTR', 'blueBackingBL', 'blueBackingBR');
			layer.addChild(background);	
		}
		
		override public function drawBody():void 
		{
			drawImage();
			drawButtons();
			build();
		}
		
		private function drawImage():void 
		{
			_imageBack = backing(440, 245, 46, 'blueLightBacking');
			_imageBack.x = (settings.width - _imageBack.width) / 2;
			_imageBack.y = 50;
			bodyContainer.addChild(_imageBack);
			Load.loading(Config.getImage(_target.info.type, String(_target.sid), 'jpg'), onLoadImage)
		}
		
		private function onLoadImage(data:Bitmap):void 
		{
			_image = new Bitmap(data.bitmapData);
			Size.size(_image, 440, 240);
			_image.smoothing = true;
			_image.x = _imageBack.x + (_imageBack.width - _image.width) / 2;
			_image.y = _imageBack.y + (_imageBack.height - _image.height) / 2;
			bodyContainer.addChild(_image);
			
			var maska:Shape = new Shape();
			maska.graphics.beginFill(0xffffff, 1)
			maska.graphics.drawRoundRect(0, 0, 420, 225, 60, 60)
			maska.graphics.endFill()
			maska.x = _image.x + (_image.width - maska.width) / 2;
			maska.y = _image.y + (_image.height - maska.height) / 2;
			bodyContainer.addChild(maska);
			
			_image.mask = maska;
		}
		
		private function drawDescription():void
		{
			_description = Window.drawText(_target.info.windowtext,{
				color			:0xffffff,
				borderColor		:0x004762,
				borderSize		:4,
				fontSize		:24,
				width			:430,
				textAlign		:'center',
				wrap			:true,
				multiline		:true
			})
		}
		
		private function drawButtons():void 
		{
			_sendBttn = new Button({
				caption			:Locale.__e('flash:1382952380118'),
				fontColor		:0xffffff,
				width			:170,
				height			:51,
				fontSize		:32,
				bgColor			:[0xfed131, 0xf8ab1a],
				bevelColor		:[0xf7fe9a, 0xcb6b1e],
				fontBorderColor	:0x6e411e
			});
			_takeBttn = new Button({
				caption			:Locale.__e('flash:1382952379786'),
				fontColor		:0xffffff,
				width			:170,
				height			:51,
				fontSize		:32,
				bgColor			:[0xbcec63, 0x68bc21],
				bevelColor		:[0xe0ffad, 0x4e8b2c],
				fontBorderColor	:0x085c10
			});
			
			_takeBttn.addEventListener(MouseEvent.CLICK, onTakeEvent)
			_sendBttn.addEventListener(MouseEvent.CLICK, onSendEvent)
		}
		
		private function onTakeEvent(e:MouseEvent):void 
		{
			Window.closeAll();
			new PostmanGetWindow({
				model	:_model,
				target	:_target
			}).show();
		}
		private function onSendEvent(e:MouseEvent):void 
		{
			Window.closeAll();
			new PostmanSendWindow({
				model	:_model,
				target	:_target
			}).show();
		}
		
		private function build():void 
		{
			exit.x -= 10;
			exit.y += 15;
			
			titleLabel.y += 35;
			
			
			_description.x = (settings.width - _description.width) / 2;
			_description.y = _imageBack.y + _imageBack.height + 15;
			
			_sendBttn.x = settings.width / 2 - _sendBttn.width - 20;
			_sendBttn.y = settings.height - _sendBttn.height - 55;
			
			_takeBttn.x = settings.width / 2 + 10;
			_takeBttn.y = settings.height - _takeBttn.height - 55;
			
			bodyContainer.addChild(_description);
			bodyContainer.addChild(_sendBttn);
			bodyContainer.addChild(_takeBttn);
		}
	}

}