package hlp 
{
	import com.junkbyte.console.Cc;
	import core.Numbers;
	import core.Post;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import ui.Cursor;
	import units.Unit;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	
	public class QickResourcesBuyManager {
		
		public function QickResourcesBuyManager() {
			
		}
		
		private static var _content:Array = [];
		private static var _currentIndex:int = 0;
		public static function init():void{
			
			_content = [];
			for (var sid:String in App.data.storage) {
				if (int(sid) < 184)
					continue;
					
				if (App.data.storage[sid].visible == 0)	
					continue;
					
				if (App.data.storage[sid].type == 'Resource') {
					_content.push(sid);
				}
			}
			
			//App.self.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			App.self.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			addOnCursor(_currentIndex);
			
			Cc.visible = false;
		}
		public static function initBySid(sidNum:int):void{
			//if (App.data.storage[sidNum].type != 'Resource' || sidNum < 184)
			//{
				//trace(sidNum + ' ' + App.data.storage[sidNum].title + 'Не являеться ресурсом или его сид меньше 184');
				//return;
			//}
			_content = [];
			_content.push(sidNum);
			sidNum = 0;
			addOnCursor(sidNum);
			Cc.visible = false;
		}
		
		public static function getSid(sid:int):void{
			//if (App.data.storage[sidNum].type != 'Resource' || sidNum < 184)
			//{
				//trace(sidNum + ' ' + App.data.storage[sidNum].title + 'Не являеться ресурсом или его сид меньше 184');
				//return;
			//}
			App.user.stock.buy(sid, 100, function():void{});
			Cc.visible = false;
		}
		
		public static function getupd(sid:int):void{
			var t:String = 'Не привязано'
				if (App.data.updates.hasOwnProperty(User.getUpdate(sid)))
					t = App.data.updates[User.getUpdate(sid)].title
				new SimpleWindow( {
					title:Locale.__e("flash:1474469531767"),
					label:SimpleWindow.ATTENTION,
					text:t,
					popup:true
				}).show();
			Cc.visible = false;
		}
		
		public static function getItems(list:String):void{
			var items:Array = list.split(',');
			var itemList:Object = {};
			for each(var itm:String in items)
			{
				var itemArray:Array = itm.split(':');
				itemList[int(itemArray[0])] = int(itemArray[itemArray.length - 1]);
			}
			trace();
			App.user.stock.buyAll(itemList);
		}
		
		public static function addQuest(qid:int):void{
			var scored:Object = {};
			var mids:Object = {};
			for (var i:int = 1; i <= Numbers.countProps(App.data.quests[qid].missions); i++)
			{
				mids[i] = {1:1}
			}
			scored[qid] = mids;
			
			
			Post.send( {
				ctr:'quest',
				act:'score',
				uID:App.user.id,
				wID:App.user.worldID,
				score:JSON.stringify(scored),
				f:1
			},function(error:*, data:*, params:*):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
			
			Cc.visible = false;
		}
		
		//private static function onKeyDown(e:KeyboardEvent):void 
		private static function onMouseWheel(e:MouseEvent):void 
		{
			//if (Keyboard.S == e.keyCode) {
				//next();
			//}
			//if (Keyboard.A == e.keyCode) {
				//prev();
			//}
			if (e.delta > 0) {
				next();
			}else {
				prev();
			}
		}	
		
		private static function addOnCursor(index:int):void {
			var sid:String = _content[index];
			
			trace(sid +' ' + App.data.storage[sid].title);
			if (App.map.moved) {
				App.map.moved.previousPlace();
				Cursor.type = "default";	
				App.map.moved = null;
			}
			
			//App.ui.bottomPanel.onCursorsEvent();
			
			
			var unit:Unit = Unit.add( { sid:sid, buy:true } );
			unit.move = true;
			App.map.moved = unit;
		}
		
		private static function next():void 
		{
			_currentIndex++;
			if (_currentIndex >= _content.length) {
				_currentIndex = 0;
			}
			
			addOnCursor(_currentIndex);
		}
		
		private static function prev():void {
			_currentIndex--;
			if (_currentIndex < 0) {
				_currentIndex = _content.length - 1;
			}
			
			addOnCursor(_currentIndex);
		}
	}
}