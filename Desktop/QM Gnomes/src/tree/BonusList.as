package tree
{
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	
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
				var title:TextField = UI.drawText(
					settings.titleText, 
					{
						fontSize	:26,
						color		:settings.titleColor,//0xFFFFFF,//0x564c45,
						borderColor	:settings.titleBorderColor,//0x252a38,//0xf9f2dd,
						//borderSize  :3,
						autoSize	:"left"
					}
				);
				
				title.x = settings.titleX + 5;
				title.y = settings.titleY;
				addChild(title);
				X = title.x + title.textWidth + 15;
			}
			var counter:int = 0;
			for (var sID:* in bonus)
			{
				if (sID == 'time')
				{
					settings['time'] = true;
				}else{
					settings['time'] = false;
				}
				
				var item:InternalBonusItem = new InternalBonusItem(sID, bonus[sID], settings.size, settings);
				addChild(item);
				item.x = X;
				item.y = Y;
				X += item.width;
				counter ++;
				if (counter > 3)
				{
					X = 0;
					Y += 63;
					counter = 0;
				}
				
			}
			//var bg:Bitmap;
			////if (!settings.backingShort) {
				//bg = Window.backing(X, 60, 12, settings.background);
			//}else {
				//bg = Window.backingShort(X, settings.background);
			//}
			//
			//if(hasBacking){
				//addChildAt(bg, 0);
				//bg.x = settings.bgX; bg.y = settings.bgY;
			//}
		}
		
	
	}
}

import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import tree.LayerX;

internal class InternalBonusItem extends LayerX
{
	private var icon:Bitmap;
	private var bubble:Bitmap;
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
		
		bubble = new Bitmap(Textures.textures.bubbleBackingBig);
		UI.size(bubble, 60, 60);
		bubble.smoothing = true;
		var newBmap:Bitmap = new Bitmap(Textures.textures.tick)
		if (_settings.time)
			onLoad(newBmap);
		else
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad)
			
		var counterText:String;
		
		if (_settings.time)
			counterText = TimeConverter.timeToCuts(count, false, true);
		else
			counterText = 'x' + String(count);
		
		text = UI.drawText(counterText,
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
		text.y = bubble.y + bubble.height - text.height;
		text.x = bubble.x + bubble.width - 10;
		
		if (count == 0)
			text.visible = false;
		if (_settings.time)
			tip = function():Object {
				return {
					title:'Время всех крафтов',
					text:'И что-то там еще...'
				}
			}
		else
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
		UI.size(icon, 50, 50);
		icon.smoothing = true;
		icon.x = (bubble.width - icon.width) / 2;
		icon.y = (bubble.height - icon.height) / 2;
	}
}