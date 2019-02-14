package 
{
	import enixan.components.List;
	import enixan.components.ListNode;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	
	public class ProjectPanel extends List 
	{
		
		public function ProjectPanel(stage:Stage, width:int, height:int, params:Object = null) 
		{
			
			if (!params) params = { };
			params.backgroundAlpha = 0;
			params.haveScroller = true;
			
			type = List.HORIZONTAL;
			
			super(stage, width, height, params);
			
			nodeHeight = 80;
			blockDrag = true;
		}
		
		override public function add(info:Object, update:Boolean = false):void {
			super.add(info, update)
		}
		
	}

}