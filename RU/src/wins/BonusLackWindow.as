package wins 
{
	import com.adobe.images.BitString;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class BonusLackWindow extends Window 
	{
		private var _persImage:Bitmap;
		private var _description:TextField;
		public function BonusLackWindow(settings:Object=null) 
		{
			settings = settingsInit(settings);
			super(settings);
			
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			settings["width"]				= 680;
			settings["height"] 				= 355;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings['exitTexture'] 		= 'blueClose';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x1f5167;
			settings['fontBorderSize']		= 3;
			settings['fontSize'] 			= 40;
			settings['title'] 				= Locale.__e('flash:1429693439093');
			
			return settings;
		}
		
		private function parseContent():void
		{
			settings.content = Numbers.objectToArraySidCount(settings.bonus);
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing4(settings.width, settings.height, 160, 'blueBackingTL', 'blueBackingTR', 'blueBackingBL', 'blueBackingBR');
			layer.addChild(background);	
		}
		
		override public function drawBody():void 
		{
			this.x += 40;
			fader.x -= 40;
			
			drawPersonage();
			drawDescription();
			contentChange();
			build();
			
		}
		
		private function drawPersonage():void 
		{
			Load.loading(Config.getImageIcon('content', 'JanePresent'), function(data:Bitmap):void{
				_persImage = new Bitmap(data.bitmapData);
				_persImage.y = -15;
				_persImage.x = -115;
				bodyContainer.addChild(_persImage);
			})
		}
		
		private function drawDescription():void 
		{
			_description = Window.drawText(Locale.__e('flash:1518449154191'), {
				fontSize		:30,
				color			:0xffe558,
				borderColor		:0x174052,
				borderSize		:3,
				textAlign		:'center',
				width			:525,
				multiline		:true,
				wrap			:true
			})
		}
		
		override public function contentChange():void 
		{
			parseContent()
		}
		
		private function build():void 
		{
			titleLabel.y += 40;
			exit.y += 10;
			exit.x -= 15;
			
			_description.x = (settings.width - _description.width) / 2;
			_description.y = 52;
			
			bodyContainer.addChild(_description);
		}
	}
}

internal class BubbleItem extends LayerX
{
	private var _settings:Object = {
		width:105,
		height:105
	}
	public function BubbleItem(settings:Object)
	{
		for (var property:* in settings)
			_settings[property] = settings[property];
	}
}