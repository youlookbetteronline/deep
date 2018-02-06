package  
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author ...
	 */
	public class TargerMover 
	{
		private var _targets:Array;
		private var _mark:Shape = new Shape();
		private var _stage:Stage;
		
		private static var _instance:TargerMover = null;
		
		private var _isCtrl:Boolean = false;
		
		public function TargerMover() {
			
		}
		
		public static function get instance():TargerMover {
			if (_instance == null)
				_instance = new TargerMover();
			return _instance;
		}
		
		public function addTarget(_targetDisplayObject:*):void {
			/*if (_target && _mark && _mark.parent) {
				_mark.parent.removeChild(_mark);
			}*/
			_targets = [];
			_targets.push(_targetDisplayObject);
			
			/*_mark.graphics.clear();
			_mark.graphics.beginFill(0xff0000, 0.5);
			_mark.graphics.drawRect(0, 0, 20, 20);
			_mark.graphics.endFill();*/
			//_target.addChild(_mark);
		}
		
		public function pushTarget(_targetDisplay:*):void {
			trace("pushTarget", _targetDisplay);
			_targets.push(_targetDisplay);
		}
		
		public function addEvents(stage:Stage):void {
			_stage = stage;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.CONTROL) {
				_isCtrl = false;
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.CONTROL) {
				_isCtrl = true;
				//return;
			}
			
			for each (var target:DisplayObject in _targets) {
				if (target == null) return;
			
				if (e.keyCode == Keyboard.LEFT)
				{
					target.x -= 1;
				}
				if (e.keyCode == Keyboard.RIGHT)
				{
					target.x += 1;
				}
				if (e.keyCode == Keyboard.UP)
				{
					if (_isCtrl) {
						target.scaleX += 0.05;
						target.scaleY += 0.05;
						return;
					}
					target.y -= 1;
				}
				if (e.keyCode == Keyboard.DOWN)
				{
					if (_isCtrl) {
						target.scaleX -= 0.05;
						target.scaleY -= 0.05;
						return;
					}
					target.y += 1;
				}
				
				if (e.keyCode == Keyboard.SPACE) {
					trace(target, target.name, 'x: '+target.x, 'y: '+target.y, 'w:' + target.width, 'h:'+target.height, 'sX:'+target.scaleX, 'sY:'+target.scaleY);
				}
			}
			
		}
		
		private function onMouseClick(e:MouseEvent):void {
			var ar:Array = _stage.getObjectsUnderPoint(new Point(e.stageX, e.stageY));
			if (ar.length > 0) {
				for each(var item:* in ar) {
					if (_isCtrl == false) {
						addTarget(item);
					}
				}
				if(_isCtrl)pushTarget(item);
				
			}
		}
		
		
		
	}

}