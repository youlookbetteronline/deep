package wins.elements 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class PuzzleItem extends Sprite
	{	
		public var bg:Bitmap;
		public var item:Object;
		
		private var bitmap:Bitmap;
		private var _parent:*;
		
		public function PuzzleItem(item:Object, parent:*)
		{
			this._parent = parent;
			this.item = item;
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			Load.loading(Config.getImage('paintings/parts', 'PaintPiece' + (item.id + 1)), function(data:*):void
			{				
				bitmap.bitmapData = data.bitmapData;
				bitmap.smoothing = true;
				//bitmap.x = item.pos.x;
				//bitmap.y = item.pos.y;
				
				_parent.counter++;
			})	
		}
		
		public function dispose():void
		{
			if (bitmap && bitmap.parent)
				bitmap.parent.removeChild(bitmap);
			bitmap = null;
		}
	}
}