package wins.petWindow 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.MaterialItem;
	import wins.Window;
	
	/**
	 * ...
	 * @author ...
	 */
	public class PetFoodItem extends MaterialItem 
	{
		
		private var _applyBttn:Button;
		public function get applyBttn():Button 
		{
			return _applyBttn;
		}
		public function PetFoodItem(settings:Object) 
		{
			//titleColor = settings.color || 0xFAFFFF;
			//titleBorderColor = settings.borderColor || 0x683E0C;
			//backingColor = settings.backingColor || 0x683E0C;
			//backingRadius = settings.backingRadius || 70;
			
			settings.color = settings.color || 0xFAFFFF;
			settings.borderColor = settings.borderColor || 0x683E0C;
			settings.backingColor = settings.backingColor || 0xF6E4D0;
			settings.backingRadius = settings.backingRadius || 85;
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, checkStatus);
			//_dY = 25;
			super(settings);
			drawFoodCount();
			checkStatus();
		}
		
		// Назване с админки
		override protected function drawTitle():void 
		{
			title = Window.drawText(App.data.storage[sID].title, {
				color:			0x6e411e,
				border:			false,
				//borderColor:	titleBorderColor,
				textAlign:		"center",
				autoSize:		"center",
				fontSize:		24,
				textLeading:	-6,
				multiline:		true,
				wrap:			true,
				width:			130
			});
			
			title.x = background.x + (background.width - title.width) / 2;
			title.y = background.y - title.textHeight;
			addChild(title);
		}
		
		override protected function drawBttns():void 
		{
			if (type == MaterialItem.IN)
			{
				wishBttn = new ImageButton(Window.textures.wishlistBttn);
				
				searchBttn = new ImageButton(Window.textures.showMeBttn);
				
				askBttn = new Button({
					caption		:Locale.__e("flash:1407231372860"),
					radius      :16,
					fontColor:0xffffff,
					fontBorderColor:0x085c10,
					bgColor:[0xc7e314,0x84b92f],
					//borderColor:[0xa0d5f6, 0x3384b2],
					bevelColor:[0xdef58a, 0x698e2a],
					width		:121,
					height		:42,
					fontSize	:22
				});
				
				askBttn.x = (background.width - askBttn.width) / 2;
				askBttn.y = background.y + background.height + 8;
				
				buyBttn = new MoneyButton({
					caption		:Locale.__e('flash:1382952379751'),
					width		:121,
					height		:42,
					fontSize	:22,
					radius		:16,
					countText	:0,
					multiline	:true
				});
				
				buyBttn.updatePos();
				buyBttn.x = (background.width - buyBttn.width) / 2;
				buyBttn.y = askBttn.y + askBttn.height + 10;
				
				
				if (!App.user.quests.tutorial && (App.data.storage[sID].mtype != 6 || Config.admin)) 
				{
					addChild(buyBttn);
				}
				
				buyBttn.addEventListener(MouseEvent.CLICK, buyEvent);	
				
				addChild(askBttn);
				if (App.user.quests.tutorial) 
				{
					askBttn.y += 10;
					askBttn.name = 'seach_bttn';
				}
				
				askBttn.addEventListener(MouseEvent.CLICK, searchEventNew);
			}
			
			searchBttn.tip = function():Object
			{
				return {text: Locale.__e('flash:1425981456235')}
			}
			
			_applyBttn = new Button( { 
				caption		:Locale.__e('flash:1469455530021'),
				width		:112,
				height		:44,
				fontSize	:22,
				radius		:16,
				multiline	:false,
				eventPostManager:true
			} );
			
			_applyBttn.x = background.x + (background.width - _applyBttn.width) * 0.5;
			_applyBttn.y = buyBttn.y;
			_applyBttn.addEventListener(MouseEvent.CLICK, onApplyButtonClick);
			
			addChild(_applyBttn);
		}
		public function showGlowing(more:Boolean = false):void 
		{
			_applyBttn.showGlowing();
			//super.showGlowing(more);
		}
		
		public var unitToFind:Array;
		
		private function searchEventNew(e:*):void{
			Window.closeAll();
			unitToFind = Map.findUnits([1722]);
			App.map.focusedOn(unitToFind[0], false, function():void{
				unitToFind[0].click();
			});
		}
		
		private function onApplyButtonClick(e:MouseEvent):void 
		{
			dispatchEvent(new Event(Event.SELECT));
			_applyBttn.state = Button.DISABLED;
		}
		
		override public function checkStatus(e:* = null):void 
		{
			super.checkStatus();
			if(App.user.stock.count(sID) < need)
				_applyBttn.visible = false;
			else
				_applyBttn.visible = true;
		}
		
		override public function dispose():void 
		{
			if (_applyBttn)
				_applyBttn.removeEventListener(MouseEvent.CLICK, onApplyButtonClick);
				
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, checkStatus);
			
			super.dispose();
		}
		
		private function drawFoodCount():void
		{
			var textFoodCount:TextField = Window.drawText("+" + String(App.data.storage[sID].count),
			{
				width		:100,
				fontSize	:24,
				multiline	:true,
				wrap		:true,
				textAlign	:"left",
				color		:0xf6d347,
				borderColor	:0x7b270e
			});
			var petFoodIcon:Bitmap = new Bitmap();
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].view),
			function(data:Bitmap):void
			{
				petFoodIcon.bitmapData = data.bitmapData;
				petFoodIcon.x = background.width - 30;
				petFoodIcon.y = background.height - 55;
				petFoodIcon.scaleX = petFoodIcon.scaleY = 0.5;
				
				textFoodCount.x = petFoodIcon.x + petFoodIcon.width - 10;
				textFoodCount.y = petFoodIcon.y + 11;
				//if (_bitmap)
				//{
					//_bitmap.bitmapData = data.bitmapData;
					//Size.size(_bitmap, 40, 40);
				//}
				
			});
			addChild(petFoodIcon);
			addChild(textFoodCount);
			
		}
		
	}
}