package units.table 
{
	public class TableSlot
	{
		private var _currentMaterial:int;
		private var _count:uint;
		private var _finished:int;
		private var _isOpen:Boolean = false;
		private var _maxMaterialCount:int = 0;
		private var _priceFactor:Number = 1;
		private var _openPrice:int = 0;
		private var _sellTime:int = 0;
		
		public function get currentMaterial():int 
		{
			return _currentMaterial;
		}
		
		public function set currentMaterial(value:int):void 
		{
			_currentMaterial = value;
		}		
		
		public function get count():uint 
		{
			return _count;
		}
		
		public function set count(value:uint):void 
		{
			_count = value;
		}		
		
		public function get finished():int 
		{
			return _finished;
		}
		public function set finished(value:int):void 
		{
			_finished = value;
		}		
		
		public function get isOpen():Boolean 
		{
			return _isOpen;
		}
		
		public function set isOpen(value:Boolean):void 
		{
			_isOpen = value;
		}
		
		public function get maxMaterialCount():int 
		{
			return _maxMaterialCount;
		}
		
		public function get priceFactor():Number
		{
			return _priceFactor;
		}
		
		public function get openPrice():int
		{
			return _openPrice;
		}
		
		public function get sellTime():int
		{
			return _sellTime;
		}		
		
		public function TableSlot(maxCount:int, priceFactor:Number, openPrice:int, sellTime:int, material:int = 0, materialCount:int = 0, finishedTime:int = 0, open:Boolean = false)
		{
			_maxMaterialCount = maxCount;
			_priceFactor = priceFactor;
			_openPrice = openPrice;
			_sellTime = sellTime;
			
			_currentMaterial = material;
			_count = materialCount;
			_finished = finishedTime;
			_isOpen = open;
		}
	}
}