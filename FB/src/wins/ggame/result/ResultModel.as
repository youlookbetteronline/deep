/**
 * Created by Andrew on 16.05.2017.
 */
package wins.ggame.result {
	public class ResultModel
	{
		private var _gained:Object = {};
		private var _successGained:Object = {};
		private var _successGainedCount:int;
		private var _gainedCount:int;
		private var _wasted:Object = {};
		private var _title:String = '';
		private var _gainedText:String = '';
		private var _wastedText:String = '';
		private var _onClose:Function;

		private static var _instance:ResultModel;

		public static function get instance():ResultModel{
			if(!_instance)
				_instance = new ResultModel(new Blocker());

			return _instance;
		}

		public function ResultModel(blocker:Blocker)
		{}

		public function get wastedText():String {
			return _wastedText;
		}

		public function set wastedText(value:String):void {
			_wastedText = value;
		}

		public function get gainedText():String {
			return _gainedText;
		}

		public function set gainedText(value:String):void {
			_gainedText = value;
		}

		public function get title():String {
			return _title;
		}

		public function set title(value:String):void {
			_title = value;
		}

		public function get wasted():Object {
			return _wasted;
		}

		public function set wasted(value:Object):void {
			_wasted = value;
		}

		public function get gained():Object {
			return _gained;
		}

		public function set gained(value:Object):void {
			_gained = value;
		}
		
		public function get successGained():Object {
			return _successGained;
		}

		public function set successGained(value:Object):void {
			_successGained = value;
		}
		
		public function get successGainedCount():int {
			return _successGainedCount;
		}

		public function set successGainedCount(value:int):void {
			_successGainedCount = value;
		}
		
		public function get gainedCount():int {
			return _gainedCount;
		}

		public function set gainedCount(value:int):void {
			_gainedCount = value;
		}

		public function get onClose():Function {
			return _onClose;
		}

		public function set onClose(value:Function):void {
			_onClose = value;
		}
	}
}

class Blocker
{

}