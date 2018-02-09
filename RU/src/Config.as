package
{
	import com.junkbyte.console.Cc;
	import core.CookieManager;
	import core.Log;
	import core.MD5;
	import flash.system.Capabilities;
	import flash.utils.getTimer;

	public class Config
	{
		//public static var FVResourcesVersion:int;
		public static var totalVersion:int;		
		public static var versionObjects:int 		= 698  + totalVersion;		//Обьекты
		public static var versionInterface:int 		= 346  + totalVersion;		//Интерфейс
		public static var versionImages:int 		= 1084 + totalVersion;		//Icons + Images
		
		public static var _mainIP:Array;
		public static var _resIP:*;
		public static var _curIP:String;
		public static var testMode:int = 1;
		public static var resServer:uint = 0;
		public static var secure:String = "http://";
		public static var OK:Object = {
			secret_key:'AEE526096F080F3DBA4A28DD'
		};
		
		public static function get appUrl():String
		{
			switch(App.self.flashVars.social) {
				case 'VK':
					return 'http://vk.com/app5754423';
				case 'DM':
					return 'http://vk.com/app4937396';
				break;	
				case 'MM':
					return 'http://my.mail.ru/apps/751332';
				break;
				case 'FS':
					return 'https://fotostrana.ru/app/my/deep';
				break;
				case 'OK':
					return 'https://ok.ru/game/1249472256';
				break;
				case 'FB':
					return 'https://apps.facebook.com/deepseastory';
				break;
				default:
					return '';
				break;
			}
		}
		
		public static function get connection():String 
		{
			return (App.self.flashVars['connection']) ? App.self.flashVars['connection'] : null;
		}
		
		public function Config()
		{
			
		}
		
		public static function get randomKey():String 
		{
			var pos:int = int(Math.random() * (31 - 13));
			return MD5.encrypt(String(getTimer()) + App.user.id).substring(pos, pos + 13);
		}
		
		public static function setServersIP(parameters:Object):void
		{
			var mainIP:Array;
			var resIP:Array;
			
			if(parameters.hasOwnProperty('mainIP')){
				mainIP = JSON.parse(parameters.mainIP) as Array;
				resIP = JSON.parse(parameters.resIP) as Array;
			}	
			
			Log.alert("mainIP: " + mainIP);
			Log.alert("resIP: " + resIP);
			
			switch(App.SERVER) {
				case "DM":
					_mainIP	= mainIP != null ? mainIP : ['deep.islandsville.com', 'deep.islandsville.com'];
					break;
				case "VK":
					_mainIP	= mainIP != null ? mainIP : ['dp-vk1.islandsville.com', 'dp-vk1.islandsville.com'];
					break;
				case "FS":
					_mainIP	= mainIP != null ? mainIP : ['dp-fs1.islandsville.com', 'dp-fs1.islandsville.com'];	
					break;
				case "MM":
					_mainIP	= mainIP != null ? mainIP : ['dp-mm1.islandsville.com', 'dp-mm1.islandsville.com'];	
					break;	
				case "OK":
					_mainIP	= mainIP != null ? mainIP : ['dp-ok1.islandsville.com', 'dp-ok1.islandsville.com'];	
					break;	
				case "FB":
					_mainIP	= mainIP != null ? mainIP : ['dp-fb1.islandsville.com', 'dp-fb1.islandsville.com'];	
					break;
				case "FBD":
					_mainIP	= mainIP != null ? mainIP : ['dp-fb.islandsville.com', 'dp-fb.islandsville.com'];	
					break;	
				case "SP":
					_mainIP	= mainIP != null ? mainIP : ['dp-sp1.islandsville.com', 'dp-sp1.islandsville.com'];	
					break;
				case "YB":
					_mainIP	= mainIP != null ? mainIP : ['dp-yb1.islandsville.com', 'dp-yb1.islandsville.com'];	
					break;
				case "YBD":
					_mainIP	= mainIP != null ? mainIP : ['dp-yb.islandsville.com', 'dp-yb.islandsville.com'];	
					break;	
				case "MX":
					_mainIP	= mainIP != null ? mainIP : ['dp-mx1.islandsville.com', 'dp-mx1.islandsville.com'];	
					break;	
				case "AM":
					_mainIP	= mainIP != null ? mainIP : ['dp-am.islandsville.com', 'dp-am.islandsville.com'];	
					break;		
			}
			
			//_resIP 	= resIP  != null ? resIP  : ['dp-vk-static.islandsville.com'];
			//_resIP 	= resIP  != null ? resIP  : ['dp-mm-static.islandsville.com'];
			//_resIP 	= resIP  != null ? resIP  : ['dp-ok-static.islandsville.com'];
			//_resIP 	= resIP  != null ? resIP  : ['dp-fs-static.islandsville.com'];
			//_resIP 	= resIP  != null ? resIP  : ['dp-fs-static.islandsville.com'];
			_resIP 	= resIP  != null ? resIP  : ['deep.islandsville.com'];
			//_resIP 	= resIP  != null ? resIP  : ['deep.office.ad'];
			//_resIP 	= resIP  != null ? resIP  : ['dp-mx-static.islandsville.com'];
			//_resIP 	= resIP  != null ? resIP  : ['dp-fb-static.islandsville.com'];
			
			var resRand:int = int(Math.random() * _resIP.length);
			_resIP = _resIP[resRand];
			
			var rand:int = int(Math.random() * _mainIP.length);
			
			_curIP = _mainIP[rand];
			//_resIP = _curIP;
			_mainIP.splice(_mainIP.indexOf(_curIP));
			
			Log.alert("_mainIP: " + _curIP);
			Log.alert('_resIP: ' + _resIP);
			
			CookieManager._domain = String(_mainIP);
		}
		
		public static function changeIP():Boolean 
		{
			_curIP = _mainIP.shift();
			if (_curIP) {
				return true;
			}
			return false;
		}
		
		public static function getQuestIcon(type:String, icon:String):String 
		{
			return secure + _resIP + '/resources/icons/quests/' + type + '/' + icon + '.png' + '?v='+ versionImages;
		}
		
		public static function getQuestAva(icon:String):String 
		{
			return secure + _resIP + '/resources/icons/avatars/' + icon + '.png' + '?v='+ versionImages;
		}
		
		public static function getUrl():String 
		{
			return secure + _curIP + '/';
		}
		
		public static function getData(lang:String = ""):String 
		{
			return secure + _curIP + '/app/data/json/game.json?v=' + String(new Date().time);
		}
		
		public static function getWindowData(window:String):String 
		{
			return secure + _curIP + '/app/data/windows/'+ window +'.json?v=' + String(new Date().time);
		}
		
		public static function getLandData(landId:String = '4'):String 
		{
			return secure + _curIP + '/app/data/php/islands/' + String(landId) + '.json?v=23';
		}
		
		public static function getLocale(lg:String):String
		{
		   return resources + 'locales/' + lg + '.csv?v=' + int(Math.random() * 1000);
		}
			
		public static function get resources():String 
		{
			return secure + _resIP + '/resources/'; 
		}	
		
		public static function getIcon(type:String, icon:String):String 
		{
			//return secure + _resIP + '/resources/icons/store/ss.png';
			return secure + _resIP + '/resources/icons/store/' + type + '/' + icon + '.png'+"?v=" + versionImages;
		}
		
		public static function getImageIcon(type:String, icon:String, _type:String = 'png'):String 
		{
			return secure + _resIP + '/resources/icons/' + type + '/' + icon + '.'+_type+"?v=" + versionImages;
		}
		
		public static function getImage(type:String, icon:String, _type:String = 'png'):String
		{
			return secure + _resIP + '/resources/images/' + type + '/' + icon + '.' + _type +"?v=" + versionImages;
		}
		public static function getCross(url:String):String 
		{
			return secure + url+ '?v='+versionObjects;
		}
		
		public static function getSwf(type:String, name:String):String 
		{
			if (type == 'Sound') 
			{
				return Config.resources +'swf/' + type + '/' + name + '.swf?v='+ 1235;
			}
			return Config.resources +'swf/' + type + '/' + name + '.swf?v='+ versionObjects;
		}
		
		public static function getInterface(type:String):String 
		{
			Cc.log(Config.versionInterface);
			Cc.log(Config.versionImages);
			Cc.log(Config.versionObjects);
			//return 'D:/______DEEP/gui/' + type + '.swf?v=' + versionInterface;
			return Config.resources +'interface/' + type + '.swf?v=' + versionInterface;
		}
		
		public static function getDream(type:String):String
		{
			return Config.resources +'lands/' + type + '.swf?v='+versionObjects;//версия карты 27
		}
		
		public static function getDreamImage(type:String):String
		{
			return Config.resources +'lands/' + type + '.jpg?v='+versionObjects;
		}
		
		public static function setSecure(secureValue:String = "http://"):void 
		{
			secure = secureValue;
		}
		
		public static function toSecure(url:String):String 
		{
			if (secure.indexOf('https:') != -1 && url.indexOf('http:') != -1) 
			{
				url = url.replace('http:', 'https:');
			}
			
			return url;
		}
		
		public static function getUnversionedIcon(type:String, icon:String, _type:String = 'png'):String 
		{
			return secure + _resIP + '/resources/icons/' + type + '/' + icon + '.' + _type;
		}
		
		public static function getUnversionedImage(type:String, icon:String, _type:String = 'png'):String 
		{
			return secure + _resIP + '/resources/images/' + type + '/' + icon + '.' + _type;
		}
		
		public static function get admin():Boolean
		{
			//return false;
			
			if (Capabilities.playerType == 'StandAlone')
				return true;
			var adminsArray:Array = ['973881489414432', '830321993812336', '640899449454407','9912798254696685069', '1850121798639095', '1884198341793819']
			if (adminsArray.indexOf(App.user.id) != -1)
				return true;
			var optionAdmins:String = "";
			var adminList:Array = [];
			optionAdmins = App.data.options.admins;
			adminList = optionAdmins.split(",");
			for (var i:int = 0; i < adminList.length; i++)
			{
				adminList[i] = String(uint(adminList[i]));
			}
			
			return (adminList.indexOf(App.user.id) >= 0) ? true : false;
		}
		
		public static function get dumpUsers():Boolean 
		{
			if (Capabilities.playerType == 'StandAlone')
				return true;
			
			return (['1','50545195','216968557','83730403', '96391814', '29060311','159185922','413309776','573841176790','413309776','89750529','571421116771','17631457865330787470','575889735345','89824749'].indexOf(App.user.id) >= 0) ? true : false;
		}
	}
}