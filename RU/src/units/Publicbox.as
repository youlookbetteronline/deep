package units 
{
	import astar.AStarNodeVO;
	import core.Numbers;
	import core.Post;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.Hints;
	import ui.UnitIcon;
	import wins.LevelLockWindow;
	import wins.PublicboxWindow;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Publicbox extends Box 
	{
		public static const MAIN_BOX:int 	= 2335;
		public static const MAXPLAYERS:int = 5;

		public function Publicbox(object:Object) 
		{
			super(object);
		}
		
		override public function storageEvent():void 
		{
			var price:Object = { }
			price = Numbers.firstProp(info['in']).val;	
			if(price){
				if (!App.user.stock.takeAll(price))	return;
				Hints.minus(Numbers.firstProp(info['in']).key, Numbers.firstProp(info['in']).val, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
			}
			var postObject:Object = {
				ctr		:this.type,
				act		:'storage',	
				channel	:String(App.owner.id+'_'+App.owner.worldID),		
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid
			}		
			Post.send(postObject, onStorageEvent);
		}
		
		override public function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.reward && data.reward != null)
				Treasures.packageBonus(data.reward[App.user.id], new Point(this.x, this.y));
				
			var _objParams:Object = {
				bonus:data.reward
			}
			Connection.sendMessage({
				u_event	:'reward_window_open', 
				params	: _objParams
			});
				
			setTimeout(uninstall, 1000);	
		}
		
		override public function get visible():Boolean 
		{
			return super.visible;
		}
		
		override public function set visible(value:Boolean):void 
		{
			if (value)
				showIcon();
			else
				clearIcon();
			super.visible = value;
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void 
		{
			super.onMoveAction(error, data, params);
			visible = true;
			
			placing(coords.x, coords.y, coords.z);
				
			take();
			var _objParams:Object = {
				sID		:this.sid,
				iD		:this.id,
				coords	:this.coords,
				rotation:int(this.rotate)
			};
			Connection.sendMessage({
				u_event	:'box_drop', 
				aka		:App.user.aka, 
				params	:_objParams
			});
		}
		
		override public function click():Boolean 
		{
			
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
			
			if (levelLock)
			{
				new LevelLockWindow({
					level	:this.info.level,
					search	:this.info.sID
				}).show();
				return false;
			}
			//if (!super.click()) return false;
			//if (!clickable || id == 0) return false;
			//App.tips.hide();
			
			new PublicboxWindow({
				target	:this
			}).show()
			return true;
			/*var price:Object = { };
			price[Stock.FANTASY] = 1;				
			if (!App.user.stock.checkAll(price))	return false;
			showKeyWindow();
			return true;*/
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			
			if(visible)
				showIcon();
		}
		
		public function showIcon():void {
			clearIcon();
			drawIcon(UnitIcon.BUILDING_REWARD, sid, 1, {
				iconScale: 1
			}, 0, 0, -50);
		}
	}
	

}