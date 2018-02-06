package wins
{
	import adobe.utils.CustomActions;
	import com.adobe.utils.ArrayUtil;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public class RewardListB2 extends Sprite 
	{
		public var bonus:Object;
		public var backing:Bitmap;
		public var title:TextField;
		public var cols:int = 20;
		public var bigBlink:Boolean = false;
		public var itemWidth:int = 95;
		public var itemHeight:int = 95;
		public var itemHasBacking:Boolean = false;
		public var itemToItemWidth:int = 0;
		private var itemsSprite:Sprite = new Sprite();
		private var params:Object = { };
		
		public function RewardListB2(bonus:Object, hasBacking:Boolean = true, widthBacking:int = 0, params:Object = null, text:String = "flash:1383056749229")
		{
			if (!params) params = { };
			if (params) this.params = params;
			
			title = Window.drawText(
				Locale.__e(text), {
					fontSize	:26,
					color		:0x564c45,
					borderColor	:0xf9f2dd,
					autoSize	:"left"
				}
			);
			
			var i:int = 0;
			var minY:int = 0;
			var maxY:int = 0;
			if(!params || !params.hasOwnProperty('cols'))
				cols = Numbers.countProps(bonus)
			else
				cols = params.cols;
			if (params && params.hasOwnProperty('itemHasBacking'))
				itemHasBacking = params.itemHasBacking;
				
			if (params && params.hasOwnProperty('itemWidth'))
				itemWidth = params.itemWidth;
			if (params && params.hasOwnProperty('itemHeight'))
				itemHeight = params.itemHeight;
			if (params && params.hasOwnProperty('itemToItemWidth'))
				itemToItemWidth = params.itemToItemWidth;
			
			
			var itemParams:Object = { disableCount:params['disableCount'] || false, scale:params['scale'] || 0.8, hasBackGround:itemHasBacking, bgParams: { width:itemWidth, height:itemHeight, texture:'itemBacking' }};
			if (params && params.hasOwnProperty('bigBlink')) {
				bigBlink = true;
				itemParams.bigBlink = params.bigBlink;
			}
			
			
			var list:Array = [];
			for (var sID:* in bonus) {
				
				if (!(bonus[sID] is int)) {
					for (var sid:* in bonus[sID]) {
						list.push( {
							sid:sid,
							count:bonus[sID][sid]
						});
					}
				}else{
					list.push( {
						sid:sID,
						count:bonus[sID]
					});
				}
			}
			
			if (params['sort'])
				list.sortOn('count', Array.NUMERIC);
			
			for (var j:int = 0; j < list.length; j++)
			{
				var object:Object = list[j];
				
				var item:RewardItem = new RewardItem(object.sid, object.count, itemParams);
				itemsSprite.addChild(item);
				
				item.x = ((i) % cols) * (itemWidth) + itemToItemWidth * i;
				item.y = int((i) / cols) * (itemHeight);
				
				/*item.x = 95 * i - ;
				item.y = -10;*/
				
				if (i == 0)
					minY = item.y;
					
				if (i == Numbers.countProps(bonus)-1) 
					maxY = item.y + item.height;
				i++;
			}
			
			
			if (widthBacking == 0) {
				widthBacking = 10 + 100 * i;
			}
			
			backing = Window.backing(widthBacking, maxY - minY + title.height/*100 + title.height*/, 12, "bonusBacking");
			
			if(hasBacking){
				addChildAt(backing, 0);
				backing.y = title.height + 10;
				
				itemsSprite.x = (backing.width - itemsSprite.width) / 2;
				itemsSprite.y = backing.y + (backing.height - itemsSprite.height) / 2;
			}
			addChild(itemsSprite);
			
			title.x = (backing.width - title.width)/2;
			title.y = 10;
			addChild(title);
		}
		
		public function take():void{
			var childs:int = itemsSprite.numChildren;
			
			while(childs--) {
				var reward:RewardItem = itemsSprite.getChildAt(childs) as RewardItem;
				
				var item:BonusItem = new BonusItem(reward.sID, reward.count);
			
				var point:Point = Window.localToGlobal(reward);
				item.cashMove(point, App.self.windowContainer);
			}
		}
	}
}

import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class RewardItem extends LayerX
{
	private var icon:Bitmap;
	public var text:TextField;
	public var sID:uint;
	public var count:int;
	public var bg:Bitmap;
	public var bigBlink:Boolean = true;
	public var hasBackGround:Boolean = true;
	public var scale:Number = 0.8;
	public var bgParams:Object = {
			width:90,
			height:90,
			texture:'bonusBacking'
		}
	private var preloader:Preloader;
	
	public function RewardItem(sID:uint, count:int, params:Object = null)
	{
		icon = new Bitmap();
		this.sID = sID;
		this.count = count;
		
		
		if (params) {
			if(params.hasOwnProperty('hasBackGround'))
				hasBackGround = params.hasBackGround;
			if (params.hasOwnProperty('bgParams')){
				for (var t:* in params.bgParams) {
					bgParams[t] = params.bgParams[t];
				}
			}
			if (params.hasOwnProperty('bigBlink'))
				bigBlink = params.bigBlink;
			if (params.hasOwnProperty('scale'))
				scale = params.scale;
		}
		
		bg = Window.backing(bgParams.width, bgParams.height, 12, bgParams.texture);
		addChild(bg);
		bg.visible = hasBackGround;
		
		if (!params['disableCount']) {
			var txt:String = bigBlink?'x' + String(count):String(count);
			text = Window.drawText(txt,{
				fontSize:26,
				color:0x604729,
				borderColor:0xffffff,
				autoSize:"left"
			});
			text.height = text.textHeight;
			text.visible = false;
		}
		
		preloader = new Preloader();
		preloader.x = bg.width / 2;
		preloader.y = bg.height / 2 + 10;
		preloader.scaleX = preloader.scaleY = 0.8;
		addChild(preloader);
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad)
		
		tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			}
		}
	}
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		
		//icon.scaleX = icon.scaleY = scale;
		/*if(icon.height > 80)
		{
			var scale:Number = 80 / icon.height;
			icon.scaleX = icon.scaleY = scale;
		}*/
		Size.size(icon, bgParams.width, bgParams.height);
		
		icon.x = (bg.width - icon.width) / 2;
		icon.y = (bg.height - icon.height) / 2;
		addChild(icon);
		
		if (text) {
			text.x = bigBlink?(bg.width - text.width) * 2 / 3 + 30:(bg.width - text.width) / 2 + 30;
			text.y = bigBlink?bg.height * 2 / 3 - 25:bg.height - 35;
			text.visible = true;
			addChild(text);
		}
	}
}