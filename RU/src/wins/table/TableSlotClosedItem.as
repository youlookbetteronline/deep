package wins.table 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import silin.filters.ColorAdjust;
	import units.Table;
	import wins.SelectAnimalWindow;
	import wins.SelectMaterialWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class TableSlotClosedItem extends TableSlotItem 
	{
		private var _bttnOpen:MoneyButton;
		private var _selectMaterialWindow:SelectMaterialWindow;
		private var _placeholder:Bitmap;
		
		public function TableSlotClosedItem(target:Table, slotID:int) 
		{
			super(target, slotID);
		}
		
		override protected function drawbody():void 
		{
			_bg = Window.backing(145, 165, 50, "itemBacking");
			addChild(_bg);
			
			_placeholder = new Bitmap(Window.textures["redRibbonItem"]);
			_placeholder.x = (width - _placeholder.width) * 0.5;
			_placeholder.y = (height - _placeholder.height) * 0.5 - 10;
			_placeholder.alpha = 0.5;
			addChild(_placeholder);
			
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(0.25);
			mtrx.brightness(-0.2);
			_bg.filters = [mtrx.filter];
			
			_placeholder.filters = [mtrx.filter];
			
			_bttnOpen = new MoneyButton( {
				width:120,
				height:45,	
				caption:Locale.__e("flash:1382952379890"),
				countText:_currentSlot.openPrice.toString()
			});
			
			_bttnOpen.x = (width - _bttnOpen.width) * 0.5;
			_bttnOpen.y = height - (_bttnOpen.height * 0.5);
			
			_bttnOpen.addEventListener(MouseEvent.CLICK, onBttnOpenClick);
			addChild(_bttnOpen);
		}
		
		private function onBttnOpenClick(e:MouseEvent):void 
		{	
			if (_bttnOpen.mode == Button.DISABLED)
				return;
			
			if (App.user.stock.check(Stock.FANT, _currentSlot.openPrice))
			{
				_bttnOpen.state = Button.DISABLED;
				dispatchEvent(new TableSlotItemEvent(TableSlotItemEvent.OPEN_SLOT, 0, 0, _slotID));
			}
		}
		
		override public function dispose():void 
		{
			_bttnOpen.removeEventListener(MouseEvent.CLICK, onBttnOpenClick);
			super.dispose();
		}
		
	}

}