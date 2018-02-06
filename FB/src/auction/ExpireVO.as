package auction {
	
	/**
	 * ...
	 * @author Andrew Lysenko
	 */
	public class ExpireVO {
		private var _start:uint;
		private var _end:uint;
		
		public function ExpireVO(exprire:Object) {
			_start = exprire.s;
			_end = exprire.e;
		}
		
		public function get start():uint {
			return _start;
		}
		
		public function get end():uint 
		{
			return _end;
		}
	}
}