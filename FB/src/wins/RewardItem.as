package wins 
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class RewardItem extends Sprite 
	{
		public var background:Bitmap
		public var bitmap:Bitmap
		public var countLabel:TextField;
		public var title:TextField;
		public var count:int;
		public var sID:int;
		
		private var iconCont:LayerX = new LayerX();
		
		private var settings:Object = {
			fontSize : 22,
			widthTxt : 100,
			titleColor:0x6d4b15,
			titleBorderColor:0xfcf6e4
		};
		
		public function RewardItem(sID:int, count:int, settings:Object = null)
		{
			this.count = count;
			this.sID = sID;
			
			if (settings != null) {
				for (var obj:* in settings) {
					if(settings[obj] != null)
						this.settings[obj] = settings[obj];
				}
			}
			
			
			
			background = Window.backing(110, 120, 10, "textBacking");
			//addChild(background);
			
			bitmap = new Bitmap(null, "auto", true);
			
			var item:Object = App.data.storage[sID];
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
			addChild(iconCont);
			
			iconCont.addChild(bitmap);
			
			iconCont.tip = function():Object {
				return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].description
				}
			} 
			
			drawCount();
			
			title = Window.drawText(item.title, {
				color:0x804926,
				borderColor:0xffffff,
				textAlign:"center",
				fontSize:24,
				multiline:true
				//word:true,
				//width:widthTxt
			});
			title.wordWrap = true;
			title.width = this.settings.widthTxt;
			title.height = title.textHeight + 5;
			title.y = -20;
			title.x = 5;
			//title.border = true;
			addChild(title);
		}
		
		
		public function drawCount():void {
			
			countLabel = Window.drawText(String(count), {
				fontSize		:32,
				color			:0xffffff,
				borderColor		:0x774702,
				autoSize:"center"
			});
			
			
			var width:int = countLabel.width + 24 > 30?countLabel.width + 24:30;
			var bg:Bitmap = Window.backing(width, 40, 10, "smallBacking");
			
			//addChild(bg);
			bg.x = (background.width - bg.width)/2;
			bg.y = background.height - 30;
			
			addChild(countLabel);
			countLabel.x = bg.x + (bg.width - countLabel.width) / 2;
			countLabel.y = bg.y + 20;
		}
		
		
		private function onLoad(data:*):void{
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true
			//bitmap.scaleX = bitmap.scaleY = 0.65
			
			//bitmap.x = (background.width - bitmap.width) / 2;
			//bitmap.y = (background.width - bitmap.height) / 2 + 5;
			
			iconCont.x = (background.width - bitmap.width) / 2;
			iconCont.y = (background.width - bitmap.height) / 2 + 5;
		}
	}

}