package units 
{
	
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import ui.UserInterface;
	import units.Anime;

	public class Ship extends Sprite {
		
		public var anime:Anime2;
		public var params:Object = {
			view:		'Port',
			info:		null,
			target:		null
		}
		
		public function Ship(params:Object) {
			
			for (var s:* in params)
				this.params[s] = params[s];
			
			draw();
			
			//this.addEventListener(MouseEvent.MOUSE_DOWN, onClick, false, 5000);
			this.addEventListener(MouseEvent.MOUSE_OVER, onOver, false, 5000);
			this.addEventListener(MouseEvent.MOUSE_OUT, onOut, false, 5000);
		}
		
		public function draw():void {
			/*if (params.hasOwnProperty('swf')) {
				onLoad(params.swf);
			}else {
				Load.loading(Config.getSwf(params.type, params.view), onLoad);
			}*/
		}
		
		private function onLoad(data:*):void {
			params['swf'] = data;
			
			anime = new Anime2(params['swf'], { w:240, h:240 } );
			addChild(anime);
		}
		
		public function click():void {
			onClick()
		}
		
		public function onClick(e:MouseEvent = null):void {
			if (params.onClick != null) {
				params.onClick();
				//if(e!=null)
					//e.stopImmediatePropagation();
			}
		}
		public function onOver(e:MouseEvent):void {
			UserInterface.effect(anime, 0.1, 1);
		}
		public function onOut(e:MouseEvent):void {
			UserInterface.effect(anime, 0, 1);
		}
		
		public function dispose():void {
			//this.removeEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
	}
	
}