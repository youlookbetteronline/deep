package enixan 
{
	import com.adobe.crypto.MD5;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author 
	 */
	public class Util 
	{
		
		
		/**
		 * Количество элементов в объекте
		 * @param	object
		 * @return
		 */
		public static function countProps(object:Object = null):int {
			var nums:int = 0;
			
			if (object)
				for (var s:String in object) nums++;
			
			return nums;
		}
		
		public static function drawText(data:Object):TextField {
			
			var object:Object = {
				text:			'',
				background:		false,
				backgroundColor:0xffffff,
				border:			false,
				borderColor:	0x111111,
				size:			16,
				color:			0x666666,
				bold:			false,
				italic:			false,
				underline:		false,
				multiline:		false,
				selectable:		false,
				type:			TextFieldType.DYNAMIC,
				textAlign:		TextFormatAlign.LEFT,
				autoSize:		TextFieldAutoSize.NONE,
				leftMargin:		null,
				rightMargin:	null,
				indent:			null,
				leading:		null,
				sharpness:		100,
				thickness:		50,
				embedFonts:		true,
				font:			'Tahoma',
				wrap:			false,
				maxChars:		0,
				restrict:		null
			}
			
			for (var s:* in data) {
				if (data[s] !== null)
					object[s] = data[s];
			}
			
			if (object.type == TextFieldType.INPUT)
				object.selectable = true;
			
			var textField:TextField = new TextField();
			textField.embedFonts = object.embedFonts;
			textField.defaultTextFormat = new TextFormat(object.font, object.size, object.color, object.bold, object.italic, object.underline, null, null, object.textAlign, object.leftMargin, object.rightMargin, object.indent, object.leading);
			textField.autoSize = object.autoSize;
			textField.background = object.background;
			textField.border = object.border;
			textField.borderColor = object.borderColor;
			textField.selectable = object.selectable;
			textField.type = object.type;
			textField.text = object.text;
			textField.wordWrap = Boolean(object.wrap || object.wordWrap);
			textField.multiline = object.multiline;
			textField.maxChars = object.maxChars;
			textField.restrict = object.restrict;
			
			if (!object.width) textField.width = textField.textWidth + 4;
			else textField.width = object.width;
			
			if (!object.height) textField.height = textField.textHeight + 4;
			else textField.height = object.height;
			
			return textField;
			
		}
		
		
		public static function getLineWith(string:String, from:String):String {
			var pos:int = from.indexOf(string);
			var begin:int = from.lastIndexOf('\n', pos);
			var end:int = from.indexOf('\n', pos);
			var line:String = from.substring(begin, end);
			
			line = line.replace(/[\n,\t,\r]/ig, '');
			
			return line;
		}
		
		
		private static var loaders:Vector.<Loader>;
		private static var loaderLocalAssoc:Object;
		public static function load(url:String = null, onComplete:Function = null, onError:Function = null):void {
			
			if (!url) {
				error();
				return;
			}
			
			var name:String = url.substring((url.lastIndexOf('\/') >= 0) ? url.lastIndexOf('\/') : 0, url.length);
			//var cash:File = new File(File.cacheDirectory.nativePath + File.separator + 'ObjectGenerator');
			//cash.createDirectory();
			
			/*if (!loaderLocalAssoc) {
				loaderLocalAssoc = { };
				var list:Array = cash.getDirectoryListing();
				for (var i:int = 0; i < list.length; i++) {
					loaderLocalAssoc[list[i].name] = list[i].nativePath;
				}
			}*/
			
			if (!loaders)
				loaders = new Vector.<Loader>;
			
			//var fileHash:String = MD5.hash(url);
			//if (loaderLocalAssoc.hasOwnProperty(fileHash))
				//url = loaderLocalAssoc[fileHash];
			
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, error);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
			
			var request:URLRequest = new URLRequest(/*(loaderLocalAssoc.hasOwnProperty(fileHash)) ? loaderLocalAssoc[fileHash] : */url);
			
			loader.load(request);
			loaders.push(loader);
			
			function complete(e:Event):void {
				dispose(e.target.loader as Loader);
				
				if (onComplete != null)
					onComplete(e.target.content);
				
				/*var file:File = new File(cash.nativePath + File.separator + name);
				if (!file.exists) {
					Files.save(file, e.target.bytes, true);
					loaderLocalAssoc[fileHash] = file.nativePath;
				}*/
				
			}
			function error(e:Event = null):void {
				dispose(e.target.loader as Loader);
				
				if (onError != null)
					onError();
			}
			function dispose(loader:Loader):void {
				
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, complete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, error);
				loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
				
				var index:int = loaders.indexOf(loader);
				if (index >= 0) loaders.splice(index, 1);
			}
			
		}
		
		public static function trimTransparency(input:BitmapData, colourChecker:uint = 0x00FF00):Object {
			
			var orignal:Bitmap = new Bitmap(input);
			
			var clone:BitmapData = new BitmapData(orignal.width, orignal.height, true, colourChecker);
			clone.draw(orignal);
			
			var bounds:Rectangle = clone.getColorBoundsRect(0xFFFFFFFF, colourChecker, false);
			var returnedBitmap:Bitmap = new Bitmap();
			
			var bmd:BitmapData = new BitmapData(bounds.width, bounds.height,true,0x00000000);
			bmd.copyPixels(orignal.bitmapData, bounds, new Point(0, 0));
			
			return {
				bmd:	bmd,
				dx:		bounds.left,
				dy:		bounds.top
			};
		}
		
	}

}