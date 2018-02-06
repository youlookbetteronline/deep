package units 
{
	import core.Post;
	import core.TimeConverter;
	import flash.geom.Point;
	import models.BankerModel;
	import ui.UnitIcon;
	import wins.BankerWindow;
	import wins.Window;
	/**
	 * ...
	 * @author das
	 */
	public class Banker extends Techno 
	{
		private var _model:BankerModel;
		public function Banker(object:Object) 
		{
			super(object);
			initModel(object);
			showIcon();
			startAccumulation();
			tip = function():Object{
				return parseTips();
			}
			//removable = true;
		}
		
		private function initModel(params:Object):void 
		{
			
			_model = new BankerModel();
			if (params.storageTime)
				_model.storageTime = params.storageTime;
			if (params.storageTime && params.storageTime < App.time)
				_model.tribute = true;
			/*if (App.user.data.user.loyalty && App.user.data.user.loyalty.hasOwnProperty(info.mtake))
				BankerModel.loyalty = App.user.data.user.loyalty;*/
			_model.storageCallback = storageEvent;
		}
		
		private function parseTips():Object{
			if (App.user.mode == User.GUEST)
			{
				return{
					title:		info.title,
					text:		info.description
				}
			}
			else if (_model.tribute)
			{
				return{
					title:		info.title,
					text:		Locale.__e('flash:1508335692298')
				}
			}
			else
			{
				return {
					title:		info.title,
					text:		Locale.__e('flash:1508331757663') + ' ' + App.data.storage[info.madd].title + ' - ' + BankerModel.loyalty[info.madd].count + '\n' + 
					info.description
				};
			}
		}
		
		override public function click():Boolean 
		{
			
			if (App.user.mode == User.GUEST)
				return false;
			else
			{
				new BankerWindow({
					model:_model,
					target:this
				}).show();
				return true;
			}
			
		}
		
		private function startAccumulation():void 
		{
			_model.tribute = false;
			App.self.setOnTimer(accumulation);
		}
		
		private function accumulation():void
		{
			if (App.time >= _model.storageTime)
				onAccumulationComplete();
		}
		
		private function onAccumulationComplete():void
		{
			App.self.setOffTimer(accumulation);
			_model.tribute = true;
			showIcon();
		}
		
		override public function showIcon():void 
		{
			if (App.user.mode == User.GUEST){
				clearIcon();
				return;
			}
			else
			{
				initCoordsCloud();
				if (_model.tribute)
				{
					var _view:int = info.madd;						
					drawIcon(UnitIcon.REWARD, _view, 1, {
					glow:		true
					}, 0, coordsCloud.x, coordsCloud.y);
				}
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
			
			_model.tribute = false;
		}
		
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			Window.closeAll();
			if (data.loyalty)
				BankerModel.loyalty = data.loyalty;
			if (data.died)
			{
				this.removable = true;
				this.uninstall();
			}
			_model.storageTime = App.time + info.time;
			_model.tribute = false;
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			if(data.added)
				Treasures.bonus(data.added, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			startAccumulation();
			clearIcon();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			if (data.storageTime)
				_model.storageTime = data.storageTime;
			if (App.user.data.user.loyalty && App.user.data.user.loyalty.hasOwnProperty(info.mtake))
				BankerModel.loyalty = App.user.data.user.loyalty;
			startAccumulation();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			if (data.storageTime)
				_model.storageTime = data.storageTime;
			if (App.user.data.user.loyalty && App.user.data.user.loyalty.hasOwnProperty(info.mtake))
				BankerModel.loyalty = App.user.data.user.loyalty;
			if (data.loyalty)
				BankerModel.loyalty = data.loyalty
			startAccumulation();
		}
		
	}

}
