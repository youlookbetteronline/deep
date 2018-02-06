package utils 
{
	import com.greensock.TweenLite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.EventsManager;
	import ui.Hints;
	import units.Explode;
	import units.FakeHero;
	import units.Firework;
	import units.Personage;
	import units.Resource;
	import units.Unit;
	import wins.LockMapWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class SocketActions 
	{
		
		public static const not_key:String = 'ytf$%$yuGFis*&udh'
		public function SocketActions() 
		{
			
		}
		
		public static function checkUserTargets(uid:String):void
		{
			var userID:String = uid;
			if (SocketEventsHandler.personages.hasOwnProperty(uid))
			{
				/*if (App.user.addTarget({target: this, near: true, callback: onTakeResourceEvent, event: Personage.WORK, jobPosition: getContactPosition(), shortcutCheck: true, onStart: function(_target:* = null):void
				{ordered = false;}}))
				{
					if (App.user.mode == User.PUBLIC)
					{
						SocketActions.checkResource(this);
					}
					reserved++;
					balance = true;
				} else {
					ordered = false;
				}*/
				
				if (!SocketEventsHandler.personages[uid].currentTarget && SocketEventsHandler.personages[uid].targets.length > 0)
				{
					SocketEventsHandler.personages[uid].currentTarget = SocketEventsHandler.personages[uid].targets[0];
					SocketEventsHandler.personages[uid].currentTarget.reserved = 1;
					
					SocketEventsHandler.personages[uid].addTarget({target: SocketEventsHandler.personages[uid].currentTarget, near: true, callback: function():void 
					{
						trace('done');
						if(!SocketEventsHandler.personages.hasOwnProperty(userID))
							return;	
						SocketEventsHandler.personages[userID].currentTarget.reserved = 0;
						SocketEventsHandler.personages[userID].currentTarget = null;
						checkUserTargets(userID);
					}, event: Personage.WORK, jobPosition: SocketEventsHandler.personages[uid].currentTarget.getContactPosition(), shortcutCheck: true, onStart: function(_target:* = null):void
					{
						//ordered = false;
					}});
				}else
					SocketEventsHandler.personages[uid].onStop();
			}
		}
		
		public static function clearUserResources(uid:String):void
		{
			if (!SocketEventsHandler.personages.hasOwnProperty(uid))
				return;
			for each(var _res:* in SocketEventsHandler.personages[uid].targets)
			{
				_res.state = _res.DEFAULT
			}
			
			for each(var _fres:* in SocketEventsHandler.personages[uid].fireworkTargets)
			{
				_fres.state = _fres.DEFAULT
				_fres.busy = 0;
				_fres.clickable = true;
			}
			
			for (var _resID:* in SocketEventsHandler.objects['resources'])
			{
				if (SocketEventsHandler.objects['resources'][_resID] == uid)
				{
					delete SocketEventsHandler.objects['resources'][_resID];
				}
			}
			
			if (SocketEventsHandler.personages.hasOwnProperty(uid))
			{
				SocketEventsHandler.personages[uid].targets = [];
				SocketEventsHandler.personages[uid].onStop();
			}
		}
		
		public static function resourceReserve(uid:String, _resID:int, _resSID:int):void
		{
			if (SocketEventsHandler.personages.hasOwnProperty(uid))
			{
				var unit:Resource = Map.findUnit(_resSID, _resID);
				unit.state = unit.HIGHLIGHTED;
				SocketEventsHandler.personages[uid].targets.push(unit);
				checkUserTargets(uid);
			}
			SocketEventsHandler.objects['resources'][_resID] = uid;
		}
		
		public static function resourceFree(uid:String, _resID:int, _resSID:int):void
		{
			if (SocketEventsHandler.objects['resources'].hasOwnProperty(_resID) && 
				SocketEventsHandler.objects['resources'][_resID] == uid)
			{
				if (SocketEventsHandler.personages.hasOwnProperty(uid))
				{
					var unit:Resource = Map.findUnit(_resSID, _resID);
					/*if(!unit){
						checkUserTargets(uid);
					}*/
					unit.state = unit.DEFAULT;
					SocketEventsHandler.personages[uid].targets.splice(SocketEventsHandler.personages[uid].targets.indexOf(unit), 1);
					SocketEventsHandler.personages[uid].tm.dispose();
					SocketEventsHandler.personages[uid].finishJob();
					SocketEventsHandler.personages[uid].currentTarget.reserved = 0;
					SocketEventsHandler.personages[uid].currentTarget = null;
					if(unit.capacity < 1){
						unit.uninstall();
					}
					checkUserTargets(uid);
				}
				delete SocketEventsHandler.objects['resources'][_resID];
			}
		}
		
		//public static function createFakeHero(uid:String, obj:Object):Boolean
		//{
			//
		//}
		public static function reserveFirework(targets:*, uID:String, sID:int, iD:int):void 
		{
			var fireWork:Firework = Map.findUnit(sID, iD);
			if (!fireWork)
				return;
			if (!SocketEventsHandler.personages.hasOwnProperty(uID))
				return;
			fireWork.ownerID = uID;
			
			for each(var _val:* in targets)
			{
				var unit:Resource = Map.findUnit(_val[0], _val[1]);
				unit.busy = 1;
				unit.clickable = false;
				unit.state = unit.HIGHLIGHTED;
				SocketEventsHandler.personages[uID].fireworkTargets.push(unit);
				SocketEventsHandler.objects['resources'][iD] = uID;
			}
		}
		
		public static function generateDamage(targets:*, uID:String, sID:int, iD:int):void 
		{
			//var target:Resource;
			var damageLeft:int = App.data.storage[sID].capacity;
			var destroyed:Array = [];
			var damageTargets:Array = [];
			var fireWork:Firework = Map.findUnit(sID, iD);
			fireWork.clickable = false;
			for each(var _val:* in targets)
			{
				var unit:Resource = Map.findUnit(_val[0], _val[1]);
				//unit.state = unit.DEFAULT;
				unit.damage = _val[2];
				destroyed.push(unit)
			}
			
			/*while (damageLeft > 0)
			{
				if (damageTargets.length <= destroyed.length) break;
				
				for (var i:int = 0; i < damageTargets.length; i++)
				{
					target = damageTargets[i];
					if (destroyed.indexOf(target) != -1) continue;
					if (target.capacity - target.damage > 0)
					{
						target.damage ++;
						damageLeft --;
						if (damageLeft <= 0) break;
					} else {
						destroyed.push(target);
					}
				}
			}*/
			showExplodes(destroyed, uID, fireWork);
		}
		
		private static function showExplodes(damageTargets:Array, uID:String, fireWork:Firework):void
		{
			var counter:int = 0;
			var X:int = App.map.x;
			var Y:int = App.map.y;
			
			doExplode();
			var count:int = 0;
			var interval:int = setInterval(doExplode, 300);
			
			function doExplode():void 
			{
				if (counter >= damageTargets.length) 
				{
					clearInterval(interval);
					//hideTargets();
					//fireWork.isboom = false;
					TweenLite.to(fireWork, 1, { alpha:0, onComplete:fireWork.uninstall } );
					return;
				}
				
				var target:Resource = damageTargets[counter];
				
				if (target.damage != 0) 
				{
					setTimeout(function():void{
						if (SocketEventsHandler.personages.hasOwnProperty(uID))
						{
							if(SocketEventsHandler.objects['resources'].hasOwnProperty(target.id))
								delete SocketEventsHandler.objects['resources'][target.id];
							if (SocketEventsHandler.personages[uID].fireworkTargets.indexOf(target) != -1)
								SocketEventsHandler.personages[uID].fireworkTargets.splice(SocketEventsHandler.personages[uID].fireworkTargets.indexOf(target), 1);
						}
						target.showDamage(uID);
					}, 200);	
				}else{
					target.damage = 0;
					target.busy = 0;
					target.clickable = true;
				}
				
				var explode:Explode = new Explode(fireWork.explodeTextures);
				explode.scaleX = explode.scaleY = 0.75;
				explode.filters = [new GlowFilter(0xffFF00, 1, 15, 15, 4, 3)];
				explode.x = target.x;
				explode.y = target.y - 100;
				counter ++;	
			}
		}
		
		public static function createFakeHero(uid:String, obj:Object):void
		{
			if (SocketEventsHandler.personages.hasOwnProperty(uid))
				return;
			var fakeUnits:Array = Map.findUnitsByType(['FakeHero'])
			if (fakeUnits.length > 0)
			{
				for each(var _unit:* in fakeUnits)
				{
					if (SocketEventsHandler.personages.hasOwnProperty(_unit.owner.id))
					{
						break;
						return;
					}
				}
				
			}
				
			var heroSid:int = 0;
			if (obj.params.owner.sex == "m")
				heroSid = User.BOY;
			else
				heroSid = User.GIRL;
				
			var hero:FakeHero = new FakeHero(obj.params.owner, {sid:heroSid, id:8, x:obj.params.coords.x, z:obj.params.coords.z, aka:obj.aka} );
			SocketEventsHandler.personages[uid] = hero;
			if (obj.params.hasOwnProperty('fireworks'))
			{
				var fworks:* = JSON.parse(obj.params.fireworks);
				for each(var _fw:* in fworks)
				{
					var firework:Firework = Map.findUnit(_fw['sid'], _fw['id']);
					if (firework)
						SocketActions.reserveFirework(JSON.parse(_fw.targets), uid, _fw['sid'], _fw['id']);
				}
			}
			if (obj.params.hasOwnProperty('resources'))
			{
				var resources:* = JSON.parse(obj.params.resources);
				for each(var _res:* in resources)
				{
					SocketActions.resourceReserve(uid, _res['id'], _res['sid']);
					//var unit:Resource = Map.findUnit(_res['sid'], _res['id']);
					//if(unit)
						//SocketEventsHandler.personages[uid].targets.push(unit)
				}
				//SocketActions.checkUserTargets(uid);
			}
		}
		
		public static function checkUserResource(_res:*):Boolean
		{
			if (SocketEventsHandler.objects['resources'].hasOwnProperty(_res.id))
			{
				if (SocketEventsHandler.objects['resources'][_res.id] == App.user.id)
					return true;
			}else{
				return true;
			}
			return false
		}
		
		public static function checkResource(_res:*):Boolean
		{
			if (SocketEventsHandler.objects['resources'].hasOwnProperty(_res.id))
			{
				if (SocketEventsHandler.objects['resources'][_res.id] == App.user.id)
					return true;
				else
					return false
			}else{
				SocketEventsHandler.objects['resources'][_res.id] = App.user.id;
				Connection.sendMessage({
					u_event	:'resource_reserve', 
					aka		:App.user.aka, 
					params	:{iD:_res.id, sID:_res.sid}
				});
				return true;
			}
			return false;
		}
		
		public static function checkUsers(users:Array):void
		{
			for (var _pers:* in SocketEventsHandler.personages){
				if (String(_pers) == App.user.id)
					continue;
				if (users.indexOf(String(_pers)) == -1){
					EventsManager.addEvent( {
						ctr			:'leave',
						act			:'hero',
						titleText	:SocketEventsHandler.personages[_pers].aka,
						uID			:_pers,
						text		:Locale.__e('flash:1503069343042')
					});
					SocketActions.clearUserResources(String(_pers));
					SocketEventsHandler.personages[_pers].uninstall();
					delete SocketEventsHandler.personages[_pers];
				}
			}
		}
		private static var timeOut:uint = 1;
		private static var canRefresh:Boolean = true;
		private static function refreshTimeout():void
		{
			canRefresh = true;
			clearTimeout(timeOut);
		}
		
		public static function renewUsers(users:Array):void
		{
			if (!canRefresh)
				return;
				
			canRefresh = false;
			timeOut = setTimeout(refreshTimeout, 2000);
			SocketEventsHandler.personages = new Object();
			for each(var _user:* in users)
			{
				if (_user != App.user.id)
					Connection.sendMessage({u_event:'get_hero', uID:_user});
			}
		}
		
		public static function get lockAction():Boolean
		{
			if (App.user.mode == User.PUBLIC)
			{
				if (App.user.data['publicWorlds'][App.owner.worldID] == 0)
					return true;
				else
					return false;
			}
			else
				return false;
		}
		
		public static function lockStartMap():void
		{
			if (User.isOwner)
				new LockMapWindow( { } ).show();
			else
				Hints.text(Locale.__e('flash:1503907375605'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));

		}
		
	}

}