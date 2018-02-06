package units 
{
	import core.Post;
	import units.unitEvent.UnitEvent;
	import wins.ApothecaryWindow;
	import wins.FlowerStandWindow;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Pharmacy extends Building 
	{
		public var orders:Object;
		
		public function Pharmacy(object:Object) 
		{
			super(object);
			orders = object.items;
		}
		
		override public function click():Boolean
		{	
			
			if (!super.click() || this.id == 0)
			{
				return false;
			}			
			
			/*if (App.user.mode == User.GUEST) 
			{
				guestClick();
				return true;
			}*/
			
			if (!isReadyToWork()) 
				return true;
			
			if (isPresent()) 
				return true;
			
			if (isProduct()) 
				return true;
			
			if (openConstructWindow()) 
				return true;
			
			/*if (sid == APOTHECARY)
			{
				new ApothecaryWindow( {
				} ).show();
				return true;
			}*/
			
			//openProductionWindow();			
			
			return true;
		}
		
		override public function openProductionWindow():void 
		{
			//if (sid == CAPSULE) return;
			
			if (level < totalLevels)
			{
				return;
			}
			
			//if (info.devel) 
			//{
			switch(this.sid)
			{
				case 707:
					new ApothecaryWindow( {
						items:info.items,
						orders:orders,
						target:this
					} ).show();
					break
				case 1165:
					new FlowerStandWindow( {
						items:info.items,
						orders:orders,
						target:this
					} ).show();
					break
			}
			//if (this.sid == 707)
			//{
				//new ApothecaryWindow( {
					//items:info.items,
					//orders:orders,
					//target:this
				//} ).show();
			//}
			//}
		}
		
		override public function stockAction(params:Object = null):void {
			
			if (!App.user.stock.check(sid)) {
				//TODO показываем окно с ообщением, что на складе уже нет ничего
				return;
			}else if (!World.canBuilding(sid)) {
				uninstall();
				return;
			}
			
			App.user.stock.take(sid, 1);
			
			Post.send( {
				ctr:this.type,
				act:'stock',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z,
				level:this.level
			}, onStockAction);
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			if (error) 
			{
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			orders = data.items;
			showIcon();
			
			
			hasUpgraded = false;
			hasBuilded = true;
			
			if (info.instance && info.instance.devel && (info.type == 'Building' || info.type == 'Barter')) 
			{
				openConstructWindow();
			}
			
			App.user.addInstance(info.sid);
			makeOpen();
			hasUpgraded = true;
			
			dispatchEvent(new UnitEvent(UnitEvent.UNIT_SHOP_ACTION));
			
			World.tagUnit(this);
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			orders = data.items;
			showIcon();
			
			hasUpgraded = false;
			hasBuilded = true;
			
			if (info.instance.devel && (info.type == 'Building' || info.type == 'Barter')) {
				openConstructWindow();
			}
			
			App.user.addInstance(info.sid);
			makeOpen();
			hasUpgraded = true;
			
			dispatchEvent(new UnitEvent(UnitEvent.UNIT_SHOP_ACTION));
			
			World.tagUnit(this);
		}
		
		override public function checkOnAnimationInit():void 
		{
			if (textures && textures['animation'] && ((level == totalLevels /*- craftLevels*/) /*|| this.sid == 236*/)) 
			{
				initAnimation();
				
					beginAnimation();
					startAnimation();
				
			}
			
			
		}
	}
}