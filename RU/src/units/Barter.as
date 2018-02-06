package units 
{
	import astar.AStarNodeVO;
	import core.Post;
	import wins.BarterWindow;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Barter extends Building 
	{
		public var bTime:uint = 0;
		public var bID:int = 0;
		public static const VOJDBARTER:int = 2276;
		public function Barter(object:Object) 
		{
			super(object);
			if (object.hasOwnProperty('bID'))
				bID = object.bID;
			if (object.hasOwnProperty('bTime'))
				bTime = object.bTime;
		}
		
		override public function click():Boolean 
		{
			/*if (bID == 0)
			{
				onRefreshAction(true);
				return false;
			}*/
			if (pest && pest.alive)//Вредитель
				return false;
			hidePointing();
			stopBlink();
			
			
			if (App.user.useSectors)
			{
				var node1:AStarNodeVO = App.map._aStarNodes[this.coords.x][this.coords.z];
				
				if (!node1.sector.open)
				{
					new SimpleWindow( {
						title:Locale.__e("flash:1474469531767"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1495607052980') + " " + info.title,
						confirm:function():void
						{
							node1.sector.fireNeiborsReses();
						}
					}).show();
					return false;
				}
			}
			
			/*if (!super.click() || this.id == 0)
			{
				return false;
			}*/		
			
			if (App.user.mode == User.GUEST) 
			{
				guestClick();
				return true;
			}
			
			if (onOpenBarter()) 
				return true;
			
			if (!isReadyToWork()) 
				return true;
			
			if (isPresent()) 
				return true;
			
			if (isProduct()) 
				return true;
			
			if (openConstructWindow()) 
				return true;			
			
			return true;
		}
		public function onOpenBarter():Boolean
		{
			if (App.user.mode == User.GUEST)
				return false;
			if (level == totalLevels)
			{
				if (needQuest != 0 && App.user.mode == User.OWNER)
				{
					if (!App.user.quests.data.hasOwnProperty(needQuest))
					{
						new SimpleWindow( {
							title:Locale.__e("flash:1481879219779"),
							label:SimpleWindow.ATTENTION,
							text:Locale.__e('flash:1481878959561', App.data.quests[needQuest].title)
						}).show();
						return false;
					}
				}
				
				new BarterWindow({target:this}).show();
				return true;
			}
			
			return false;
		}
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			super.onUpgradeEvent(error, data, params);
			if (level == totalLevels && bID == 0 && bTime == 0)
				onExchangeAction(0);
		}
		
		public function onRefreshAction(pay:Boolean = false, _callback:Function = null):void
		{
			var sendObject:Object = {
				ctr:this.type,
				act:'refresh',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				buy:int(pay)
			}
			
			Post.send(sendObject, onRefreshEvent, {callback:_callback});
		}
		
		protected function onRefreshEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			if (data.hasOwnProperty('bData')){
				bID = data.bData['bID'];
				bTime = data.bData['bTime'];
			}
			if(data.hasOwnProperty('buy') && data.buy == true){
				App.user.stock.takeAll(data.__take);
			}
			if (params.callback != null) 
			{
				params.callback();
			}
		
		}
		
		public function onExchangeAction(bID:uint, _callback:Function = null):void
		{			
			var sendObject:Object = {
				ctr:this.type,
				act:'exchange',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				bID:bID
			}
			
			Post.send(sendObject, onExchangeEvent, {callback:_callback});
		}
		
		
		protected function onExchangeEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			var barter:Object = App.data.barter[bID];
			if (barter)
			{
				App.user.stock.takeAll(barter.items);
				App.user.stock.addAll(barter.outs);
			}
			if (data.hasOwnProperty('bData')){
				bID = data.bData['bID'];
				bTime = data.bData['bTime'];
			}
			if (params.callback != null) 
			{
				params.callback();
			}
		}
		
	}

}