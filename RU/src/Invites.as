package  
{
	import core.Log;
	import flash.events.EventDispatcher;
	import api.ExternalApi;
	import core.Post;
	import flash.events.Event;
	public class Invites extends EventDispatcher
	{		
		public var data:Object;
		public var random:Array = [];
		public var invited:Object = {}; //меня пригласили
		public var requested:Object = {}; //я пригласил
		public var searched:Object = {}; //я пригласил
		/*public var randomProfiles:Object = {};
		public var invitedProfiles:Object = {};
		public var requestedProfiles:Object = {};*/
		public var inited:Boolean = false;
		public var invitedProfiles:Object = {};
		public var requestedProfiles:Object = {};
		public var randomProfiles:Object = {};
		
		public function Invites() 
		{
			
		}
		
		public function init(callback:Function = null):void {
			if (inited) {
				callback();
				return;
			}
			
			Post.send({
				'ctr':'invites',
				'act':'get',
				'uID':App.user.id
			}, function(error:*, response:*, params:*):void {
				if (!error) {

			//		response['random'] = {'-20502660':{aka:'1234',_id:'-20502660'},'-20502714':{aka:'5678',_id:'-20502714'},'-20493147':{aka:'9123',_id:'-20493147'},'-20490561':{aka:'4567',_id:'-20490561'}}
					var _random:Object = response['random'];
					var fid:*;
					
					if(response['random']){
						for each(fid in response['random']) {
							random.push(fid);
						}
					}
				
					
					invited = response['invited'] || { };
					requested = response['requested'] || { };
					inited = true;
					
					dispatchEvent(new Event(Event.CHANGE));
					var j:int = 0;
					var idsArr:Array = [];
					for (var _id:* in random) {
							idsArr[j] = random[_id]._id;
							j++
						}
					for (var _id2:* in invited) {
							idsArr[j] = invited[_id2]._id;
							j++
						}
					for (var _id3:* in requested) {
							idsArr[j] = requested[_id3]._id;
							j++
						}
						/*idsArr = [];
						idsArr[0] = 'okyzdro4rc6c8';
						idsArr[1] = 'c5q81gedc11ek';
						idsArr[2] = 'txnbjb1u3ggbx';
						idsArr[3] = 'nuet6ye13dn';*/
						Log.alert('profiles invites start');
						Log.alert(idsArr);
						
					ExternalApi.getUsersProfile(idsArr, function(profiles:Object):void {
						inited = true;
						Log.alert('profiles invites');
						Log.alert(profiles);
						for (var friend:Object in profiles) {
							if (invited[friend] != undefined) {
								Log.alert('profiles invited');
								Log.alert(profiles[friend]);
								invitedProfiles[friend] = profiles[friend];
							}else if (requested[friend] != undefined) {
								Log.alert('profiles invited');
								Log.alert(profiles[friend]);
								requestedProfiles[friend] = profiles[friend];
							}else {
								Log.alert('profiles randomProfiles');
								Log.alert(profiles[friend]);
								randomProfiles[friend] = profiles[friend];
							}	
						}
						if(callback != null){
							callback();
						}
					});
				}
			});
		}
		
		
		
		public function invite(fID:String, callback:Function):void {
			
			Post.send({
				'ctr':'invites',
				'act':'invite',
				'uID':App.user.id,
				'fID':fID
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					for (var i:int = 0; i < random.length; i++) {
						if (random[i]['_id'] == fID) {
							invited[fID] = random[i];
							invited[fID]['time'] = App.time;
							break;
						}
					}
					if (searched.hasOwnProperty(fID)) {
						invitedProfiles[fID] = randomProfiles[fID];
						invited[fID] = searched[fID];
						invited[fID]['time'] = App.time;
					}
					callback();
					
					dispatchEvent(new Event(Event.CHANGE));
				}
			});
			
		}
		
		public function accept(fID:String, callback:Function):void {
			
			Post.send({
				'ctr':'invites',
				'act':'accept',
				'uID':App.user.id,
				'fID':fID
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					
					var friend:Object = response['friend'];
					for (var p:String in requestedProfiles[fID]) {
						friend[p] = requestedProfiles[fID][p];
					//	Log.alert('p   fID');
					//	Log.alert(p);
					}
					friend['uid'] = fID;
				//	Log.alert('fID');
					//Log.alert(fID);
					App.user.friends.addFriend(fID, friend);
					delete requested[fID];
					callback();
					
					dispatchEvent(new Event(Event.CHANGE));
				}
			});
			
		}
		
		public function reject(fID:String, callback:Function):void {
			
			Post.send({
				'ctr':'invites',
				'act':'reject',
				'uID':App.user.id,
				'fID':fID
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					
					
					callback();
					
					if (requested.hasOwnProperty(fID)) {
						delete requested[fID];
						delete requestedProfiles[fID];
					}
					if (invited.hasOwnProperty(fID)) {
						if (invited[fID].time == 0 && App.user.friends.data.hasOwnProperty(fID)) {
							delete App.user.friends.data[fID];
							
						}
						delete invited[fID];
						delete invitedProfiles[fID];
					}
					if (App.user.friends.hasFriends(fID)) {
						App.user.friends.removeFriend(fID);
					}
					callback();
					
					dispatchEvent(new Event(Event.CHANGE));
				}
			});
			
		}
		
		public function search(fID:String, callback:Function):void {
			if (searched.hasOwnProperty(fID)) {
				callback(searched[fID]);
				return;
			}
			
			Post.send( {
				ctr:	'invites',
				act:	'search',
				uID:	App.user.id,
				fID:	fID
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					if (response.friend) {
						searched[fID] = response.friend;
					}
					
					if (App.isJapan()) 
					{
					ExternalApi.getUsersProfile([fID], function(profiles:Object):void {
						inited = true;
						Log.alert('profiles invites');
						Log.alert(profiles);
						for (var friend:Object in profiles) {
						searched[fID] = profiles[friend];
						}
						
						callback(profiles[friend]);
					});	
					}else 
					{
						callback(response.friend);
					}
					
					
					
				}
			});
		}
		
		public function canInvite(fID:String):Boolean {
			if (fID == App.user.id || invited.hasOwnProperty(fID) || requested.hasOwnProperty(fID) || App.user.friends.hasFriends(fID))
				return false;
			
			return true;
		}
		
		public static function get externalPermission():Boolean {
			return false;
			if (App.user.id == '' || !App.isJapan())
				return true;
			
			return false;
		}
	}

}