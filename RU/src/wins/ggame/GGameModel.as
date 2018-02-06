/**
 * Created by Andrew on 11.05.2017.
 */
package wins.ggame {
	import core.Numbers;

	public class GGameModel
	{
		private var _gameStartCallback:Function;
		private var _saveGameStartCallback:Function;

		private var _raundTime:int;
		private var _minElements:int;
		private var _maxOnScreen:int;

		private var _title:String;
		private var _itemsOrder:Array;

		private var _uniqItems:Vector.<ItemVO> = new Vector.<ItemVO>();

		private var _catchPrice:Object;
		private var _startPrice:Object;

		private var _catched:Object;

		private var _groupOfMaterialsCount:int = 0;

		private var _paused:Boolean = false;
		private var _garbage:Array;

		private static var _instance:GGameModel;

		public function GGameModel(blocker:Blocker)
		{}

		public static function get instance():GGameModel{
			if(!_instance)
				_instance = new GGameModel(new Blocker());

			return _instance;
		}

		public function reset():void
		{
			_catched = {};
			_groupOfMaterialsCount = 0;
			_itemsOrder = [];

		}

		public function get title():String {
			return _title;
		}

		public function set title(value:String):void {
			_title = value;
		}

		public function get minElements():int {
			return _minElements;
		}

		public function set minElements(value:int):void {
			_minElements = value;
		}

		public function get raundTime():int {
			return _raundTime;
		}

		public function set raundTime(value:int):void {
			_raundTime = value;
		}

		public function get saveGameStartCallback():Function {
			return _saveGameStartCallback;
		}

		public function set saveGameStartCallback(value:Function):void {
			_saveGameStartCallback = value;
		}

		public function get gameStartCallback():Function {
			return _gameStartCallback;
		}

		public function set gameStartCallback(value:Function):void {
			_gameStartCallback = value;
		}

		public function get itemsOrder():Array {
			return _itemsOrder;
		}

		public function set itemsOrder(value:Array):void {
			_itemsOrder = value;
		}

		public function get maxOnScreen():int {
			return _maxOnScreen;
		}

		public function set maxOnScreen(value:int):void {
			_maxOnScreen = value;
		}

		public function get uniqItems():Vector.<ItemVO> {
			return _uniqItems;
		}

		public function set uniqItems(value:Vector.<ItemVO>):void {
			_uniqItems = value;
		}

		public function get catchPrice():Object {
			return _catchPrice;
		}

		public function set catchPrice(value:Object):void {
			_catchPrice = value;
		}

		public function get startPrice():Object {
			return _startPrice;
		}

		public function set startPrice(value:Object):void {
			_startPrice = value;
		}

		public function get startPriceSID():int{
			return Numbers.firstProp(_startPrice).key;
		}

		public function get catchPriceSID():int {
			return Numbers.firstProp(_catchPrice).key;
		}

		public function get canCatch():int {
			return App.user.stock.count(catchPriceSID);;
		}

		public function get catched():Object {
			return _catched;
		}

		public function set catched(value:Object):void {
			_catched = value;
		}

		public function get catchedCount():int{
			var catchedCount:int = 0;

			for(var sid:String in _catched)
			{
				catchedCount += _catched[sid];
			}

			return catchedCount;
		}
		
		public function get successCatched():Object{
			var _successCatched:Object = new Object;
			for (var suc:* in catched)
			{
				for each(var itm:* in uniqItems)
				{
					if (suc == itm.sid && itm.count)
					{
						_successCatched[suc] = catched[suc]
						
					}
				}
			}
			return _successCatched;
		}
		
		public function get successCatchedCount():int{
			var successCatchedCount:int = 0;

			for(var sid:String in successCatched)
			{
				successCatchedCount += successCatched[sid];
			}

			return successCatchedCount;
		}

		public function get groupOfMaterialsCount():int {
			return _groupOfMaterialsCount;
		}

		public function set groupOfMaterialsCount(value:int):void {
			_groupOfMaterialsCount = value;
		}

		public function get paused():Boolean {
			return _paused;
		}

		public function set paused(value:Boolean):void {
			_paused = value;
		}
		
		public function get firstGame():Boolean {
			if (int(App.user.storageRead('ggameplay')) == 1)
				return false
			else
				return true
		}
		
		public function get garbage():Array {
			_garbage = [];
			for each(var itm:* in uniqItems)
			{
				if (!itm.count)
					_garbage.push(itm.sid);
				
			}
			return _garbage;
		}
	}
}

class Blocker
{

}



