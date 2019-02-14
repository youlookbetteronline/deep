package
{
	import core.CookieManager;
	import core.Log;
	import core.MD5;
	import flash.external.ExternalInterface;
	import flash.utils.getTimer;

	public class Config
	{
		public static var _mainIP:*;
		
		public static var _resIP:*;
		
		public static var _curIP:String;
		
		public static var testMode:int = 1;
		public static var resServer:uint = 0;
		public static var testServer:Boolean = false;
		
		public static var secure:String = "http://";
		

		
		public function Config()
		{

		}
		
		public static function setServersIP(parameters:Object = null):void
		{
			var mainIP:Array;
			var resIP:Array;
			
			if(parameters && parameters.hasOwnProperty('mainIP')){
				mainIP = JSON.parse(parameters.mainIP) as Array;
				resIP = JSON.parse(parameters.resIP) as Array;
			}	
			
			Log.alert("mainIP: " + mainIP);
			Log.alert("resIP: " + resIP);
			
			switch(App.social) {
				case "DM":
					_mainIP	= mainIP != null ? mainIP : ['gnome.islandsville.com', 'gnome.islandsville.com'];
				/*	break;
				case "VK":
					_mainIP	= mainIP != null ? mainIP : ['dp-vk1.islandsville.com', 'dp-vk1.islandsville.com'];
					break;
				case "FS":
					_mainIP	= mainIP != null ? mainIP : ['dp-fs1.islandsville.com', 'dp-fs1.islandsville.com'];	
					break;
				case "FB":
					_mainIP	= mainIP != null ? mainIP : ['dp-fb1.islandsville.com', 'dp-fb1.islandsville.com'];	
					break;
				case "MM":
					_mainIP	= mainIP != null ? mainIP : ['dp-mm1.islandsville.com', 'dp-mm1.islandsville.com'];	
					break;	
				case "OK":
					_mainIP	= mainIP != null ? mainIP : ['dp-ok1.islandsville.com', 'dp-ok1.islandsville.com'];	
					break;	
				case "YB":
					_mainIP	= mainIP != null ? mainIP : ['dp-yb1.islandsville.com', 'dp-yb1.islandsville.com'];	
					break;	
				case "YBD":
					_mainIP	= mainIP != null ? mainIP : ['dp-yb.islandsville.com', 'dp-yb.islandsville.com'];	
					break;	
				case "MX":
					_mainIP	= mainIP != null ? mainIP : ['dp-mx1.islandsville.com', 'dp-mx1.islandsville.com'];	
					break;*/
			}
			
			_resIP 	= resIP  != null ? resIP  : ['gnome.islandsville.com'];
			
			var resRand:int = int(Math.random() * _resIP.length);
			_resIP = _resIP[resRand];
			
			var rand:int = int(Math.random() * _mainIP.length);
			
			_curIP = _mainIP[rand];
			//_resIP = _curIP;
			_mainIP.splice(_mainIP.indexOf(_curIP));
			
			//Log.alert('ExternalInterface available? ' + String(ExternalInterface.available));
			//if (ExternalInterface.available)
			//{
				//var _vars:Object = ExternalInterface.call("flashvarsFUNC");
				//
				//if (_vars.hasOwnProperty('mainIP'))
				//{
					//_curIP = _vars['mainIP'];
					//Log.alert('_curIP from js: ' + _curIP);
				//}
			//}
			
			Log.alert("_mainIP: " + _curIP);
			Log.alert('_resIP: ' + _resIP);
			
			CookieManager._domain = String(_mainIP);
		}
		
		public static function changeIP():Boolean {
			_curIP = _mainIP.shift();
			if (_curIP) {
				return true;
			}
			return false;
		}
		
		public static function toSecure(url:String):String {
			if (secure.indexOf('https:') != -1 && url.indexOf('http:') != -1) {
				url = url.replace('http:', 'https:');
			}
			
			return url;
		}
		
		public static function getUrl():String {
			return secure + _curIP + '/';
		}
		
		private static var version:int = 64;//Math.random()*999999999;
		public static var iconsVersion:int = 10;
		
		public static function getIcon(type:String, icon:String):String {
			return secure + _resIP + '/resources/icons/store/' + type + '/' + icon + '.png'+"?v="+iconsVersion;
		}
		public static function getImageIcon(type:String, icon:String, _type:String = 'png'):String {
			return secure + _resIP + '/resources/icons/' + type + '/' + icon + '.'+_type+"?v="+version;
		}
		
		public static function getQuestIcon(type:String, icon:String):String {
			return secure + _resIP + '/resources/icons/quests/' + type + '/' + icon + '.png' + '?v='+version;
		}
		
		public static function getQuestAva(icon:String):String {
			return secure + _resIP + '/resources/icons/avatars/' + icon + '.png' + '?v='+version;
		}
		public static function getData(lang:String = ""):String {
			return secure + _curIP + '/app/data/json/game.json?v=' + String(new Date().time);
		}
		public static function getLocale(lg:String):String
		{
		   return resources + 'locales/' + lg + '.csv?v=' + String(new Date().time);
		}
		public static function get resources():String {
			return secure + _resIP + '/resources/';
		}	
	}
}