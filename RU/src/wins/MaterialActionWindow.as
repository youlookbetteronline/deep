package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Unit;
	/**
	 * ...
	 * @author ...
	 */
	public class MaterialActionWindow extends AddWindow 
	{
		private var materialBttn:MoneyButton;
		private var picture:Bitmap = new Bitmap();
		private var descPicture:TextField;
		
		public function MaterialActionWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings["width"] = 500;
			settings["height"] = 422;
			settings["fontSize"] = 56;
			settings["faderAlpha"] = 0.2;
			settings["faderAsClose"] = true;
			settings["hasPaginator"] = false;
			settings['background'] = 'paperScroll';
			settings['exitTexture'] = 'closeBttn';
			settings['description'] = Locale.__e('flash:1497340343228');
			settings['title'] = App.data.storage[Numbers.firstProp(App.data.actions[settings.pID].items).key].title;
			super(settings);		
		}
		
		/*override public function drawTitle():void{
		}*/
		
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
		
		override public function drawBody():void 
		{
			drawRibbon();
			this.y -= 20;
			this.fader.y += 20;
			exit.x -= 8;
			exit.y -= 25;
			//exit.visible = false;
			var _lang:String = "_EN";
		    if (App.lang == 'ru')
			_lang = "_RU";
			var preloader:Preloader = new Preloader();
			preloader.x = settings.width / 2;
			preloader.y = 145;
			bodyContainer.addChild(preloader);
		    Load.loading(Config.getImage('promo/images', action.image+_lang), function(data:Bitmap):void {
				bodyContainer.removeChild(preloader);
				picture.bitmapData = data.bitmapData;
				picture.x = (settings.width - picture.width) / 2;
				picture.y = 25;
				bodyContainer.addChild(picture)
			});
			drawDescription();
				
			if (action.mprice)
				drawMaterialPrice();
			
		}
		
		public function drawMaterialPrice():void 
		{	
			var bttnSettings:Object = {
				caption			:Locale.__e("flash:1382952379751"),
				countText		:String(Numbers.firstProp(action.mprice[App.social]).val),
				iconScale		:.7,
				fontCountSize	:32,
				fontSize		:30,
				width			:186,
				height			:52
			};
			
			if (materialBttn != null)
				bodyContainer.removeChild(materialBttn);
			materialBttn = new MoneyButton(bttnSettings)
			bodyContainer.addChild(materialBttn);
			
			materialBttn.x = (settings.width - materialBttn.width) / 2;
			materialBttn.y = settings.height - materialBttn.height / 2 - 54;
			
			materialBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		
		
		public function drawDescription():void 
		{
			var descText:String = App.data.actions[action.id].text1;
			if (descText == '')
				descText = App.data.storage[Numbers.firstProp(App.data.actions[action.id].items).key].description;
				
			descPicture = Window.drawText(descText, {
				fontSize 	:44,
				color  		:0xfdff68,
				borderColor :0x7f4015,
				textAlign 	:"center",
				textLeading	:-4,
				multiline 	:true,
				width   	:450,
				wrap		:true
		    });
		    descPicture.x = (settings.width - descPicture.width) / 2;
		    descPicture.y = settings.height - 140;
		    bodyContainer.addChild(descPicture);
		}
		
		
		
	}

}