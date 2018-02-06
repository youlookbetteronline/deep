package buttons 
{
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.UserInterface;
	import wins.Window;
	
	
	public class MoneyButton extends Button
	{
		public var type:* = "";
		public var countLabel:TextField;		
		public var countText:int;
		public var fontCountSize:int = 20;
		public var fontCountColor:uint = 0xDCFA9B;
		public var fontCountBorder:uint = 0x53742d;
		public var coinsIcon:Bitmap;
		private var countStyle:TextFormat = new TextFormat(); 
		
		public function MoneyButton(settings:Object = null) 
		{
			settings["width"]				= settings.width || 200;
			settings["height"]				= settings.height || 44;
			settings['caption']				= ((settings.caption=='none')?(''):(settings.caption || Locale.__e("flash:1382952379751")));			
			settings["bgColor"]				= settings.bgColor || [0x99cbfe, 0x5c87ef];
			settings["borderColor"]			= settings.borderColor || [0xffffff, 0xffffff];
			settings["bevelColor"]			= settings.bevelColor || [0xb5dbff, 0x386cdc];
			settings["fontColor"]			= settings.fontColor || 0xffffff;				
			settings["fontBorderColor"]		= settings.fontBorderColor || 0x104f7d;		
			settings["fontCountColor"]		= settings.fontCountColor || 0xffffff;				//Цвет шрифта
			settings["fontCountBorder"]		= settings.fontCountBorder || 0x104f7d;				//Цвет обводки шрифта			
			settings['iconScale']			= settings.iconScale || 0.55;			
			settings['iconDY']				= settings.iconDY || 0;			
			settings["countText"]			= settings.countText || 50;				
			settings["fontSize"]			= settings.fontSize || 22;
			settings["fontCountSize"]		= settings.fontCountSize || 23;
			settings["fontBorderCountSize"] = 5;
			settings["radius"]				= settings.radius || 16;
			//settings["eventPostManager"]	= settings.eventPostManager || true;				// по умолчанию денежная кнопка добавляется в PostManager
			settings["eventPostManager"]  	= (settings.eventPostManager == undefined)?  true : settings.eventPostManager;
			
			countText = settings.countText; 
			
			this.order = settings.order;
			this.type = settings.type;
			super(settings);
		}
		
		public function set countLabelText(count:int):void {
			countText = count;
			countLabel.text = countText + "";
			countLabel.setTextFormat(countStyle);
		}
		
		public function get countLabelText():int {
			return countText;
		}
		
		override protected function drawTopLayer():void {
			
			textLabel = new TextField();
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			
			textLabel.multiline = true;
			textLabel.antiAliasType = AntiAliasType.ADVANCED;
			textLabel.embedFonts = true;
			textLabel.sharpness = 100;
			textLabel.thickness = 50;
			//textLabel.autoSize = TextFieldAutoSize.LEFT

			textLabel.text = settings.caption;

			var style:TextFormat = new TextFormat(); 
			style.color = settings.fontColor; 
			style.size = settings.fontSize;
			style.font = settings.fontFamily;
			style.align = TextFormatAlign.CENTER;
			style.leading = settings.textLeading;
			textLabel.setTextFormat(style);
			var filter:GlowFilter = new GlowFilter(settings.fontBorderColor,1,settings.fontBorderSize,settings.fontBorderSize,10,1);
			textLabel.filters = [filter];	
			
			textLabel.x = 10;
			
			textLabel.width = textLabel.textWidth + 6;
			textLabel.height = textLabel.textHeight + 6;
			
			//Size.fitImtoTextField(textLabel);
			
			var deltaWidth:int = settings.setWidth?40:0;
			
			
			if (textLabel.width > (settings.width - deltaWidth)) {
				if(textLabel.text.indexOf(' ') != -1){
					textLabel.wordWrap = true;
				}
				textLabel.width = settings.width - deltaWidth - 10;
				//Size.fitImtoTextField(textLabel);
				textLabel.height = textLabel.textHeight + 8;
				
				while (textLabel.textHeight > bottomLayer.height || textLabel.textWidth > settings.width - deltaWidth ) {
					settings.fontSize -= 1;
					if (settings.fontSize  < 16) {
						style.leading = -3;
					}
					style.size = settings.fontSize;
					textLabel.setTextFormat(style);
					textLabel.height = textLabel.textHeight+8;
				}
			}
			
			textLabel.y = (settings.height - textLabel.textHeight) / 2 - 4;
			if (deltaWidth == 0) {
				textLabel.x = (settings.width - textLabel.textWidth) / 2;
			}
			//textLabel.border = true;
			//topLayer.addChild(textLabel);
			
			countLabel = new TextField();
			countLabel.mouseEnabled = false;
			countLabel.mouseWheelEnabled = false;
			
			countLabel.antiAliasType = AntiAliasType.ADVANCED;
			countLabel.embedFonts = true;
			countLabel.sharpness = 100;
			countLabel.thickness = 50;

			countLabel.text = settings.countText + "";
			countLabelText = settings.countText;
			
			countStyle.color = settings.fontCountColor; 
			countStyle.size = settings.fontCountSize*App._fontScale;
			countStyle.font = settings.fontFamily;
			countStyle.align = TextFormatAlign.RIGHT;
			
			countLabel.setTextFormat(countStyle);
			
			var countFilter:GlowFilter = new GlowFilter(settings.fontCountBorder,1,settings.fontBorderCountSize,settings.fontBorderCountSize,10,1);
			countLabel.filters = [countFilter];	
			if (settings.boostsec)
			{
				coinsIcon = new Bitmap(UserInterface.textures.clock, "auto", true);
			}
			else{
				if(settings.type == "gold"){
					coinsIcon = new Bitmap(UserInterface.textures.goldenPearl, "auto", true);
				}else {
					coinsIcon = new Bitmap(UserInterface.textures.blueCristal, "auto", true);
				}
			}
			if (settings.iconScale)
			{
				coinsIcon.scaleX = settings.iconScale;
				coinsIcon.scaleY = settings.iconScale;
			}
			
			textLabel.y = (bottomLayer.height - textLabel.textHeight) / 2 - 4;
			
			coinsIcon.y = (bottomLayer.height - coinsIcon.height) / 2 + settings.iconDY;
			
			countLabel.height = countLabel.textHeight;
			countLabel.width = countLabel.textWidth + 6;
			
			var minX:int = textLabel.textWidth + textLabel.x + 10;
			
			textLabel.x = 0;
			coinsIcon.x = textLabel.x + textLabel.width + 0;
			coinsIcon.filters = [new GlowFilter(0xffffff, .8, 2, 2, 4)];
			countLabel.x = coinsIcon.x + coinsIcon.width + 0;
			countLabel.y = coinsIcon.y + (coinsIcon.height - countLabel.textHeight)/2;
			
			topLayer.addChild(coinsIcon);
			topLayer.addChild(textLabel);
			topLayer.addChild(countLabel);
			
			
			topLayer.x = (settings.width - topLayer.width) / 2;
			if (settings.hasDotes)
				topLayer.x += 10;
			
			addChild(topLayer);
		}
		
		public function updatePos():void
		{
			if (settings.notChangePos) return;
			
			countLabel.y = (bottomLayer.height - countLabel.textHeight) / 2;
			textLabel.y = (bottomLayer.height - textLabel.textHeight) / 2 - 4;
			coinsIcon.y = (bottomLayer.height - coinsIcon.height) / 2 + settings.iconDY;
			
			topLayer.x = (settings.width - topLayer.width) / 2;
			
			if (settings.hasDotes)
				topLayer.x += 10;
		}
		
		//override protected function drawDownBottomLayer():void
		//{
			//super.drawDownBottomLayer();
			//var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,settings.active.fontBorderColor,0.9,2,2,2,1);
			//countLabel.filters = [textFilter, shadowFilter];
		//}
		//
		//override protected function drawBottomLayer():void
		//{
			//super.drawDownBottomLayer();
			//textFilter = new GlowFilter(settings.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
			//var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,settings.fontBorderColor,0.9,2,2,2,1);
			//if(countLabel)countLabel.filters = [textFilter, shadowFilter];
		//}
		
		public function set count(number:String):void 
		{
			countLabel.text = number;
			countLabel.setTextFormat(countStyle);
			countLabel.width = countLabel.textWidth + 6;
			
			updatePos();
		}
		
	}

}