package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class LevelLockWindow extends Window 
	{
		
		private var okBttn:Button;
		private var image:Bitmap;
		public function LevelLockWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['hasPaginator'] = false;
			settings['background'] = 'paperScroll';
			settings['width'] = 430;
			settings['height'] = 390
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x492103;
			settings['borderColor'] = 0x492103;
			settings['shadowColor'] = 0x492103;
			settings['fontSize'] = 56;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 0;
			settings['hasTitle'] = false
			super(settings);
			
		}
		
		override public function drawBody():void 
		{			
			okBttn = new Button( { 
				caption:Locale.__e('flash:1382952380242'),
				width	:130,
				height	:50,
				radius	:12
			});
			exit.y -= 20;
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - okBttn.height;
			bodyContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, close);
			
			image = new Bitmap();
			var glow:Bitmap = new Bitmap(Window.textures.glowBig);
			glow.x = (settings.width - glow.width) / 2;
			glow.y = -15;
			bodyContainer.addChild(glow);
			
			Load.loading(Config.getIcon(App.data.storage[settings.search].type, App.data.storage[settings.search].preview), function(data:*):void{
				image.bitmapData = data.bitmapData;
				Size.size(image, 200, 180)
				image.x = glow.x + (glow.width - image.width) / 2;
				image.y = glow.y + (glow.height - image.height) / 2;
				bodyContainer.addChild(image);
			});
			
			var desc:TextField = Window.drawText(Locale.__e('flash:1499421029406'), 
			{
				fontSize	:28,
				color		:0xffffff,
				borderColor	:0x451c00,
				textAlign	:"center",
				width		:310
			});
			desc.x = (settings.width - desc.width) / 2;
			desc.y = settings.height - 150;
			bodyContainer.addChild(desc);
			
			var descLvl:TextField = Window.drawText(Locale.__e('flash:1499421118301',[settings.level]),
			{
				fontSize	:32,
				color		:0xffd153,
				borderColor	:0x451c00,
				textAlign	:"center",
				width		:120
			});
			descLvl.x = (settings.width - descLvl.width) / 2;
			descLvl.y = desc.y + desc.height + 6;
			bodyContainer.addChild(descLvl);
		}
		
	}

}