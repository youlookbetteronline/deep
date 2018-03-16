package utils 
{
	import core.Numbers;
	import core.Post;
	import wins.BubbleSimpleWindow;
	import wins.TopBubbleWindow;
	import wins.TopResultWindow;
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

		public static function getTopID(targetSid:int):int
		{
			for (var _t:* in App.data.top)
			{
				if (App.data.top[_t].target == targetSid)
				{
					if (!App.data.top[_t].expire || App.data.top[_t].expire.s > App.time || App.data.top[_t].expire.e < App.time)
						continue;
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
			if (!top)
			{
				new BubbleSimpleWindow({
					popup	:true,
					title	:Locale.__e('flash:1474469531767'),
					label	:Locale.__e('flash:1520250885239')
				}).show();
				return;
			}
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
			content = content.sortOn('points', Array.NUMERIC | Array.DESCENDING);
			var windowSettings:Object = {
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
			}
			switch (App.data.top[top].window)
			{
				case 'TopBubbleWindow':
					new TopBubbleWindow(windowSettings).show();
					break
				default:
					new TopWindow(windowSettings).show();
			}
			//getReward();
			
			
			//close();
		}
		
		public static function checkRewards():void
		{
			for (var _top:* in App.user.top)
			{
				if (App.data.top[_top].checkreward) //TODO поле на старт
				{
					for (var _inst:* in App.user.top[_top])
					{
						var bonus:Object = {}
						if (App.user.top[_top][_inst].hasOwnProperty('tbonus') && App.user.top[_top][_inst].tbonus)
						{
							for (var tb:* in App.user.top[_top][_inst].tbonus)
								bonus[tb] = Numbers.firstProp(App.user.top[_top][_inst].tbonus[tb]).key * Numbers.firstProp(App.user.top[_top][_inst].tbonus[tb]).val
							new TopResultWindow({
								bonus		:bonus,
								position	:App.user.top[_top][_inst].position,
								topName		:App.data.top[_top].title,
								type		:'tbonus',
								iID			:_inst,
								tID			:_top
							}).show();
							
						}
						else if (App.user.top[_top][_inst].hasOwnProperty('lbonus') && App.user.top[_top][_inst].lbonus)
						{
							for (var lb:* in App.user.top[_top][_inst].lbonus)
								bonus[lb] = Numbers.firstProp(App.user.top[_top][_inst].lbonus[lb]).key * Numbers.firstProp(App.user.top[_top][_inst].lbonus[lb]).val
							if (!bonus || Numbers.countProps(bonus) == 0)
								return;
							new TopResultWindow({
								bonus		:bonus,
								position	:App.user.top[_top][_inst].position,
								topName		:App.data.top[_top].title,
								type		:'lbonus',
								iID			:_inst,
								tID			:_top
							}).show();

						}
					}
				}
			}
		}
		
		public static function getReward(tID:int, iID:int, type:String, callback:Function):void 
		{
			Post.send( {
				ctr:	'top',
				act:	type,
				uID:	App.user.id,
				tID:	tID,
				iID:	iID
			}, onRewardEvent, {
				tID		:tID,
				iID		:iID,
				callback: callback
			});
		}
		
		private static function onRewardEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.hasOwnProperty('bonus'))
			{
				var bonus:Object = {}
				for (var tb:* in data.bonus)
					bonus[tb] = Numbers.firstProp(data.bonus[tb]).key * Numbers.firstProp(data.bonus[tb]).val
				params.callback(bonus);
			}
			delete App.user.data.user.top[params.tID][params.iID]['tbonus'];
		}
		
	}

}