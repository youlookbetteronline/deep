package units 
{
	import core.Post;
	import models.BathyscapheModel;
	import utils.Locker;
	import wins.BathyscapheWindow;
	/**
	 * ...
	 * @author das
	 */
	public class Bathyscaphe extends Building 
	{
		private var _model:BathyscapheModel;
		private var _currentThrow:int;
		public function Bathyscaphe(object:Object) 
		{
			super(object);
			initModel(object);
			initToUser();
			currentThrow = _model.throws
			if (App.user.worldID != User.SYNOPTIK_MAP)
			{
				this.uninstall();
			}
			
		}
		
		private function initModel(params:Object):void 
		{
			_model = new BathyscapheModel();
			_model.throwCallback = throwEvent;
			_model.throws = params.throws;
			_model.limitThrows = info.lthrow;
			_model.materialThrows = info.mthrow;
		}
		
		private function initToUser():void 
		{
			App.user.bathyscaphe = this;
		}
		override public function showIcon():void 
		{
			if (level >= 8 && !Config.admin)
				return ;
			super.showIcon();
		}
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST)
				return false;
			/*if (level >= 8 && !Config.admin)
			{
				Locker.availableUpdate();
				return false;
			}*/
			if (level != totalLevels || openConstructWindow()) 
				return openConstructWindow()
			else
			{
				new BathyscapheWindow({
					target:	this,
					model:	_model
				}).show();
				return true;
			}
		}
		
		
		private function throwEvent(count:int, throwCallback:Function):void
		{			
			Post.send({
				ctr		:this.type,
				act		:'throw',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				count	:count
			}, onThrowEvent, {
				throwCallback:throwCallback
			});
		}
		
		private function onThrowEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			if (data.unit && data.unit.throws)
			{
				_model.throws = data.unit.throws;
				currentThrow = data.unit.throws;
			}
			App.user.stock.takeAll(data.__take);
			params.throwCallback();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			initToUser()
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			initToUser()
		}
		
		public function get currentThrow():int 
		{
			return _currentThrow;
		}
		
		public function set currentThrow(value:int):void 
		{
			_currentThrow = value;
		}
		
		override public function take():void 
		{
			if (App.user.worldID != User.SYNOPTIK_MAP)
				return;
			super.take();
		}
		
	}

}