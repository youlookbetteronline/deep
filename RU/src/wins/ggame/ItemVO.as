/**
 * Created by Andrew on 15.05.2017.
 */
package wins.ggame
{
	public class ItemVO
	{
		private var _sid:int;
		private var _count:Boolean;
		private var _chance:int;

		public function ItemVO(sid:int, count:Boolean, chance:int)
		{
			_sid = sid;
			_count = count;
			_chance = chance;
		}

		public function get chance():int {
			return _chance;
		}

		public function get count():Boolean {
			return _count;
		}

		public function get sid():int {
			return _sid;
		}
	}
}
