package utils 
{
	import api.com.adobe.images.PNGEncoder;
	import by.blooddy.crypto.image.JPEGEncoder;
	import flash.display.BitmapData;
	import flash.net.FileReference;
	/**
	 * ...
	 * @author 
	 */
	public class Saver 
	{
		public function Saver(){}
		public static var fileRef:FileReference = new FileReference();
		
		public static function saveText(text:String, name:String):void
		{
			Saver.fileRef.save(text, name+".txt");
		}
		
		public static function savePNG(bitmapData:BitmapData, name:String):void
		{
			Saver.fileRef.save(PNGEncoder.encode(bitmapData), name + ".png");
		}
		
		public static function saveJPG(bitmapData:BitmapData, name:String):void
		{
			Saver.fileRef.save(JPEGEncoder.encode(bitmapData), name + ".jpg");
		}
		
		public static function saveMapUnits():void
		{
			var unitString:String = JSON.stringify(App.user.units)
			var unitObj:Object = JSON.parse(unitString)
			var regExps:Array = new Array();
			regExps.push(
				{
					input:	/"[0-9]+"\:|,"capacity":[0-9]+/g,
					output:	' '
				},
				{
					input:	/^\{ /,
					output:	'['
				},
				{
					input:	/}$/,
					output:	']'
				}
			)
			for each(var exp:* in regExps)
				unitString = unitString.replace(exp.input, exp.output);
			fileRef.save(unitString, String(App.user.worldID)+".json");
		}
		
	}

}