/**
 * Created by Andrew on 10.05.2017.
 */
package wins.ggame {
import core.Load;

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;

	public class StickObject extends LayerX
	{
		private var _started:Boolean;
		private var _minCoords:Point;
		private var _maxCoords:Point;
		private var _icon:Bitmap;

		private var _right:Point;
		private var _left:Point;
		private var _paused:Boolean = false;

		public function StickObject(type:String, name:String, minCoords:Point, maxCoords:Point)
		{
			_started = false;
			
			initLimits(minCoords, maxCoords);
			initIcon(type, name);
			initListeners();
		}

		private function initIcon(type:String, name:String):void {
			Load.loading(Config.getImage(type, name), function(data:Bitmap):void {
				_icon = data;
				_icon.visible = _started;
				_maxCoords.x -= _icon.width / 2;
				_minCoords.x += _icon.width / 2;

				addChild(_icon);
				_icon.x = -_icon.width / 2;
				_icon.y =  -_icon.height / 2;


				drawDebugPoints();
			});
		}

		private function initListeners():void {
			App.self.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}

		private function initLimits(minCoords:Point, maxCoords:Point):void {
			_minCoords = minCoords;
			_maxCoords = maxCoords;
		}

		private function onMouseMove(event:MouseEvent):void {
			if(!_started  && !_icon || _paused)
				return;

			if(this.parent.mouseX < _minCoords.x)
				this.x = _minCoords.x;
			else
				if(this.parent.mouseX > _maxCoords.x)
					this.x = _maxCoords.x;
				else
					this.x = this.parent.mouseX;

			if(this.parent.mouseY < _minCoords.y)
				this.y = _minCoords.y - _icon.height;
			else
				if(this.parent.mouseY > _maxCoords.y)
					this.y = _maxCoords.y - _icon.height;
				else
					this.y = this.parent.mouseY - _icon.height;

			updateCorners();
		}

		private function updateCorners():void {
			if(!_left || !_right)
			{
				_left = new Point();
				_right = new Point();
			}

			_left.x = this.x - _icon.width / 2;
			_left.y = this.y;

			_right.x = this.x + _icon.width / 2;
			_right.y = this.y;
		}

		public function get started():Boolean {
			return _started;
		}

		public function set started(value:Boolean):void {
			_started = value;

			if(_icon)
				_icon.visible = _started;
		}

		private function drawDebugPoints():void {
			//if (!Config.admin)
			return;

			var s1:Shape = new Shape();

			s1.graphics.beginFill(0x00FF00);
			s1.graphics.drawCircle(0,0, 10);
			s1.graphics.endFill();

			s1.x = -_icon.width / 2;
			s1.y = 0;

			addChild(s1);

			var s2:Shape = new Shape();

			s2.graphics.beginFill(0x00FF00);
			s2.graphics.drawCircle(0,0, 10);
			s2.graphics.endFill();

			s2.x = _icon.width / 2;
			s2.y = 0;

			addChild(s2);
		}

		public function dispose():void
		{
			App.self.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

			if(_icon && _icon.parent)
			{
				_icon.parent.removeChild(_icon);
				_icon = null;
			}
		}

		public function set paused(value:Boolean):void {
			_paused = value;
		}

		public function get right():Point {
			return _right;
		}

		public function set right(value:Point):void {
			_right = value;
		}

		public function get left():Point {
			return _left;
		}

		public function set left(value:Point):void {
			_left = value;
		}
	}
}
