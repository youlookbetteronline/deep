package wins 
{
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import silin.gadgets.Preloader;
	public class PergamentWindow extends Window 
	{
		
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		
		public var finished:uint = 0;
		
		
		public function PergamentWindow(settings:Object=null) 
		{
			
			settings['hasPaginator'] = false;
			settings['background'] = 'paperScroll';
			settings['fontSize'] = 40;
			
			super(settings);
		}
		
		
		override public function drawBody():void 
		{
			drawMirrowObjs('decSeaweed', settings.width + 35, - 35, settings.height - 172, true, true, false, 1, 1);
			
			paginator.onPageCount = settings.itemsOnPage;
			paginator.update();
			
			var upBack:Bitmap = new Bitmap();			
			upBack = Window.backing(400, 400, 40, "cloverInnerBacking"); //внутренняя подложка за айтемами
			upBack.x = settings.width / 2 - upBack.width / 2;
			upBack.y = 50;
			exit.y -= 30;
			
			contentChange();
			drawDescription();
		}
		
		private var back:Shape = new Shape();
		public function drawDescription():void {
			back.graphics.beginFill(0xfff4b9, .9);
		    back.graphics.drawRect(0, 0, settings.width - 120, 120);
		    back.graphics.endFill();
			back.height = 54;
		    back.x = (settings.width - back.width) / 2 ;
		    back.y = 40;
		    back.filters = [new BlurFilter(70, 0, 2)];
		    bodyContainer.addChild(back);
			
			var desc:String = settings.description;
			
			var descLabel:TextField = Window.drawText(desc, {
				fontSize :28,
				color  :0x6e411e,
				//borderColor :0x7f3d0e,
				border: false,
				textAlign :"center",
				multiline :true,
				width   :back.width,
				wrap: true
		    });
		    descLabel.x = back.x + (back.width - descLabel.width) / 2;
		    descLabel.y = back.y + (back.height - descLabel.height) / 2 + 3;
		    bodyContainer.addChild(descLabel);
		}
		
		override public function dispose():void
		{
			super.dispose();
		}	
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xf9fdff,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x5c9900,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: 0x235b00,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -12;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
			
			var titleBackingBmap:Bitmap = backingShort(titleLabel.width + 120, 'ribbonGrenn',true,1.3);//305
			titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
			titleBackingBmap.y = -56;
			bodyContainer.addChild(titleBackingBmap);
		}
		
		override public function titleText(settings:Object):Sprite
		{
			if (!settings.hasOwnProperty('width'))
				settings['width'] = 300;
				
			var cont:Sprite = new Sprite();
			var cont2:Sprite = new Sprite();
			var shadow:Sprite = new Sprite();
			
			var fontBorder:int = settings.fontBorderSize;
			settings.fontBorderSize = fontBorder;
			var fontBorderGlow:int = settings.fontBorderGlow;
			settings.fontBorderGlow = fontBorderGlow;
			
			
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			this.settings['titleWidth'] = textLabel.textWidth;
			this.settings['titleHeight'] = textLabel.textHeight;
			textLabel.wordWrap = true;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;
			
			var borderColor:uint = settings.borderColor
			settings.borderColor = borderColor;
			settings.color = borderColor;
			
			var textShadow:TextField = Window.drawText(settings.title, settings);
			textShadow.wordWrap = true;
			textShadow.width = settings.width;
			textShadow.height = textLabel.textHeight + 4;
			
			textShadow.cacheAsBitmap = true;
			textLabel.cacheAsBitmap = true;

			var textShadow2:TextField = Window.drawText(settings.title, settings);
			textShadow2.wordWrap = true;
			textShadow2.width = settings.width;
			textShadow2.height = textLabel.textHeight + 4;
			textShadow2.cacheAsBitmap = true;
			
			settings.borderColor = 0x2a5e0b;
			settings.color = 0x2a5e0b;
			var textShadow3:TextField = Window.drawText(settings.title, settings);
			textShadow3.wordWrap = true;
			textShadow3.width = settings.width;
			textShadow3.height = textLabel.textHeight + 4;
			textShadow3.cacheAsBitmap = true;
					
			var textShadow4:TextField = Window.drawText(settings.title, settings);
			textShadow4.wordWrap = true;
			textShadow4.width = settings.width;
			textShadow4.height = textLabel.textHeight + 4;
			textShadow4.cacheAsBitmap = true;
			
			cont2.addChild(shadow);
			shadow.addChild(textShadow3);
			shadow.addChild(textShadow4);
			cont2.addChild(cont);
			
			cont.addChild(textLabel);
			textFilter = new GlowFilter(0x579705, 1, 3,3, 10, 1);
			cont.filters = [textFilter];
			
			shadowFilter = new BlurFilter(2,2,1);
			shadow.filters = [shadowFilter];
			
			
			textShadow.y = 1;
			textShadow2.y = -2;
			textShadow3.y = 4;
			textShadow3.x = 1;
			textShadow4.y = 4;
			textShadow4.x = -1;
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont2;
		}
	}

}
