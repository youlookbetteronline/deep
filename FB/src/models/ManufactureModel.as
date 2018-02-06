package models 
{
	/**
	 * ...
	 * @author ...
	 */
	public class ManufactureModel 
	{
		private var _crafts:Array
		public function ManufactureModel() 
		{
			
		}
		
		public function get crafts():Array 
		{
			return _crafts;
		}
		
		public function set crafts(value:Array):void 
		{
			_crafts = value;
		}
		
		
	}

}