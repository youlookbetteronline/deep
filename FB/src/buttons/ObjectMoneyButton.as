package buttons
{
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class ObjectMoneyButton extends Button
	{
		public var type:* = "";
		public var fontCountSize:int = 20;
		public var fontCountColor:uint = 0xDCFA9B;
		public var fontCountBorder:uint = 0x53742d;
		public var coinsIcon:Bitmap;
		public var countText:int;
		public var countLabel:TextField;
		
		private var _countStyle:TextFormat = new TextFormat();
		
		public function ObjectMoneyButton(settings:Object = null)
		{
			settings["width"] = settings.width || 200;
			settings["height"] = settings.height || 44;
			settings['caption'] = ((settings.caption == 'none') ? ('') : (settings.caption || Locale.__e("flash:1382952379751")));
			settings["bgColor"] = settings.bgColor || [0x99cbfe, 0x5c87ef];
			settings["borderColor"] = settings.borderColor || [0xffffff, 0xffffff];
			settings["bevelColor"] = settings.bevelColor || [0xb5dbff, 0x386cdc];
			settings["fontColor"] = settings.fontColor || 0xffffff;
			settings["fontBorderColor"] = settings.fontBorderColor || 0x104f7d;
			settings["fontCountColor"] = settings.fontCountColor || 0xffffff;				//Цвет шрифта
			settings["fontCountBorder"] = settings.fontCountBorder || 0x104f7d;				//Цвет обводки шрифта			
			settings["mID"] = settings.mID || 3;
			settings['iconDY'] = settings.iconDY || 0;
			settings["countText"] = settings.countText || 50;
			settings["fontSize"] = settings.fontSize || 22;
			settings["fontCountSize"] = settings.fontCountSize || 23;
			settings["fontBorderCountSize"] = 5;
			settings["radius"] = settings.radius || 16;
			settings["eventPostManager"] = (settings.eventPostManager == undefined) ? true : settings.eventPostManager;
			
			countText = settings.countText;
			
			this.order = settings.order;
			this.type = settings.type;
			super(settings);
		}
		
		override protected function drawTopLayer():void
		{
			textLabel = new TextField();
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			textLabel.multiline = true;
			textLabel.antiAliasType = AntiAliasType.ADVANCED;
			textLabel.embedFonts = true;
			textLabel.sharpness = 100;
			textLabel.thickness = 50;
			textLabel.text = settings.caption;
			
			var style:TextFormat = new TextFormat();
			style.color = settings.fontColor;
			style.size = settings.fontSize;
			style.font = settings.fontFamily;
			style.align = TextFormatAlign.CENTER;
			style.leading = settings.textLeading;
			textLabel.setTextFormat(style);
			var filter:GlowFilter = new GlowFilter(settings.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
			textLabel.filters = [filter];
			textLabel.width = textLabel.textWidth + 8;
			textLabel.height = textLabel.textHeight + 8;
			
			var deltaWidth:int = settings.setWidth ? 40 : 0;
			
			if (textLabel.width > (settings.width - deltaWidth))
			{
				if (textLabel.text.indexOf(' ') != -1)
				{
					textLabel.wordWrap = true;
				}
				textLabel.width = settings.width - deltaWidth - 10;
				textLabel.height = textLabel.textHeight + 8;
				
				while (textLabel.textHeight > bottomLayer.height || textLabel.textWidth > settings.width - deltaWidth)
				{
					settings.fontSize -= 1;
					if (settings.fontSize < 16)
					{
						style.leading = -3;
					}
					style.size = settings.fontSize;
					textLabel.setTextFormat(style);
					textLabel.height = textLabel.textHeight + 8;
				}
			}
			
			textLabel.y = (settings.height - textLabel.height) / 2;//(settings.height - textLabel.textHeigh) / 2 - 4;
			
			countLabel = new TextField();
			countLabel.mouseEnabled = false;
			countLabel.mouseWheelEnabled = false;
			countLabel.antiAliasType = AntiAliasType.ADVANCED;
			countLabel.embedFonts = true;
			countLabel.sharpness = 100;
			countLabel.thickness = 50;
			countLabel.text = settings.countText + "";
			countLabelText = settings.countText;
			
			_countStyle.color = settings.fontCountColor;
			_countStyle.size = settings.fontCountSize * App._fontScale;
			_countStyle.font = settings.fontFamily;
			_countStyle.align = TextFormatAlign.RIGHT;
			
			countLabel.setTextFormat(_countStyle);
			
			var countFilter:GlowFilter = new GlowFilter(settings.fontCountBorder, 1, settings.fontBorderCountSize, settings.fontBorderCountSize, 10, 1);
			countLabel.filters = [countFilter];
			countLabel.height = countLabel.textHeight;
			countLabel.width = countLabel.textWidth + 6;
			
			coinsIcon = new Bitmap();
			if (App.data.storage.hasOwnProperty(settings.mID)) {
				Load.loading(Config.getIcon(App.data.storage[settings.mID].type, App.data.storage[settings.mID].preview), onLoad);
			} else {
				countLabel.x = textLabel.x + textLabel.width + 4;
				countLabel.y = (settings.height - countLabel.height) / 2;
			}
			
			var minX:int = textLabel.textWidth + textLabel.x + 10;
			
			topLayer.addChild(textLabel);
			topLayer.addChild(countLabel);
			topLayer.addChild(coinsIcon);
			
			topLayer.x = (settings.width - topLayer.width) / 2;
			if (settings.hasDotes)
				topLayer.x += 10;
			
			addChild(topLayer);
		}
		
		public function updatePos():void
		{
			if (settings.notChangePos) return;
			
			countLabel.y = (bottomLayer.height - countLabel.height) / 2;
			textLabel.y = (bottomLayer.height - textLabel.height) / 2;//(bottomLayer.height - textLabel.textHeight) / 2 - 4;
			coinsIcon.y = (bottomLayer.height - coinsIcon.height) / 2 + settings.iconDY;
			
			topLayer.x = (settings.width - topLayer.width) / 2;
			
			if (settings.hasDotes)
				topLayer.x += 10;
		}
		
		private function onLoad(data:Bitmap):void
		{
			coinsIcon.bitmapData = data.bitmapData;
			coinsIcon.smoothing = true;
			Size.size(coinsIcon, settings.height - 10, settings.height - 10);
			coinsIcon.x = textLabel.x + textLabel.width + 2;
			coinsIcon.y = (bottomLayer.height - coinsIcon.height) / 2 + settings.iconDY;
			coinsIcon.filters = [new GlowFilter(0xffffff, .8, 2, 2, 4)];
			
			countLabel.x = coinsIcon.x + coinsIcon.width + 2;
			countLabel.y = coinsIcon.y + (coinsIcon.height - countLabel.height) / 2;
			
			topLayer.x = (settings.width - topLayer.width) / 2;
		}
		
		public function set countLabelText(count:int):void
		{
			countText = count;
			countLabel.text = countText + "";
			countLabel.setTextFormat(_countStyle);
		}
		
		public function get countLabelText():int
		{
			return countText;
		}
		
		public function set count(number:String):void
		{
			countLabel.text = number;
			countLabel.setTextFormat(_countStyle);
			countLabel.width = countLabel.textWidth + 6;
			
			updatePos();
		}
	}
}