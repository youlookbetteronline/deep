var groupId = '53290312794300';
var cache = {
  profile: {},
  friends: {},
  alluids: [],
  appuids: [],
  invitable_friends: {}
};

function getNetwork(){
	getGame().setNetwork(cache);
}


function getMe(callback){
	FAPI.Client.call({"method":"users.getCurrentUser"}, function(status, data) {		
		var birthday = data.birthday.split('-');
		var year = (birthday[0] || '').length == 4?birthday[0]:0;
		cache.profile = {
			uid			:data.uid,
			first_name	:data.first_name,
			last_name	:data.last_name,
			sex			:data.gender == 'male'?'m':'f',
			photo		:data.pic_1,
			year		:year,
			country		:(data.location != undefined)?data.location.country || '':'',
			city		:(data.location != undefined)?data.location.city || '':''
		};
		if(callback){
			callback();
		}
	});
}

function getAppUsers(callback){
	FAPI.Client.call({"method":"friends.getAppUsers"}, function(status, data) {
		if(status == 'ok'){
			cache.appuids = data.uids;
		}
		getUsers('friends',cache.appuids, 0, callback);
	});
}


function getFriends(callback){
	FAPI.Client.call({"method":"friends.get"}, function(status, data) {
		if(status == 'ok'){
			cache.alluids = data;
			if(callback != null){
				callback();
			}
		}
	});
}

function Shuffle(o) {
	for(var j, x, i = o.length; i; j = parseInt(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
	return o;
};

function getInvitableFriends(callback){
	var ids = [];
	for(var i in cache.alluids){
		var id = cache.alluids[i];
		if(cache.appuids.indexOf(id) == -1){
			ids.push(id);
		}
	}
	Shuffle(ids);
	ids = ids.splice(0,100);
	getUsers('invitable_friends', ids, 0, callback);
}

function getUsers(type, uids, start, callback){
	var chunk = [];
	for(var i=0; i<uids.length, start<uids.length; i++){
		chunk.push(uids[i]);
		start++;
		if(chunk.length == 99 || start >= uids.length){
			getUsersPart(type, chunk, function(){
				getUsers(type, uids, start, callback);
			});
			return;
		}
	}
	if(callback != null){
		callback();
	}
}

function getUsersPart(type, uids, callback){
	console.log(uids.join(','));
	FAPI.Client.call({"method":"users.getInfo", "uids":uids.join(','), "fields":"first_name,last_name,pic_1"}, function(status, data, error) {
		if(status == 'ok'){
			for(var i in data){
				cache[type][data[i].uid] = {
					uid			:data[i].uid,
					first_name	:data[i].first_name,
					last_name	:data[i].last_name,
					sex			:data[i].gender == 'male'?'m':'f',
					photo		:data[i].pic_1
				};
			}
		}
		
		if(callback != null){
			callback();
		}
	});
}

function showInvite(msg){
    FAPI.UI.showInvite(msg);
}
function notify(uid, text, type)
{
	showNotification(text);
}
function showNotification(msg){
    FAPI.UI.showNotification(msg);
}

function checkGroupMember(){
	FAPI.Client.call({"method":"group.getUserGroupsV2", "uid":cache.profile.uid, "count":50}, function(status, data) {
		if(status == 'ok'){
			for(var i in data.groups){
				if(data.groups[i].groupId == groupId){
					getGame().onCheckGroupMember(true);
					return;
				}
			}
		}
		getGame().onCheckGroupMember(false);
	});   
}

function showPayment(params)
{
	//ForticomAPI.showPayment(params.name, params.description, params.code, params.price, null, null, params.currency, params.callback);
	if(cache.profile.uid == '172024512656'){
	    params.price = 1;
	}
	console.log(params);
	FAPI.UI.showPayment(params.name, params.description, params.code, params.price, null, null, params.currency, params.callback);
}



function post(params){
	FAPI.UI.postMediatopic({
		"media":[
			// {
				// "type": "text",
				// "text": params.text
			// },
			// {
				// "type": "link",
				// "url": params.link
			// },
			{
				"type": "app",
				"text": params.text,
				"images": [{
					"url": params.image,
					"title": params.title
				}],
				"actions":[{
					"text": params.action,
					"mark": params.mark
				}]
			}
		]
	}, false);
}

function API_callback(method, result, data)
{
	if (method == "postMediatopic")
	{
		getGame().onWallPostComplete(result);
	}
	else if (method == "showPayment")
	{
		getGame().updateBalance();
	} else if (method == "showInvite")
	{
		getGame().onInviteComplete(data);
	} 

	console.log(method + "_" + result);
}
