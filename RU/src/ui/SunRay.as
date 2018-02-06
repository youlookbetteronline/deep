package ui
{
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.events.*;
	import flash.geom.Vector3D;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import wins.Window;
	
	public class SunRay extends Sprite
	{		
		private var center:Sprite;
		private var boxPanel:Shape;
		private var inDrag:Boolean = false;
		
		public function SunRay():void
		{
			createBoxes();
			//createCenter();
			App.self.addEventListener(AppEvent.ON_MAP_REDRAW, relocateCenter);
		}
		
		public function createCenter():void
		{
			var centerRadius:int = 20;
			//center = new Sprite(); 
			//
			//// circle 
			//center.graphics.lineStyle(1, 0x000099); 
			//center.graphics.beginFill(0xCCCCCC, 0.5); 
			//center.graphics.drawCircle(0, 0, centerRadius); 
			//center.graphics.endFill(); 
			//// cross hairs 
			//center.graphics.moveTo(0, centerRadius); 
			//center.graphics.lineTo(0, -centerRadius); 
			//center.graphics.moveTo(centerRadius, 0); 
			//center.graphics.lineTo(-centerRadius, 0); 
			//center.x = 175; 
			//center.y = 175; 
			//center.z = 0; 
			//this.addChild(center); 
		
			//center.addEventListener(MouseEvent.MOUSE_DOWN, startDragProjectionCenter); 
			//center.addEventListener(MouseEvent.MOUSE_UP, stopDragProjectionCenter); 
			//center.addEventListener( MouseEvent.MOUSE_MOVE, doDragProjectionCenter); 
			//this.transform.perspectiveProjection = new PerspectiveProjection();
			//this.transform.perspectiveProjection.projectionCenter = new Point(App.map.centerPoint.x, App.map.centerPoint.y); 
			//App.self.addEventListener(AppEvent.ON_MAP_REDRAW, relocateCenter);
		}
		
		public function relocateCenter(e:AppEvent = null):void
		{
			//this.transform.perspectiveProjection.projectionCenter = new Point(App.map.centerPoint.x, App.map.centerPoint.y);
			
			var xl:Number = App.map.centerPoint.x - (bmapRay.x + bmapRay.bitmapData.width / 2);
			var yl:Number = App.map.centerPoint.y - (bmapRay.y + 10);
			var _angle:Number = 330 + Math.abs(Math.atan2(yl, xl)) * (20 / Math.PI) * -1;
			bmapRay.rotationX = _angle;
			bmapRay.rotationY = -30 + Math.abs(Math.atan2(yl, xl)) * (60 / Math.PI);
			var val:Number = ((Math.abs(xl) + Math.abs(yl)) - App.self.stage.stageWidth * .8 / App.map.scaleY) / 1000;
			bmapRay.filters = null;
			if(val > 1){
				bmapRay.alpha = 1;
				if(val > 1){
					bmapRay.filters = [new BlurFilter(15 * (val - 1), 15 * (val - 1), 1)];
					//trace('alpha: ' + val);
				}/*else{
					bmapRay.filters = null;
				}*/
			}else{
				bmapRay.alpha = val;
				//bmapRay.filters = null;
			}
			
			//if((Math.abs(xl) + Math.abs(yl)) - App.self.stage.stageWidth){
				//hideRay();
			//}
			//trace('xl = ' + xl + ' yl = ' + yl);
			//trace('xl + yl = ' + (xl + yl));
			//trace('atan2 = ' + (Math.atan2(yl, xl)));
			//trace('rotationX = ' + bmapRay.rotationX);
			//trace('rotationY = ' + bmapRay.rotationY);
			//bmapRay2.rotationX = _angle - 5;
			//bmapRay3.rotationX = _angle + 5;
		}
		
		private var bmapRay:Bitmap = new Bitmap(Window.textures.ray);
		
		//private var bmapRay2:Bitmap;
		//private var bmapRay3:Bitmap;
		public function createBoxes():void
		{
			
			//bmapRay = new Bitmap(ray);
			bmapRay.transform.perspectiveProjection = new PerspectiveProjection();
			bmapRay.transform.matrix3D = new Matrix3D();
			//bmapRay.transform.matrix3D.appendRotation(-45, Vector3D.X_AXIS);
			//bmapRay.transform.matrix3D.appendRotation(45, Vector3D.Y_AXIS);
			
			this.addChild(bmapRay);
			bmapRay.x = App.map.width / 2 - 800 + Math.random() * 1600;
			bmapRay.y = -70;
			bmapRay.z = 0;
			
			bmapRay.transform.perspectiveProjection.projectionCenter = new Point(bmapRay.x + bmapRay.bitmapData.width / 2, bmapRay.y + 10);
			//bmapRay.transform.matrix.transformPoint(new Point(bmapRay.width / 2, bmapRay.height));
			//TweenLite.to(this, 3, { animateRay:1, onComplete:reAnimate});
			//TweenLite.to(this,1)
			relocateRay();
			//hsTimeout = setTimeout(hideRay, 2000 + Math.random()*2500);
			//reAnimate();
			//setInterval(relocateRay, 5000);
		}
		private var hsTimeout:uint;
		private var hsTween:TweenLite;
		public function hideRay():void
		{
			clearTimeout(hsTimeout);
			if (hsTween) {
				hsTween.kill()
				hsTween = null;
			}
			App.self.removeEventListener(AppEvent.ON_MAP_REDRAW, relocateCenter);
			hsTween = TweenLite.to(bmapRay, 1, {alpha: 0});
			hsTimeout = setTimeout(relocateRay, 6000 + Math.random()*2500);
		}
		public function relocateRay():void
		{
			bmapRay.x = App.map.width / 2 - 300 + Math.random() * 600;
			bmapRay.y = -70;
			bmapRay.z = 0;
			//if (App.map.centerPoint.y > bmapRay.y + App.self.stage.stageHeight)
			//{
			App.self.addEventListener(AppEvent.ON_MAP_REDRAW, relocateCenter);
			//relocateCenter();
			bmapRay.transform.perspectiveProjection.projectionCenter = new Point(bmapRay.x + bmapRay.bitmapData.width / 2, bmapRay.y + 10);
			//hsTween = TweenLite.to(bmapRay, 1, {alpha: 1, onComplete:function():void{
			relocateCenter();
			//}});
			//}
			//hsTimeout = setTimeout(hideRay, 2000 + Math.random()*2500);
		}
		
		public function dispose():void{
			clearTimeout(hsTimeout);
			App.self.removeEventListener(AppEvent.ON_MAP_REDRAW, relocateCenter);
			if (hsTween) {
				hsTween.kill()
				hsTween = null;
			}
		}
		
		private function reAnimate():void
		{
			if (animateRay == 0)
			{
				TweenLite.to(this, 3, {animateRay: 1, onComplete: reAnimate});
			}
			else
			{
				TweenLite.to(this, 3, {animateRay: 0, onComplete: reAnimate});
			}
		}
		
		private var _animateRay:Number = 0;
		
		public function get animateRay():Number
		{
			return _animateRay;
		}
		
		public function set animateRay(_val:Number):void
		{
			var rad:Number = Math.PI * _val;
			//var xl:Number = App.map.centerPoint.x - (bmapRay.x + bmapRay.bitmapData.width/2);
			//var yl:Number = App.map.centerPoint.y - (bmapRay.y + 10);
			var _angle:Number = 320 + Math.abs(rad / 2) * (40 / Math.PI) * -1;
			bmapRay.rotationX = _angle;
			bmapRay.rotationY = -30 + Math.abs(rad) * (60 / Math.PI);
			//bmapRay.alpha = ((Math.abs(xl) + Math.abs(yl)) - App.self.stage.stageHeight*.75) / 1000;
			_animateRay = _val;
		}
	}
}