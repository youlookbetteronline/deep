package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import units.Anime2;
	/**
	 * ...
	 * @author ...
	 */
	public class UpgradeFinishWindow extends Window 
	{
		private var background:Bitmap;
		private var picture:Bitmap;
		private var anime:Anime2;
		private var sID:int;
		private var preloader:Preloader = new Preloader();
		private var fbIcon:Bitmap = new Bitmap();
		private var tellBttn:Button;
		public function UpgradeFinishWindow(settings:Object=null) 
		{
			if (!settings)
				settings = { };

			settings['sID'] = settings.sID;
			settings['fontColor'] = 0xfffe88;
			settings['title'] = Locale.__e('flash:1382952379735') || settings.title;
			settings['fontBorderColor'] = 0x451c00;
			settings['borderColor'] = 0x451c00;
			settings['shadowColor'] = 0x4d3300;
			settings['fontSize'] = 50;
			settings['fontBorderSize'] = 3;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['shadowSize'] = 1;
			settings["width"] = settings.width || 575;
			settings["height"] = settings.height || 480;
			settings['exitTexture'] = 'closeBttnMetal';
			sID = settings.sID;
			super(settings);
		}
		
		override public function drawBackground():void
		{
			picture = new Bitmap(Window.textures.backingPicture);
			picture.x = 0;
			picture.y = 0;
			Size.size(picture, 557, 454);
			settings.width = picture.width + 25;
			settings.height = picture.height + 25;
			layer.addChild(picture);
			background = backing(settings.width, settings.height, 30, 'ironBacking');
			background.x = picture.x + (picture.width - background.width) / 2;
			background.y = picture.y + (picture.height - background.height) / 2;
			layer.addChild(background);
		}
		
		override public function drawBody():void
		{
			exit.y -= 35;
			drawRibbon();
			preloader.x = (settings.width - preloader.width) / 2;
			preloader.y = 200;
			bodyContainer.addChild(preloader);
			Load.loading(Config.getSwf(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:*):void{
				bodyContainer.removeChild(preloader);
				drawAnimation(data);
			});
			var text:String = Locale.__e('flash:1493307334139') + " " + App.data.storage[sID].title;
			var descriptionLabel:TextField = drawText(text, {
				fontSize:36,
				textAlign:"center",
				color:0xffffff,
				borderColor:0x451c00,
				width:settings.width - 80,
				multiline: true,
				wrap: true
			});
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = settings.height - 160;
			bodyContainer.addChild(descriptionLabel);
			
			
			tellBttn = new Button( {
				width:300,
				height:65,
				fontSize:32,
				bgColor	:[0x57b9fd, 0x4273da],
				bevelColor:[0xa6deff, 0x3a5bab],
				fontColor:0xffffff,				//Цвет шрифта
				fontBorderColor:0x18419e,
				radius:22,
				caption:Locale.__e("flash:1493288771912")
			});
			tellBttn.x = (settings.width - tellBttn.width) / 2;
			tellBttn.y = settings.height - tellBttn.height - 20;
			tellBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(tellBttn);
			
			fbIcon = new Bitmap(Window.textures.fbIcon);
			Size.size(fbIcon, 43, 43);
			fbIcon.x = tellBttn.x + tellBttn.width - fbIcon.width - 15;
			fbIcon.y = tellBttn.y + (tellBttn.height - fbIcon.height) / 2 + 2;
			bodyContainer.addChild(fbIcon);
			tellBttn.textLabel.x -= 20;
			tellBttn.addEventListener(MouseEvent.CLICK, tellEvent);
		}
		
		private function tellEvent(e:*= null):void
		{
			settings.callback();
			close();
			return;
		}

		private function drawAnimation(swf:Object):void 
		{
			anime = new Anime2(swf, { w:310, h:230 } );
			anime.x = (settings.width - anime.width) / 2;
			anime.y = 70;
			bodyContainer.addChild(anime);
		}
		
		
		override protected function drawRibbon():void 
		{
			var titleBackingBmap:Bitmap = backingShort(350, 'actionRibbonBg', true);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -75;
			bodyContainer.addChild(titleBackingBmap);
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y + 16;
			
			bodyContainer.addChild(titleLabel);
		}
		
		
		
	}

}