package wins.table 
{
	import buttons.Button;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import units.Table;
	import wins.PriceFactor;
	import wins.SelectAnimalWindow;
	import wins.SelectMaterialWindow;
	import wins.Window;
	import wins.WindowEvent;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TableSlotEmptyItem extends TableSlotItem 
	{
		private var _bttnSelectMaterial:Button;
		public function get bttnSelectMaterial():Button 
		{
			return _bttnSelectMaterial;
		}
		
		private var _selectMaterialWindow:SelectMaterialWindow;
		public function get selectMaterialWindow():SelectMaterialWindow 
		{
			return _selectMaterialWindow;
		}
		
		private var _placeholder:Bitmap;
		
		public function TableSlotEmptyItem(target:Table, slotID:int) 
		{
			super(target, slotID);
		}
		
		override protected function drawbody():void 
		{
			super.drawbody();
			
			/*_placeholder = new Bitmap(Window.textures["octopusCook"]);
			_placeholder.x = (width - _placeholder.width) * 0.5;
			_placeholder.y = (height - _placeholder.height) * 0.5 - 10;
			_placeholder.alpha = 0.5;
			addChild(_placeholder);*/
			
			_bttnSelectMaterial = new Button( {
				width:120,
				height:45,	
				caption:Locale.__e("flash:1382952379978"),
				fontSize:22
			});
			
			_bttnSelectMaterial.x = (width - bttnSelectMaterial.width) * 0.5;
			_bttnSelectMaterial.y = _bg.y + _bg.height + 20;//height - (_bttnSelectMaterial.height * 0.5);
			
			_bttnSelectMaterial.addEventListener(MouseEvent.CLICK, onBttnSelectMaterialClick);
			addChild(_bttnSelectMaterial);
			
			tip = tips;
		}
		
		private function tips():Object
		{
			return {
				text:Locale.__e("flash:1464963482132")//Здесь можно выбрать блюдо и поставить на продажу.
			}
		}
		
		public var fishMaterialSid:int;
		public var fishMaterialCount:int;
		public var priceFactors:Vector.<PriceFactor> = new Vector.<PriceFactor>();
		
		private function outItemsPush(id:int):Array
		{
			var curMat:Object = App.data.storage[id];
			var table:Object = {};
			var infoo:Array = [];
			table = App.data.storage[_target.sid];
			var fishID:int = 0;
			
			for (var f:* in table["in"])
			{
				if (f == id) 
				{
					fishID = table["in"][f]
				}
			}
			
			fishMaterialSid = App.data.treasures[App.data.storage[fishID].treasure][App.data.storage[fishID].treasure].item[0];
			fishMaterialCount = App.data.treasures[App.data.storage[fishID].treasure][App.data.storage[fishID].treasure].count[0];
			infoo.push(fishMaterialSid);
			infoo.push(fishMaterialCount);
			
			return infoo;
		}
		
		private function onBttnSelectMaterialClick(e:MouseEvent):void 
		{
			var priceFactors:Vector.<PriceFactor> = new Vector.<PriceFactor>();
			var items:Array = [];
			for each (var itemID:int in _target.acceptedMaterials) 
			{
				items.push(itemID);
			}
			
			var itemsSort:Function = function(item1:int, item2:int):int {
				if (App.user.stock.count(item1) > App.user.stock.count(item2))
				{
					return -1;
				}
				else
				{
					return 1;
				}
			}
			items.sort(itemsSort);
			
			var _selectMaterialWindowTEST:SellMaterialWindow = new SellMaterialWindow(priceFactors, _currentSlot.maxMaterialCount, _currentSlot.sellTime,  { items:items, priceTitle:Locale.__e("flash:1382952380034") } );
			
			
			var arr:Array = new Array(outItemsPush(_selectMaterialWindowTEST.currentMaterialID));
			priceFactors.push(new PriceFactor(arr[0][0], arr[0][1]));
			_selectMaterialWindow = new SellMaterialWindow(priceFactors, _currentSlot.maxMaterialCount, _currentSlot.sellTime,  { items:items, priceTitle:Locale.__e("flash:1382952380034") } );
			_selectMaterialWindow.addEventListener(Event.COMPLETE, onSelectComplete);
			_selectMaterialWindow.addEventListener(Event.CHANGE, onMaterialChange);
			_selectMaterialWindow.addEventListener(WindowEvent.ON_AFTER_CLOSE, onSelectCanceled);
			_selectMaterialWindow.show();
		}
		
		private function onMaterialChange(e:Event):void 
		{
			var priceFactors:Vector.<PriceFactor> = new Vector.<PriceFactor>();
			var arr:Array = new Array(outItemsPush(_selectMaterialWindow.currentMaterialID));
			
			priceFactors.push(new PriceFactor(arr[0][0], arr[0][1]));
			
			_selectMaterialWindow.priceFactors = priceFactors;
		}
		
		private function onSelectCanceled(e:WindowEvent):void 
		{
			_selectMaterialWindow.removeEventListener(Event.COMPLETE, onSelectComplete);
			_selectMaterialWindow.removeEventListener(Event.CHANGE, onMaterialChange);
			_selectMaterialWindow.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onSelectCanceled);
		}
		
		private function onSelectComplete(e:Event):void 
		{
			_selectMaterialWindow.removeEventListener(Event.COMPLETE, onSelectComplete);
			_selectMaterialWindow.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onSelectCanceled);
			
			var mID:int = _selectMaterialWindow.currentMaterialID;
			var count:int = _selectMaterialWindow.currentCount;
			
			dispatchEvent(new TableSlotItemEvent(TableSlotItemEvent.SET_ITEMS, mID, count, _slotID));
			
			_selectMaterialWindow.close();
			_selectMaterialWindow = null;
		}
		
		override public function dispose():void 
		{
			_bttnSelectMaterial.removeEventListener(MouseEvent.CLICK, onBttnSelectMaterialClick);
			super.dispose();
		}
	}
}