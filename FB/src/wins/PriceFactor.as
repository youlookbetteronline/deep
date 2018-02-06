package wins 
{
	/**
	 * ...
	 * @author ...
	 */
	public class PriceFactor 
	{
		
		private var _materialID:int;
		public function get materialID():int 
		{
			return _materialID;
		}
		
		
		private var _factor:Number;
		public function get factor():Number 
		{
			return _factor;
		}
		
		
		public function PriceFactor(mID:int, factor:Number = 1) 
		{
			_materialID = mID;
			_factor = factor;
		}
	}
}