package wins 
{
	import adobe.utils.CustomActions;
	import enixan.Compiler;
	import enixan.Util;
	import enixan.components.Button;
	import enixan.components.CheckBox;
	import enixan.components.DropList;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filesystem.File;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	import mx.controls.Alert;
	import mx.controls.textClasses.TextRange;
	import wins.Window;
	
	public class TextureWindow extends Window 
	{
		
		[Embed(source="../../res/folder.png")]
		private var FolderIcon:Class;
		private var folderBMD:BitmapData = new FolderIcon().bitmapData;
		
		public static var animate:Boolean = true;
		public static var Stage:int = -1;
		public static var Anim:String = '';
		public static var instance:TextureWindow;
		public static var bitmapData:BitmapData = new BitmapData(100, 100, true, 0x0);
		
		public function TextureWindow(params:Object = null)
		{
			
			if (!params) params = { };
			
			params.width = 1100;
			params.height = 740;
			params.itemWidth = 500;
			params.itemHeight = 450;
			
			super(params);
			
			TextureWindow.instance = this;
		}
		
		override public function draw():void {
			super.draw();
			
			var titleCont:Sprite = new Sprite();
			titleCont.mouseChildren = false;
			titleCont.mouseEnabled = false;
			container.addChild(titleCont);
			
			var titleLabel:TextField = Util.drawText( {
				text:		'Текстуры',
				size:		42,
				color:		0xffffff
			});
			titleLabel.x = params.width * 0.5 - titleLabel.width * 0.5;
			titleLabel.y = 7;
			titleCont.addChild(titleLabel);
			
		}
		
		
		override public function close(e:MouseEvent = null):void {
			
			TextureWindow.instance = null;
			
			super.close();
		}
		
	}

}
