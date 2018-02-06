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
	public class ExtraBonusList extends Sprite 
	{
		public var bonus:Object;
		public var settings:Object = {
			hasTitle:true,
			titleText:Locale.__e("flash:1382952380000"),
			background:'rewardStripe',
			backingShort:false,
			backDafault:true,
			titleX:40,
			titleY:27,
			bgX:0,
			bgY:0,
			titleColor:0xFFFFFF,
			titleBorderColor:0x7e3e14,
			size:40,
			width: 520
		}
		
		public function ExtraBonusList(bonus:Object, hasBacking:Boolean = true, _settings:Object = null)
		{
			if (_settings != null) {
				for (var _item:String in _settings)
					this.settings[_item] = _settings[_item];
			}
			if (settings.hasOwnProperty('glow')) 
			{
				
			}else 
			{
				//App.ui.staticGlow(this,{color:0xce903d,size:3});
			}
			
			var X:int = 15;
			/*if(settings.hasTitle){
				var title:TextField = Window.drawText(
					settings.titleText, 
					{
						fontSize	:28,
						color		:settings.titleColor,//0xFFFFFF,//0x564c45,
						borderColor	:settings.titleBorderColor,//0x252a38,//0xf9f2dd,
						borderSize  :settings.borderSize || 3,
						autoSize	:"left"
					}
				);
				
				title.x = settings.titleX + 5;
				title.y = settings.titleY;
				addChild(title);
				X = title.x + title.textWidth + 7;
			} */
			
			
			
			for (var sID:* in bonus)
			{
				var item:InternalBonusItem = new InternalBonusItem(sID, bonus[sID], settings.size, settings);
				addChild(item);
				item.x = X;
				item.y = 12;
				X+=item.width+3;
			}
			X += 10;
			/*if (settings.extraWidth) {
				X += 100;
			}*/
			var bg:Bitmap;
			if (settings.backDafault) {
				bg = Window.separator2(X, 'giftBeckingCollection', 'giftBeckingCollectio');
			}else {
				bg = Window.backingShort(X + 20, settings.background);
			}
			
			if(hasBacking){
				addChildAt(bg, 0);
				bg.x = settings.bgX + 10; 
				bg.y = settings.bgY;
			}
			//drawCount();
		}
		
		
		/*public function drawCount():void{
			
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
				
				title.x = item.x + 5;
				title.y = item.height / 2;
				addChild(title);
				//X = title.x + title.textWidth;
			} 
			
		}*/
		
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
import core.Size;
import flash.display.Bitmap;
import flash.text.TextField;
import wins.Window;

internal class InternalBonusItem extends LayerX
{
	private var backBmap:Bitmap;
	private var icon:Bitmap;
	private var preloader:Preloader = new Preloader();
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
		if (_settings != null)
		{
			for (var _item:String in _settings)
				this.settings[_item] = _settings[_item];
		}
		
		this.size = size;
		icon = new Bitmap();
		this.sID = sID;
		this.count = count;
		
		backBmap = new Bitmap(Window.textures.clearBubbleBacking_0);
		//Size.size(backBmap, size+15, size+15);
		backBmap.visible = false;
		addChild(backBmap);
		
		addChild(preloader);
		Size.size(preloader, size, size);
		preloader.x = 26;
		preloader.y = 30;
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad)
		
		text = Window.drawText("x "+String(count),
			{
				fontSize	:settings.textSize || 24,
				color		:settings.bonusTextColor,
				borderColor	:0x7e3e14,
				borderSize  :settings.borderSize || 3,
				autoSize	:"left"
			}
		);
		
		text.height = text.textHeight;
		
		addChild(icon);
		addChild(text);
		text.y = 40 - text.textHeight/2;
		text.x = 36;
		
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
		removeChild(preloader);
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		var scale:Number = size / icon.height;
		icon.scaleX = icon.scaleY = scale;
		icon.y = 60/2 - icon.height/2;
		icon.x += 5;
		
		backBmap.x = icon.x + (icon.width - backBmap.width) / 2;
		backBmap.y = icon.y + (icon.height - backBmap.height) / 2;
		backBmap.visible = true;
		//text.x = backBmap.x;
		//text.y = backBmap.y;
		//text.x = icon.width+5;
	}
}