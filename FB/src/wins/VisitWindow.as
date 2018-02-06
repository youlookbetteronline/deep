package wins 
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;

	public class VisitWindow extends Window
	{
		private var cookingCont:Sprite;
		private var background:Bitmap;
		private var back:Shape;
		private var maxWidth:Number;
		private var view:Sprite;
		
		public static var slider:Shape;
		public static var cookingBar:ProgressBar;
		
		private static var mProgress:Number;
		private static var dProgress:Number;
		
		public function VisitWindow(settings:Object = null) 
		{
			if (settings == null) 
			{
				settings = new Object();
			}
			
			settings['width'] 			= 500;
			settings['height'] 			= 400;
			settings['title'] 			= settings['title'] ||  Locale.__e("flash:1382952380329");
			settings['hasPaginator'] 	= false;
			settings['hasExit'] 		= false;
			settings['hasTitle'] 		= false;
			settings['faderClickable'] 	= false;
			settings['escExit'] 		= false;
			settings['faderAlpha'] 		= 0.6;
			settings['mode'] 			= settings['mode'];
			
			super(settings);
		}
		
		public function showProgressBar():void
		{
			if (!cookingCont)
			{
				cookingCont = new Sprite();
				bodyContainer.addChild(cookingCont);
			}
			
			while (cookingCont.numChildren > 0)
			{
				cookingCont.removeChildAt(0);
			}
			
			view = new Sprite();
			
			back = new Shape();
			back.graphics.beginFill(0xffffff, 1);
			back.graphics.drawRoundRect(0, 0, 160, 14, 14, 14);
			back.graphics.endFill();
			cookingCont.addChild(back);
			back.alpha = 0.5;
			
			back.x = background.x +(background.width - back.width) / 2;
			back.y = background.y + background.height + 30;
			
			slider = new Shape();
			progress();
			maxWidth = slider.width;
			view.addChild(slider);
			
			var Mask:Shape = new Shape();
			Mask.graphics.beginFill(0xff0000, 1);
			Mask.graphics.drawRect(0,0,view.width,view.height);
			Mask.graphics.endFill();
			
			view.x = back.x + (back.height - view.height) * 0.5;
			view.y = back.y + (back.height - view.height) * 0.5 + 1;
		   
			Mask.filters = [new BlurFilter(5, 0)];
			
			view.cacheAsBitmap = true;
			Mask.cacheAsBitmap = true;
			
			cookingCont.addChild(view);
		}
		public static function mapProgress(value:Number = 0):void
		{
			mProgress = value/2;
			progress(dProgress + mProgress)
		}
		
		public static function disposeProgress(value:Number = 0):void
		{
			dProgress = value/2;
			progress(dProgress + mProgress)
		}
		
		public static function progress(value:Number = 0):void
		{
			var width:int = 10 + 142 * value;
			var height:int = 10;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(width, height, 90);
			
			slider.graphics.clear();
			slider.graphics.beginGradientFill(GradientType.LINEAR, [0x7eb4fa, 0x716bd4], [1, 1], [0, 255], matrix);
			slider.graphics.lineStyle(2, 0xfceec9);
			slider.graphics.drawRoundRect(2, 0, width, height, 10, 10);
			slider.graphics.endFill();
		}
		
		override public function drawBackground():void 
		{
			background = new Bitmap(Window.textures.teleport);
			layer.addChild(background);
			background.x -= 40;
			background.y -= 100;
			
			var text:TextField = Window.drawText(settings['title'], {
				fontSize:36,
				fontBorderSize: 4,
				borderSize: 2,
				autoSize:'center',
				color:0xffffff,
				borderColor:0x104d0a
			});
			
			var ribbon:Bitmap = backingShort((text.textWidth <= 160) ? 330 : text.textWidth + 160, 'ribbonGrenn');
			ribbon.x = background.x + (background.width - ribbon.width) / 2;
			ribbon.y = background.y + background.height - 50;
			layer.addChild(ribbon);
			
			layer.addChild(text);
			text.x = ribbon.x + (ribbon.width - text.textWidth) / 2/* - 15*/;
			text.y = ribbon.y + (ribbon.height - text.height) / 2 - 13/* - 7*/;
			
			showProgressBar();
		}
		
	}

}