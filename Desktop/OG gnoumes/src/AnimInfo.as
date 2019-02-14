package 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class AnimInfo extends ViewInfo {
		
		public static const LINEAR_ANIMATION:uint = 1;
		public static const PINGPONG_ANIMATION:uint = 2;
		public static const ADVANCED_ANIMATION:uint = 3;
		
		private var __animType:uint;	// Тип анимации
		
		public var frame:int;			// Кадр массива chain
		public var play:Boolean;		// Проигрывается или нет
		public var repeat:uint;			// Повторений кадра
		
		public var road:Boolean;		// Дорожка под анимацией
		public var speed:Number = 0.15;	// Скорость дорожки
		
		public var files:Vector.<File>;
		public var bmds:Vector.<BitmapData>;
		public var basicChain:Array;
		public var chain:Array;
		
		public var indents:Vector.<Point>;			// Отступы картинки от 0,0 анимации
		public var atlasPositions:Vector.<Point>;	// Позиции картинок на атласе
		public var atlas:BitmapData;
		public var png:ByteArray;
		
		public function AnimInfo(file:File, name:String, x:int = 0, y:int = 0, files:Vector.<File> = null, animType:uint = 1, repeat:uint = 3) {
			
			super(file, name, x, y);
			
			this.files = files;
			
			indents = new Vector.<Point>(this.files.length);
			atlasPositions = new Vector.<Point>(this.files.length);
			bmds = new Vector.<BitmapData>(this.files.length);
			basicChain = AnimInfo.chainPingPong(bmds.length);
			
			this.repeat = repeat;
			this.animType = animType;
		}
		
		override public function get bitmapData():BitmapData {
			if (bmds && bmds.length > 0 && bmds[0])
				return bmds[0];
			
			return super.bitmapData;
		}
		
		/**
		 * 
		 */
		public function addBitmapData(bmd:BitmapData, position:int):void {
			bmds[position] = bmd;
			
			sourceWidth = bmd.width;
			sourceHeight = bmd.height;
		}
		
		/**
		 * Количество кадров
		 */
		public function get frames():uint {
			return bmds.length;
		}
		
		//
		public function get animType():uint {
			return __animType;
		}
		public function set animType(value:uint):void {
			if (value == __animType) return;
			
			__animType = value;
			
			createAnimation();
		}
		
		//
		public function createAnimation(animType:uint = 0, repeat:uint = 0):void {
			
			if (__animType == 0) return;
			
			if (animType > 0) __animType = animType;
			if (repeat > 0) this.repeat = repeat;
			
			switch(__animType) {
				case LINEAR_ANIMATION:
					chain = AnimInfo.chainLinear(bmds.length, this.repeat);
					break;
				case PINGPONG_ANIMATION:
					chain = AnimInfo.chainPingPong(bmds.length, this.repeat);
					break;
				default:
					if (!chain || chain.length == 0)
						chain = AnimInfo.chainLinear(bmds.length, this.repeat);
			}
		}
		
		private var copyChain:Array;
		public function copy(from:int, to:int):void {
			if (from < 0 || from >= to) return;
			
			copyChain = [];
			
			for (from; from < to; from++) {
				if (chain.length > from)
					copyChain.push(chain[from]);
			}
		}
		public function paste(to:int, reverse:Boolean = false):Array {
			if (!copyChain || chain.length < to)
				return chain;
			
			for (var i:int = 0; i < copyChain.length; i++) {
				if (copyChain[i] < 0 || copyChain[i] >= bmds.length)
					return chain;
			}
			
			if (reverse) {
				for (i = copyChain.length - 1; i > -1; i--) {
					chain.splice(to + copyChain.length - 1 - i, 0, copyChain[i]);
				}
			}else{
				for (i = 0; i < copyChain.length; i++) {
					chain.splice(to + i, 0, copyChain[i]);
				}
			}
			
			return chain;
		}
		public function del(from:int, to:int):Array {
			if (from >= 0 && from < to)
				chain.splice(from, to - from);
			
			return chain;
		}
		
		
		public function clone():AnimInfo {
			var animInfo:AnimInfo = new AnimInfo(file, name, x, y, files, animType, repeat);
			animInfo.bmds = bmds;
			animInfo.atlas = atlas;
			animInfo.atlasPositions = atlasPositions;
			animInfo.png = png;
			
			copy(0, chain.length);
			animInfo.chain = copyChain;
			
			for (var i:int = 0; i < indents.length; i++)
				animInfo.indents[i] = new Point(indents[i].x, indents[i].y);
			
			return animInfo;
		}
		
		
		public static function chainLinear(frames:int, repeat:int = 3):Array {
			var array:Array = [];
			for (var i:int = 0; i < frames; i++) {
				for (var j:int = 0; j < repeat; j++)
					array.push(i);
			}
			return array;
		}
		public static function chainPingPong(frames:int, repeat:int = 3):Array {
			var array:Array = [];
			for (var i:int = 0; i < frames; i++) {
				for (var j:int = 0; j < repeat; j++)
					array.push(i);
			}
			i -= 2;
			for (i; i > -1; i--) {
				for (j = 0; j < repeat; j++)
					array.push(i);
			}
			return array;
		}
		
		
		public function changeName(name:String):void {
			Main.app.animationChangeName(this, name);
		}
		
	}

}