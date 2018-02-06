package wins 
{
	import buttons.Button;
	import com.greensock.easing.Back;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	public class MessageWindow extends Window 
	{
		
		public static var side:int = 1;
		private static var prevQID:int;
		public var okBttn:Button;
		
		private var persImage:Bitmap;
		private var interCont:Sprite;
		private var cont:Sprite;
		
		public var personage:int = 0;
		
		
		public function MessageWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			settings['width'] = 900;
			settings['hasPaginator'] = false;
			settings['hasClose'] = false;
			settings['hasTitle'] = false;
			settings['escExit'] = false;
			settings['hasExit'] = false;
			settings['faderClickable'] = false;
			settings['faderAlpha'] = 0.45;
			settings['hasAnimations'] = false;
			
			settings['title'] = settings['title'] || '';
			settings['description'] = settings['description'] || '';
			//settings['backgraund'] = 'dailyBacking';
			super(settings);
			
			//if (settings.qID == prevQID)
				//trace();
			//if (settings.qID == 34)
				//trace();
			prevQID = settings.qID;
			side = (side + 1) % 2;
		}
		
		override public function drawBackground():void { }
		private var prevStWidth:int = 0;
		private var prevStHeight:int = 0;
		override protected function onRefreshPosition(e:Event = null):void 
		{
			super.onRefreshPosition(e);
			cont.x += (App.self.stage.stageWidth - prevStWidth) / 2;
			cont.y += (App.self.stage.stageHeight - prevStHeight) / 2;
			prevStWidth = App.self.stage.stageWidth;
			prevStHeight = App.self.stage.stageHeight;
		}
		override public function drawBody():void {
			cont = new Sprite();
			persImage = new Bitmap();
			addChild(cont);
			cont.addChild(persImage);
			
			prevStWidth = App.self.stage.stageWidth;
			prevStHeight = App.self.stage.stageHeight;
			
			interCont = new Sprite();
			cont.addChild(interCont);
			
			var fontSize:int = 25;
			if (App.lang == 'jp') fontSize = 45;
			var textLabel:TextField = drawText(settings.description, {
				width:			440,
				autoSize:		'center',
				textAlign:		'center',
				fontSize:		fontSize,
				color:			0x532c0b,
				borderColor:	0xfae8d2,
				multiline:		true,
				wrap:			true
			});
			textLabel.wordWrap = true;
			textLabel.multiline = true;
			
			textLabel.x = (side) ? 100 : 390;
			textLabel.y = 50;
			
			var back:Bitmap = backing(textLabel.width + 80, textLabel.height + 100, 50, 'dailyBacking');
			back.x = textLabel.x - 40;
			back.y = textLabel.y - 50;
			
			var decor1:Bitmap = new Bitmap(Window.texture('dialogueBackingDec'));
			decor1.x = back.x - 14;
			decor1.y = back.y;
			
			var decor2:Bitmap = new Bitmap(Window.texture('dialogueBackingDec'));
			decor2.scaleX = decor2.scaleY = -1;
			decor2.x = back.x + back.width + 14;
			decor2.y = back.y + back.height;
			
			var upLine:Bitmap = new Bitmap(Window.textures.dividerLine);
			upLine.width = textLabel.width;
			upLine.scaleY = -1;
			upLine.alpha = 0.4;
			upLine.x = textLabel.x;
			upLine.y = textLabel.y - 25;
			
			var downLine:Bitmap = new Bitmap(Window.textures.dividerLine);
			downLine.width = textLabel.width;
			downLine.alpha = 0.4;
			downLine.x = textLabel.x;
			downLine.y = textLabel.y + textLabel.height + 28;
			
			var titleLabel:TextField = drawText(settings.title, {
				autoSize:		'center',
				fontSize:		48,
				color:			0xfefcff,
				borderColor:	0xb48849,
				shadowSize:		4,
				shadowColor:	0x513a32
			});
			titleLabel.x = textLabel.x + (textLabel.width - titleLabel.width) / 2;
			titleLabel.y = textLabel.y - 75;
			
			okBttn = new Button( {
				width:		160,
				height:		46,
				caption:	Locale.__e('flash:1382952380242')
			});
			okBttn.name = 'tmw_okBttn';
			okBttn.x = textLabel.x + (textLabel.width - okBttn.width) / 2;
			okBttn.y = textLabel.y + textLabel.height + okBttn.height - 32;
			okBttn.addEventListener(MouseEvent.CLICK, onClick);
			
			
			interCont.addChild(back);
			//interCont.addChild(decor1);
			//interCont.addChild(decor2);
			interCont.addChild(textLabel);
			interCont.addChild(upLine);
			interCont.addChild(downLine);
			drawMirrowObjs('titleDecRose', titleLabel.x - 70, titleLabel.x + titleLabel.width + 70, titleLabel.y + 10, false, false, false, 1, 1, interCont);
			interCont.addChild(titleLabel);
			interCont.addChild(okBttn);
			
			interCont.x = (App.self.stage.stageWidth - settings.width) / 2;
			interCont.y = App.self.stage.stageHeight;
			
			setTimeout(function():void {
				TweenLite.to(interCont, 0.5, { 
					y:		App.self.stage.stageHeight - interCont.height,
					ease:	Back.easeOut
				} );
			}, 300);
			
			Load.loading(Config.getImageIcon('quests/preview', settings.personage), function(data:Bitmap):void {
				persImage.bitmapData = data.bitmapData;
				persImage.scaleX = (side) ? -1 : 1;
				var rect:Rectangle = persImage.bitmapData.getColorBoundsRect(0xff000000, 0x00000000,false);
				persImage.x = (side) ? (interCont.x + interCont.width + 10 + rect.x + rect.width) : (interCont.x + 390 - rect.x - rect.width - 10);
				persImage.y = App.self.stage.stageHeight;// interCont.y - 115;
				
				TweenLite.to(persImage, 0.5, { 
					y:		(interCont.height + 130 > rect.height + rect.y) ? 
							(App.self.stage.stageHeight - interCont.height / 2 - rect.height / 2 - rect.y - 15) : (App.self.stage.stageHeight - rect.height / 2 - rect.y - 170),
					ease:	Back.easeOut
				} );
			} );
		}
		
		private function onClick(e:MouseEvent):void {
			if (settings.callback && (settings.callback is Function)) {
				settings.callback();
			}
			
			close();
		}
		
		override public function dispose():void {
			if (okBttn) okBttn.removeEventListener(MouseEvent.CLICK, onClick);
			
			super.dispose();
		}
	}

}