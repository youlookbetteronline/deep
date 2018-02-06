package units 
{
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.geom.Point;
	import models.UniversityModel;
	import wins.SimpleWindow;
	/**
	 * ...
	 * @author das
	 */
	public class University extends Building 
	{
		private var _model:UniversityModel;
		public function University(object:Object) 
		{
			super(object);
			initModel(object)
		}
		
		private function initModel(params:Object):void 
		{
			_model = new UniversityModel();
			_model.manufactures = manufactureList();
		}
		
		override protected function tips():Object 
		{
			if (App.user.mode == User.GUEST)
			{
				return {
					title:info.title,
					text:info.description
				};
			}
			
			var open:Boolean = App.map._aStarNodes[coords.x][coords.z].open;
			if (!open || !clickable || sid == PET_CAGE_SID || sid == GIRL_IN_TRAP_SID) 
			{
				return {
					title:info.title,
					text:info.description,
					timer:false
				};
			}
			else if (level < totalLevels)
			{
				return {
					title:info.title,
					text:Locale.__e("flash:1461569023187") + '. ' + Locale.__e('flash:1509456693290', App.data.storage[model.manufactures[0]].title),//Нажми чтобы достроить
					timer:false
				};
			}
			else if (hasProduct) 
			{
				var text:String = '';
				if (formula)
					text = App.data.storage[formula.out].title;
				
				return {
					title:info.title,
					text:Locale.__e("flash:1382952379845", [text]),
					timer:false
				};
			} 
			else if (created > 0 && !hasBuilded) 
			{
				return {
					title:info.title,
					text:Locale.__e('flash:1395412587100'),
					timerText:TimeConverter.timeToCuts(created - App.time, true, true),
					timer:true
				}
			} 
			else if (upgradedTime > 0 && !hasUpgraded) 
			{
				return {
					title:info.title,
					text:Locale.__e('flash:1395412562823'),
					timerText:TimeConverter.timeToCuts(upgradedTime - App.time, true, true),
					timer:true
				}
			} 
			
			var defText:String = '';
			var prevItm:String;
			
			if (defText.length > 0) 
			{
				return {
					title:info.title,
					text:Locale.__e('flash:1404823388967', [defText]),
					timer:false
				};
			} 
			else 
			{
				return {
					title:info.title,
					text:info.description
				};
			}
		}
		
		override public function click():Boolean 
		{
			if (level < totalLevels)
				return openConstructWindow()
			else
			{
				new SimpleWindow( {
					title:Locale.__e("flash:1474469531767"),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1509554123111', this.info.title),
					popup:true
				}).show();
				return true;
			}
		}
		
		override public function upgradeEvent(params:Object, fast:int = 0):void 
		{
			if (level  > totalLevels) 
			{
				return;
			}
			var price:Object = { };
			for (var sID:* in params) {
				price[sID] = params[sID];
			}			
			gloweble = true;
			var instances:int = instanceNumber();
			Post.send( {
				ctr:		this.type,
				act:		'upgrade',
				uID:		App.user.id,
				id:			this.id,
				wID:		App.user.worldID,
				sID:		this.sid,
				fast:		fast,
				iID:		instances,
				manufs:		JSON.stringify(searchManufactures())
			},onUpgradeEvent, params);
			
			ordered = true;
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
				if (data.__take)
					App.user.stock.takeAll(data.__take)
				
				if (data.manufs)
				{
					var manufs:Array = Numbers.objectToArray(data.manufs);
					for each(var man:* in manufs)
					{
						var unt:* = Map.findUnit(man.sID, man.id)
						unt.model.crafts = Numbers.objectToArray(man.crafts);
					}
				}
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
				ordered = false;
			}
		}
		
		private function manufactureList():Array 
		{
			var list:Array = [];
			for each(var item:* in App.data.storage)
			{
				if (item.hasOwnProperty('university'))
				{
					for each(var unId:int in item.university)
					{
						if (unId == this.sid)
							list.push(item.sID);
					}
				}
			}
			return list;
		}
		
		private function searchManufactures():Object 
		{
			var obj:Object = new Object();
			var tempObj:Array = Map.findUnits(_model.manufactures);
			for each(var univ:* in tempObj)
			{
				obj[univ.sid] = univ.id;
			}
			trace();
			return obj;
		}
		
		public function get model():UniversityModel 
		{
			return _model;
		}
		
		public function set model(value:UniversityModel):void 
		{
			_model = value;
		}
		
	}

}