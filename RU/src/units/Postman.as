package units 
{
	import core.Numbers;
	import core.Post;
	import flash.geom.Point;
	import models.PostmanModel;
	import wins.PostmanGetWindow;
	import wins.PostmanWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class Postman extends Building 
	{
		private var _model:PostmanModel
		public function Postman(object:Object) 
		{
			super(object);
			initModel(object);
		}
		
		private function initModel(params:Object):void 
		{
			_model = new PostmanModel(this);
			_model.refreshCallback = refreshEvent
			_model.sendCallback = sendEvent
			_model.takeCallback = takeEvent
		}
		
		private function getSendFriends(friends:*):Array{
			var result:Array = []
			for (var fr:* in friends)
			{
				result.push(App.user.friends.data[fr])
			}
			return result;
		}
		
		private function openWindow():void
		{
			new PostmanWindow({
				model	:_model,
				target	:this
			}).show()
		}
		
		private function refreshEvent():void 
		{
			if (level < totalLevels)
				return;
			Post.send({
				ctr		:this.type,
				act		:'refresh',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid
			}, onRefreshEvent, {
				callback:openWindow
			});
		}
		
		private function onRefreshEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			updateData(data);
			params.callback()
		}
		
		private function sendEvent(message:String, fID:String, callback:Function = null):void 
		{
			if (level < totalLevels)
				return;
			Post.send({
				ctr		:this.type,
				act		:'send',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				msg		:message,
				fID		:fID
			}, onSendEvent, {
				callback:callback
			});
		}
		
		private function onSendEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			App.user.stock.takeAll(data.__take);
			updateData(data);
			if (params.callback)
				params.callback()
		}
		
		private function takeEvent(gID:String, callback:Function = null):void 
		{
			if (level < totalLevels)
				return;
			Post.send({
				ctr		:this.type,
				act		:'take',
				uID		:App.user.id,
				id		:this.id,
				wID		:App.user.worldID,
				sID		:this.sid,
				gID		:gID
			}, onTakeEvent, {
				callback:callback
			});
		}
		
		private function onTakeEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			//Treasures.bonus(data.bonus, new Point(App.self.stage.mouseX, App.self.stage.mouseY));			
			var item:BonusItem = new BonusItem(Numbers.firstProp(data.bonus).key, Numbers.firstProp(data.bonus).val);
			//var point:Point = Window.localToGlobal(reward);
			item.cashMove(new Point(App.self.stage.mouseX, App.self.stage.mouseY), App.self.windowContainer);
			App.user.stock.addAll(data.bonus);
			App.ui.upPanel.update(['moxie']);
			updateData(data)
			if (params.callback)
				params.callback()
		}
		
		private function updateData(data:*):void
		{
			_model.friends = data.friends;
			_model.post = data.post;
			_model.sendFriends = getSendFriends(_model.friends);
		}
		
		
		override public function click():Boolean 
		{
			if (App.user.mode == User.GUEST) 
				return true;

			if (openConstructWindow(false)) 
				return true;
				
			_model.refreshCallback();
			return true;
		}
		
	}

}