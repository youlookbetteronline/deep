package wins.elements 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class ContentManager extends Sprite
	{
		public var itemType:Class;
		public var content:Array = [];
		private var settings:Object = {
			from:0,
			to:2,
			cols:2,
			margin:10,
			padding:10
		};
		
		public function ContentManager(settings:Object) {
			for (var prop:* in settings) {
				this.settings[prop] = settings[prop];
			}
			itemType = settings.itemType;
			content = settings.content;
		}
		
		public function update(_from:int,_to:int):void {
			var i:int = 0;
			for (i = numChildren-1; i >= 0; i-- ) {
				removeChild(getChildAt(i));
			}
			var itemClass:Class = itemType;
			for (i = _from; i < _to; i++ ) {
				content[i]['pagePos'] = i - _from;
				var item:* = new itemClass(content[i]);
				item.x = settings.padding + ((i - _from) % settings.cols) * ( item.itemRect.width + settings.margin);
				item.y = settings.padding + int((i - _from) / settings.cols) * ( item.itemRect.height + settings.margin);
				
				addChild(item);
			}
		}
	}
}