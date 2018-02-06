package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	public class CapsuleItem extends MaterialItem 
	{
		public static const IN:int = 1;
		public static const OUT:int = 2;
		public static const READY:int = 1;
		public static const UNREADY:int = 2;
		
		public function CapsuleItem(settings:Object, bg:Bitmap=null) 
		{
			super(settings, bg);
			
		}
		
		override protected function drawBttns():void
		{
			if (type == MaterialItem.IN)
			{
				/*searchBttn = new ImageButton(Window.textures.showMeBttn);
				searchBttn.scaleX = searchBttn.scaleY = 0.7;
				searchBttn.scaleX = searchBttn.scaleY = .9;
				searchBttn.x = 0;
				searchBttn.y = 25;
				addChild(searchBttn);
				searchBttn.addEventListener(MouseEvent.CLICK, askEvent);*/	
			}else
			{
				if (outCount > 1)
				{
					var outCount_txt:TextField = Window.drawText("x "+String(outCount),{
						fontSize		:20,
						color			:0xffdc39,
						borderColor		:0x6d4b15,
						textAlign:"right"
					});
					
					outCount_txt.width = 140;					
					addChild(outCount_txt);
					outCount_txt.x = 10;
					outCount_txt.y = 125;					
				}						
				
				cookBttn = new Button({
					caption:Locale.__e('flash:1382952380036'),
					width:116,
					height:36,
					radius:25,
					shadow:true
				});
				
				cookBttn.x = background.width / 2 - cookBttn.width / 2;
				cookBttn.y = 174;				
				addChild(cookBttn);
			}
			
			/*searchBttn.tip = function():Object
			{								
				return {text: Locale.__e('flash:1425981456235')}				
			}*/			
		}
		
		override public function changeOnUNREADY():void
		{			
			status = MaterialItem.UNREADY;
			countContainer.y = background.height - countContainer.height - 30 ;
			var filter:GlowFilter = new GlowFilter(0x713f15, 1, 4, 4, 2, 1);
			var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90, 0x713f15,1,1,1,8,1);			
			
			if (
				App.data.storage[sID].type != 'Building' && 
				App.data.storage[sID].type != 'Guide' &&
				App.data.storage[sID].type != 'Bridge' &&
				App.data.storage[sID].type != 'Dock' &&
				App.data.storage[sID].type != 'Floors' &&
				App.data.storage[sID].type != 'Techno' 
				){				
				
				//searchBttn.visible = false;
			}else{
				//searchBttn.visible = false;
			}
			
			if (info.mtype == 3)
			{
				//searchBttn.visible = false;
			}
		}
		
		override public function drawCount():void
		{			
		}
		
		override public function drawBitmap():void
		{
			
			sprTip.tip = function():Object {
				return {
					title: info.title,
					text: info.description
				};
			}
			
			bitmap = new Bitmap();
			sprTip.addChild(bitmap);
			addChild(sprTip);
			
			/*if (App.user.stock.count(sID) < need) {
				setTimeout(setPluck, 2000);
			}*/
			
			addChild(preloader);
			preloader.x = (background.width) / 2;
			preloader.y = (background.height) / 2;
			Load.loading(Config.getIcon(info.type, info.preview), onPreviewComplete);
		}
		
		override public function setText(type:String, txt:*):void
		{			
		}
		
		/*override public function askEvent(e:MouseEvent):void
		{			
			new SimpleWindow( {
				height:		300,
				text:		App.data.storage[sID].description,
				popup:		true
			}).show();
		}*/
		
		override public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			bitmap.scaleX = bitmap.scaleY = 0.7;
			sprTip.x = (background.width - bitmap.width)/ 2;
			sprTip.y = (background.height - bitmap.height) / 2 + bitmapDY;
			
			if (bgItem)
			{				
				sprTip.addChildAt(bgItem, 0);
				bitmap.x = bgItem.x + (bgItem.width - bitmap.width) / 2;
				bitmap.y = (bgItem.height - bitmap.height) / 2;
			}
			
			var count:uint = App.user.stock.count(sID);
			
			if (count == 0) 
			{  
				bitmap.alpha = 0.2;
				var glowFilter:GlowFilter = new GlowFilter(0x000000, 1, 6, 6, 2, 1);
				bitmap.filters = [glowFilter];
			}else {
				bitmap.alpha = 1;
			}
		}
		
		override public function changeOnREADY():void
		{
			//searchBttn.visible = false;
			status = MaterialItem.READY;
		}
	}
}