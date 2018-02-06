package wins.elements 
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import wins.Window;

	public class DiscountAction extends Sprite 
	{
		public static var RIBBON:int = 0;
		public static var NO_RIBBON:int = 1; 
		private var settings:Object = {
			mode: DiscountAction.NO_RIBBON
		};
		
		public function DiscountAction(_settings:Object = null)
		{
			for (var _par:* in _settings)
			{
				settings[_par] = _settings[_par]
			}
			//settings = _settings;
			drawBacking();
			drawDiscountActionIco();
			drawTitle();
			drawDiscount();
			
			checkPositions();
		}
		
		private function checkPositions():void
		{
			switch(settings.mode){
				case 0:
					percent.x = back.x + (back.width - percent.width) / 2;
					percent.y = back.y + (back.width - percent.width) / 2;
					percent.y += 15;
					
					title.x = back.x + (back.width - title.width) / 2;
					title.y = back.y + (back.width - title.width) / 2;
					title.y += 48;
					break;
				case 1:
					
					percent.x = back.x + (back.width - percent.width) / 2;
					percent.y = back.y + (back.width - percent.width) / 2;
					percent.x += 8;
					percent.y += 38;
					
					title.x = back.x + (back.width - title.width) / 2;
					title.y = back.y + (back.width - title.width) / 2;
					title.x += 8;
					title.y += 5;
					break;
			}
		}
		private var percent:TextField;
		private function drawDiscount():void
		{
			var textSettings:Object = {
				color:0xffe610,
				fontSize:32,
				borderColor:0x6f1700,
				textAlign:'center',
				width:100
			}
			
			percent = Window.drawText(String(settings.profit) + '%', textSettings);
			addChild(percent);
		}
		 
		private var title: TextField;
		private function drawTitle ():void
		{
			var textSettings:Object = {
				color:0xffffff,
				fontSize:24,
				borderColor:0x6f1700,
				textAlign:'center',
				width:100
			}
			
			title = Window.drawText(Locale.__e("flash:1450087466832"), textSettings);
			addChild(title);
		}
		
		private var back:Shape;
		private function drawBacking():void
		{
			back = new Shape();
			back.graphics.beginFill(0x0, 0);
			back.graphics.drawCircle(30, 30, 30);
			back.graphics.endFill();
			addChild(back);
		}
		
		private var discountActionsIco: Bitmap;
		private function drawDiscountActionIco(): void
		{
			discountActionsIco = new Bitmap();
			var preview:String = "";
			switch(settings.mode){
				case 0:
					preview = 'actionBack1_Reduced';
					break;
				case 1:
					preview = 'actionBack2';
					break;
			}
			Load.loading(Config.getImageIcon('promo/bg', preview), function(data:*):void {
				discountActionsIco.bitmapData = data.bitmapData;
				discountActionsIco.smoothing = true;
				discountActionsIco.x = back.x + (back.width - discountActionsIco.width) / 2;
				discountActionsIco.y = back.y + (back.height - discountActionsIco.height) / 2;

			});
			addChild(discountActionsIco);
		}
	}
}