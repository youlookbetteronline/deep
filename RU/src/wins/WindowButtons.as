package wins 
{
	
	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import fog.FogCloud;
	import org.flintparticles.twoD.renderers.PixelRenderer;
	import ui.Cursor;
	import units.Plant;
	import units.Wigwam;
	import wins.PurchaseWindow;
	import units.Storehouse;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class WindowButtons extends Window 
	{
		
		public var button1:Button;
		public var button2:Button;
		public var button3:Button;
		
		public var textLabel:TextField = null;
		public var textLabel2:TextField = null;
		
		public var neededItem:Bitmap = new Bitmap;
		
		private var requireItems:Object = null;
		
		private var requireText:String = new String;
		
		public var background:Bitmap;
		
		public var bitmap:Bitmap = new Bitmap;
		
		private var bitmapLabel:Bitmap = null;
		//private var back:Bitmap;
		
		private var dY:int = 0;
		private var dX:int = 0;
		private var textLabel_dY:int = 0;
		private var titleLabel_dY:int = 0;
		private var textLabelOffsetY:int = 0;
		
		public function WindowButtons(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			settings['title'] 			= settings.title;
			settings['text'] 			= settings.text;
			settings['text2'] 			= settings.text2 || false;
			settings['textAlign'] 		= settings.textAlign || 'center';
			settings['autoSize'] 		= settings.autoSize || 'center';
			settings['textSize'] 		= settings.textSize || 24;
			settings['padding'] 		= settings.padding || 20;
			settings["width"]			= settings.width || 400;
			settings["height"] 			= settings.height || 200;
			settings["fontSize"]		= 38;
			settings["fontColor"]       = 0xffffff;
			settings["bitmap"]	 		= settings.bitmap || null;
			settings['button1'] 		= settings.button1 || false;
			settings['button2'] 		= settings.button2 || false;
			settings['button3'] 		= settings.button3 || false;
			settings['neededItems']     = settings.neededItems || 645;  // если ничего не надо - всегда надо динамит
			
			textLabelOffsetY			= settings.textLabelOffsetY || 0;
			textLabel_dY = 0;
			
			super(settings);
		}
		
		override public function drawBody():void {

			if (settings.offsetY) {
				this.y = settings.offsetY;
				fader.y = Math.abs(settings.offsetY);
			}
			
			if (settings.offsetX) {
				this.x = settings.offsetX;
				fader.x =  Math.abs(settings.offsetX);
			}
			
			var textFontSize:int;
			if (settings.title != null) {
				textFontSize = settings.textSize;
			} else
				textFontSize = settings.textSize + 8;
				
			requireItems = settings.neededItems;
			
			if (requireItems){
				for (var t:* in requireItems) {
					requireText += App.data.storage[t].title + ' ';
				}
				textLabel = Window.drawText(settings.text + ' ' + requireText, {
				color: 0xFFFFFF,
				borderColor:0x6f3d1a,
				borderSize:4,
				fontSize:textFontSize,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				multiline:true
				});
			}  else {
				textLabel = Window.drawText(settings.text, {
				color: 0xFFFFFF,
				borderColor:0x6f3d1a,
				borderSize:4,
				fontSize:textFontSize,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				multiline:true
				});
			}
			

			textLabel.wordWrap = true;
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			textLabel.width = settings.width - 80;
			textLabel.height = textLabel.textHeight + 4;
			
			var y1:int = titleLabel.y + titleLabel.height;
			var y2:int = bottomContainer.y;
			
			bodyContainer.addChild(textLabel);
			//textLabel.border = true;
			textLabel.x = (settings.width - textLabel.width)/2;
			textLabel.y = titleLabel.y + titleLabel.height;
			
			exit.y = - 16;
			
			if (settings.text2) {
				textLabel2 = Window.drawText(settings.text2, {
					color:0xFFFFFF,
					borderColor:0x6f3d1a,
					borderSize:4,
					fontSize:textFontSize,
					textAlign:settings.textAlign,
					autoSize:settings.autoSize,
					multiline:true
					});
					
				textLabel2.wordWrap = true;
				textLabel2.mouseEnabled = false;
				textLabel2.mouseWheelEnabled = false;
				textLabel2.width = settings.width - 50;
				textLabel2.height = textLabel.textHeight + 4;
				
				textLabel.x = 25;
				textLabel.y = 30;
				
				exit.x += 10;
				//exit.y = textLabel.y - 30;
				
				bodyContainer.addChild(textLabel2);
				
				textLabel2.x = textLabel.x;
				textLabel2.y = textLabel.y + textLabel.height + 20 ;
				
			}
			
			drawBttns();
			
			if (settings.title != null) {
				//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, settings.titleHeight / 2 + titleLabel.y + 2, true, true, true);
				//drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, settings.height - 105);
				//drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, 45,false,false,false,1,-1);
			}
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap =  backing2(settings.width, settings.height, 50, 'questBackingTop', 'questBackingBot');
			layer.addChild(background);	
			//background = backing2(settings.width, settings.height, 50, 'questBackingTop', 'questBackingBot');
		}
			
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: true,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 80,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -2; 
			bodyContainer.addChild(titleLabel);
		}
		
		public function drawBttns():void {
			if (settings.button1){	
				button1 = new Button( {
						caption:Locale.__e('flash:1382952379751'),
						fontSize:26,
						width:120,
						hasDotes:false,
						height:47
				});
				
				button1.addEventListener(MouseEvent.CLICK, buttonAction1);
				
				bodyContainer.addChild(button1);
				button1.x = settings.width / 2 - button1.width - 10;
				button1.y = textLabel.y + textLabel.height + 10 ;
			}
			if (settings.button2){
				button2 = new Button( {
						caption:Locale.__e('flash:1407231372860'),
						fontSize:26,
						width:120,
						hasDotes:false,
						height:47
				});
				
				button2.addEventListener(MouseEvent.CLICK, buttonAction2);
				
				bodyContainer.addChild(button2);
				button2.x = settings.width / 2 + 10 ;
				button2.y = settings.height - button2.height *2;
			}
			if (settings.button3){
				button3 = new Button( {
						caption:Locale.__e('flash:1382952379751'),
						fontSize:26,
						width:120,
						hasDotes:false,
						height:47
				});
				
				button3.addEventListener(MouseEvent.CLICK, buttonAction3);
				
				bodyContainer.addChild(button3);
				button3.x = settings.width / 2 - button3.width / 2;
				button3.y = settings.height - button3.height *2;//textLabel.y + textLabel.height  + button3.height / 2 ;
				/*if(textLabel2){
					button3.y += textLabel2.height;
				}*/
			}
			if (settings.button2 && settings.button3){
				button2.x = (settings.width - button2.width - button3.width) / 2
				button3.x = button2.x + button2.width + 5;
			}
			
			bottomContainer.y = settings.height - bottomContainer.height - 36;
			bottomContainer.x = 0;
		}
		
		public function buttonAction1(e:MouseEvent):void {
			close();
			new PurchaseWindow( {
					width:550,
					itemsOnPage:3,
					//content:PurchaseWindow.createContent("Firework"),
					content:PurchaseWindow.createContent("Firework", {backview:['dinamite_1']}),
					title:App.data.storage[645].title,
					popup:true,
					description:Locale.__e("flash:1382952379757"),
					closeAfterBuy:false,
					autoClose:false
				}).show();
		}
		public var targets:Array = [];
		public function buttonAction2(e:MouseEvent):void{
			close();
			var sID:int = 0;
			for (var t:* in settings.neededItems){
				sID = t; // получили айдишник того, чего не хватает для добычи ресурса
			}
			ShopWindow.findMaterialSource(sID);
			
		}
		
		//private function glowing():void {
			//customGlowing(background, glowing);
			//customGlowing(placeBttn, null, 0xff9900);	
		//}
		//
		//private function customGlowing(target:*, callback:Function = null,colorGlow:uint = 0xFFFF00):void {
			//TweenMax.to(target, 1, { glowFilter: { color:colorGlow, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				//TweenMax.to(target, 0.8, { glowFilter: { color:colorGlow, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					//if (callback != null) {
						//callback();
					//}
				//}});	
			//}});
		//}
		
		public function buttonAction3(event:MouseEvent):void {
			var niID:int;
			var niView:String;
			for (var t:* in settings.neededItems){
				niID = t; // получили айдишник того, чего не хватает для добычи ресурса
			}
			
			for each (var niResource:* in App.data.storage) 
			{
				if (niResource.type == 'Energy') {
					if (niResource.out == niID) {
						niView = niResource.view;
					}
				} 
			}
			
			close();
			var itemsOnPage: int;
			if(niView == "Feed"){
				itemsOnPage = 2;
			}else{
				itemsOnPage = 3;
			}
			new PurchaseWindow( {
					width:(niView == "Feed") ? 420 : 600,
					itemsOnPage:itemsOnPage,
					content:PurchaseWindow.createContent("Energy", {view:niView}),
					title:App.data.storage[niID].title,
					popup:true,
					description:Locale.__e("flash:1382952379757"),
					closeAfterBuy:false,
					autoClose:false
				}).show();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}

}