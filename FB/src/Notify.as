package  
{
	import api.ExternalApi;
	import core.Log;
	import core.Post;
	import flash.external.ExternalInterface;
	import strings.Strings;
	import wins.BonusVisitingWindow;
	
	public class Notify
	{		
		public function Notify() 
		{
			
		}
		
		public static function inviteToMap(_fid:String, _callback:Function = null, message:String =''):void {
			//var message:String = Strings.__e('WakeUpFriend_notify', []);
			notify( {
				uid:_fid,
				text:message,
				type:'request',
				callback:_callback
			});
		}
		
		public static function wakeUp(fid:String, callback:Function = null):void {
			var message:String = Strings.__e('WakeUpFriend_notify', []);
			notify({
				uid:fid,
				text:message,
				type:'request',
				callback:onWakeUpComplete
			});
		}
		
		private static function onWakeUpComplete(result:Boolean):void {
			if (!result) 
				return;
			Post.send( {
				ctr:'friends',
				act:'alert',
				uID:App.user.id,
				fID:App.owner.id
			},function(error:*, data:*, params:*):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				App.ui.upPanel.hideWakeUpPanel();
				if (data !=null&&data.hasOwnProperty('bonus')&&data.bonus!={}) 
				{
					new BonusVisitingWindow( { bonus:data.bonus, wakeUpBonus:true } ).show();
					App.user.friends.data[App.owner.id].alert = App.time;
				}
			});
		}
			
		public static function notify(params:Object):void 
		{
			Log.alert('NOTIFY');
			Log.alert(params);
			ExternalApi.apiNormalScreenEvent();
			
			switch(App.social) 
			{
				case 'VK':
				case 'DM':
					if (ExternalInterface.available){
						ExternalInterface.addCallback("updateNotify", function(callback:Boolean = true):void {
							if (params.callback)
								params.callback();
						});
						ExternalInterface.call("notify", params.uid, params.text);
					}
					break;
				case "FB":
					if (ExternalInterface.available){
						ExternalInterface.addCallback("updateNotify", function(result:Boolean):void {
							if (params.callback)
								params.callback(result);
						});
						ExternalInterface.call("notify", params.uid, params.text);
					}
					break;
			}
		}	
	}	
}