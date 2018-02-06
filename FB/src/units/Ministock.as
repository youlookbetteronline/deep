package units 
{
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.Load;
	import wins.ShipWindow;
	
	public class Ministock extends AUnit 
	{
		
		public var ship:Ship;
		
		public function Ministock(object:Object) 
		{
			layer = Map.LAYER_SORT;
			
			super(object);
			
			Load.loading(Config.getSwf(type, info.view), onLoad)
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			textures = data;
			
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			framesType = info.view;
			if (textures && textures.hasOwnProperty('animation')) 
				initAnimation();
		}
		
		override public function click():Boolean {
			return true;
		}
		
		public function onShipClick():void {
			new ShipWindow( {
				target:		this
			}).show();
		}
		private var shipPos:Object = { x:100, y:-100};
		public function addShip():void {
			ship = new Ship( {
				view:		type,
				info:		info,
				target:		this,
				onClick:	onShipClick
			});
			ship.x = shipPos.x;
			ship.y = shipPos.y;
			addChild(ship);
			initShipAnimation();
		}
		private var shipAnimate:Boolean = false;
		private function initShipAnimation():void {
			if (shipAnimate) return;
			
			shipAnimate = true;
			TweenLite.to(ship, 3, { y:shipPos.y + 15, ease:Cubic.easeInOut, onComplete:function():void {
				TweenLite.to(ship, 3, { y:shipPos.y, ease:Cubic.easeInOut, onComplete:function():void {
					if (!parent) return;
					shipAnimate = false;
					initShipAnimation();
				}});
			}});
		}
		
		override public function uninstall():void {
			super.uninstall();
		}
		
	}

}