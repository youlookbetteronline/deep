package wins.elements
{
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class BonusList extends Sprite 
	{
		public var bonus:Object;
		public var settings:Object = {
			hasTitle:true,
			titleText:Locale.__e("flash:1382952380000"),
			background:'upgradeSmallBacking',
			backingShort:false,
			titleX:10,
			titleY:15,
			bgX:0,
			bgY:0,
			titleColor:0xFFFFFF,
			titleBorderColor:0x4b390f,
			size:40,
			width: 520
		}
		
		public function BonusList(bonus:Object, hasBacking:Boolean = false, _settings:Object = null)
		{
			if (_settings != null) {
				for (var _item:String in _settings)
					this.settings[_item] = _settings[_item];
			}
			
			var X:int = 0;
			var Y:int = 0;
			if(settings.hasTitle){
				var title:TextField = Window.drawText(
					settings.titleText, 
					{
						fontSize	:26,
						color		:settings.titleColor,
						borderColor	:settings.titleBorderColor,
						autoSize	:"left"
					}
				);
				
				title.x = settings.titleX + 5;
				title.y = settings.titleY;
				addChild(title);
				X = title.x + title.textWidth + 15;
			}
			//var counter:int = 0;
			for (var sID:* in bonus)
			{
				var item:InternalBonusItem = new InternalBonusItem(sID, bonus[sID], settings.size, settings);
				addChild(item);
				if (X + item.width + 4 > settings.width)
				{
					X = 0;
					Y += item.bubble.height + 6;
				}
				item.x = X;
				item.y = Y;
				X += item.width + 4;
				//counter ++;
				/*if (counter > 3)
				{
					X = 0;
					Y += 63;
					counter = 0;
				}*/
				
			}
		}
	}
}

import core.Load;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class InternalBonusItem extends LayerX
{
	private var icon:Bitmap;
	public var bubble:Bitmap;
	public var text:TextField;
	public var sID:uint;
	public var count:int;
	public var size:Number;
	
	public var settings:Object = {
			bonusTextColor:0xFFFFFF,
			bonusBorderColor:0x4b390f
		}
	
	public function InternalBonusItem(sID:uint, count:int, size:Number, _settings:Object = null)
	{
		if (_settings != null) {
				for (var _item:String in _settings)
					this.settings[_item] = _settings[_item];
		}
		
		this.size = size;
		icon = new Bitmap();
		this.sID = sID;
		this.count = count;
		
		bubble = new Bitmap(Window.textures.clearBubbleBacking);
		Size.size(bubble, 40, 40);
		bubble.smoothing = true;
		var newBmap:Bitmap = new Bitmap()
		//if (_settings.time)
			//onLoad(newBmap);
		//else
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad)
			
		var counterText:String;
		
		if (_settings.time)
			counterText = TimeConverter.timeToCuts(count, false, true);
		else
			counterText = 'x' + String(count);
		
		text = Window.drawText(counterText,
			{
				fontSize	:24,
				color		:settings.bonusTextColor,
				borderColor	:settings.bonusBorderColor,
				//borderSize  :3,
				autoSize	:"left"
			}
		);
			
		text.height = text.textHeight;
		
		addChild(bubble);
		
		addChild(icon);
		addChild(text);
		text.y = bubble.y + bubble.height - 10 - text.height /2;
		text.x = bubble.x + bubble.width - 10;
		
		if (count == 0)
			text.visible = false;
			
		tip = function():Object {
			return {
				title:App.data.storage[this.sID].title,
				text:App.data.storage[this.sID].description
			}
		}
	}
	
	private function onLoad(data:Bitmap):void
	{
		icon.bitmapData = data.bitmapData;
		Size.size(icon, bubble.width - 4, bubble.height - 4);
		icon.smoothing = true;
		icon.x = (bubble.width - icon.width) / 2;
		icon.y = (bubble.height - icon.height) / 2;
	}
}