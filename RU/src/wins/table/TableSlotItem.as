package wins.table 
{
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.text.TextField;
	import units.Table;
	import units.table.TableSlot;
	import wins.Window;
	
	public class TableSlotItem extends LayerX 
	{
		protected var _target:Table;
		protected var _slotID:int;		
		protected var _currentSlot:TableSlot;		
		protected var _priceFactor:Number;
		protected var _sellTime:int;		
		protected var _bg:Bitmap;
		
		public function TableSlotItem(target:Table, slotID:int) 
		{
			super();
			
			_target = target;
			_slotID = slotID;
			
			_currentSlot = _target.slots[slotID - 1];
			
			_priceFactor = _currentSlot.priceFactor;
			_sellTime = _currentSlot.sellTime;
			
			drawbody();
		}
		
		protected function drawbody():void
		{
			//_bg = Window.backing(165, 165, 40, "itemBacking");
			_bg = new Bitmap(Window.textures.tablePlate);
			//_bg.visible = false;
			_bg.y = 40;
			addChild(_bg);
		}
		
		public function dispose():void
		{			
		}
	}
}