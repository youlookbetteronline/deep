package core
{
	import com.junkbyte.console.Cc;
	import com.shortybmc.data.parser.CSV;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class Lang
	{
		public static var DICTIONARY:Dictionary = new Dictionary();
		public static var loadingLangs:int = 0;
		public static var DATA:Object = {};
		
		public static function translate(data:*):Object {
			
			var startLang:String = App.lang;
			for each(var _lg:String in _langs) {
				DATA[_lg] = Numbers.copyObject(data);
				App.lang = _lg;
				translateGameData(DATA[_lg]);
			}
			
			App.lang = startLang;
			return DATA[App.lang];
		}
		
		private static function translateGameData(data:*):void {
			for (var id:* in data) {
				var val:* = data[id];
				if (typeof val == 'object') {
					translateGameData(val);
				}else if(typeof val == 'string'){
					if (val.indexOf(':') != -1) {
						data[id] = Locale.__e(val);
					}
				}
			}
		}
		
		public static function get dictionary():Dictionary 
		{
			return DICTIONARY[App.lang];
		}
		
		private static var _langs:Array = [];
		public static function loadLangQueue(lgs:Array, callback:Function):void 
		{
			for (var i:int = 0; i < lgs.length; i++) {
				var lang:Lang = new Lang(lgs[i]);
				_langs.push(lang);
				loadingLangs ++;
			}
			for each(lang in _langs){
				lang.loadLanguage(onLoadLang);
			}
			
			function onLoadLang():void {
				loadingLangs --;
				if (loadingLangs <= 0) {
					callback();
				}
			}
			
			_langs = lgs;
		}
		
		public static function changeLang():void {
			var index:int = _langs.indexOf(App.lang);
			if (index + 1 >= _langs.length) {
				index = 0;
			}else {
				index ++;
			}
			
			
			App.lang = _langs[index];
			App.data = DATA[App.lang];
			Cc.log('Change lang:  ' + App.lang);
		}
		
		private var _lg:String;
		public function Lang(lg:String) {
			this._lg = lg;
		}
		
		public function loadLanguage(callback:Function):void
		{
			if (_lg == "ru_str")
			{
				callback();
				return;
			}
			
			var csv:CSV = new CSV();
			csv.addEventListener (Event.COMPLETE, completeHandler);
			csv.addEventListener(IOErrorEvent.IO_ERROR, function(e:*):void { } );
			csv.load(new URLRequest(Config.getLocale(_lg)));
			
			//trace('LOADING: ', Config.getLocale(lg));
			
			function completeHandler(event:Event):void {
				
				var dictionary:Dictionary = new Dictionary();
				
				for (var s:int = 0; s < csv.data.length; s++) {
					var obj:Object = csv.data[s];
					for (var j:int = 0; j < obj.length; j++)
					{
						var string:String = obj[j];
						
						for (var i:int = 0; i < string.length; i++)
						{
							var simbol:String = string.charAt(i);
							var spart:String;
							var fpart:String;
							
							if (string.charAt(i) == '"' && (string.charAt(i + 1) != null && string.charAt(i + 1) != '"'))
							{
								spart = string.slice(0, i);
								fpart = string.slice(i+1, string.length);
								string = spart + fpart;
							}
							else if(string.charAt(i) == '"')
							{
								spart = string.slice(0, i);
								fpart = string.slice(i+1, string.length);
								string = spart + fpart;
							}
						}
						
						string = string.replace(/\\n/g, "\n");
						obj[j] = string;
					}
					
					dictionary[csv.data[s][0]] = csv.data[s][1];
				}
				
				DICTIONARY[_lg] = dictionary;
				
				callback();
			}
		}
	}
}