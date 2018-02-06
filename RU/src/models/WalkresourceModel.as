package models 
{
	/**
	 * ...
	 * @author ...
	 */
	public class WalkresourceModel 
	{
		private var _outsList:Array = [];
		private var _capacity:int = 0;
		public function WalkresourceModel() 
		{
			
		}
		
		public function get outsList():Array 
		{
			return _outsList;
		}
		
		public function set outsList(value:Array):void 
		{
			_outsList = value;
		}
		
		public function get capacity():int 
		{
			return _capacity;
		}
		
		public function set capacity(value:int):void 
		{
			_capacity = value;
		}
		
		
	}

}