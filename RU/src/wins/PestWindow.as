package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.Cursor;

	public class PestWindow extends Window
	{
		public var okBttn:Button;
		public var ConfirmBttn:Button;
		public var textLabel:TextField = null;
		public function PestWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['textAlign'] 		= settings.textAlign || 'center';		
			settings['hasButtons']		= false	
			settings["width"]			= 465;
			settings["height"] 			= 260;		
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;			
			settings["fontSize"]		= 38;	
			settings["hasTitle"]		= false;
			settings["hasExit"]			= false;			
			settings["fontColor"]       = 0xffffff;
			settings['background'] = 'capsuleWindowBacking';
			super(settings);
		}
		override public function drawBackground():void 
		{
			super.drawBackground();
			var paper:Bitmap = new Bitmap();
			paper = backing(settings.width - 70, settings.height - 70, 46, 'paperGlow');
			paper.x = (settings.width - paper.width) / 2;
			paper.y = (settings.height - paper.height) / 2;
			layer.addChild(paper);
		}
		
		override public function drawBody():void
		{
			textLabel = Window.drawText(settings.text, {
				color:0x6f3d1a,
				border:false,
				fontSize:30,
				textAlign:settings.textAlign,
				multiline:true,
				wrap:true,
				width:350
			});		
			textLabel.x = (settings.width - textLabel.width) / 2;
			textLabel.y = (settings.height - textLabel.height) / 2 - 15;
			bodyContainer.addChild(textLabel);
			
			var pestImg:Bitmap = new Bitmap(Window.textures.pestNew);
			pestImg.x = -25;
			pestImg.y = 140
			bodyContainer.addChild(pestImg);
			
			var suchOk:Bitmap = new Bitmap(Window.textures.suchOk);
			suchOk.scaleX = suchOk.scaleY = 0.8;
			bodyContainer.addChild(suchOk);
			suchOk.smoothing = true;
			suchOk.x = settings.width - suchOk.width;
			suchOk.y = settings.height - suchOk.height + 15;
			
			drawBttns();
		}
	
		public function drawBttns():void 
		{
			okBttn = new Button( {
				caption:settings.buttonText,
				fontSize:26,
				width:160,
				hasDotes:false,
				height:47
			});
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
			bodyContainer.addChild(okBttn);
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - okBttn.height;
			okBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
		}
		
		public function onOkBttn(e:MouseEvent):void {
			close();
		}
	}
}