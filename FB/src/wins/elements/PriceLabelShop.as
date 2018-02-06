package wins.elements 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class PriceLabelShop extends Sprite
	{
		public var icon:Bitmap;
		public var text:TextField;
		
		private var num:int = 0;
		
		public function PriceLabelShop(price:Object) 
		{
			if (price == null) return;
			var count:int = 0;
			for (var sID:* in price) {
				count = price[sID];
			
				if (sID == null) return;
				switch(sID) {
					case Stock.COINS:
						icon = new Bitmap(UserInterface.textures.goldenPearl, "auto", true);
						icon.height = 30;
						break;
					//case Stock.FANTASY:
					case Stock.FANT:
						icon = new Bitmap(UserInterface.textures.blueCristal, "auto", true);
						icon.height = 30;
						break;	
					case Stock.FANTASY:
						continue;
						//icon = new Bitmap(UserInterface.textures.energyIcon, "auto", true);
						//icon.height = 30;
						break;	
					case App.data.storage[App.user.worldID].techno[0]:
						continue;
						break;	
					default:
						icon = new Bitmap();
				}
				
				addChild(icon);
				
				var settings:Object = {
						fontSize:24,
						autoSize:"left",
						color:0xffdc39,
						borderColor:0x6d4b15
					}
					
				if (sID == Stock.FANT)
				{
					settings["color"]	 	= 0xcaebfc;
					settings["borderColor"] = 0x25216e;
				}
				
				if (sID == Stock.FANTASY)
				{
					settings["color"]	 	= 0xfefdcf;//0xfebde8;
					settings["borderColor"] = 0x775002;//0x9b174b;
				}
				
				text = Window.drawText(String(count), settings);
				
				addChild(text);
				text.height = text.textHeight;
				
				
				icon.scaleX = icon.scaleY;
				icon.smoothing = true;
				
				icon.x = 6;
				icon.y = -10 - (icon.height +2) * num;
				
				text.x = icon.width + 8;
				//text.y = icon.height / 2 - text.textHeight / 2 - (text.height-2) * num;
				text.y = icon.y + 2;
				
				num++;
				
			}
		
			if (num == 1) {
				icon.y -= 20;
				text.y -= 20;
			}
		}
		
		public function getNum():int
		{
			return num;
		}
		
	}

}