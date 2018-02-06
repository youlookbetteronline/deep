package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Unit;
	/**
	 * ...
	 * @author ...
	 */
	public class CongratultaionWindow extends Window 
	{
		private var helpBttn:Button;
		private var image:Bitmap;
		public function CongratultaionWindow(settings:Object=null) 
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
			settings['title'] = Locale.__e('flash:1474469531767');
			super(settings);
			
		}
		
		override public function drawBody():void 
		{
			drawRibbon();
			exit.y -= 20;
			helpBttn = new Button( { 
				caption:Locale.__e('flash:1407231372860'),
				width	:130,
				height	:50,
				radius	:12
			});
			helpBttn.x = (settings.width - helpBttn.width) / 2;
			helpBttn.y = settings.height - helpBttn.height - 25;
			bodyContainer.addChild(helpBttn);
			helpBttn.addEventListener(MouseEvent.CLICK, onSearchEvent);
			
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
			
			var desc:TextField = Window.drawText(Locale.__e('flash:1499413207981'), 
			{
				fontSize	:32,
				color		:0xffffff,
				borderColor	:0x451c00,
				textAlign	:"center",
				width		:310
			});
			desc.x = (settings.width - desc.width) / 2;
			desc.y = settings.height - 150;
			bodyContainer.addChild(desc);
		}
		private function onSearchEvent(e:*):void 
		{
			close();
			if (App.user.worldID != 4)
			{
				close();
				new WorldsWindow( {
					title: Locale.__e('flash:1415791943192'),
					sID:	settings.search,
					only:	[4],
					popup:	true
				}).show();
			}
			else
			{
			closeAll();
			var target:Unit = Map.findUnits([settings.search]).shift();
			App.map.focusedOn(target, false  );
			}
		}
		
		override protected function drawRibbon():void 
		{
			var titleBackingBmap:Bitmap = backingShort(350, 'actionRibbonBg', true);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -35;
			bodyContainer.addChild(titleBackingBmap);
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y + 16;
			
			bodyContainer.addChild(titleLabel);
		}
		
	}

}