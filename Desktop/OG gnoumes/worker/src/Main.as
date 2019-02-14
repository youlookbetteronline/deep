package
{
	import com.adobe.images.PNGEncoder;
	import com.shortybmc.data.parser.CSV;
	import core.Lang;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.MessageChannel;
	import flash.system.Security;
	import flash.system.System;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setInterval;
	
	public class Main extends Sprite 
	{
		
		public static const PING:String = 'ping';
		public static const BITMAPDATA_TO_PNG:String = 'bitmapDataToPNG';
		public static const WORK1:String = 'work1';
		public static const WORK2:String = 'work2';
		public static const WORK3:String = 'work3';
		
		public var mainChannel:MessageChannel;
		public var workerChannel:MessageChannel;
		
		private var event:String;
		private var key:String;
		private var data:Object;
		
		private var garbage:Array;
		
		Security.allowDomain("*");
        Security.allowInsecureDomain("*");
		
		public function Main() {
			
			if (Worker.current.isPrimordial) return;
			
			garbage = [];
			
			mainChannel = Worker.current.getSharedProperty('toMain');
			workerChannel = Worker.current.getSharedProperty('toWorker');
			
			workerChannel.addEventListener(Event.CHANNEL_MESSAGE, onChannelMessage);
			
		}
		
		private function onChannelMessage(e:Event):void {
			var object:Object = workerChannel.receive();
			
			if (!object.event) return;
			
			clear();
			register(object);
			
			switch(object.event) {
				case BITMAPDATA_TO_PNG:
					bitmapDataToPng(object.data);
					break;
				case WORK1:
					work1(object.data);
					break;
				case WORK2:
					work2(object.data);
					break;
				case WORK3:
					work3(object.data);
					break;
				case PING:
					send(PING, 'ping');
					break;
				default:
					send(object);
			}
		}
		private var regData:Object;
		private function register(object:Object):Boolean {
			if (!regData)
				regData = { };
			
			if (!object.event)
				return false;
			
			regData[object.event] = object;
			return true;
		}
		
		// Очистка данных мусорки
		private function clear():void {
			while (garbage.length) {
				var object:* = garbage.shift();
				if (!object) continue;
				
				if (object is BitmapData) {
					(object as BitmapData).dispose();
				}
				
				object = null;
			}
			
			trace(System.totalMemory);
		}
		
		public function send(data:*, event:String = null):void {
			
			if (!data) return;
			
			var object:Object;
			if (event && regData[event]) {
				object = regData[event];
				object.data = data;
			}else {
				object = data;
			}
			
			trace('[Worker] Send.');
			mainChannel.send(object);
		}
		
		
		
		
		
		// BitmapData to PNG
		private function bitmapDataToPng(data:*):void {
			var bytes:ByteArray = new ByteArray();
			if (data is BitmapData) {
				bytes = PNGEncoder.encode(data as BitmapData);
			}
			
			garbage.push(data);
			garbage.push(bytes);
			
			send(bytes, BITMAPDATA_TO_PNG);
		}
		
		
		
		
		private function work3(data:Object):void {
			var bmd:BitmapData = new BitmapData(data.width, data.height, true, 0);
			bmd.setPixels(bmd.rect, data.bytes as ByteArray);
			
			garbage.push(data.bytes);
			garbage.push(bmd);
			
			var object:Object = trimTransparency(bmd);
			object['bytes'] = object.bmd.getPixels(object.bmd.rect);
			object['id'] = data.id;
			object['width'] = object.bmd.width;
			object['height'] = object.bmd.height;
			delete object.bmd;
			
			send(object, WORK3);
		}
		
		
		
		
		
		// BitmapData to PNG and to File (bmd, destination, name)
		private function work1(data:Object):void {
			var bmd:BitmapData = new BitmapData(data.width, data.height, true, 0);
			bmd.setPixels(bmd.rect, data.bytes as ByteArray);
			
			garbage.push(bmd);
			garbage.push(data.bytes);
			
			var object:Object = trimTransparency(bmd);
			object['bytes'] = object.bmd.getPixels(object.bmd.rect);
			object['id'] = data.id;
			object['width'] = object.bmd.width;
			object['height'] = object.bmd.height;
			
			var png:ByteArray = new ByteArray();
			png = PNGEncoder.encode(object.bmd);
			object['png'] = png;
			delete object.bmd;
			
			send(object, WORK1);
			
			png = null;
		}
		private function trimTransparency(input:BitmapData, colourChecker:uint = 0x00FF00):Object {
			
			var clone:BitmapData = new BitmapData(input.width, input.height, true, colourChecker);
			clone.draw(input);
			
			var bounds:Rectangle = clone.getColorBoundsRect(0xFFFFFFFF, colourChecker, false);
			
			var bmd:BitmapData;
			if (bounds.width == 0 && bounds.height == 0) {
				bounds.left = 0;
				bounds.top = 0;
				bounds.width = 1;
				bounds.height = 1;
			}
			
			bmd = new BitmapData(bounds.width, bounds.height, true, 0);
			bmd.copyPixels(input, bounds, new Point(0, 0));
			
			garbage.push(bmd);
			
			return {
				bmd:	bmd,
				dx:		bounds.left,
				dy:		bounds.top
			};
		}
		
		
		
		
		// 
		private function work2(data:Object):void {
			
			var bitmapData:BitmapData;
			var currWidth:int = 0;
			var currHeight:int = 0;
			var maxHeight:int = 0;
			var result:Object = {
				results:[],
				png:null
			}
			
			for (var i:int = 0; i < data.bmds.length; i++) {
				
				garbage.push(data.bmds[i]);
				
				bitmapData = new BitmapData(data.width, data.height, true, 0);
				bitmapData.setPixels(bitmapData.rect, data.bmds[i]);
				
				result.results[i] = trimTransparency(bitmapData);
				
				bitmapData = result.results[i].bmd;
				
				if (bitmapData.height > maxHeight) maxHeight = bitmapData.height;
				if (currWidth + bitmapData.width < 8000) {
					currWidth += bitmapData.width;
				}else {
					currHeight += maxHeight;
					maxHeight = 0;
					currWidth = 0;
				}
			}
			
			var atlas:BitmapData = new BitmapData(currWidth + 200, currHeight + maxHeight + 200, true, 0);
			var matrix:Matrix = new Matrix();
			currWidth = 0;
			currHeight = 0;
			maxHeight = 0;
			
			for (i = 0; i < result.results.length; i++) {
				bitmapData = result.results[i].bmd;
				matrix.tx = currWidth;
				matrix.ty = currHeight;
				result.results[i]['ox'] = matrix.tx;
				result.results[i]['oy'] = matrix.ty;
				atlas.draw(bitmapData, matrix);
				
				if (bitmapData.height > maxHeight) maxHeight = bitmapData.height;
				if (currWidth + bitmapData.width < 8000) {
					currWidth += bitmapData.width;
				}else {
					currHeight += maxHeight;
					maxHeight = 0;
					currWidth = 0;
				}
			}
			
			var atlasObject:Object = trimTransparency(atlas);
			atlas = atlasObject.bmd;
			if (atlasObject.dx > 0 || atlasObject.dy > 0) {
				for (i = 0; i < result.results.length; i++) {
					result.results[i].ox -= atlasObject.dx;
					result.results[i].oy -= atlasObject.dy;
				}
			}
			
			result['png'] = PNGEncoder.encode(atlas);
			
			garbage.push(atlas);
			garbage.push(result.png);
			
			send(result, WORK2);
		}
		
		
	}
	
}