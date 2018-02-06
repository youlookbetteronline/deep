/**
 * Created by Andrew on 10.05.2017.
 */
package units
{
	import com.google.analytics.ecommerce.Item;
	import utils.ObjectsContent;
	import wins.SimpleWindow;

	import core.Numbers;
	import core.Numbers;
	import core.Post;

	import flash.net.navigateToURL;

	import flashx.textLayout.operations.MoveChildrenOperation;

	import wins.ggame.GGameEvent;
	import wins.ggame.GGameModel;
	import wins.ggame.GGameWindow;
	import wins.ggame.ItemVO;
	import wins.ggame.result.ResultModel;

	public class GGame extends Building
	{
		private var _startActionInProgress:Boolean = false;
		private var _saveActionInProgress:Boolean = false;
		private var _items:Array = [];
		private var _model:GGameModel;

		public function GGame(object:Object)
		{
			super(object);

			initModel();
			
		}

		/**
		 * создаем модель данных
		 */
		private function initModel():void {
			_model = GGameModel.instance;

			_model.gameStartCallback        = startAction;
			_model.saveGameStartCallback    = saveAction;
			_model.raundTime                = info.time;
			_model.minElements              = info.minTimes;
			_model.title                    = info.title;
			_model.maxOnScreen              = info.maxElements;
			_model.startPrice               = info.startprice;
			_model.catchPrice               = info.catchprice;
			_model.uniqItems                = convertItemsToVO();
		}

		/**
		 * Простая коынвертацию предметов что мы получаем из админки в объекты VO
		 */
		private function convertItemsToVO():Vector.<ItemVO> {
			var returnValue:Vector.<ItemVO> = new Vector.<ItemVO>();

			for(var id:String in info.lots.lot)
			{
				returnValue.push(new ItemVO(info.lots.lot[id],
											info.lots.s[id],
											info.lots.percent[id])
				);
			}

			return returnValue;
		}

		/*override public function openProductionWindow(settings:Object = null):void {
			new GGameWindow().show();
		}*/
		
		override public function click():Boolean 
		{
			var _quest:int = 718;//квест по блоку миниигры
			if (App.user.mode == User.OWNER)
			{
				if (!App.data.quests.hasOwnProperty(_quest)){
					new SimpleWindow({
						title:Locale.__e("flash:1481879219779"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1382952379805')
					}).show();
					return false;
				}
					
				if (!App.user.quests.data.hasOwnProperty(_quest))
				{
					new SimpleWindow({
						title:Locale.__e("flash:1481879219779"),
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1481878959561', App.data.quests[_quest].title)
					}).show();
					return false;
				}
			}else{
				return false;
			}
			new GGameWindow().show();
			return true;
		}

		/**
		 * Начало игры, списывается цена старта, и генерируется список длиною в count елементов
		 *
		 */
		public function startAction():void
		{
			if(_startActionInProgress || _saveActionInProgress)
				return;

			_startActionInProgress = true;
			Post.send({
				ctr:	type,
				act:	'start',
				sID:	sid,
				id:		id,
				wID:	App.user.worldID,
				uID:	App.user.id,
				count:      90
			}, function(error:int, data:Object, params:Object):void {
				_startActionInProgress = false;
				if (error) {
					Errors.show(error, data);
					return;
				}
				_model.reset();

				_items = Numbers.objectToArray(data.materials);

				_items.sortOn(function (a:*, b:*):int
				{
					return (Math.random()  > 0.5)?1:-1;
				});

				_model.itemsOrder = _items;

				App.user.stock.takeAll(_model.startPrice);

				dispatchEvent(new GGameEvent(GGameEvent.ON_GAME_START,true, true));
			});
		}

		/**
		 * сохранение статистики отправляем список sid:count что мы наловили, а нам присылают цену что нужно списать
		 *
		 */
		private function saveAction(callback:Function = null):void
		{
			if(_saveActionInProgress)
				return;

			_saveActionInProgress = true;
			Post.send({
				ctr:	type,
				act:	'finish',
				sID:	sid,
				id:		id,
				wID:	App.user.worldID,
				uID:	App.user.id,
				add:    JSON.stringify(_model.catched)
			}, function(error:int, data:Object, params:Object):void {
				_saveActionInProgress = false;
				if (error) {
					_model.reset();
					Errors.show(error, data);
					return;
				}
				if (_model.firstGame)
					App.user.storageStore('ggameplay', 1);
				if(App.user.stock.takeAll(data.price/*, true*/))
				{
					trace();
				}
				if(App.user.stock.addAll(_model.catched))
				{
					trace();
				}

				ResultModel.instance.wasted    				= data.price;
				ResultModel.instance.gained     			= _model.catched;
				ResultModel.instance.successGained     		= _model.successCatched;
				ResultModel.instance.successGainedCount     = _model.successCatchedCount;
				ResultModel.instance.gainedCount     		= _model.catchedCount;
				ResultModel.instance.title      			= Locale.__e('flash:1494408737447');
				ResultModel.instance.gainedText 			= Locale.__e('flash:1505123315837');
				ResultModel.instance.wastedText 			= Locale.__e('flash:1495010299447');
				ResultModel.instance.onClose    			= resultWindowClose;

				if(callback != null)
					callback();

				_model.catched = {};
			});
		}

		private function resultWindowClose():void
		{
			_model.reset();
		}
	}
}
