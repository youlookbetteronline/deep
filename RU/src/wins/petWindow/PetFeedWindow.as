package wins.petWindow
{
	import buttons.ImageButton;
	import com.adobe.net.URIEncodingBitmap;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import units.Pet;
	import wins.ExpeditionHintWindow;
	import wins.InfoWindow;
	import wins.MaterialItem;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class PetFeedWindow extends Window 
	{
		private static const MAX_ITEMS_ON_PAGE:int = 4;
		private static const TEXT_BORDER:uint = 10;
		private static const TEXT_HEIGHT:uint = 50;
		private var _pet:Pet;
		private var _itemsContainer:Sprite;
		private var _helpButton:ImageButton;
		
		private var _data:Array;
		private var _items:Vector.<PetFoodItem>;
		
		private var _textDescription:TextField;
		private var _textBonusesLeft:TextField;
		private var _textPickActions:TextField;
		private var _textBonusesLeftValue:TextField;
		private var whiteBg:Shape;
		
		public function PetFeedWindow($pet:Pet, $settings:Object=null) 
		{
			_pet = $pet;
			$settings['background'] = 'capsuleWindowBacking';
			$settings['title'] = $pet.info.title;
			$settings["width"] = 850;
			$settings["height"] = 430;
			$settings["itemsOnPage"] = MAX_ITEMS_ON_PAGE;
			$settings['exitTexture'] = 'closeBttnMetal';
			$settings['fontBorderColor'] = 0x085c10;
			_data = Pet.petFoods;
			super($settings);
		}
		
		override public function createPaginator():void 
		{
			super.createPaginator();
			paginator.onPageCount = MAX_ITEMS_ON_PAGE;
			paginator.itemsCount = _data.length;
			paginator.visible = !(paginator.itemsCount <= paginator.onPageCount);
		}
		
		override public function drawExit():void 
		{
			super.drawExit();
			_helpButton = new ImageButton(Window.textures["aksBttnNew"]);
			_helpButton.x -= 10;
			_helpButton.y -= 10;
			_helpButton.addEventListener(MouseEvent.CLICK, onHelpClick);
			headerContainer.addChild(_helpButton);
			exit.y -= _helpButton.y + 35;
			exit.x = settings.width - exit.width + 15;
		}
		
		private function onHelpClick(e:MouseEvent):void 
		{
			var hintWindow:ExpeditionHintWindow = new ExpeditionHintWindow({
				popup		:true,
				hintsNum	:3,
				hintID		:3,
				height		:540
			});
			hintWindow.show();	
		}
		
		override public function drawBackground():void 
		{
			super.drawBackground();
			var paper:Bitmap = new Bitmap();
			paper = backing(settings.width - 85, settings.height - 85, 46, 'paperGlow');
			paper.x = (settings.width - paper.width) / 2;
			paper.y = (settings.height - paper.height) / 2;
			layer.addChild(paper);
		}
		
		override public function drawBody():void 
		{
			super.drawBody();
			drawRibbon();
			titleLabel.y = titleBackingBmap.y;
			
			initTextDescription();
			initTextBonusLeft();
			initTextPickAction();
			initTextBonusValue();
			_itemsContainer = new Sprite();
			bodyContainer.addChild(_itemsContainer);
			contentChange();
			paginator.x = (settings.width - paginator.width) * 0.5 - 35;
			if (settings.glowFeedItems) {
				glowFeedItems();
			}
			
			
			
			whiteBg = new Shape();
			whiteBg.graphics.beginFill(0xffffff, 0.65);
			whiteBg.graphics.drawRect(0, 0, settings.width - 200, 270);
			whiteBg.x = (settings.width - whiteBg.width) / 2;
			whiteBg.y = _itemsContainer.y + 70;
			whiteBg.graphics.endFill(); 
			whiteBg.filters = [new BlurFilter(80, 0, 2)];
			layer.addChild(whiteBg);
			
		}
		
		private function initTextDescription():void 
		{
			_textDescription = Window.drawText(_pet.info.description, 
			{
				width		:settings.width - 100,
				fontSize	:24,
				multiline	:true,
				wrap		:true,
				textAlign	:"center",
				color		:0x7B3917,
				borderColor	:0xFBF1F0
			});
			_textDescription.x = (settings.width - _textDescription.width) * 0.5;
			_textDescription.y = 40;
		}
	
		
		private function initTextBonusLeft():void 
		{
			_textBonusesLeft = Window.drawText(Locale.__e("flash:1393581955601"), 
				{
					width			:115,
					fontSize		:35,
					textAlign		:"left",
					color			:0xffce48,
					borderColor		:0x7e3e14
				});
			bodyContainer.addChild(_textBonusesLeft);
		}
		
		private function initTextBonusValue():void 
		{
			_textBonusesLeftValue = Window.drawTextX(_pet.bountiesLeft.toString(),
				60,
				TEXT_HEIGHT * 2,
				0,
				0,
				bodyContainer,
					{fontSize:(App.lang == 'jp')?28:34,
					textAlign:"center",
					color:0xFBF1F0,
					borderColor:0x7B3917});
		}
		
		private function initTextPickAction():void 
		{
			_textPickActions = Window.drawText(Locale.__e("flash:1469521503656"),
				{
					width			:155,
					fontSize		:30,
					textAlign		:"left",
					color			:0xFBF1F0,
					borderColor		:0x7B3917
				});
			bodyContainer.addChild(_textPickActions);
		}
		
		private function glowFeedItems():void
		{
			for each (var ins:PetFoodItem in _items)
			{
				if (ins.status == MaterialItem.READY) 
				{
					ins.showGlowing();
				}
			}
		}
		
		override public function contentChange():void 
		{	
			disposeItems();
			updateItems();
			updateItemsContainer();
			updateBottomTextsPosition();
			updateBonusTextValue();
		}
		
		private function updateItems():void 
		{
			_items = new Vector.<PetFoodItem>();
			
			paginator.pages = 	(_data.length % MAX_ITEMS_ON_PAGE > 0) ? 
								(_data.length / MAX_ITEMS_ON_PAGE) + 1 : 
								(_data.length / MAX_ITEMS_ON_PAGE);
								
			var endIndex:int = _data.length;
			var itemSettings:Object = { type:MaterialItem.IN, need:1};
			var currentItem:PetFoodItem;
			for (var j:int = paginator.startCount; j < endIndex; j++) 
			{
				itemSettings["sID"] = _data[j];
				currentItem = new PetFoodItem(itemSettings);
				currentItem.addEventListener(Event.SELECT, onItemSelect);
				currentItem.x = _items.length * (currentItem.background.width + 75);
				currentItem.y = 90;
				_itemsContainer.addChild(currentItem);
				_items.push(currentItem);
			}
		}
		
		private function updateItemsContainer():void 
		{
			_itemsContainer.x = 105;
			_itemsContainer.y = -5;
			_textBonusesLeftValue.text = _pet.bountiesLeft.toString();
			_textBonusesLeftValue.text = "9";
		}
		
		private function updateBottomTextsPosition():void 
		{
			_textBonusesLeft.x = settings.width / 2 - _textBonusesLeft.width - 45;
			_textBonusesLeft.y = settings.height - _textBonusesLeft.height - 72;
			
			_textPickActions.x = settings.width / 2 + _textBonusesLeftValue.width - 45;
			_textPickActions.y = _textBonusesLeft.y + 4;
		}
		
		private function updateBonusTextValue():void 
		{
			bodyContainer.removeChild(_textBonusesLeftValue);
			initTextBonusValue();
			_textBonusesLeftValue.x = settings.width / 2 - 55;
			_textBonusesLeftValue.y = _textBonusesLeft.y + 1;
		}
		
		private function onItemSelect(e:Event):void 
		{
			var foodID:int = PetFoodItem(e.currentTarget).sID;
			var needCount:int = PetFoodItem(e.currentTarget).need;
			_pet.feed(foodID, true, contentChange);
		}
		
		override public function dispose():void 
		{
			disposeItems();
			disposeHelpButton();
			super.dispose();
		}
		
		private function disposeItems():void
		{
			if (_items && _items.length > 0)
			{
				for each( var currentItem:PetFoodItem in _items)
				{
					currentItem.removeEventListener(Event.SELECT, onItemSelect);
					_itemsContainer.removeChild(currentItem);
					currentItem.dispose();
					currentItem = null;
				}
			}
			_items = null;
		}
		
		private function disposeHelpButton():void 
		{
			_helpButton.removeEventListener(MouseEvent.CLICK, onHelpClick);
			_helpButton = null;
		}
	}
}