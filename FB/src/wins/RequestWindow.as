package wins 
{
	import api.ExternalApi;
	import buttons.SimpleButton;
	import core.Log;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author 
	 */
	public class RequestWindow extends AskWindow
	{
		public function RequestWindow(mode:int, settings:Object = null, callBack:Function = null) {
			super(mode, settings);
		}
		
		private var _receivers:Array = [];
		override protected function inviteCheckedEvent(e:MouseEvent):void 
		{
			var checkedFriends:Array = new Array();
			if (settings.content.length <= 0)
				return;
			settings.content.sortOn('checked');
			
			for (var i:int = 0; i < settings.content.length; i++) {
				if (settings.content[i].checked == 1) {
					_receivers.push(settings.content[i].uid);
				}
			}
			
			var material:Object = App.data.storage[settings.sID];
			var msg:String = Locale.__e('flash:1493817921500', [material.title]);//1382952379740
			
			if (_receivers.length >= 50)
			{
				_receivers = _receivers.slice(0, 49);
				new SimpleWindow({
					title:Locale.__e("flash:1474469531767"),
					text:Locale.__e("flash:1495444973415"),
					label: SimpleWindow.ATTENTION, 
					popup:true,
					dialog: true,
					confirm: function():void {
						ExternalApi.notifyFriend( { uid:_receivers, text:msg, callback:onNotifyComplete } )
					}
				}).show();
			}
			else
			{
				ExternalApi.notifyFriend( { uid:_receivers, text:msg, callback:onNotifyComplete } )
			}
			close();
			//settings.callback(_receivers);
			
			
		}
		
		private function onNotifyComplete(result:Boolean):void {
			Log.alert('onNotifyComplete');
			Log.alert(result);
			if(result){
				settings.callback(_receivers);
			}else {
				// игрок не отправил уведомления
			}
		}
	}
		
}