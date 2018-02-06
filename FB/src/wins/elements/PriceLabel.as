package wins.elements 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class PriceLabel extends Sprite
	{
		public var icon:Bitmap;
		public var text:TextField;
		
		/**
		 * 
		 * @param	price	Объект цены
		 * @param	compareWithStock	Сравнивать со значением на складе
		 * @param	stockEnableColorize	Подсветить красным если не хватает
		 */
		public function PriceLabel(price:Object, compareWithStock:Boolean = false, stockEnableColorize:Boolean = false) 
		{
			if (!price) return;
			
			for (var id:* in price) {
				
				var count:String = price[id];
				var colors:Object = { color:0xffdc39, borderColor:0x6d4b15 };
				
				if (App.user.stock.count(id) < price[id]) {
					//if (compareWithStock) {
						//count = Locale.__e('flash:1382952380278', [App.user.stock.count(id), price[id]]);
					//}
					//
					//if (stockEnableColorize) {
					colors = { color:0xffffff, borderColor:0x7f4015 };
					//}
				}
				
				var priceItem:PriceItem = new PriceItem(id, count, colors);
				priceItem.y = 33 * numChildren;
				addChild(priceItem);
			}
			
		}	
		
	}

}
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

internal class PriceItem extends Sprite {
	
	public const SIZE:int = 25;
	
	private var tipLayer:LayerX;
	public var image:Bitmap;
	public var textLabel:TextField;
	public var sid:int;
	public var text:String;
	public var colors:Object;
	
	public function PriceItem(sid:int, text:String = '', colors:Object = null):void {
		
		this.sid = sid;
		this.text = text;
		this.colors = colors;
		
		tipLayer = new LayerX();
		addChild(tipLayer);
		tipLayer.tip = function():Object {
			return {
				title:	App.data.storage[sid].title,
				text:	App.data.storage[sid].description
			}
		}
		
		drawImage(sid);
		drawText(text);
	}
	
	public function drawImage(sid:int):void {
		var bmd:BitmapData;
		
		image = new Bitmap();
		tipLayer.addChild(image);
		
		switch(sid) {
			case Stock.FANT:
				bmd = UserInterface.textures.blueCristal;
				break;
			case Stock.COINS:
				bmd = UserInterface.textures.goldenPearl;
				break;
			case Stock.GUESTFANTASY:
				bmd = UserInterface.textures.guestAction;
				break;
			case Stock.FANTASY:
				bmd = UserInterface.textures.energyIcon;
				break;
			default:
				load();
		}
		
		if (bmd) {
			image.bitmapData = bmd;
			image.smoothing = true;
			image.y += 4;
			image.filters = [new GlowFilter(0xffffff, .7, 4, 4, 10)]; 
			Size.size(image, SIZE, SIZE);
		}
		
		function load():void {
			var preloader:Preloader = new Preloader();
			preloader.x = SIZE * 0.5;
			preloader.y = SIZE * 0.5;
			addChild(preloader);
			
			Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), function(data:Bitmap):void {
				if (preloader && contains(preloader))
					removeChild(preloader)
				
				image.bitmapData = data.bitmapData;
				image.smoothing = true;
				image.filters = [new GlowFilter(0xffffff, .7, 4, 4, 10)]; 
				Size.size(image, SIZE, SIZE);
			});
		}
	}
	
	public function drawText(text:String):void {
		var settings:Object = {
			fontSize:24,
			autoSize:"left",
			color:colors.color,
			borderColor:colors.borderColor
		}
		
		textLabel = Window.drawText(text, settings);
		textLabel.x = SIZE + 4;
		textLabel.y = 3;
		addChild(textLabel);
	}
	
}