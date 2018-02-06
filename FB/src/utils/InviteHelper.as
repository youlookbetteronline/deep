package utils 
{
	import api.ExternalApi;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.external.ExternalInterface;
	import strings.Strings;
	import wins.AskWindow;
	import wins.SimpleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class InviteHelper 
	{
		
		public function InviteHelper() 
		{
			
		}
		
		public static function inviteOther(callback:Function = null):void
		{
			if (App.user.quests.tutorial)
				return;
			if (App.isSocial('NK','FS','MM','FB','YB','AI','HV','YN','SP','GN')) {
				ExternalApi.apiInviteEvent(null, App.self.onInviteComplete);
				
			}else if (App.social == "OK"){
				ExternalApi.apiInviteEvent(null, App.self.showInviteCallback);
			}else{
				new AskWindow(AskWindow.MODE_NOTIFY_2,  {
					title		:Locale.__e('flash:1407159672690'), 
					inviteTxt	:Locale.__e("flash:1407159700409"), 
					desc		:Locale.__e("flash:1430126122137"),
					itemsMode	:5
				}, InviteHelper.sendPost).show();
			}
		}
		
		public static function sendPost(uid:*):void 
		{
			var message:String = Strings.__e("FreebieWindow_sendPost", [Config.appUrl]);
			var bitmap:Bitmap = new Bitmap(Window.textures.iPlay, "auto", true);
			
			if (bitmap != null) {
				ExternalApi.apiWallPostEvent(ExternalApi.GIFT, bitmap, String(uid), message, 0, null, {url:Config.appUrl});
			}
		}
		
		
		public static function checkRequests():void 
		{
			if (!ExternalInterface.available)
				return;
			if(Numbers.countProps(App.user.requestsInvite) > 0){
				for (var _uid:* in App.user.requestsInvite){
					new SimpleWindow({
						title			:Locale.__e("flash:1507200040169"),
						label			:SimpleWindow.ATTENTION,
						text			:Locale.__e("flash:1507200058487",[App.user.requestsInvite[_uid].name]),
						faderAsClose	:false,
						escExit			:false,
						popup			:true,
						dialog:			true,
						confirm:function():void {
							//if (ExternalInterface.available){
							ExternalInterface.addCallback("updateFriend", function(__uid:*):void{
								Post.send( {
									'ctr':'friends',
									'act':'add',
									'uID':App.user.id,
									'fID':__uid
								}, function (error:int, data:Object, params:Object):void{
									if (error){
										delete App.user.requestsInvite[_uid];
										return;
									}
									Log.alert('addFriend');
									Log.alert(data);
									
									App.user.friends.addFriend(__uid, data[__uid]);
									delete App.user.requestsInvite[_uid];
								});
								
								//var friendData:Object = App.user.requestsInvite[__uid];
								//friendData['first_name'] = App.user.requestsInvite[__uid].name;
								//friendData['last_name'] = '';
								//friendData['uid'] = _uid;
								//App.user.friends.addFriend(__uid, friendData);
								//Log.alert('updateFriend');
								//Log.alert(friendData);
								//delete App.user.requestsInvite[_uid];
							});
							ExternalInterface.call("approveRequest", _uid);
							//}
							
						},
						cancel:function():void {
							//if (ExternalInterface.available){
							ExternalInterface.call("rejectRequest", _uid);
							//}
							delete App.user.requestsInvite[_uid];
						}
					}).show();
				}
			}
		}
		
	}

}