package models 
{
	/**
	 * ...
	 * @author das
	 */
	public class BathyscapheModel 
	{
		private var _throwCallback:Function;
		private var _throws:int;
		private var _limitThrows:int;
		private var _materialThrows:int;
		public function BathyscapheModel() 
		{
			
		}
		
		public function get throwCallback():Function 
		{
			return _throwCallback;
		}
		
		public function set throwCallback(value:Function):void 
		{
			_throwCallback = value;
		}
		
		public function get throws():int 
		{
			return _throws;
		}
		
		public function set throws(value:int):void 
		{
			_throws = value;
		}
		
		public function get limitThrows():int 
		{
			return _limitThrows;
		}
		
		public function set limitThrows(value:int):void 
		{
			_limitThrows = value;
		}
		
		public function get materialThrows():int 
		{
			return _materialThrows;
		}
		
		public function set materialThrows(value:int):void 
		{
			_materialThrows = value;
		}
		
	}

}