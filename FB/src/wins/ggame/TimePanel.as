/**
 * Created by Andrew on 10.05.2017.
 */
package wins.ggame
{
	import core.TimeConverter;
	import flash.display.Sprite;
	import flash.text.TextField;
	import units.GGame;

	import wins.Window;

	public class TimePanel extends Sprite
	{
		private var _timerTxt:TextField;
		private var _endTime:uint;
		private var _paused:Boolean = false;
		private var _pauseStart:int = 0;
		private var _pauseEnd:int = 0;
		private var _pausedTime:int = 0;

		public function TimePanel(endTime:uint = 0)
		{
			_endTime = endTime;
			createTimer();
		}

		public function start(value:uint):void
		{
			_endTime = value;

			_pausedTime = 0;
			App.self.setOnTimer(updateTimer);
		}

		private function createTimer():void
		{
			_timerTxt = Window.drawText("", {
				width: 130,
				textAlign: 'center',
				color: 0xfff081,
				borderColor: 0x47170b,
				fontSize: (!App.lang == 'jp')?40:32
			});
			_timerTxt.x = 0;
			_timerTxt.y = 0;
			addChild(_timerTxt);

			_timerTxt.visible = false;
		}

		private function updateTimer():void
		{
			if(!_paused)
			{
				var time:int = _endTime + _pausedTime - App.time;

				if (time > 0)
				{
					_timerTxt.visible = true;
					_timerTxt.text = TimeConverter.timeToStr(time);
				}
				else
				{
					_timerTxt.visible = false;

					App.self.setOffTimer(updateTimer);
					dispatchEvent(new GGameEvent(GGameEvent.TIMER_COMPLETE));

					_endTime = 0;
					_pausedTime = 0;
				}
			}
		}

		public function dispose():void
		{
			App.self.setOffTimer(updateTimer);
		}

		public function get endTime():uint {
			return _endTime;
		}

		public function get paused():Boolean {
			return _paused;
		}

		public function set paused(value:Boolean):void {
			if(value)
			{
				if(_pauseStart == 0)
				{
					_pauseStart = App.time;
					_pauseEnd = 0;
				}
			}
			else
			{
				_pauseEnd = App.time;

				_pausedTime += _pauseEnd - _pauseStart;

				_pauseEnd = 0;
				_pauseStart = 0;

				if(_pausedTime < 0)
					_pausedTime = 0;
			}
			_paused = value;
		}
	}
}
