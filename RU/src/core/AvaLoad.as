package core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class AvaLoad 
	{
		private var _loader:Loader = null;
		private var _loaderContent:DisplayObject = null;
		private var callback:Function;
		private var errCall:Function;
		private var url:String;
		
		public function AvaLoad(url:String, callback:Function, errCall:Function = null) 
		{
			if (url == null)
				return;
			
			if (errCall != null)
				this.errCall = errCall;
			
			var data:* = Load.getCache(url);
			
			if (data != null)
			{
				callback(data);
			}else{
				this.url = url;
				this.callback = callback;
				try{
					//trace('------', url);
					_loadContent(url);
				}
				catch (err:Error) {
					if (errCall != null)
						errCall();
				}
			}
		}
		
		private function _loadContent(url:String):void
		{ 
			_loader = new Loader();
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.addEventListener(Event.ADDED, _onAddedToLoader, true, int.MAX_VALUE);
			_loader.addEventListener(Event.ADDED, _onAddedToLoader, false, int.MAX_VALUE);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onPicLoaded);
			_loader.load(new URLRequest(url), new LoaderContext(true));
		}
 
		private function _onAddedToLoader( e:Event ) : void
		{
			if (e.target)
			{
				_loaderContent = e.target as DisplayObject;
			}
		}
		
		private function onError(e:IOErrorEvent):void
		{
			if(errCall!=null)
			errCall();
		}
 
		private function _onPicLoaded( e:Event ) : void
		{
			var bd:BitmapData = (_loaderContent as Bitmap).bitmapData;
			var bdCopy:BitmapData = new BitmapData(bd.width, bd.height, true, 0x0);
			
			bdCopy.draw(bd);
			
			var scaleX:Number = 60 / bd.width;
			var scaleY:Number = 60 / bd.height;
			
			if (scaleX < 1)
			{
				var matrix:Matrix = new Matrix();
				matrix.scale(scaleX, scaleY);
				var smallBMD:BitmapData = new BitmapData(60, 60, true, 0x000000);
				smallBMD.draw(bdCopy, matrix, null, null, null, true);
				bdCopy = smallBMD;
			}
			
			bd = null;
			var bmp:Bitmap = new Bitmap(bdCopy);
			
			callback(bmp);
			
			try {
				_loaderContent = _loader.content;
			} catch (exception:Error) {
			}
		}
	}
}