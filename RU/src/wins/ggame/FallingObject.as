/**
 * Created by Andrew on 11.05.2017.
 */
package wins.ggame {
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.sampler._getInvocationCount;
import flash.text.TextField;
import flash.utils.Timer;
import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

import helpers.geometry.Polygon;

import wins.Window;

	public class FallingObject extends LayerX
	{
		private var _icon:Bitmap;
		private var _sid:int;
		private var _moveTween:TweenLite;
		private var _hideTween:TweenLite;
		private var _info:Object;
		private var _timerID:uint;

		private var _pauseStart:uint = 0;
		private var _launchTime:uint = 0;

		private var _endPoint:Point;
		private var _time:uint;
		private var _previousPosition:Point;
		private var _currentPosition:Point;

		private var _collisionPoint:Shape;
		private var _catched:Boolean = false;
		private var _textField:TextField;

		public function FallingObject(sid:int)
		{
			super ();

			recreate(sid);
			initIcon();

			drawDebugPoints();
			//initListeners();
		}
		/*private var _pTimer:Timer;
		private function initListeners():void {
			//if(_pTimer){
				//_pTimer.stop();
				//_pTimer.removeEventListener(TimerEvent.TIMER, update);
				//_pTimer = null;
			//}
			//App.self.setOnEnterFrame(update);
			//_pTimer = new Timer(100, 0);
			//_pTimer.start();
			//_pTimer.addEventListener(TimerEvent.TIMER, update);
		}*/

		/**
		 * обновляем предыдущие координаты этот update вызывается перед update'ом твина
		 */
		/*private function update(e:*):void {
			if(_catched)
				return;

			if(!_previousPosition)
				_previousPosition = new Point();

			_previousPosition.x = this.x + _icon.width / 2;
			_previousPosition.y = this.y + _icon.height;
		}*/

		private function drawDebugPoints():void {
			//if(!Config.admin)
				return;

			if(!_collisionPoint)
			{
				_collisionPoint = new Shape();

				_collisionPoint.graphics.beginFill(0x00FF00);
				_collisionPoint.graphics.drawCircle(0,0, 10);
				_collisionPoint.graphics.endFill();

				addChild(_collisionPoint);
			}

			_collisionPoint.x = _icon.width / 2;
			_collisionPoint.y = _icon.height;
		}

		private function init(sid:int):void {
			_sid = sid;

			_info = App.data.storage[_sid];
			_catched = false;

			if(_currentPosition)
			{
				_currentPosition.x = this.x;
				_currentPosition.y = this.y;
			}

			if(_previousPosition)
			{
				_previousPosition.x = this.x;
				_previousPosition.y = this.y;
			}
		}

		/**
		 * переиницализация, когда объкт отрабатол, и мы хотим использовать его заново, с другой view
		 */
		public function recreate(sid:int):void
		{
			if (sid == 0)
				return;
			init(sid);
			initIcon();
		}

		/**
		 * загрузка иконки предмета что падает
		 */
		private function initIcon():void {
			if(_icon && _icon.parent == this)
			{
				_icon.bitmapData = null;
				removeChild(_icon);
			}

			Load.loading(Config.getIcon(_info.type, _info.view), function(data:Bitmap):void {
				_icon = new Bitmap();
				_icon.bitmapData = data.bitmapData;
				Size.size(_icon, 70, 70);
				addChild(_icon);

				_icon.x = 0;
				_icon.y = 0;

				drawDebugPoints();
				drawDebugTextField();
			});
		}

		private function drawDebugTextField():void {
			//if(!Config.admin)
				return;

			if(!_textField)
			{
				_textField = Window.drawText(sid.toString(), {
					width:		_icon.width,
					color:		0xfbdb38,
					borderColor:0x682c00,
					textAlign:	'center',
					fontSize:	34
				});
				addChild(_textField);
			}
			else
			{
				setChildIndex(_textField, numChildren -1);

				_textField.text = sid.toString();
			}
		}

		/**
		 * спрятать объект
		 */

		private function hide(time:Number = 0.4, callback:Function = null):void
		{
			if(_hideTween && _hideTween.active)
				_hideTween.killVars({x:true, y:true, onComplete:true, onUpdate:true});

			_hideTween = TweenLite.to(
					this,
					time,
					{
						alpha:0,
						onComplete:function():void
						{
							if(callback != null)
								callback();
						}
					});
		}

		/**
		 * поймать объект
		 */
		public function mesh():void
		{
			if(_moveTween)
				_moveTween.killVars({x:true, y:true, onComplete:true, onUpdate:true});

			if(_catched)
				return;

			_catched = true;

			hide(0.4, function ():void {
				dispatchEvent(new GGameEvent(GGameEvent.ITEM_CATCHED, false, true));
			})
		}

		/**
		 * остановить твин движения
		 */
		public function stop():void
		{
			if(_moveTween)
				_moveTween.killVars({x:true, y:true, onComplete:true, onUpdate:true});

			App.self.setOffTimer(updateDelay);
		}

		/**
		 * инициализация движеня, объект полетит в endPoint за time секунд, задержка старта delay милисекунд
		 */
		public function initMove(endPoint:Point, time:uint, delay:uint = 0):void
		{
			if(_moveTween)
				_moveTween.killVars({x:true, y:true, onComplete:true, onUpdate:true});

			if(delay > 0)
			{
				_launchTime = App.time + delay / 1000;
				App.self.setOnTimer(updateDelay);

				_time = time;
				_endPoint = endPoint;
			}
			else
			{
				startMove(endPoint, time);
				App.self.setOffTimer(updateDelay);
			}
		}

		/**
		 * таймер задержки старта движения
		 */
		private function updateDelay():void
		{
			if(_launchTime > 0 && _launchTime <= App.time)
			{
				startMove(_endPoint, _time);
				_launchTime = 0;
			}
		}

		/**
		 * отмена hide'a
		 */
		public function stopHide():void
		{
			if(_hideTween && _hideTween.active)
			{
				_hideTween.killVars({x:true, y:true, onComplete:true, onUpdate:true});
				_hideTween.kill();
			}
		}

		/**
		 * начало движения после того как initMove отработал и delay прошел
		 */
		private function startMove(endPoint:Point, time:uint):void
		{
			if(_hideTween && _hideTween.active)
			{
				_hideTween.killVars({x:true, y:true, onComplete:true, onUpdate:true});
				_hideTween.kill();
			}

			alpha = 1;
			if(!_previousPosition)
				_previousPosition = new Point();

			if(GGameModel.instance.paused)
			{
				_timerID = setTimeout(function ():void {
					startMove(endPoint, time);
					clearTimeout(_timerID);
				}, 400);

				return;
			}
			_previousPosition.x = this.x + _icon.width / 2;
			_previousPosition.y = this.y + _icon.height;

			_moveTween = TweenLite.to(
					this,
					time,
					{
						x:endPoint.x,
						y:endPoint.y,
						ease:Linear.easeNone,
						onComplete:function():void
						{
							dispatchEvent(new GGameEvent(GGameEvent.ITEM_MOVE_COMPLETE, false, true));
						},
						onUpdate:onTweenUpdate
					});
		}

		/**
		 * на update твина движения записываю текущие координаты объекта
		 */
		private function onTweenUpdate():void {
			if(_catched)
				return;
			if(!_icon)
				return;

			if(!_currentPosition)
			{
				_currentPosition = new Point();
			}else{
				_previousPosition.x = _currentPosition.x;
				_previousPosition.y = _currentPosition.y;
			}
			_currentPosition.x = this.x + _icon.width / 2;
			_currentPosition.y = this.y + _icon.height;
		}

		/**
		 * запаузить объект
		 */
		public function pause():void
		{
			if(_moveTween && _moveTween.active)
			{
				_moveTween.pause();
			}
			else
			{
				_pauseStart = App.time;
			}
		}

		/**
		 * отмена паузы
		 */
		public function unpause():void
		{
			if(_moveTween)
			{
				_moveTween.resume();
			}
			else
			{
				_pauseStart = 0;
			}
		}

		public function dispose():void
		{
			if(_icon && _icon.parent)
			{
				_icon.parent.removeChild(_icon);
				_icon = null;
			}

			if(_moveTween)
			{
				_moveTween.kill();
			}

			if(_timerID)
			{
				clearTimeout(_timerID);
			}
			/*if(_pTimer){
				_pTimer.stop();
				_pTimer.removeEventListener(TimerEvent.TIMER, update);
				_pTimer = null;
			}*/
			//App.self.setOffEnterFrame(update);
			App.self.setOffTimer(updateDelay);
		}

		public function get currentPosition():Point {
			return _currentPosition;
		}

		public function get previousPosition():Point {
			//var _point = new Point(_previousPosition.x, _previousPosition.y)
			if (!_previousPosition)
				return new Point(0, 0);
			return _previousPosition;
			//return new Point(_previousPosition.x, _previousPosition.y);
		}

		public function get sid():int {
			return _sid;
		}

		public function set sid(value:int):void {
			_sid = value;
		}

	public function get catched():Boolean {
		return _catched;
	}

	public function set catched(value:Boolean):void {
		_catched = value;
	}
}
}
