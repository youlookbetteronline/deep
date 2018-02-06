package utils 
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import wins.Window;
	/**
	 * ...
	 * @author 111
	 */
	public class UnitsHelper 
	{
		//[Embed(source="abstract_fish.swf", mimeType="application/octet-stream")]
        //private static var SwfClass:Class;
		
		public function UnitsHelper() 
		{
			
		}
		
		private static var textureFish:*;
		private static var loader:Loader = new Loader();
		public static function loadTexture():void
		{
			//var swfBytes:ByteArray = new SwfClass();
            //loader.loadBytes(swfBytes);
			
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, textureComplete);
			
		}
		
		public static function textureComplete(event:Event):void
		{
			textureFish = loader.content;
		}
		public static function get walkTexture():Object
		{
			//if(textureFish){
				//return textureFish;
			//}else{
				//loadTexture();
			//}
			var _obj:Object = 
			{
				sprites:[],
				animation:{
					animations:{
						stop_pause:{
							chain:[0,0,0],
							frames:[[{
								bmd:Window.textures.sign2,
								ox:-31,
								oy:-76
							}]]
						},
						rest:{
							chain:[0,0,0],
							frames:[[{
								bmd:Window.textures.sign2,
								ox:-31,
								oy:-76
							}]]
						},
						walk:{
							chain:[0,0,0],
							frames:[[{
								bmd:Window.textures.sign2,
								ox:-31,
								oy:-76
							}],[{
								bmd:Window.textures.sign3,
								ox:-28,
								oy:-81
							}]]
						}
					}
				}
			};
			return _obj;
		}
		
		public static function get bTexture():Object
		{
			var _obj:Object = 
			{
				sprites:[{
					bmp:Window.textures.sign2,
					dx: -40,
					dy:-60
				}]
			};
			return _obj;
		}
		
		public static function get cTexture():Object
		{
			var _obj:Object = 
			{
				sprites:[{
					bmp:new BitmapData(10,10,true,0x0),
					dx: -40,
					dy:-60
				}]
			};
			return _obj;
		}
	}

}