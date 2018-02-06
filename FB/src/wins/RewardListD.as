package wins
{
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class RewardListD extends Sprite 
	{
		public var fruits:Array;
		public var counts:Array;
		public var backing:Bitmap;
		public var title:TextField;
		public var cols:int = 20;
		public var itemWidth:int = 95;
		public var itemHeight:int = 95;
		public var itemHasBacking:Boolean = false;
		public var itemIsGardener:Boolean = false;
		private var itemsSprite:Sprite = new Sprite();
		private var params:Object = { };
		
		public function RewardListD(fruits:Array, counts:Array, hasBacking:Boolean = true, widthBacking:int = 0, params:Object = null, text:String = "flash:1428416396057")
		{
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
				cols = fruits.length;
			else
				cols = params.cols;
			if (params && params.hasOwnProperty('itemHasBacking'))
				itemHasBacking = params.itemHasBacking;
			
			if (params && params.hasOwnProperty('itemIsGardener'))
				itemIsGardener = params.itemIsGardener;
			
			if (params && params.hasOwnProperty('itemWidth'))
				itemWidth = params.itemWidth;
			if (params && params.hasOwnProperty('itemHeight'))
				itemHeight = params.itemHeight;
			
			
			var itemParams:Object = { hasBackGroung:itemHasBacking, bgParams: { width:itemWidth, height:itemHeight, texture:'itemBacking' }, isGardener:itemIsGardener};
			
			for (var s:int = 0; s < fruits.length; s++) {
				var item:RewardItem = new RewardItem(fruits[s], counts[s], itemParams);
				itemsSprite.addChild(item);
				
				item.x = ((i) % cols) * (itemWidth + 8);
				item.y = int((i) / cols) * (itemHeight);
				
				if (i == 0)
					minY = item.y;
				
				if (i == fruits.length - 1) 
					maxY = item.y + item.height;
				i++;
			}
			
			
			if (widthBacking == 0) {
				widthBacking = 10 + 100 * i;
			}
			
			backing = Window.backing(widthBacking, maxY - minY + title.height, 12, "bonusBacking");
			
			if(hasBacking) {
				addChildAt(backing, 0);
				backing.y = title.height + 10;
			}
			addChild(itemsSprite);
			
			itemsSprite.x = (backing.width - itemsSprite.width) / 2;
			itemsSprite.y = backing.y + (backing.height - itemsSprite.height) / 2;
			
			title.x = (backing.width - title.width)/2;
			title.y = 10;
			addChild(title);
		}
	}
}

import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.text.TextField;
import wins.Window;

internal class RewardItem extends LayerX {
	
	private var icon:Bitmap;
	public var textCount:TextField;
	//public var textTitle:TextField;
	public var textEmpty:TextField;
	public var sID:uint;
	public var count:int;
	public var bg:Bitmap;
	public var hasBackGround:Boolean = false;
	public var isGardener:Boolean = false;
	private var preloader:Preloader;
	public var bgParams:Object = {
			width:90,
			height:90,
			texture:'bonusBacking'
	}
	
	public function RewardItem(sID:uint, count:int, params:Object = null) {
		icon = new Bitmap();
		this.sID = sID;
		this.count = count;
		if (params) {
			hasBackGround = true
			if(params.hasOwnProperty('hasBackGround'))
				hasBackGround = params.hasBackGround;
			
			if (params.hasOwnProperty('isGardener')) {
				isGardener = params.isGardener;
			}
			
			if (params.hasOwnProperty('bgParams')){
				for (var t:* in params.bgParams) {
					bgParams[t] = params.bgParams[t];
				}
			}
		}
		
		bg = Window.backing(bgParams.width, bgParams.height, 12, bgParams.texture);
		addChild(bg);
		bg.visible = hasBackGround;
		
		/*textTitle = Window.drawText(String(App.data.storage[sID].title), {
			fontSize:24,
			color:0x773c18,
			borderColor:0xfaf9ec,
			autoSize:"left",
			textAlign:"center",
			width:120,
			multiline:true
		});
		textTitle.wordWrap = true;
		textTitle.visible = false;*/
		
		textCount = Window.drawText('x' + String(count), {
			fontSize:25,
			color:0xffffff,
			borderColor:0x443632,
			autoSize:"left"
		});
		textCount.visible = false;
		
		if (sID == 0) {
			textEmpty = Window.drawText(Locale.__e("flash:1438873367929"), {	
				fontSize:24,
				color:0xfbffff,
				borderColor:0x7f5032,
				autoSize:"left",
				textAlign:"center",
				width:80
			});
			textEmpty.x = (bg.width - textEmpty.width) / 2;
			textEmpty.y = (bg.height - textEmpty.height) / 2;
			addChild(textEmpty);
		} else {
			preloader = new Preloader();
			preloader.x = bg.width / 2;
			preloader.y = bg.height / 2;
			preloader.scaleX = preloader.scaleY = 0.8;
			addChild(preloader);
			
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad)
		}
	}
	
	private function onLoad(data:Bitmap):void {
		removeChild(preloader);
		
		icon.bitmapData = data.bitmapData;
		Size.size(icon, 110, 110);
		icon.smoothing = true;
		icon.x = (bg.width - icon.width) / 2;
		icon.y = (bg.height - icon.height) / 2 - 5;
		
		//textTitle.x = (bg.width - textTitle.width) / 2;
		//textTitle.y = 10;
		//textTitle.visible = true;
		
		textCount.x = bg.width - textCount.width - 16;
		textCount.y = bg.height - 40;
		textCount.visible = true;
		
		addChild(icon);
		//addChild(textTitle);
		addChild(textCount);
		
		if (isGardener) {
			//textTitle.visible = false;
			textCount.borderColor = 0x6a2c17;
			textCount.x = bg.width - textCount.width - 12;
			textCount.y = bg.height - 36;
			Size.size(icon, 84, 84);
			icon.x = (bg.width - icon.width) / 2;
			icon.y = (bg.height - icon.height) / 2;
		}
	}
}