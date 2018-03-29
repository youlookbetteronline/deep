package units 
{
	import buttons.Button;
	import core.Post;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import utils.Finder;
	import utils.Locker;
	import utils.TopHelper;
	import wins.HorseCompetitionWindow;
	import wins.HorseUpgradeWindow;
	import wins.SimpleWindow;
	import wins.HippodromeMainWindow;
	import wins.SimpleWindow;
	import wins.TopRewardWindow;
	/**
	 * ...
	 * @author 
	 */
	public class Hippodrome extends Building 
	{
		public var growNeed:Object;
		public var players:Object;
		public var floor:int = 0;
		public var games:int = 0;
		public var playTime:uint = 0;
		
		public static const WIN:int = 1;
		public static const LOSE:int = 2;
		public static const DRAW:int = 3;
		
		public static const HOME:int = 7;
		public static const GUEST:int = 8;
		
		public function Hippodrome(object:Object) 
		{
			if (object.hasOwnProperty('players'))
				players = object.players;
				
			if (object.hasOwnProperty('growNeed'))
				growNeed = object.growNeed;
				
			if (object.hasOwnProperty('floor'))
				floor = object.floor;
				
			if (object.hasOwnProperty('games'))
				games = object.games;
				
			if (object.hasOwnProperty('playTime'))
				playTime = object.playTime;
				
			super(object);
			
		}
		
		override public function click():Boolean
		{
			hidePointing();
			stopBlink();
			
			if (needQuest != 0 && App.user.mode == User.OWNER)
			{
				if (!App.user.quests.data.hasOwnProperty(needQuest))
				{
					new SimpleWindow( {
						title			:Locale.__e("flash:1481879219779"),
						label			:SimpleWindow.ATTENTION,
						text			:Locale.__e('flash:1481878959561', App.data.quests[needQuest].title),
						confirmText		:Locale.__e('flash:1504271459817'),
						cancelText		:Locale.__e('flash:1504271483291'),
						faderAsClose	:false,
						escExit			:false,
						popup			:true,
						dialog			:true,
						confirm:function():void {
							Finder.questInUser(needQuest);
						},
						cancel:function():void {
							Finder.questInUser(needQuest, true);
						}
					}).show();
					/*new SimpleWindow( {
						title:Locale.__e("flash:1481879219779"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1481878959561', App.data.quests[needQuest].title)
					}).show();*/
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
			
			if (!isReadyToWork()) 
				return true;
			
			if (isPresent()) 
				return true;
			
			if (isProduct()) 
				return true;
			
			if (openConstructWindow()) 
				return true;
			
			//openUpgrade();			
			openMainWindow();			
			
			return true;
		}
		
		override public function guestClick():void 
		{
			//Locker.blockClick();
			//return;
			if (level < totalLevels)
				return;
			if (guestDone) return;
			
			if (players.hasOwnProperty(App.user.id) && players[App.user.id] > App.time)
			{
				new SimpleWindow( {
					title:Locale.__e("flash:1481879219779"),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1494490267345')
				}).show();
				return;
			}
				
			if (!App.user.friends.takeGuestEnergy(App.owner.id)) 
				return;
				
			new HorseCompetitionWindow( {
				title		:Locale.__e('flash:1494340775437'),
				target		:this,
				popup		:true,
				friend		:App.owner,
				mode		:Hippodrome.GUEST
				
			}).show();
			
		}
		
		override public function onBoostEvent(count:int = 0):void 
		{
			if (App.user.stock.count(Stock.FANT) < count) 
				return;
			
			var postObject:Object = {
				ctr:this.type,
				act:'skip',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			};
			
			/*if (freeBoostsFor.length > 0 && freeBoostsFor.indexOf(fID) >= 0)
			{
				postObject["t"] = 1;
			}
			else
			{*/
				App.user.stock.take(Stock.FANT, count);
			//}
			var self:Hippodrome = this;
			Post.send(postObject, function(error:*, data:*, params:*):void {
				ordered = false;
				if (error) {
					Errors.show(error, data);
					return;
				}
				if (data.hasOwnProperty('playTime'))
					self.playTime = data.playTime;
			});
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			else 
			{
				level = data.level;
				hasUpgraded = false;
				hasBuilded = true;
				upgradedTime = data.upgrade;
				App.self.setOnTimer(upgraded);
				
				addEffect(Building.BUILD);
				showIcon();
				
				if (data.bonus)
				{
					Treasures.bonus(Treasures.convert(data.bonus), new Point(this.x, this.y));
				}
				
				if (data.hasOwnProperty('growNeed'))
					growNeed = data.growNeed;
				
				ordered = false;
			}
		}
		
		/*private function openUpgrade():void{
			if (level < totalLevels)
			{
				return;
			}
			new HorseUpgradeWindow( {
				title:			info.title,
				'upgTime':		0,
				request:		growNeed,
				target:			this,
				win:			this,
				onUpgrade:		upgradeEvent,
				hasDescription:	true,
				popup:			false
			}).show();
		}*/
		
		public function openMainWindow():void 
		{			
			if (level < totalLevels)
				return;
				
			if (checkReward())
				return;
			
			new HippodromeMainWindow( {
				title	:info.title,
				target	:this
			}).show();
		}
		
		public function checkReward():Boolean
		{
			var topID:int = TopHelper.getTopID(this.sid);
			var istanceTop:int = TopHelper.getTopInstance(TopHelper.getTopID(this.sid)) - 1;
			if (App.user.data.user.top && App.user.data.user.top.hasOwnProperty(topID) && App.user.data.user.top[topID][istanceTop])
			{
				var bonusInfo:Object = App.user.data.user.top[topID][istanceTop];
				if (bonusInfo.hasOwnProperty('tbonus') && bonusInfo['tbonus'])
				{
					Post.send( {
						ctr:	'top',
						act:	'tbonus',
						uID:	App.user.id,
						tID:	topID,
						iID:	istanceTop
					}, function(error:int, data:Object, params:Object):void {
						if (error) 
							return;
						if (data.hasOwnProperty('bonus'))
						{
							new TopRewardWindow({reward:Treasures.convert2(data.bonus)}).show();
						}
						delete App.user.data.user.top[topID][istanceTop]['tbonus'];
					});
					return true;
				}
				
				if (bonusInfo.hasOwnProperty('lbonus') && bonusInfo['lbonus'])
				{
					Post.send( {
						ctr:	'top',
						act:	'lbonus',
						uID:	App.user.id,
						tID:	topID,
						iID:	istanceTop
					}, function(error:int, data:Object, params:Object):void {
						if (error) 
							return;
						if (data.hasOwnProperty('bonus'))
						{
							new TopRewardWindow({reward:Treasures.convert2(data.bonus)}).show();
						}
						delete App.user.data.user.top[topID][istanceTop]['lbonus'];
					});
					return true;
				}
			}
			return false;
		}
		
		public function growEvent(params:Object):void 
		{
			if (level < totalLevels)
				return;
			
			var price:Object = { };
			for (var sID:* in params) 
			{
				price[sID] = params[sID];
			}
			
			// Забираем материалы со склада
			if (!App.user.stock.takeAll(price)) return;
			
			var instances:int = instanceNumber();
			
			Post.send( {
				ctr:this.type,
				act:'grow',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				iID:instances
			},onGrowEvent, params);
		}
		
		public function onGrowEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			else 
			{
				if (data.floor)
					floor = data.floor;
				if (data.growNeed)
					growNeed = data.growNeed;
				if (data.bonus)
				{
					Treasures.bonus(Treasures.convert(data.bonus), new Point(this.x, this.y));
				}
				click();
			}
		}
		
		public function onOpenUpgWindow():void
		{
			new HorseUpgradeWindow( {
				title:			info.title,
				'upgTime':		0,
				request:		growNeed,
				target:			this,
				win:			this,
				onUpgrade:		growEvent,
				hasDescription:	true,
				popup:			false
			}).show();
		}
		
		override public function showIcon():void 
		{
			if (App.user.mode == User.GUEST)
				return;
			super.showIcon();
		}
		
	}

}