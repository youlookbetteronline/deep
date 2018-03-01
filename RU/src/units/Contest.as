package units 
{
	import core.Numbers;
	import core.Post;
	import flash.geom.Point;
	import models.ContestModel;
	import ui.UnitIcon;
	import wins.ContestWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Contest extends Techno 
	{
		private var _model:ContestModel;
		
		public function Contest(object:Object) 
		{
			super(object);
			initModel(object);
			showIcon();
			startWork();
			tip = function():Object{
				return parseTips();
			}
			touchableInGuest = true;
			
		}
		
		private function initModel(params:Object):void 
		{
			_model = new ContestModel();
			if (params.crafted)
				_model.crafted = params.crafted;
			if (params.toThrow)
				_model.toThrow = params.toThrow;			
			_model.kicks = params.kicks || 0;
			if (_model.crafted <= App.time)
				_model.tribute = true;			
			_model.floor = params.floor || 1;
			_model.totalFloor = Numbers.countProps(info.levels);
			_model.storageCallback = storageEvent;
			_model.throwCallback = throwEvent;
			_model.upgradeCallback = upgradeEvent;
		}
		
		private function parseTips():Object{
			return{
				title:		info.title,
				text:		info.description
			}
			
		}
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST)
			{
				return false;
			}
			new ContestWindow({
				model:	_model,
				target:	this
			}).show();
			return true;
		}
		
		private function startWork():void 
		{
			App.self.setOnTimer(work);
		}
		
		private function work():void
		{
			if (App.time >= _model.crafted)
				onProductionComplete();
		}
		
		private function onProductionComplete():void
		{
			App.self.setOffTimer(work);
			_model.tribute = true;
			_model.crafted = App.time;
			showIcon();
		}
		
		override public function showIcon():void 
		{
			if (App.user.mode == User.GUEST){
				clearIcon();
				return;
			}
			initCoordsCloud();
			if (_model.tribute)
			{
				var _view:int = Stock.COINS;
				if(info.hasOwnProperty('shake') && info.shake!="")
					for (var shake:* in App.data.treasures[info.shake][info.shake].item)
						if (Treasures.onlySystemMaterials(info.shake))
						{
							if (App.data.treasures[info.shake][info.shake].probability[shake] == 100)
								_view = App.data.treasures[info.shake][info.shake].item[shake]
						}
						else if (App.data.storage[App.data.treasures[info.shake][info.shake].item[shake]].mtype != 3 &&
							App.data.treasures[info.shake][info.shake].probability[shake] == 100){	
								_view = App.data.treasures[info.shake][info.shake].item[shake];
								break;
						}		
						
				drawIcon(UnitIcon.REWARD, _view, 1, {
					glow:		true
				}, 0, coordsCloud.x, coordsCloud.y);
			}
		}
		
		override public function storageEvent():void
		{
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent);
		}
		
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			_model.crafted = App.time + info.time;
			_model.tribute = false;
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			App.user.stock.addAll(data.bonus)
			SoundsManager.instance.playSFX('bonus');
			startWork();
			clearIcon();
		}
		
		public function throwEvent(typeThrow:String, throwCallback:Function):void
		{			
			Post.send({
				ctr	:this.type,
				act	:'throw',
				uID	:App.user.id,
				id	:this.id,
				wID	:App.user.worldID,
				sID	:this.sid,
				type:typeThrow
			}, onThrowEvent, {
				throwCallback:throwCallback
			});
		}
		
		public function onThrowEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			_model.toThrow = data.toThrow;
			_model.kicks = data.kicks;
			App.user.stock.takeAll(data.__take)
			params.throwCallback();
		}
		
		public function upgradeEvent(upgradeCallback:Function):void
		{			
			Post.send({
				ctr	:this.type,
				act	:'upgrade',
				uID	:App.user.id,
				id	:this.id,
				wID	:App.user.worldID,
				sID	:this.sid
			}, onUpgradeEvent, {
				upgradeCallback:upgradeCallback
			});
		}
		
		public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			_model.toThrow = data.toThrow;
			_model.floor = data.floor;
			if (data.bonus)
			{
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
				App.user.stock.addAll(data.bonus)
				SoundsManager.instance.playSFX('bonus');
			}
			params.upgradeCallback();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			if (data.toThrow)
				_model.toThrow = data.toThrow;
			startWork();
			goHome();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			if (data.toThrow)
				_model.toThrow = data.toThrow;
			startWork();
			goHome();
		}
	}

}