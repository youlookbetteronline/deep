package utils 
{
	import core.Numbers;
	import core.Post;
	import wins.TopWindow;
	/**
	 * ...
	 * @author 
	 */
	public class TopHelper 
	{
		public static const WINNER:int = 1;
		public static const LOOSER:int = 2;
		public function TopHelper() 
		{	}
		private static var expire:int;
		private static var top:int = 0;
		private static var targetSid:int = 0;
		private static var topNumber:int = 100;
		private static var topUsers:Object = {};
		private static var topRewerd:Object;
		
		public static var defUsers:Object = {
			50545195:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545196:{
				aka			 :'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545190:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545199:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545198:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545197:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			},50545198:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545199:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545200:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545201:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545202:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545203:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545204:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545204:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545205:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545206:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545207:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545208:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545209:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545210:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545211:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}, 50545212:{
				aka			:'First Name',
				photo		:'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',
				attraction	:int(Math.random()*1000)
			}
		};
		
		public static function getTopID(targetSid:int):int
		{
			for (var _t:* in App.data.top)
			{
				if (App.data.top[_t].target == targetSid)
				{
					return _t;
					break;
				}
			}
			return 0;
		}
		
		
		public static function getTopInstance(topId:int):int
		{
			if (App.data.top[topId])
			{
				//App.data.top[topId].expire.s = 1493835839;
				var timeFromStart:int = App.time - App.data.top[topId].expire.s;
				
				var idid:int = Math.abs((timeFromStart)  / Numbers.WEEK);
				return idid;
			}
			
			return -1;
		}
		
		public static function showTopWindow(targetSid:int):void
		{
			TopHelper.targetSid = targetSid;
			top = TopHelper.getTopID(targetSid);
			expire = App.data.top[top].expire.e;
			onTop100();
		}
		
		
		private static function onTop100():void 
		{	
			Post.send( {
				ctr:		'top',
				act:		'users',
				uID:		App.user.id,
				tID:		top
			}, function(error:int, data:Object, params:Object):void {
				if (error) 
					return;
				
				if (data.hasOwnProperty('users'))
					topUsers = data['users'] /*defUsers*/;

				if (Numbers.countProps(topUsers) > topNumber) 
				{
					var array:Array = [];
					
					for (var s:* in topUsers) 
					{
						array.push(topUsers[s]);
					}
					
					array.sortOn('points', Array.NUMERIC | Array.DESCENDING);
					array = array.splice(0, topNumber);
					
					for (s in topUsers) 
					{
						if (array.indexOf(topUsers[s]) < 0)
							delete topUsers[s];
					}
				}
				
				//changeRate();
			
				/*if (onUpdateRate != null) {
					onUpdateRate();
					onUpdateRate = null;
				}*/
				onTop100Show();
			});
		}
		
		private static function onTop100Show():void 
		{
			var info:* = App.data.storage[targetSid];
			var content:Array = [];
			var k:int = 0;
			for (var s:* in topUsers)
			{
				var user:Object = topUsers[s];
				user['uID'] = s;
				content.push(user);
				k++
			}
			var top100DescText:String =  App.data.top[top].description;// Locale.__e('flash:1467807241824');
			//getReward();
			new TopWindow( {
				target		:null,
				title		:info.title,
				expire		:expire, 
				content		:content,
				description	:top100DescText,
				max			:topNumber,
				info		:info,
				sid			:targetSid,
				top			:App.data.top[top],
				popup		:true
			}).show();
			
			//close();
		}
		
	}

}