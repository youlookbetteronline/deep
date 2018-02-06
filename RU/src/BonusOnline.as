package 
{
	import core.Numbers;
	import core.Post;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import ui.Hints;
	import wins.BonusOnlineWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ... ich
	 */
	public class BonusOnline 
	{
		private var init:Boolean = false;
		private var _visitTime:int = 0; //seconds
		private var lastTime:uint = 0; //seconds
		public var bonus:Object = { };
		public var info:Object;
		public var ID:int;
		public var bID:int;
		private var win:BonusOnlineWindow;
		public function get active():Boolean
		{
			var flag:Boolean = true;
			for each (var val:int in info.devel.req )
				if ( val >= visitTime)
					flag = false;
			return init &&  Numbers.countProps(bonus) < Numbers.countProps(info.devel.req);
		}
		private var isUpdate:Boolean;
		public function get canTakeReward():Boolean
		{
			/*var count:int = 0;
			for each(var val:int in info.devel.req)
			{
				if (val < App.user.bonusOnline.visitTime)
					count++;
			}
			if (!isUpdate && Numbers.countProps(bonus) < count)
			{
				App.user.stock.checkSystem();
				isUpdate = true;
			}*/
			return /*Numbers.countProps(bonus) < count*/nextTimePoint <= 0;
		}
		
		public var thisTime:int = App.time;
		public var numberBonus:int;
		public function get nextTimePoint():Number
		{
			var re:int = 0;
			numberBonus = Numbers.countProps(App.user.bonusOnline.bonus);
			if (numberBonus <= 0){
				numberBonus = 0;
			//if (numberBonus == 0)
				//re = App.user.data.user.createtime
				re = Numbers.getProp(info.devel.req, numberBonus).val + App.user.bonusOnline.visitTime - App.time;
			}else{
				re = Numbers.getProp(info.devel.req, numberBonus).val + App.user.bonusOnline.visitTime - App.time;
			
			}
			if (numberBonus >= 1)
				re -= Numbers.getProp(info.devel.req, numberBonus-1).val;
			//else
				//re -= 
			if (re < 0)
				re = 0;
			//if(App.time > re)
			/*for each(var val:int in info.devel.req)
			{
				re = val;
				if (val > App.user.bonusOnline.visitTime)
					break;
			}*/
			return re;
		}
		
		public function get showIcon():Boolean
		{
			return init && Numbers.countProps(bonus) < Numbers.countProps(info.devel.req);
		}
		public function BonusOnline(data:Object) 
		{
			for (var key:String in App.data.bonus)
			{
				if ( App.data.bonus[key].type == 'MPresent')
				{
					info = App.data.bonus[key];
					ID = int (key);
					break;
				}
			}
			//return;
			//data['present'] = {
				//'time':App.data.bonus[1].devel.req[1], 
				//'bonus':App.data.bonus[1].devel.obj[1]
			//}
			
			if (data.hasOwnProperty('present'))
			{
				if (App.user.id == '1')
					return;
				init = true;
				var numberBonus:int = Numbers.countProps(data.present.bonus);
				if (numberBonus <= 0)
				{
					if ( data.present.time )
						_visitTime = data.present.time;
					if ( data.present.bonus )
						bonus = data.present.bonus;
				}else
				{
					if ( data.present.bonus[numberBonus] )
						_visitTime = data.present.bonus[numberBonus];
					if ( data.present.bonus )
						bonus = data.present.bonus;
				}
			}else{
				init = true;
				_visitTime = App.time;
				takeBonus();
			}
			App.self.setOnTimer(updateTimer);
		}
		public function takeBonus(bonID:int = -1/*, win:BonusOnlineWindow*/):void
		{
			var point:Point = new Point(App.self.windowContainer.mouseX, App.self.windowContainer.mouseY);
			//bID = 2;
			Post.send({
				'ctr':'bonus',
				'act':'present',
				'uID':App.user.id,
				'wID':App.user.worldID,
				'sID':ID,
				'bID':bonID
			}, function(error:*, data:*, params:*):void {
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				bID = bonID;
				if (data.bonus && data.bonus.hasOwnProperty("bonus")) 
					return;
					
				if (data && data.hasOwnProperty("bonus")) 
				{
					Hints.plusAll(data.bonus, point, App.self.windowContainer);
					BonusItem.takeRewards( data.bonus, point);
					App.user.stock.addAll( data.bonus);
				}
				App.user.bonusOnline.bonus[bonID] = App.time;
				_visitTime = App.time;
				/*if (data.bonus && data.bonus.hasOwnProperty("time")) {
					lastTime = data.bonus.time;
				}*/
				/*for (var key:String in info.devel.req)
				{
					if (info.devel.req[key] <= visitTime)
						bonus[key] = App.time;
				}*/
				App.ui.upPanel.update();
				isUpdate = false;
			});
			
		}
		private function updateTimer():void {
			
			thisTime++;
		}
		public function set visitTime(value:uint):void{
			_visitTime = value;
		}
		public function get visitTime():uint{
			return _visitTime;
		}
		public function dispose():void
		{
			App.self.setOffTimer(updateTimer);
		}
	}

}