package units 
{
	import core.Numbers;
	import core.Post;
	import models.ManufactureModel;
	import ui.Hints;
	import wins.ProductionWindow;
	import wins.ShopWindow;
	import wins.SpeedWindow;
	/**
	 * ...
	 * @author das
	 */
	public class Manufacture extends Building 
	{
		private var _model:ManufactureModel;
		public function Manufacture(object:Object) 
		{
			super(object);
			initModel(object);
			
		}
		
		private function initModel(params:Object):void 
		{
			_model = new ManufactureModel();
			if (params.crafts)
				_model.crafts = Numbers.objectToArray(params.crafts);
		}
		
		override public function openProductionWindow():void 
		{
			if (level < totalLevels)
			{
				return;
			}
			if (crafted > App.time) 
			{
				var priceSpeed:int = Math.ceil((crafted - App.time) / App.data.options['SpeedUpPrice']);
				new SpeedWindow( {
					title			:info.title,
					priceSpeed		:priceSpeed,
					target			:this,
					info			:info,
					finishTime		:crafted,
					totalTime		:App.data.crafting[model.crafts[0]].time,
					btmdIconType	:info.type,
					btmdIcon		:info.preview,
					doBoost			:onBoostEvent
				}).show();
				return;
			}				 			
			if (_model.crafts) 
			{		
				new ProductionWindow( {
					title:			info.title,
					mcrafts:		_model.crafts,
					target:			this,
					onCraftAction:	onCraftAction,
					hasPaginator:	true,
					hasButtons:		true,
					find:			helpTarget
				}).focusAndShow();
				
			}
		}
		
		private function searchUniversity():Object 
		{
			var obj:Object = new Object();
			var tempObj:Array = Map.findUnits(info.university);
			for each(var univ:* in tempObj)
			{
				obj[univ.sid] = univ.id;
			}
			trace();
			return obj;
		}
		
		override public function buyAction(setts:* = null):void 
		{
			if (!setts)
				setts = {};
			
			SoundsManager.instance.playSFX('build');
			
			var price:Object = Payments.itemPrice(sid);
			
			if (App.user.stock.takeAll(price)) {
				
				if(App.user.hero)
					Hints.buy(this);
				
				if (info.hasOwnProperty('instance')) {
					var instances:int = World.getBuildingCount(sid);
				}

				var params:Object = {
					ctr:	this.type,
					act:	'buy',
					uID:	App.user.id,
					ac:		(ShopWindow.currentBuyObject.currency)?1:0,
					wID:	(setts.hasOwnProperty('wID'))?setts.wID:App.user.worldID,
					sID:	this.sid,
					iID:	instances,
					x:		coords.x,
					z:		coords.z,
					univers:JSON.stringify(searchUniversity())
				};
				
				Post.send(params, onBuyAction);
				
			} else {
				ShopWindow.currentBuyObject.type = null;
				ShopWindow.currentBuyObject.currency = null;
				uninstall();
			}
			
			isBuyNow = false;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			super.onBuyAction(error, data, params);
			if (data.crafts)
				_model.crafts = Numbers.objectToArray(data.crafts);
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void 
		{
			super.onStockAction(error, data, params);
			if (data.crafts)
				_model.crafts = data.crafts;
		}
		
		public function get model():ManufactureModel 
		{
			return _model;
		}
		
		public function set model(value:ManufactureModel):void 
		{
			_model = value;
		}
		
	}

}