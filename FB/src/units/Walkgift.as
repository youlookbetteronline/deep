package units 
{
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Numbers;
	import core.Post;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import ui.UnitIcon;
	/**
	 * ...
	 * @author ...
	 */
	public class Walkgift extends WorkerUnit 
	{
		public var senderId:String;
		public var presentSid:int;
		public function Walkgift(object:Object, view:String='') 
		{
			presentSid = Numbers.firstProp(object.valentine).key;
			var place:Object = findPlaceNearTarget({info:{area:{w:1, h:1}}, coords:{x:App.map.heroPosition.x, z:App.map.heroPosition.z}, base: 1}, 8);
			object.x = place.x
			object.z = place.z;
			senderId = object.fID;
			super(object, view);
			removable = false;
		}
		
		override public function onLoad(data:*):void 
		{
			if ((App.user.friends.data.hasOwnProperty(senderId) == false) && (senderId != App.user.id))
			{
				this.visible = false;
				return;
			}
			super.onLoad(data);
			textures = data;
			getRestAnimations();
			addAnimation();
			createShadow();
			
			goHome();
			showIcon();
			if (preloader)
			{
				TweenLite.to(preloader, 0.5, { alpha:0, onComplete:removePreloader } );
			}
		}
		
		override public function setRest():void 
		{
			/*if (App.user.quests.tutorial) {
				framesType = STOP;
				return;
			}*/
			
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			restCount = generateRestCount();
			framesType = randomRest;
			startSound(randomRest);
		}
		
		//public var coordsCloud:Object = new Object();
		public function showIcon():void
		{
			if (cloudPositions.hasOwnProperty(App.data.storage[sid].view) ) 
			{
				coordsCloud.x = cloudPositions[App.data.storage[sid].view].x;
				coordsCloud.y = cloudPositions[App.data.storage[sid].view].y;
			}else{
				coordsCloud.x = 0;
				coordsCloud.y = -50;
			}
				
			//if (App.user.mode == User.OWNER)
			//{
				/*if (hasProduct) 
				{*/
				drawIcon(UnitIcon.AVATAR, 1189, 1, {
					glow: true,
					iconDX: 0,
					iconDY: 0,
					friend: senderId
				}, 0, coordsCloud.x, coordsCloud.y);
				/*}else {
					clearIcon();
				}*/
			//}
		}
		
		override public function click():Boolean 
		{			
			var node:AStarNodeVO = App.map._aStarNodes[coords.x ][coords.z];
			if (!node.open)
				return false;
				
			if (App.user.mode == User.GUEST)
			{
				return true;
			}
			var that:Walkgift = this;
			Post.send( {
				ctr:		'Walkgift',
				act:		'gifttake',
				uID:		App.user.id,
				wID:		App.map.id,
				pID:		presentSid,
				fID:		senderId,
				sID:		this.sid,
				id: 		this.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				//App.user.stock.takeAll(data.__take)
				
				if(data.hasOwnProperty('bonus'))
					Treasures.bonus(data.bonus, new Point(that.x, that.y));
				that.uninstall();
				/*new SimpleWindow( {
					hasTitle:true,
					height:300,
					title:Locale.__e("flash:1382952379735"),
					text:Locale.__e("flash:1486477799296")
				}).show();*/
					//if (data['users']) settings.target.usersLength = data.users;
			});
			
			return true;
		}
		
	}

}