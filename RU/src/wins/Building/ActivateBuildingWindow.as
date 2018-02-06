package wins.Building 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.MaterialItem;
	import wins.Window;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ActivateBuildingWindow extends Window 
	{
		private var _description:String;
		private var _textDescription:TextField;
		
		public var _confirmButton:Button;
		private var _cancelButton:Button;
		
		private var _activationMaterials:Object;
		
		private var _itemsContainer:Sprite;
		private var _materialItems:Vector.<MaterialItem>;
		private var character:Bitmap;
		
		public function ActivateBuildingWindow(activationMaterials:Object, settings:Object=null) 
		{
			settings["background"] = "helpWindowBacking";
			settings["multiline"] = true;
			settings["hasPaginator"] = false;
			settings["width"] = 400;
			settings["height"] = 400;
			settings["titleDecorate"] = false;
			if (settings["description"])
			{
				_description = settings["description"];
			}
			
			super(settings);
			_activationMaterials = activationMaterials;
		}
		
		private var preloader:Preloader = new Preloader();
		override public function drawBody():void 
		{
			super.drawBody();
			character = new Bitmap();
			drawDescription();
			drawItems();
			
			bodyContainer.addChild(preloader);
			preloader.x = -138;
			preloader.y = 184;
			
			_cancelButton = new Button({
				width:120,
				height:60,
				caption:Locale.__e("flash:1396963190624")
			});
			_cancelButton.x = (settings.width * .5) - _cancelButton.width - 15;
			_cancelButton.y = settings.height - _cancelButton.height - 30;
			_cancelButton.addEventListener(MouseEvent.CLICK, onCancelClick);
			//bodyContainer.addChild(_cancelButton);
			
			_confirmButton = new Button( {
				width:120,
				height:60,
				caption:Locale.__e("flash:1382952379786")
			} );
			_confirmButton.x = (settings.width * 0.5 - _confirmButton.width * 0.5);
			_confirmButton.y = settings.height - _cancelButton.height - 30;
			_confirmButton.addEventListener(MouseEvent.CLICK, onConfirmClick);
			bodyContainer.addChild(_confirmButton);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			updateButtons();
			darwWorkers();
		}
		private function darwWorkers():void
		{
			Load.loading(Config.getImageIcon('quests/preview', 'workers'), function(data:*):void { 
				if (bodyContainer.contains(preloader))
					bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				
				
				Size.size(character, 450, 550); // magic numbers
				character.x = -character.width * 0.5;
				character.y = -60;
				bodyContainer.addChildAt(character,0);
			});
		}
		override protected function onRefreshPosition(e:Event = null):void 
		{
			super.onRefreshPosition(e);
			if (character)
			{
				character.x = -character.width * 0.5;
				character.y = -60;
			}
		}
		private function onChangeStock(e:AppEvent):void 
		{
			updateButtons();
		}
		
		private function updateButtons():void
		{
			if ( hasAllMaterials())
				_confirmButton.state = Button.NORMAL;
			else
				_confirmButton.state = Button.DISABLED;
		}
		
		private function hasAllMaterials():Boolean
		{
			var result:Boolean = true;
			
			for (var key:String in _activationMaterials)
			{
				if (App.user.stock.count(int(key)) < _activationMaterials[key])
				{
					result = false;
					break;
				}
			}
			
			return result;
		}
		
		private function drawDescription():void 
		{
			_textDescription = Window.drawText(_description,
			{
				textAlign:"center",
				width:settings.width - 60,
				height:200,
				fontSize:22,
				wrap:true,
				miltiline:true
			});
			
			_textDescription.x = (settings.width - _textDescription.width) * 0.5;
			_textDescription.y = 25;
			bodyContainer.addChild(_textDescription);
			
			var separator:Bitmap = Window.backingShort(settings.width - 100, 'dividerLine', false);
			separator.x = settings.width * 0.5 - separator.width * 0.5;
			separator.y = _textDescription.y + _textDescription.height + 5;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
		}
		
		private function drawItems():void
		{
			if (!_itemsContainer)
			{
				_itemsContainer = new Sprite();
			}
			
			if (!_materialItems)
			{
				_materialItems = new Vector.<MaterialItem>();
			}
			
			var currentMaterialItem:MaterialItem;
			for (var key:String in _activationMaterials)
			{
				currentMaterialItem = new MaterialItem({sID:int(key), need:int(_activationMaterials[key]), type:MaterialItem.IN});
				currentMaterialItem.x = _materialItems.length * (currentMaterialItem.width + 5);
				currentMaterialItem.y = 15;
				_itemsContainer.addChild(currentMaterialItem);
				_materialItems.push(currentMaterialItem);
			}
			
			_itemsContainer.x = (settings.width - _itemsContainer.width) * 0.5;
			_itemsContainer.y = (settings.height - _itemsContainer.height) * 0.5;
			
			bodyContainer.addChild(_itemsContainer);
		}
		
		private function onCancelClick(e:MouseEvent):void 
		{
			dispatchEvent(new ActivateBuildingWindowEvent(ActivateBuildingWindowEvent.CANCEL_ACTIVATION));
			close();
		}
		
		private function onConfirmClick(e:MouseEvent):void 
		{
			dispatchEvent(new ActivateBuildingWindowEvent(ActivateBuildingWindowEvent.CONFIRM_ACTIVATION));
			close();
		}
		
		
		override public function dispose():void 
		{
			_cancelButton.removeEventListener(MouseEvent.CLICK, onCancelClick);
			_confirmButton.removeEventListener(MouseEvent.CLICK, onConfirmClick);
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			
			super.dispose();
		}
	}
}