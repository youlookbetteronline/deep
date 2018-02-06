package ui 
{
	import core.Numbers;
	import core.Post;
	
	
	/**
	 * ...
	 * @author 
	 */
	public class WishListManager
	{
		
		public static const MAX_COUNT:uint = 4;
		public static const DURATION:uint = 86400;
		private static var _totalFriendsRequests:int = 0;
		public static var friendsRequests:Object = {};
		
		public function WishListManager()
		{
			
		}
		
		public static function pushRequest(sid:String, uid:String):void 
		{
			if (!friendsRequests.hasOwnProperty(sid)) 
			{
				friendsRequests[sid] = [];
			}
			//if (App.user.friends && Gifts.canTakeFreeGift(uid))
				friendsRequests[sid].push(uid);
		}
		
		public static function refreshRequest():void 
		{
			for (var sid:String in friendsRequests) 
			{
				for each(var uid:String in friendsRequests[sid])
				{
					if (!Gifts.canTakeFreeGift(uid))
						friendsRequests[sid].splice(friendsRequests[sid].indexOf(uid), 1);
				}
			}
		}
		public static function removeUserRequests(uid:String):void 
		{
			for (var sid:String in friendsRequests) 
			{
				friendsRequests[sid].splice(friendsRequests[sid].indexOf(uid), 1);
			}
		}
		
		public static function getRequestCount(sid:String):int 
		{
			refreshRequest();
			var lengthRequest:int = 0;
			if (friendsRequests.hasOwnProperty(sid))
				lengthRequest = friendsRequests[sid].length;
			return lengthRequest;
		}
		
		public static function get totalFriendsRequests():int 
		{
			refreshRequest();
			var result:int = 0;
			for (var sid:String in friendsRequests) 
			{
				result += friendsRequests[sid].length;
			}
			return result;
		}
		
		public static function get count():int 
		{
			return Numbers.countProps(App.user.wishlist);
		}
		
		public static function getTime(sID:int):uint 
		{
			if(App.user.wishlist.hasOwnProperty(sID))
				return App.user.wishlist[sID].t;
				
			return 0;
		}
		
		public static function getFriends(sID:int):Array 
		{
			if(App.user.wishlist.hasOwnProperty(sID))
				return App.user.wishlist[sID].f;
				
			return [];
		}	
		
		public static function add(sID:int, friends:Array):Boolean 
		{
			if (!App.user.wishlist.hasOwnProperty(sID))
			{
				if (count >= MAX_COUNT)
					return false;
					
				App.user.wishlist[sID] = {
					f:[],
					t:App.time + DURATION
				}
			}
			
			Post.send( {
				ctr:'wishlist',
				act:'add',
				uID:App.user.id,
				sID:sID,
				friends:JSON.stringify(friends)
			}, function():void { 
				App.user.wishlist[sID].f = App.user.wishlist[sID].f.concat(friends);
			} );
			
			return true;
		}
	}	
	
}