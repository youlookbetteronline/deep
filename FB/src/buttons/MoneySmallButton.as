package buttons 
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.UserInterface;
	import wins.Window;
	
	
	public class MoneySmallButton extends Button
	{
		public var countLabel:TextField;
		public var captionLabel:TextField;
		
		public var countText:int = 99;
		public var fontCountSize:int = 20;
		public var fontCountColor:uint = 0xFFFFFF;
		public var fontCountBorder:uint = 0x38510D;
		public var coinsIcon:Bitmap;
		
		private var countStyle:TextFormat = new TextFormat(); 
		
		public function MoneySmallButton(settings:Object = null) 
		{
			var defaults:Object = new Object()
			defaults["type"]			= "real";	
			defaults["width"] 			= 120;	
			defaults["height"] 			= 38;	
			defaults["fontBorderSize"] 	= 4;
			defaults["fontBorderGlow"] 	= 2;
			defaults["caption"]			= "";//Locale.__e("");
			defaults["textAlign"]		= "center";	
			defaults["borderGlow"] 		= 0;
			defaults["borderWidth"] 	= 2.5;
			
			defaults["fontSize"]		= 20;
			defaults["sound"]		= 'green_button';
			
			if (settings == null) settings = defaults;
			
			if (settings.type == "coins")
			{
				defaults["borderColor"]		= [0xfbe109,0xd2aa09];	//Цвета градиента
				defaults["bgColor"] 		= [0xfbe109, 0xd2aa09];//[0xA9DC3C, 0x96C52E];	//Начальный цвет градиента
				defaults["fontColor"]	 	= 0x614605;				//Цвет шрифта	
				defaults["fontBorderColor"] = 0xf0e6c1;				//Цвет обводки шрифта	
				defaults["fontCountColor"]	= 0x614605;				//Цвет шрифта	
				defaults["fontCountBorder"] = 0xf0e6c1;				//Цвет обводки шрифта	
			}			
			else if (settings.type == "seaStone")
			{
				defaults["borderColor"]		= [0xcbc6a0,0xcbc6a0];	//Цвета градиента
				defaults["bgColor"] 		= [0xfdcc41, 0xfdcc41];//[0xA9DC3C, 0x96C52E];	//Начальный цвет градиента
				defaults["fontColor"]	 	= 0x9ae1e7;				//Цвет шрифта	
				defaults["fontBorderColor"] = 0x3d3c2a;				//Цвет обводки шрифта	
				defaults["fontCountColor"]	= 0x9ae1e7;				//Цвет шрифта	
				defaults["fontCountBorder"] = 0x3d3c2a;				//Цвет обводки шрифта
			}else if (settings.type == "eventCoin") {
				defaults["borderColor"]		= [0xcbc6a0,0xcbc6a0];	//Цвета градиента
				defaults["bgColor"] 		= [0xfdcc41, 0xfdcc41];//[0xA9DC3C, 0x96C52E];	//Начальный цвет градиента
				defaults["fontColor"]	 	= 0x9ae1e7;				//Цвет шрифта	
				defaults["fontBorderColor"] = 0x3d3c2a;				//Цвет обводки шрифта	
				defaults["fontCountColor"]	= 0x9ae1e7;				//Цвет шрифта	
				defaults["fontCountBorder"] = 0x3d3c2a;				//Цвет обводки шрифта
			}
			else 
			{
				defaults["borderColor"]		= [0xf8f2bd, 0x836a07];	//Цвета градиента
				defaults["bgColor"] 		= [0xA9DC3C, 0x96C52E];	//Начальный цвет градиента
				defaults["fontColor"]	 	= 0xFFFFFF;				//Цвет шрифта	
				defaults["fontBorderColor"] = 0xDCFA9B;				//Цвет обводки шрифта	
				defaults["fontCountColor"]	= 0xFFFFFF;				//Цвет шрифта	
				defaults["fontCountBorder"] = 0x38510D;				//Цвет обводки шрифта	
			}
			
			defaults["countDy"] 		= 0;	
			defaults["countText"] 		= 50;	
			defaults["fontCountSize"]	= 28;					//Размер шрифта
			
			for (var property:* in settings) {
				defaults[property] = settings[property];
			}
			settings = defaults
			
			super(settings);
		}
		
		override protected function drawTopLayer():void {
			
			countLabel = new TextField();
			countLabel.mouseEnabled = false;
			countLabel.mouseWheelEnabled = false;
			
			countLabel.antiAliasType = AntiAliasType.ADVANCED;
			countLabel.embedFonts = true;
			countLabel.sharpness = 100;
			countLabel.thickness = 50;

			countLabel.text = settings.countText + "";
			//countLabel.border = true;

			countStyle.color = settings.fontCountColor; 
			countStyle.size = settings.fontSize;
			countStyle.font = settings.fontFamily;
			countStyle.align = TextFormatAlign.RIGHT;
			
			countLabel.setTextFormat(countStyle);
			
			var countFilter:GlowFilter = new GlowFilter(settings.fontCountBorder,1,settings.fontBorderSize,settings.fontBorderSize,10,1);
			countLabel.filters = [countFilter];	
			
			if(settings.type == "coins"){
				coinsIcon = new Bitmap(UserInterface.textures.goldenPearl, "auto", true);
			}else if (settings.type == "seaStone") {
				coinsIcon = new Bitmap(Window.textures.stoneMoney, "auto", true);
			}else if (settings.type == "eventCoin") {
				coinsIcon = new Bitmap(Window.textures.winterEventCoin, "auto", true)
			}else {
				coinsIcon = new Bitmap(UserInterface.textures.blueCristal, "auto", true);
			}
			
			coinsIcon.scaleX = coinsIcon.scaleY = settings.scale;
			
			if (settings.iconScale)
			{
				coinsIcon.scaleX = settings.iconScale;
				coinsIcon.scaleY = settings.iconScale;
			}
			coinsIcon.filters = [new GlowFilter(0xffffff, .8, 2, 2, 4)];
			
			countLabel.height = countLabel.textHeight;
			countLabel.width = countLabel.textWidth + 6;
			
			countLabel.y = (bottomLayer.height - settings.borderWidth) / 2 - countLabel.textHeight / 2 + settings.countDy;
			coinsIcon.y = countLabel.y + (countLabel.textHeight - coinsIcon.height) / 2 +4;
			
			var cont:Sprite = new Sprite();
			topLayer.addChild(cont);
			
			//if (settings.type == "eventCoin") 
			//{
				//coinsIcon.x = -5;
				//coinsIcon.y = -0.05;
			//}else 
			//{
				////coinsIcon.x = 0;
			//}
			
			countLabel.x = coinsIcon.width + 2;
			
			cont.addChild(coinsIcon);
			cont.addChild(countLabel);
			cont.x = (settings.width - cont.width) / 2;
			
			addChild(topLayer);
		}
	}
}