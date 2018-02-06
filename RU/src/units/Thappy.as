package units
{
	import wins.happy.HappyWindow;
	import com.greensock.TweenLite;
	import core.Numbers;
	import flash.display.Bitmap;
	import wins.happy.IslandChallengeWindow;
	import wins.happy.WinnerWindow;
	import wins.TopWindow;
	import core.Post;
	import ui.Hints;
	import wins.happy.ThappyWindow;
	import wins.ShopWindow;
	
	public class Thappy extends Happy
	{
		public static var LEFT:int = 1;
		public static var RIGHT:int = 2;
		public static var CLOSE:int = -1;
		
		public var topID:int = 0;						//D
		public var totalTowerLevels:int = 0;			//D
		//public var kickCallback:Function;				//D
		public var topx:int = 100;
		
		public function Thappy(object:Object)
		{
			team = object.team || 1;
			//takeBonus = object.take || 0;
			super(object);
			
			for (var topID:* in App.data.top)
			{			//D
				if (App.data.top[topID].target == this.sid)
				{
					this.topID = topID;
					break;
				}
			}
			//if(topID)															//D !!!
				expire = App.data.top[topID].expire.e;
			//else
				//expire = App.time-1000;
				
				
			takeBonus = (App.user.top.hasOwnProperty(topID) && App.user.top[topID].hasOwnProperty('cbonus')) ? App.user.top[topID].cbonus : 0;
			
			if (info.hasOwnProperty('teams'))
			{
				totalTowerLevels = Numbers.countProps(info.teams[team].levels.c);
			}
			
			//if (takeBonus == 0)
				//removable = false;
			//else
			removable = false;						// D расскоментить при выкладывании  !!!
			stockable = false;
			
			if (expire < App.time )
			{
				//stockable = true;
				removable = true;
			}
		}
		
		//public function get viewTeam():Object
		//{
			//var re:Object = {1: 'banditPic', 2: 'huntsmanPic'}
			//return re;
		//}
		public var team:int = 1;
		public var takeBonus:int = 0;
		private var _rate:Object = {};
		public var rateChecked:int = 0;
		private const period:int = 300;
		
		public function get rate():Object
		{
			var re:Object = {1: (team == 1) ? _rate[1] + kicks : _rate[1], 2: (team == 2) ? _rate[2] + kicks : _rate[2]};
			return re;
		}
		private var _users:Object = {};
		
		public function get usersRate():Object
		{
			return _users;
		}
		
		public function set rate(object:Object):void
		{
			object = {1: (team == 1) ? object[1] - kicks : object[1], 2: (team == 2) ? object[2] - kicks : object[2]};
			_rate = object;
		}
		
		public function getRate(callback:Function = null):void
		{
			Post.send({ctr: 'top', act: 'users', uID: App.user.id, tID: topID, league: App.user.level}, function(error:int, data:Object, params:Object):void
			{
				if (error) return;
				
				//rateChecked = App.time;
				
				if (data.hasOwnProperty('users'))
				{
					HappyWindow.rates = data['users'] || {};
					
					for (var id:* in HappyWindow.rates)
					{
						if (App.user.id == id)
						{
							//HappyWindow.rate = HappyWindow.rates[id]['points'];				///D
						}
						
						HappyWindow.rates[id]['uID'] = id;
					}
				}
				
				//if (App.user.top.hasOwnProperty(HappyWindow.topID)) {
				//HappyWindow.rate = (HappyWindow.rate > App.user.top[HappyWindow.topID].count) ? HappyWindow.rate : App.user.top[HappyWindow.topID].count;
				//}
				
				if (Numbers.countProps(HappyWindow.rates) > topx)
				{
					var array:Array = [];
					for (var s:* in HappyWindow.rates)
					{
						array.push(HappyWindow.rates[s]);
					}
					array.sortOn('points', Array.NUMERIC | Array.DESCENDING);
					array = array.splice(0, topx);
					for (s in HappyWindow.rates)
					{
						if (array.indexOf(HappyWindow.rates[s]) < 0)
							delete HappyWindow.rates[s];
					}
				}
				
				if (callback != null)
					callback();
				rateChecked = App.time;
			});
		}
		
		public function getCommandRate(callback:Function = null):void
		{
			Post.send({ctr: 'top', act: 'teams', uID: App.user.id, tID: topID, league: App.user.level}, function(error:int, data:Object, params:Object):void
			{
				if (error) return;
					rate = {1: (data.teams && data.teams[1]) ? data.teams[1] : 0, 2: (data.teams && data.teams[2]) ? data.teams[2] : 0};
				if (data.rate)
				_users = data.rate.users;
				if (callback != null)
					callback();
			});
		}
		
		override public function click():Boolean
		{
			if (!clickable) return true;
			if (!isReadyToWork()) return true;
			
			if (takeBonus > 0) {
				Post.send( {
					ctr:		'top',
					act:		'users',
					uID:		App.user.id,
					tID:		this.topID  //App.user.topID
						}, function(error:int, data:Object, params:Object):void {
							if (error) 
								return;
							var content:Array = [];
							var k:int = 0;
							for (var s:* in data.users) {
								var user:Object = data.users[s];
								user['uID'] = s;
								content.push(user);
								k++;
							}	
							var top100DescText:String =  Locale.__e('flash:1467807241824');
							this.info = App.data.storage[sid];
							new TopWindow( {
								target:			this,
								content:		content,
								description:	top100DescText,
								max:			100,
								info:info =App.data.storage[sid]
								//top:topRewerd
							}).show();	
				})
					return false;
			}
			
			if (App.user.mode == User.OWNER)
			{
				if (isPresent()) return true;
				
				if (level < totalLevels)
				{
					hasUpgraded = true;
					openConstructWindow();
					return true;
				}
				
				if (expire < App.time)
				{
					WinnerWindow.target = this;
					if (!WinnerWindow.alreadyInitialized)
					{
						getCommandRate(function callback():void
						{
							WinnerWindow.init(function callback(data:Bitmap = null):void
							{
								new WinnerWindow({'view':info.teams[team].info.view}).show();
							});
						});
					}
					return true;
				}
				
				openProductionWindow();
			}
			
			return true;
		}
		
		override public function openProductionWindow():void
		{
			
			//override public function openProductionWindow(settings:Object = null):void {			//D
			var that:Thappy = this;
			getCommandRate(function callback():void
			{
				//that.sid
				that.upgrade = level;
				new ThappyWindow({target: that}).show();
			});
		}
		
		public function showTop():Boolean
		{
			if (!usersRate || Numbers.countProps(usersRate) == 0) return false;
			
			var content:Array = [];
			for (var s:* in usersRate)
			{
				var user:Object = usersRate[s];
				user['uID'] = s;
				content.push(user);
				if (!user.hasOwnProperty('first_name') && !user.hasOwnProperty('last_name'))
				{
					user['first_name'] = user['aka'];
					user['last_name'] = '';
				}
			}
			
			new TopWindow({target: this, content: content, description: '', max: 100, height: 650}).show();
			return true;
		}
		
		override public function buyAction(setts:*=null):void
		{
			var thappy:Thappy = this;
			SoundsManager.instance.playSFX('build');
			
			if (!World.canBuilding(sid)) return;
			
			var obj:Object;
			if (info.hasOwnProperty('instance'))
			{
				obj = info.instance.cost[World.getBuildingCount(sid) + App.user.stock.count(sid) + 1];
			}
			else if (info.hasOwnProperty('price'))
			{
				obj = info.price;
			}
			
			if (App.user.stock.checkAll(obj))
			{
				new IslandChallengeWindow({			//D
					onSelect: onSelect, onClose: onClose, target: this}).show();
			}
			else
			{
				ShopWindow.currentBuyObject.type = null;
				uninstall();
			}
		}
		
		private function onClose():void
		{
			clickable = false;
			TweenLite.to(this, 2, {alpha: 0, onComplete: uninstall});
		}
		
		private function onSelect(teamID:int):void
		{
			team = teamID;
			
			var obj:Object;
			if (info.hasOwnProperty('instance'))
			{
				obj = info.instance.cost[World.getBuildingCount(sid) + App.user.stock.count(sid) + 1];
			}
			else if (info.hasOwnProperty('price'))
			{
				obj = info.price;
			}
			
			if (!App.user.stock.takeAll(obj))
			{
				uninstall();
				return;
			}
			
			//if (expired < App.time)
			//return;
			
			//var instance:int = 0;
			//if ( App.user.instance.hasOwnProperty (sid ) )
			//App.user.instance[sid] ++;
			//else
			//App.user.instance[sid] = 1;
			//instance = App.user.instance[sid];
			//
			World.addBuilding(sid);
			Hints.buy(this);
			spit();
			
			Post.send({ctr: this.type, act: 'buy', uID: App.user.id, wID: App.user.worldID, sID: sid, x: coords.x, z: coords.z, iID: instance, team: teamID}, onBuyAction);
		}
		
		//override protected function onStockAction(error:int, data:Object, params:Object):void {
			//super.onStockAction(error, data, params);
				//for(var fm:* in App.data.storage[sid].teams[1].levels)
				//{
					//this.level++;
				//}
			//totalLevels = level;
			//updateLevel();
		//}
		
		override public function get kicksNeed():int
		{
			var _kicks:int = 0;
			if (info.teams[team].levels.c.hasOwnProperty(upgrade))
			{
				_kicks = info.teams[team].levels.c[upgrade];
			}
			return _kicks;
		}

	
	}

}