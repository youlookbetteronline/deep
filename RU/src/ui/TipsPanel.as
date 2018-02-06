package ui 
{
	import buttons.ImageButton;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class TipsPanel extends Sprite
	{
		public static var tipsPanel:TipsPanel;
		private var mID:int;
		
		public var settings:Object = {
			width:300,
			height:70
		}
		
		public function TipsPanel(settings:Object)
		{
			for (var key:* in settings) {
				this.settings[key] = settings[key];
			}
			qID = settings.qID;
			mID = settings.mID;
		}
		
		public function init():void
		{
			drawBg();
			drawItems();
			drawDesc();
			drawIcon();
		}
		
		private function drawIcon():void 
		{
			var bgIcon:Bitmap = new Bitmap(Window.textures.questIconBacking);
			bgIcon.scaleX = bgIcon.scaleY = 1.1;
			bgIcon.smoothing = true;
			//addChild(bgIcon);
			bgIcon.x = settings.width - bgIcon.width +5;
			bgIcon.y = (settings.height - bgIcon.height) / 2 + 2;
			
			var preloader:Preloader = new Preloader();
			addChild(preloader);
			preloader.x = bgIcon.x + bgIcon.width / 2;
			preloader.y = bgIcon.y + bgIcon.height / 2;
			
			var icon:Bitmap = new Bitmap();
			addChild(icon);
			Load.loading(Config.getQuestIcon('icons', App.data.personages[settings.indCharacter].preview), function(data:*):void {
				removeChild(preloader);
				
				icon.bitmapData = data.bitmapData;
				icon.scaleX = icon.scaleY = 1;
				icon.smoothing = true;
				icon.scaleX = -icon.scaleX;
				
				var marginX:int = 0;
				var marginY:int = 	(shape.height -icon.height)/ 2;
			
				/*switch(settings.indCharacter) {
					case 1:
						marginX = 8;
					break;
					case 2:
						marginX = -2;
						marginY = -12;
					break;
					case 3:
						marginX = 2;
						marginY = -3;
					break;
					case 4:
						marginX = -2;
						marginY = -7;
					break;
					case 5:
						marginX = 13;
						marginY = -13;
					break;
					case 6:
						marginX = 13;
						marginY = 0;
					break;
				}*/
				
				icon.x = bgIcon.x + (bgIcon.width - icon.width) /2 + icon.width + marginX;
				icon.y = /*bgIcon.y + bgIcon.height - icon.height - 7 +*/ marginY;
			});
		}
		
		private function drawDesc():void 
		{
			if (settings.title) {
				var title:TextField = Window.drawText(settings.title, {
					color:0xffffff,
					fontSize:30,
					borderColor:0x5a391a,
					autoSize:"left",
					textAlign:"left",
					borderSize:4
				});
				
				addChild(title);
				title.x = 40;
				title.y = -title.textHeight / 2;
			}
			if (settings.desc) {
				var desc:TextField = Window.drawText(settings.desc, {
					color:0x5a391a,
					fontSize:22,
					textLeading:-6,
					borderColor:0xffffff,
					autoSize:"left",
					textAlign:"left",
					multiline:true,
					wrap:true,
					border:false,
					width:settings.width - 100,
					borderSize:2
				});
				
				addChild(desc);
				desc.x = 40;
				desc.y = (settings.height - desc.textHeight) / 2;
			}
		}
		
		public var shape:Shape;
		private function drawBg():void 
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(width, height, (Math.PI / 180) * 90, 0, 0);
			
			shape = new Shape();
			shape.graphics.beginGradientFill(GradientType.LINEAR, [0xeed4a6, 0xeed4a6], [1, 1], [0, 255], matrix);
			shape.graphics.drawRoundRect(0, 0, settings.width-30, settings.height, 15);
			shape.graphics.endFill();
			shape.filters = [new GlowFilter(0x4c4725, 1, 4, 4, 3, 1)];
			shape.alpha = 0.8;
						
			addChild(shape);
		}
		
		private function drawItems():void 
		{
			var bgAttantion:ImageButton = new ImageButton(UserInterface.textures.helpBttnAttention);
			bgAttantion.x = -bgAttantion.width / 2;
			bgAttantion.scaleX = bgAttantion.scaleY = 0.95;
			bgAttantion.y = (settings.height - bgAttantion.height) / 2 +2;
			addChild(bgAttantion);
			
			/*bgAttantion.*/tipsPanel.addEventListener(MouseEvent.CLICK, onClick);
			
			//var attantionIcon:Bitmap = new Bitmap(UserInterface.textures.bigBang);
			////attantionIcon.scaleX = attantionIcon.scaleY = 1.5;
			//attantionIcon.smoothing = true;
			//addChild(attantionIcon);
			//attantionIcon.y = bgAttantion.y + (bgAttantion.height - attantionIcon.height)/2 + 2;
			//attantionIcon.x = bgAttantion.x + (bgAttantion.width - attantionIcon.width)/2;
		}
		
		private function onClick(e:MouseEvent):void 
		{
			App.user.quests.helpEvent(qID, mID);
		}
		
		public function resize():void
		{
			tipsPanel.x = App.self.stage.stageWidth - tipsPanel.settings.width - 30;
		}
		
		public var qID:uint;
		public static var alreadyShowed:Object = { };
		
		public static function show(settings:Object):void 
		{
		//	return;
			
			if (alreadyShowed[settings.qID] != null)
				return;
				
			alreadyShowed[settings.qID] = App.time;	
				
			if (tipsPanel)
				hide();
				
			tipsPanel = new TipsPanel(settings);
			tipsPanel.init();
			App.ui.addChild(tipsPanel);
			
			tipsPanel.x = App.self.stage.stageWidth - tipsPanel.settings.width -30;
			var finishX:int = App.self.stage.stageWidth - tipsPanel.settings.width -10;
			
			TweenLite.to(tipsPanel, 0.5, { x:finishX } );
			tipsPanel.y = 168;
		}
		public static function resize():void {
			if (tipsPanel == null)
				return;
				
			tipsPanel.x = App.self.stage.stageWidth - tipsPanel.settings.width - 30;
		}
		
		
		public static function hide():void {
			if (tipsPanel == null)
				return;
				
			tipsPanel.removeEventListener(MouseEvent.CLICK, tipsPanel.onClick);
			App.ui.removeChild(tipsPanel);
			tipsPanel = null;
		}
	}
}