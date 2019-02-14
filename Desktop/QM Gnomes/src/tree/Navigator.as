package tree 
{
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author 777
	 */
	public class Navigator extends Sprite 
	{
		public var isSDrugging:Boolean;
		
		private var navTree:Tree;
		private var navWidth:int = 250;
		private var navHeight:int = 250;
		private var bias:int = 30;
		private var bPoint:Object;
		private var _scale:Number = .1;
		private var uperCont:Sprite;
		private var scalesCont:Sprite;
		private var showed:Boolean = false;
		private var isDrugging:Boolean;
		private var bTree:Bitmap;
		private var scaleW:Number;
		private var scaleH:Number;
		private var uper:Shape;
		private var back:Shape;
		//private var uTween:TweenLite;
		//private var tTween:TweenLite;
		private var timer:Timer;
		
		public function Navigator(_tree:Tree) 
		{
			navTree = _tree;
			uperCont = new Sprite();
			bPoint = navTree.getFirstCoordsAndGlow;
			draw();
			drawTree();
			drawUp();
			drawScaler();
			uperCont.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			uperCont.addEventListener(MouseEvent.MOUSE_UP, onUp);
			addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			
			scalesCont.addEventListener(MouseEvent.MOUSE_DOWN, onSDown);
			App.self.addEventListener(MouseEvent.MOUSE_UP, onSUp);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
			visible = false;
		}
		
		private function onOut(e:MouseEvent = null):void
		{
			if (isDrugging){
				isDrugging = false;
				uperCont.stopDrag();
			}
			/*if (isSDrugging){
				isSDrugging = false;
				scalesCont.stopDrag();
			}*/
		}
		
		private function onMove(e:MouseEvent):void
		{
			if (isDrugging){
				//var scaleW:Number = (navWidth-bias) / navTree.width;
				//var scaleH:Number = (navWidth-bias) / navTree.height;
				navTree.x = bias/2 * navTree.scaleX / _scale -((uperCont.x - uperCont.width/2)/ _scale * navTree.scaleX);
				navTree.y = bias/2 * navTree.scaleY / _scale -((uperCont.y - uperCont.height/2)/ _scale * navTree.scaleY);
				//uperCont.x = uperCont.width/2 -navTree.x * _scale / navTree.scaleX +  bias / 2;
				//uperCont.y = uperCont.height / 2 -navTree.y * _scale / navTree.scaleY + bias / 2;
			}
			if(isSDrugging){
				navWidth = scalesCont.x;
				navHeight = scalesCont.y;
				//redrawBack();
			}
		}
		
		private function onDown(e:MouseEvent):void
		{
			isDrugging = true;
			uperCont.startDrag(
				true,
				new Rectangle(
					uper.width/2,
					uper.height/2,
					navWidth - uper.width,
					navHeight - uper.height
				)
			);
		}
		private function onUp(e:MouseEvent):void 
		{
			isDrugging = false;
			uperCont.stopDrag();
		}
		private function onSDown(e:MouseEvent):void
		{
			isSDrugging = true;
			scalesCont.startDrag(
				true/*,
				new Rectangle(
					uper.width/2,
					uper.height/2,
					navWidth - uper.width,
					navWidth - uper.height
				)*/
			);
			timer = new Timer(50, 0);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, udpateElements);
			/*if (bTree){
				if(tTween != null){
					tTween.complete(true, true);
					tTween.kill();
					tTween = null;
				}
				tTween = TweenLite.to(bTree, .5, {alpha: 0});
			}
			if (uper){
				if(uTween != null){
					uTween.complete(true, true);
					uTween.kill();
					tTween = null;
				}
				uTween = TweenLite.to(uper, .5, {alpha: 0});
			}*/
		}
		
		private function udpateElements(e:*):void 
		{
			drawTree();
			redrawBack();
		}
		private function onSUp(e:MouseEvent):void 
		{
			if(isSDrugging){
				isSDrugging = false;
				scalesCont.stopDrag();
				drawTree();
				if(timer){
					timer.removeEventListener(TimerEvent.TIMER, udpateElements);
					timer.stop();
					timer.reset();
					timer = null;
				}
				/*uper.alpha = 0;
				bTree.alpha = 0;
				if (bTree){
					if(tTween != null){
						tTween.complete(true, true);
						tTween.kill();
						tTween = null;
					}
					tTween = TweenLite.to(bTree, .5, {alpha: 1});
				}
				if (uper){
					if(uTween != null){
						uTween.complete(true, true);
						uTween.kill();
						uTween = null;
					}
					uTween = TweenLite.to(uper, .5, {alpha: 1});
				}*/
			}
		}
		public function show():void 
		{
			showed = !showed;
			if (showed)
				visible = true;
			else
				visible = false;
		}
		
		private function draw():void{
			back = new Shape();
			redrawBack();
			addChild(back);
			
		}
		private function redrawBack():void{
			back.graphics.clear();
			back.graphics.beginFill(0, 0);
			back.graphics.lineStyle(2, 0, 1);
			back.graphics.drawRect(0, 0, navWidth, navHeight);
			back.graphics.endFill();
			
		}
		public function drawTree():void{
			if(bTree){
				removeChild(bTree);
				bTree = null;
			}
			bTree = new Bitmap(new BitmapData(navWidth, navHeight, true, 0));
			scaleW = (navWidth - bias) / navTree.width * navTree.scaleX;
			scaleH = (navHeight-bias) / navTree.height * navTree.scaleY;
			_scale = Math.min(scaleW, scaleH);
			var _width:int = (App.self.stage.stageWidth * _scale) / navTree.scaleX;
			var _height:int = (App.self.stage.stageHeight * _scale) / navTree.scaleY;
			if (_width > navWidth || _height > navHeight){
				var _val:Number = Math.max(_width, _height);
				var _sscale:Number = (navWidth+0) / _val;
				_scale *= _sscale;
				//_width = (App.self.stage.stageWidth * _scale) / navTree.scaleX;
				//_height = (App.self.stage.stageHeight * _scale) / navTree.scaleY;
				//trace('width: ' + _width);
				//trace('height: ' + _height);
			}
			bTree.bitmapData.draw(navTree, new Matrix(_scale, 0, 0, _scale, bias/2, bias/2));
			addChild(bTree);
			if (uper)
				redrawUp();
		}
		
		private function drawUp():void{
			uper = new Shape();
			uper['name'] == 'upper';
			//uper.graphics.beginFill(0, 0);
			//uper.graphics.lineStyle(2, 0, 1);
			//uper.graphics.drawRect(0, 0, App.self.stage.stageWidth * (1 -navTree.scaleX + .1), App.self.stage.stageHeight * (1 - navTree.scaleY+ .1));
			//uper.graphics.endFill();
			//addChild(uper);
			uperCont.addChild(uper);
			addChild(uperCont);
			redrawUp();
		}
		
		public function drawScaler():void{
			scalesCont = new Sprite();
			addChild(scalesCont);
			var scaler:Shape = new Shape();
			scaler.graphics.beginFill(0xff0000, 1);
			scaler.graphics.lineStyle(1, 0, 1);
			scaler.graphics.drawCircle(0, 0, 4);
			scaler.graphics.endFill();
			scalesCont.addChild(scaler);
			scalesCont.x = navWidth;
			scalesCont.y = navHeight;
		}
		public function redrawUp():void{
			if (!uper)
				return;
			//var _scX:Number = 1 + (1 - navTree.scaleX);
			//var _scY:Number =  1 + (1 - navTree.scaleY);
			
			var _width:int = (App.self.stage.stageWidth * _scale) / navTree.scaleX;
			var _height:int = (App.self.stage.stageHeight * _scale) / navTree.scaleY;
			if(_width > navWidth || _height > navHeight){
				drawTree();
				return;
			}
			uper.graphics.clear();
			uper.graphics.beginFill(0xfff000, .1);
			uper.graphics.lineStyle(1, 0, 1);
			uper.graphics.drawRect(-_width/2, -_height/2, _width, _height);
			uper.graphics.endFill();
			var _valX:Number = _width / 2 - (navTree.x * _scale / navTree.scaleX) + bias / 2;
			var _valY:Number = _height / 2 - (navTree.y * _scale / navTree.scaleY) + bias / 2;
			
			if (_valX >= navWidth - uper.width/2)
				_valX = navWidth - uper.width/2;
			if (_valX <= uper.width/2)
				_valX = uper.width/2;
				
			if (_valY >= navHeight - uper.height/2)
				_valY = navHeight - uper.height/2;
			if (_valY <= uper.height/2)
				_valY = uper.height/2;
				
			uperCont.x = _valX
			uperCont.y = _valY;
			
		}
		public function dispose():void{
			/*if(tTween != null){
				tTween.complete(true, true);
				tTween.kill();
				tTween = null;
			}
			if(uTween != null){
				uTween.complete(true, true);
				uTween.kill();
				uTween = null;
			}*/
			if(timer){
				timer.removeEventListener(TimerEvent.TIMER, udpateElements);
				timer.stop();
				timer.reset();
				timer = null;
			}
			uperCont.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			uperCont.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			scalesCont.removeEventListener(MouseEvent.MOUSE_DOWN, onSDown);
			App.self.removeEventListener(MouseEvent.MOUSE_UP, onSUp);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			onOut();
		}
		
	}

}