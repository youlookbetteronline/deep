package models 
{
	import core.Numbers;
	import units.Postman;
	/**
	 * ...
	 * @author ...
	 */
	
	 public class PostmanModel 
	{
		private var _target:Postman
		private var _allFriends:Array = [];
		private var _sendFriends:Array = [];
		private var _mtake:Object;
		private var _msend:Object;
		private var _refreshCallback:Function;
		private var _sendCallback:Function;
		private var _takeCallback:Function;
		private var _friends:Object;
		private var _post:Object;
		public function PostmanModel(target:Postman) 
		{
			this._target = target;
		}
		
		public function get allFriends():Array 
		{
			for each(var _friend:* in App.user.friends.data)
			{
				 
				if (_friend.uid == '1')
					continue;
				_allFriends.push(_friend);
			}
			return _allFriends;
		}
		
		public function get mtake():Object 
		{
			return{
				sid		:Numbers.firstProp(_target.info.mtake).key,
				count	:Numbers.firstProp(_target.info.mtake).val
			}
		}
		
		public function get msend():Object 
		{
			return{
				sid		:Numbers.firstProp(_target.info.msend).key,
				count	:Numbers.firstProp(_target.info.msend).val
			}
		}
		
		public function get refreshCallback():Function 
		{
			return _refreshCallback;
		}
		
		public function set refreshCallback(value:Function):void 
		{
			_refreshCallback = value;
		}
		
		public function get friends():Object 
		{
			return _friends;
		}
		
		public function set friends(value:Object):void 
		{
			_friends = value;
		}
		
		public function get post():Object 
		{
			return _post;
		}
		
		public function set post(value:Object):void 
		{
			_post = value;
		}
		
		public function get sendCallback():Function 
		{
			return _sendCallback;
		}
		
		public function set sendCallback(value:Function):void 
		{
			_sendCallback = value;
		}
		
		public function get sendFriends():Array 
		{
			return _sendFriends;
		}
		
		public function set sendFriends(value:Array):void 
		{
			_sendFriends = value;
		}
		
		public function get takeCallback():Function 
		{
			return _takeCallback;
		}
		
		public function set takeCallback(value:Function):void 
		{
			_takeCallback = value;
		}
	}

}