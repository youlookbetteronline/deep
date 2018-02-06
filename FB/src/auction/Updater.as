package auction 
{
	/**
	 * ...
	 * @author Andrew Lysenko
	 */
	public class Updater  {
		private var _callback:Function;
		private var _delay:int;
		private var _lastUpdateTime:int;
		
		public function Updater(callback:Function, delay:int = 30) {
			_callback = callback;
			_delay = delay;
		}
		
		public function start():void{
			_lastUpdateTime = App.time;
			App.self.setOnTimer(update);
		}
		
		public function update(force:Boolean = false):void{
			if (!force && App.time - _lastUpdateTime < _delay) return;
			
			_lastUpdateTime = App.time;
			_callback();
		}
		
		public function stop():void{
			App.self.setOffTimer(update);
		}
		
		public function dispose():void{
			stop();
			_callback = null;
		}
		
		public function set delay(value:int):void  { _delay = value; }
		public function set lastUpdateTime(value:int):void  { _lastUpdateTime = value; }
		
		public function get lastUpdateTime():int 
		{
			return _lastUpdateTime;
		}
	}
}