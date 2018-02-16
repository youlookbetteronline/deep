package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import utils.InviteHelper;
	/**
	 * ...
	 * @author ...
	 */
	public class AddFriendWindow extends Window 
	{
		private var _image:Bitmap;
		private var _description:TextField;
		private var _buyBttn:Button;
		private var _inviteBttn:Button;
		public function AddFriendWindow(settings:Object=null) 
		{
			settings["width"]				= 500;
			settings["height"] 				= 245;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= true;
			settings["hasArrows"]			= false;
			settings['exitTexture'] 		= 'closeBttnMetal';
			settings['background']	 		= 'capsuleWindowBacking';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x116011;
			settings['borderColor'] 		= 0x116011;
			settings['shadowBorderColor']	= 0x116011;
			settings['fontSize'] 			= 42;
			
			super(settings);
		}
		
		override public function drawBody():void 
		{
			var _bg:Shape = new Shape();
			_bg.graphics.beginFill(0xfeeed3);
			_bg.graphics.drawRect(0, 0, settings.width - 110, 135);
			_bg.graphics.endFill();
			_bg.x = (settings.width - _bg.width) / 2;
			_bg.y = (settings.height - _bg.height) / 2 - 35;
			_bg.filters = [new BlurFilter(10, 0, 10)];
			bodyContainer.addChild(_bg);
			loadImage();
			addImage();
			drawDescription();
			drawButtons();
			build();
			drawMirrowObjs('decSeaweed', settings.width + 57, - 57, settings.height - 172, true, true, false, 1, 1, layer);
		}
		
		private function loadImage():void 
		{
			Load.loading(Config.getIcon(App.data.storage[3420].type, App.data.storage[3420].preview), onLoad) 
		}
		
		private function onLoad(data:Bitmap):void 
		{
			_image = new Bitmap(data.bitmapData);
			Size.size(_image, 110, 110);
			_image.smoothing = true;
			addImage()
		}
		
		private function addImage():void 
		{
			if (!_image)
				return;
				
			var _bg:Shape = new Shape();
			_bg.graphics.beginFill(0xb27647, 1);
			_bg.graphics.drawRoundRect(0, 0, 112, 112, 30);
			_bg.graphics.endFill();
			_bg.x = 77;
			_bg.y = 26;
			
			_image.x = _bg.x + (_bg.width - _image.width) / 2;
			_image.y = _bg.y + (_bg.height - _image.height) / 2;
			
			var _mask:Shape = new Shape();
			_mask.graphics.beginFill(0xb27647, 1);
			_mask.graphics.drawRoundRect(0, 0, 104, 104, 26);
			_mask.graphics.endFill();
			_mask.x = _bg.x + (_bg.width - _mask.width) / 2;
			_mask.y = _bg.y + (_bg.height - _mask.height) / 2;
			
			bodyContainer.addChild(_bg);
			bodyContainer.addChild(_image);
			bodyContainer.addChild(_mask);
			
			_image.mask = _mask;
		}
		
		private function drawDescription():void 
		{
			_description = Window.drawText(Locale.__e('flash:1518617867254'), {
				fontSize	:26,
				color		:0x6e411e,
				borderSize	:0,
				textAlign	:'center',
				wrap		:true,
				multiline	:true,
				width		:245
			})
		}
		
		private function drawButtons():void 
		{
			_buyBttn = new Button({
				caption			:Locale.__e('flash:1518780998508'),
				fontColor		:0xffffff,
				width			:170,
				height			:51,
				fontSize		:32,
				bgColor			:[0x66b9f0, 0x567ace],
				bevelColor		:[0xcce8fa, 0x4465b6],
				fontBorderColor	:0x2b4a84
			});
			_inviteBttn = new Button({
				caption			:Locale.__e('flash:1382952380197'),
				fontColor		:0xffffff,
				width			:170,
				height			:51,
				fontSize		:32,
				bgColor			:[0xbcec63, 0x68bd21],
				bevelColor		:[0xe0ffad, 0x4e8b2c],
				fontBorderColor	:0x085c10
			});
			
			_buyBttn.addEventListener(MouseEvent.CLICK, onBuyEvent)
			_inviteBttn.addEventListener(MouseEvent.CLICK, onInviteEvent)
		}
		
		private function onBuyEvent(e:MouseEvent):void 
		{
			close();
			new BuyFriendWindow({
				title:	Locale.__e('flash:1518782113541'),
				model:	settings.model,
				target:	settings.target,
				popup:	true
			}).show()
		}
		
		private function onInviteEvent(e:MouseEvent):void 
		{
			Window.closeAll();
			InviteHelper.inviteOther();
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			super.close(e);
		}
		
		private function build():void 
		{
			exit.y -= 20;
			
			_description.y = (settings.height - _description.height) / 2 - 35;
			_description.x = 200;
			
			bodyContainer.addChild(_description);
			
			_buyBttn.y = settings.height - _buyBttn.height - 35;
			_buyBttn.x = settings.width / 2 - _buyBttn.width - 10;
			
			_inviteBttn.y = settings.height - _inviteBttn.height - 35;
			_inviteBttn.x = settings.width / 2 + 10;
			
			bodyContainer.addChild(_buyBttn);
			bodyContainer.addChild(_inviteBttn);
		}
		
	}

}