package wins.elements 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class DialogElement extends Sprite
	{
		public static var MODE_LEFT:int = 1;
		public static var MODE_RIGHT:int = 2;
		
		
		public var settings:Object = { };
		
		public var mode:int;
		public var pers:int;
		public function DialogElement(mode:int, settings:Object = null, callBack:Function = null, light:Boolean = false,pers:int=1) 
		{
			this.pers = pers;
			this.mode = mode;
			
			this.settings['light'] = light;
			
			this.settings['title'] = settings.title;
			this.settings['desc'] = settings.desc;
			
			//this.settings['paddingY'] = settings.paddingY || 0;
			
			this.settings['titleSize'] = settings.titleSize || 28;
			this.settings['descSize'] = settings.descSize || 26;
			this.settings['textWidth'] = settings.textWidth || 360;
			
			this.settings['isBttn'] = settings.isBttn || false;
			this.settings['bttnWidth'] = settings.bttnWidth || 170;
			this.settings['bttnHeight'] = settings.bttnHeight || 46;
			this.settings['fontSizeBttn'] = settings.fontSizeBttn || 30;
			
			this.settings['scale'] = settings.scale || 1;
			
			this.settings['callBack'] = callBack;
			
			if (this.settings.isBttn == true) this.settings['paddingY'] = 20;
			else this.settings['paddingY'] = 0;
			
			drawBody();
			
			if (settings.isBttn ) 
				drawBttns();
		
		}
		
		public function settArrowPos(_x:int =0):void 
		{
			
			arrow.x += _x;
			//arrow.x = 0;
		}
		
		public var confirmBttn:Button;
		private function drawBttns():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1394546313785"),
				fontSize:settings.fontSizeBttn,
				width:settings.bttnWidth,
				height:settings.bttnHeight,
				hasDotes:false,
				light:this.settings.light,
				callBack:this.settings.callBack
			};
			
			
			confirmBttn = new Button(bttnSettings);
			/*confirmBttn.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1382952380242")
				};
			};*/
		
			confirmBttn.x = bgX * settings.scale + (bgWidth * settings.scale - confirmBttn.width)/2;
			confirmBttn.y = curHeight * settings.scale - confirmBttn.height - 20;
			if (!this.settings.light) 
			{
			addChild(confirmBttn);
			
			confirmBttn.addEventListener(MouseEvent.CLICK, onClick);
			}
		}
		
		public function onClick(e:MouseEvent=null):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			e.currentTarget.arrowVisible = false;
			e.currentTarget.hidePointing();	
			
			e.currentTarget.state = Button.DISABLED;
			
			if (settings.callBack){
				settings.callBack();
				confirmBttn.removeEventListener(MouseEvent.CLICK, onClick);
				confirmBttn.dispose();
				confirmBttn = null;
			}
		}
		
		private var curHeight:int;
		private var bgWidth:int;
		private var bgX:int;
		private var arrow:Bitmap;
		private function drawBody():void 
		{	
			var yPadding:int = 20;
			var xPadding:int = 50;
			
			var txtCont:Sprite = new Sprite();
			var bColor:uint = 0x40231b;
			var cColor:uint = 0xffffff;
			cColor
			if(settings.title){
				var title:TextField = Window.drawText(settings.title, {
					color:0x533E24,
					borderColor:0xf7f2de,
					borderSize:4,
					fontSize:settings.titleSize,
					multiline:true,
					textAlign:"center"
				});
				title.wordWrap = true;
				title.width = 320;
				title.height = title.textHeight + 10;
				
				curHeight += title.textHeight;
				
				txtCont.addChild(title);
			}
			var textSettings:Object;
			if (!this.settings.light) 
			{
				textSettings = {
				color:0x392C1A, 
				border:false,
				fontSize:settings.descSize,
				multiline:true,
				textAlign:"center"
			}
			}else 
			{
				switch (pers) 
				{
					case 3:
					cColor = 0xffffff//0xffeeb1;
					break;
					case 4:
					cColor = 0xffffff//0xdceff5;
					break;
					case 1:
					cColor = 0xffffff;
					break;
				default:
					cColor = 0xffffff;
				}
				
				
				textSettings = {
				color:cColor, 
				borderColor:bColor,
				fontSize:settings.descSize,
				multiline:true,
				textAlign:"center"
			}
			}
			var desc:TextField = Window.drawText(settings.desc, textSettings);
			desc.wordWrap = true;
			desc.width = settings.textWidth;
			desc.height = desc.textHeight + 10;
			
			txtCont.addChild(desc);
			
			
			
			
			var bgCont:Sprite = new Sprite();
		if (!this.settings.light) 	
		{	
			curHeight += desc.height + yPadding * 2 + settings.paddingY + 20;
				
			if (curHeight < 140) curHeight = 140;
			
			arrow = new Bitmap(Window.textures.tutorDialogueTail);
			arrow.smoothing = true;
			
			bgWidth = desc.textWidth + xPadding/settings.scale * 2;
			
			if (mode == MODE_LEFT) {
				arrow.x = 7;
				bgX = arrow.width - 39;
			}else {
				arrow.scaleX = -1;
				arrow.x = bgWidth - 47 + arrow.width;
			}
			arrow.y = curHeight - arrow.height - 30;
			var bg:Bitmap = Window.backing(bgWidth, curHeight, 38, 'tutorDialogueBacking');
			txtCont.x = bgX * settings.scale + (bgWidth * settings.scale - txtCont.width) / 2;
			txtCont.y = (curHeight * settings.scale - txtCont.height) / 2 - settings.paddingY;
			
		}
			else 
			{
			curHeight += desc.height + 10;
				
			//if (curHeight < 140) curHeight = 140;
			arrow = new Bitmap(Window.textures.interDialogueTail);
			arrow.smoothing = true;
			
			bgWidth = (desc.textWidth + 20);
			
			if (mode == MODE_LEFT) {
				arrow.x = bgWidth/2;
				bgX = 0;//arrow.width - 39;
			}else {
				arrow.scaleX = -1;
				arrow.x = bgWidth;
			}
			arrow.y = curHeight -6;
			bg = Window.backing(bgWidth, curHeight, 20, 'interDialoguePiece');
		
			txtCont.x = bgX * settings.scale + (bgWidth * settings.scale - txtCont.width) / 2;
			txtCont.y = (curHeight * settings.scale - txtCont.height) / 2 ;
			}
			bg.x = bgX;
				
			bgCont.addChild(bg);
			bgCont.addChild(arrow);
		
			bgCont.scaleX = bgCont.scaleY = settings.scale;
			
			
			
			var cont:Sprite = new Sprite();
			cont.addChild(bgCont);
			
			var btmd:BitmapData = new BitmapData(cont.width, cont.height, true, 0xffffff);
			btmd.draw(cont);
			
			var bgImg:Bitmap = new Bitmap(btmd);
			bgImg.smoothing = true;
			
			if (!this.settings.light) {
			addChild(bgImg);
			}else 
			{
				addChild(bgImg);
				bgImg.alpha = 0.9;
			}
			
			addChild(txtCont);
		}
		
	}

}