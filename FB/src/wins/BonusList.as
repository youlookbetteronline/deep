package wins
{
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
			background:'collectionItemBacking',
			backingShort:false,
			titleX:40,
			titleY:27,
			bgX:0,
			bgY:0,
			titleColor:0xFFFFFF,
			titleBorderColor:0x7e3e14,
			size:40,
			width: 520
		}
		
		public function BonusList(bonus:Object, hasBacking:Boolean = true, _settings:Object = null)
		{
			if (_settings != null) {
				for (var _item:String in _settings)
					this.settings[_item] = _settings[_item];
			}
			if (settings.hasOwnProperty('glow')) 
			{
				
			}else 
			{
				App.ui.staticGlow(this,{color:0xce903d,size:3});
			}
			
			var X:int = 15;
			if(settings.hasTitle){
				var title:TextField = Window.drawText(
					settings.titleText, 
					{
						fontSize	:28,
						color		:settings.titleColor,//0xFFFFFF,//0x564c45,
						borderColor	:settings.titleBorderColor,//0x252a38,//0xf9f2dd,
						//borderSize  :3,
						autoSize	:"left"
					}
				);
				
				title.x = settings.titleX + 5;
				title.y = settings.titleY;
				addChild(title);
				X = title.x + title.textWidth;
			} 
			
			
			
			for (var sID:* in bonus)
			{
				var item:InternalBonusItem = new InternalBonusItem(sID, bonus[sID], settings.size, settings);
				addChild(item);
				item.x = X;
				item.y = 0;
				X+=/*item.text.textWidth*/ 70;
			}
			
			/*if (settings.extraWidth) {
				X += 100;
			}*/
			var bg:Bitmap;
			if (!settings.backingShort) {
				bg = Window.separator2(X, 'giftBeckingCollection', 'giftBeckingCollectio');
			}else {
				bg = Window.backingShort(X, settings.background);
			}
			
			if(hasBacking){
				addChildAt(bg, 0);
				bg.x = settings.bgX + 10; bg.y = settings.bgY;
			}
		}
		
		public function take():void{
			var childs:int = numChildren;
			
			while(childs--) {
				if(getChildAt(childs) is InternalBonusItem){
					var reward:InternalBonusItem = getChildAt(childs) as InternalBonusItem ;
								
					var item:BonusItem = new BonusItem(reward.sID, reward.count);
				
					var point:Point = Window.localToGlobal(reward);
					item.cashMove(point, App.self.windowContainer);
				}
			}
		}
	}
}

import core.Load;
import flash.display.Bitmap;
import flash.text.TextField;
import wins.Window;

internal class InternalBonusItem extends LayerX
{
	private var icon:Bitmap;
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
		//if (sID == 26 || sID == 23) sID = 25; // убрать
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad)
		
		text = Window.drawText(String(count),
				{
					fontSize	:settings.textSize||28,
					color		:settings.bonusTextColor,
					borderColor	:settings.bonusBorderColor,
					//borderSize  :3,
					autoSize	:"center"
				}
			);
			
		text.height = text.textHeight;
		
		addChild(icon);
		addChild(text);
		text.y = 50 - text.textHeight/2;
		text.x = 20;
		
		//if (count == 0)
			//text.visible = false;
			
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
		icon.smoothing = true;
		var scale:Number = size / icon.height;
		icon.scaleX = icon.scaleY = scale;
		icon.y = 60/2 - icon.height/2;
		icon.x += 5;
		//text.x = icon.width+5;
	}
}