package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author ...
	 */
	public class UI 
	{
		
		public function UI() 
		{
			
		}
		
		public static function backing(width:int, height:int, padding:int = 50, texture:String = "windowBacking"):Bitmap {
				var sprite:Sprite = new Sprite();
				
				var topLeft:Bitmap = new Bitmap(Textures.textures[texture], "auto", true);
				
				var topRight:Bitmap = new Bitmap(Textures.textures[texture], "auto", true);
				topRight.scaleX = -1;
				
				var bottomLeft:Bitmap = new Bitmap(Textures.textures[texture], "auto", true);
				bottomLeft.scaleY = -1;
				
				var bottomRight:Bitmap = new Bitmap(Textures.textures[texture], "auto", true);
				bottomRight.scaleX = bottomRight.scaleY = -1;
				
				var horizontal:BitmapData = new BitmapData(1, topLeft.height, true, 0);
				horizontal.copyPixels(topLeft.bitmapData,new Rectangle(topLeft.width-1, 0, topLeft.width, topLeft.height), new Point());
				
				var vertical:BitmapData = new BitmapData(topLeft.width, 1, true, 0);
				vertical.copyPixels(topLeft.bitmapData,new Rectangle(0, topLeft.height-1, topLeft.width, topLeft.height), new Point());
				
				var center:BitmapData = new BitmapData(1, 1, true, 0);
				center.copyPixels(topLeft.bitmapData,new Rectangle(topLeft.width - 1, topLeft.height-1, 1, 1), new Point());
				
				topRight.x = width;
				topRight.y = 0;
				
				bottomLeft.x = 0;
				bottomLeft.y = height;
				
				bottomRight.y = height;
				bottomRight.x = width;
				
				var shp:Shape;
				shp = new Shape();
				shp.graphics.beginBitmapFill(horizontal);
				shp.graphics.drawRect(0, 0, width - topLeft.width * 2, topLeft.height);
				shp.graphics.endFill();
				
				var hBmd:BitmapData = new BitmapData(width - topLeft.width * 2, topLeft.height, true, 0);
				hBmd.draw(shp);
				
				var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
				var hBottomBmp:Bitmap = new Bitmap(hBmd, "auto", true);
				hBottomBmp.scaleY = -1;
				
				hTopBmp.x = topLeft.width;
				hTopBmp.y = 0;
				hBottomBmp.x = topLeft.width;
				hBottomBmp.y = height;
				
				shp = new Shape();
				shp.graphics.beginBitmapFill(vertical);
				shp.graphics.drawRect(0, 0, topLeft.width, height - topLeft.height * 2);
				shp.graphics.endFill();

				var vBmd:BitmapData = new BitmapData(topLeft.width, height - topLeft.height * 2, true, 0);
				vBmd.draw(shp);
				
				var vLeftBmp:Bitmap = new Bitmap(vBmd, "auto", true);
				var vRightBmp:Bitmap = new Bitmap(vBmd, "auto", true);
				vRightBmp.scaleX = -1;
				
				vLeftBmp.x = 0;
				vLeftBmp.y = topLeft.height;
				
				vRightBmp.x = width;
				vRightBmp.y = topLeft.height;
				
				var solid:Sprite = new Sprite();
				solid.graphics.beginBitmapFill(center);//beginFill(fillColor);
				solid.graphics.drawRect(padding, padding, width-padding*2, height-padding*2);
				solid.graphics.endFill();
				
				sprite.addChildAt(solid,0);
				
				sprite.addChild(topLeft);
				sprite.addChild(topRight);
				sprite.addChild(bottomLeft);
				sprite.addChild(bottomRight);
				sprite.addChild(hTopBmp);
				sprite.addChild(hBottomBmp);
				sprite.addChild(vLeftBmp);
				sprite.addChild(vRightBmp);
				
				solid = null;
				
				var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
				bg.draw(sprite);
							
				for (var i:int = 0; i < sprite.numChildren; i++) {
					sprite.removeChildAt(i);
				}
				sprite = null;
				
				return new Bitmap(bg, "auto", true);
			}
			
			//public static function drawBackWith(bitmapData1:BitmapData,bitmapData2:BitmapData, bitmapData3:BitmapData,dx2:int):Sprite
			//{
				//var dailyBack:Bitmap = new Bitmap(bitmapData1);
				//
				//var cont:Sprite = new Sprite();
				//dailyBack.x += 60;
				//cont.addChild(dailyBack);
				//
				//var dailyBack2:Bitmap = new Bitmap(bitmapData2);
				//dailyBack2.x = dx2;
				//cont.addChild(dailyBack2);
				//
				//var dailyBack3:Bitmap = new Bitmap(bitmapData3);
				//dailyBack3.x  =  dailyBack2.x + dailyBack2.width;
				//dailyBack3.width = dailyBack.x - dailyBack2.x - dailyBack2.width;
				//cont.addChild(dailyBack3);
				//
				//var dailyPoint1:Bitmap = new Bitmap(Textures.dailyPoint);
				//dailyPoint1.x = 60;
				//dailyPoint1.y -= 2;
				//
				//cont.addChild(dailyPoint1);
				//
				//var dailyPoint2:Bitmap = new Bitmap(Textures.dailyPoint);
				//dailyPoint2.x = 60;
				//dailyPoint2.y = dailyBack.y + dailyBack.height - 6;
				//cont.addChild(dailyPoint2);
				//
				//return cont;
			//}
			
			public static function drawText(text:String, settings:Object = null):TextField {
				
				var defaults:Object = {
					color				: 0xdfdbcf,
					multiline			: false,				//Многострочный текст
					fontSize			: 19,					//Размер шрифта
					textLeading	 		: -2,					//Вертикальное расстояние между словами	
					borderColor 		: 0x000000,//0x5d5d5d,				//Цвет обводки шрифта	
					borderSize 			: 4,					//Размер обводки шрифта
					fontBorderGlow 		: 2,					//Размер размытия шрифта
					fontFamily			: 'BrusrhType-SemiBold',		//Шрифт					
					//fontFamily			: App.TIMES_REG,		//Шрифт					
					autoSize			: 'none',
					textAlign			: 'left',
					filters				: [],
					sharpness 			: 100,
					thickness			: 50,
					border				: true,
					letterSpacing		: 0,
					input				: false,
					width				: 0,
					wrap				: false,
					angleShadow			:	90,
					strenghtFilter		:	2,
					strenghtShadow		:	8,
					distShadow			:	1,
					shadowAlpha			:	1
				}
					
				if (settings == null) {
					settings = defaults;
				}else {
					for (var property:* in settings) {
						defaults[property] = settings[property];
					}
					settings = defaults;
				}
				
				var textLabel:TextField = new TextField();
				
				if(settings.input){
					textLabel.type = TextFieldType.INPUT;
					//textLabel.selectable = false;
					//textLabel.tabEnabled = true;
				}else{
					textLabel.mouseEnabled = false;
					textLabel.mouseWheelEnabled = false;
				}
				textLabel.antiAliasType = AntiAliasType.ADVANCED;
				textLabel.multiline = settings.multiline;
				
				switch(settings.autoSize){
					case "left": textLabel.autoSize = TextFieldAutoSize.LEFT; break;
					case "center": textLabel.autoSize = TextFieldAutoSize.CENTER; break;
					case "right": textLabel.autoSize = TextFieldAutoSize.RIGHT; break;
				}
				
				//textLabel.embedFonts = true;
				textLabel.sharpness = settings.sharpness;
				textLabel.thickness = settings.thickness;
				//textLabel.border = true;
				
				var style:TextFormat = new TextFormat(); 
				style.color = settings.color; 
				style.letterSpacing = settings.letterSpacing;
				if(settings.multiline){
					style.leading = settings.textLeading; 
				}
				
				style.size = settings.fontSize;
				style.font = settings.fontFamily;
				style.bold = settings.bold || false;
				switch(settings.textAlign) {
					case 'left': style.align = TextFormatAlign.LEFT; break;
					case 'center': style.align = TextFormatAlign.CENTER; break;
					case 'right': style.align = TextFormatAlign.RIGHT; break;
				}
				
				textLabel.defaultTextFormat = style;
				if (text == null) text = "";
				textLabel.text = text;
				
				textLabel.wordWrap = settings.wrap;
				
				var metrics:*;
				if (settings.width > 0) { 
					textLabel.width = settings.width;
					metrics = textLabel.getLineMetrics(0);
					if(text.length > 3 && textLabel.textWidth+metrics.descent > settings.width) {
						while (textLabel.textWidth + metrics.descent > settings.width) {
							settings.fontSize -= 1;
							style.size = settings.fontSize;
							textLabel.setTextFormat(style);
							metrics = textLabel.getLineMetrics(0);
							//textLabel.defaultTextFormat = style;
						}
					}
				}
				textLabel.defaultTextFormat = style;
				
				var filter:GlowFilter;
				var shadowFilter:DropShadowFilter
				if(settings.borderSize>0 && settings.border){
					filter = new GlowFilter(settings.borderColor, 1, settings.borderSize, settings.borderSize, settings.strenghtFilter, 1); //(settings.borderColor, 1, settings.borderSize, settings.borderSize, 6, 1);
					shadowFilter = new DropShadowFilter(settings.distShadow, settings.angleShadow, settings.borderColor, settings.shadowAlpha, 1, 1, settings.strenghtShadow, 1);  //(1,90,settings.borderColor,0.9,2,2,2,1);
					textLabel.filters = [filter, shadowFilter];
				}			
				
				textLabel.cacheAsBitmap = true;
				
				
				if (settings.autoSize == 'none') {
					metrics = textLabel.getLineMetrics(0);
					textLabel.height = (textLabel.textHeight || metrics.height) + metrics.descent;
				}
				textLabel.width = textLabel.textWidth + 5;
				
				if (settings.dropShadow)
					textLabel.filters = [new DropShadowFilter(2, 90, 0, 0.8, 2, 2, 2)];
				
				return textLabel;
			}
			
			//public static function drawFader(array:Array, color:* = 0x3a5f2a):Sprite
			//{
				//var p0:Object = array[0];
				//var point0:Object = IsoConvert.isoToScreen(p0.x, p0.z, true);
					//
				//var p:Object;
				//var point:Object;
				//
				//var fader:Sprite = new Sprite();
				//fader.graphics.beginFill(color, 1);
				//fader.graphics.moveTo(point0.x, point0.y);
				//
				//var L:uint = array.length;
				//for (var i:int = 1; i < L; i++)
				//{
					//p = array[i];
					//point = IsoConvert.isoToScreen(p.x, p.z, true);
					//fader.graphics.lineTo(point.x, point.y);
				//}
				//
				//fader.graphics.lineTo(point0.x, point0.y);
				//fader.graphics.endFill();
				//
				//fader.filters = [ new BlurFilter(10, 10, 1) ];
				//
				//return fader;
			//}
		
		//public static function snapClip(clip:*, delta:int = 100):BitmapData
		//{
			//var bounds:Rectangle = clip.getBounds (clip);
			//var bmd:BitmapData = new BitmapData (int (bounds.width+delta), int (bounds.height + delta), true, 0);
			//bmd.draw (clip, new Matrix (1, 0, 0, 1, -bounds.x + delta/2, -bounds.y + delta/2));
			//return bmd;
		//}
		
		// window
		
		//public static function backingShort(width:int, _texture:String = "windowBacking", mirrow:Boolean = true):Bitmap {
			//var sprite:Sprite = new Sprite();
			//
				//var left:Bitmap;
				//var right:Bitmap;
			//if (Textures.textures.hasOwnProperty(_texture)) {
				//left = new Bitmap(Window.textures[_texture]);
				//right =  new Bitmap(Window.textures[_texture]);
			//}else if(UserInterface.textures.hasOwnProperty(_texture)) {
				//left =  new Bitmap(UserInterface.textures[_texture]);
				//right =  new Bitmap(UserInterface.textures[_texture]);
			//}else {
				//left =  new Bitmap(Window.textures['diamondsTop']);
				//right =  new Bitmap(Window.textures['diamondsTop']);
			//}
			//
				//right.scaleX = -1;
			//
			//var horizontal:BitmapData = new BitmapData(1, left.height, true, 0);
			//horizontal.copyPixels(left.bitmapData,new Rectangle(left.width-1, 0, left.width, left.height), new Point());
			//
			//var fillColor:uint = left.bitmapData.getPixel(left.width - 1, left.height - 1);
			//
			//right.x = width;
			//right.y = 0;
			//
			//var shp:Shape;
			//shp = new Shape();
			//shp.graphics.beginBitmapFill(horizontal);
			//shp.graphics.drawRect(0, 0, width - left.width * 2, left.height);
			//shp.graphics.endFill();
			//
			//if (width > 0) {
				//var hBmd:BitmapData = new BitmapData(Math.abs(width - left.width * 2), left.height, true, 0);
				//hBmd.draw(shp);
				//var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
				//hTopBmp.x = left.width;
				//hTopBmp.y = 0;
				//sprite.addChild(hTopBmp);
			//}else {
				//right.x = left.width*2;
			//}
				//
			//
			//
			//sprite.addChild(left);
			//if (mirrow)sprite.addChild(right);
			//
			//
			//var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
			//bg.draw(sprite);
						//
			//for (var i:int = 0; i < sprite.numChildren; i++) {
				//sprite.removeChildAt(i);
			//}
			//sprite = null;
			//
			//return new Bitmap(bg, "auto", true);
		//}
		public static function backing2(width:int, height:int, padding:int = 50, texture:String = "windowBacking", texture2:String = "windowBacking", koefBetweenTextures:int = 0):Bitmap {
				var sprite:Sprite = new Sprite();
				
				var isHeightSmoller:Boolean = false;
				
				var topLeft:Bitmap = new Bitmap(Textures.textures[texture], "auto", true);
				var topRight:Bitmap = new Bitmap(Textures.textures[texture], "auto", true);
				var bottomLeft:Bitmap = new Bitmap(Textures.textures[texture2], "auto", true);
				var bottomRight:Bitmap = new Bitmap(Textures.textures[texture2], "auto", true);
				
				var sameHeigth:Boolean = false;
				var sameWidth:Boolean = false;
				
				if (height <= topLeft.height + bottomLeft.height) {
					sameHeigth = true;
				}
				else if (width <= topLeft.width + bottomLeft.width) {
					sameWidth = true;
				}
				
				if(!sameWidth){
					var horizontal:BitmapData = new BitmapData(1, bottomLeft.height, true, 0);
					horizontal.copyPixels(topLeft.bitmapData, new Rectangle(topLeft.width - 1, 0, topLeft.width, topLeft.height), new Point());
					
					var horizontal2:BitmapData = new BitmapData(1, bottomLeft.height, true, 0);
					horizontal2.copyPixels(bottomLeft.bitmapData,new Rectangle(bottomLeft.width-1, 0, bottomLeft.width, bottomLeft.height), new Point());
				
					var shp:Shape;
					shp = new Shape();
					shp.graphics.beginBitmapFill(horizontal);
					shp.graphics.drawRect(0, 0, width - topLeft.width * 2, topLeft.height);
					shp.graphics.endFill();
					
					var shp2:Shape;
					shp2 = new Shape();
					shp2.graphics.beginBitmapFill(horizontal2);
					shp2.graphics.drawRect(0, 0, width - bottomLeft.width * 2 + koefBetweenTextures*4, bottomLeft.height);
					shp2.graphics.endFill();
					
					if (width - topLeft.width * 2 <= 0)
						width = topLeft.width * 2 + 1;
							
					var hBmd:BitmapData = new BitmapData(width - topLeft.width * 2, topLeft.height, true, 0);
					hBmd.draw(shp);
					
					if (width - bottomLeft.width * 2 <= 0)
						width = bottomLeft.width * 2 + 1;
					
					var hBmd2:BitmapData = new BitmapData(width - bottomLeft.width * 2  + koefBetweenTextures*4, bottomLeft.height, true, 0);
					hBmd2.draw(shp2);
					
					var hTopBmp:Bitmap = new Bitmap(hBmd, "auto", true);
					var hBottomBmp:Bitmap = new Bitmap(hBmd2, "auto", true);
				}
					
				if (height < topLeft.height + bottomLeft.height) {
					isHeightSmoller = true;
					var heightDiff:Number = (topLeft.height + bottomLeft.height) - height + 6;
					
					topLeft.height = topLeft.height - heightDiff / 2;
					topRight.height = topRight.height - heightDiff / 2;
					bottomLeft.height = bottomLeft.height - heightDiff / 2;
					bottomRight.height = bottomRight.height - heightDiff / 2;
					
					hTopBmp.height = hTopBmp.height - heightDiff / 2;
					hBottomBmp.height = hBottomBmp.height - heightDiff / 2;
				}
				
				if(!sameWidth){
					hTopBmp.x = topLeft.width;
					hTopBmp.y = 0;
					hBottomBmp.x = bottomLeft.width - koefBetweenTextures*2;
					hBottomBmp.y = height - hBottomBmp.height;
				}
				
				topRight.scaleX = -1;
				bottomRight.scaleX = -1;
				
				if(!sameHeigth){
					var vertical:BitmapData = new BitmapData(topLeft.width, 1, true, 0);
					vertical.copyPixels(topLeft.bitmapData,new Rectangle(0, topLeft.height-1, topLeft.width, topLeft.height), new Point());
				
					var fillColor:uint = topLeft.bitmapData.getPixel(topLeft.width - 1, topLeft.height - 1);
				}
				
				topLeft.x = 0;
				topLeft.y = 0;
				
				topRight.x = width;
				topRight.y = 0;
				
				bottomLeft.x = - koefBetweenTextures;
				if (isHeightSmoller) {
					bottomLeft.y = topLeft.height;
					if(!sameWidth)hBottomBmp.y = bottomLeft.y + bottomLeft.height - hBottomBmp.height;
				}else {bottomLeft.y = height - bottomLeft.height;}
				
				if (isHeightSmoller) 
					bottomRight.y = topRight.height;
				else 
					bottomRight.y = height - bottomRight.height;
				
				bottomRight.x = width + koefBetweenTextures;
				
				if(!sameHeigth){
					shp = new Shape();
					shp.graphics.beginBitmapFill(vertical);
					shp.graphics.drawRect(0, 0, topLeft.width, height - topLeft.height * 2);
					shp.graphics.endFill();

					var vBmd:BitmapData = new BitmapData(topLeft.width, height - topLeft.height * 2, true, 0);
					vBmd.draw(shp);
					
					var vLeftBmp:Bitmap = new Bitmap(vBmd, "auto", true);
					var vRightBmp:Bitmap = new Bitmap(vBmd, "auto", true);
					vRightBmp.scaleX = -1;
					
					vLeftBmp.x = 0;
					vLeftBmp.y = topLeft.height;
					
					vRightBmp.x = width;
					vRightBmp.y = topLeft.height;
				}
				
				if(!sameHeigth && !sameWidth){
					var solid:Sprite = new Sprite();
					solid.graphics.beginFill(fillColor);
					solid.graphics.drawRect(padding, padding, width-padding*2, height-padding*2);
					solid.graphics.endFill();
				}
				
				sprite.addChild(topLeft);
				sprite.addChild(topRight);
				sprite.addChild(bottomLeft);
				sprite.addChild(bottomRight);
				
				if (!sameHeigth && !sameWidth) sprite.addChildAt(solid, 0);
				if(!sameWidth){
					sprite.addChild(hTopBmp);
					sprite.addChild(hBottomBmp);
				}
				if(!sameHeigth){
					sprite.addChild(vLeftBmp);
					sprite.addChild(vRightBmp);
				}
				
				solid = null;
				
				var bg:BitmapData = new BitmapData(sprite.width, sprite.height,true,0x00000000);
				bg.draw(sprite);
							
				for (var i:int = 0; i < sprite.numChildren; i++) {
					sprite.removeChildAt(i);
				}
				sprite = null;
				
				return new Bitmap(bg, "auto", true);
			}
			
			import silin.filters.ColorAdjust;	
		
			public static function effect(target:*, brightness:Number = 1, saturation:Number = 1):void {
				var mtrx:ColorAdjust;
				mtrx = new ColorAdjust();
				mtrx.saturation(saturation);
				mtrx.brightness(brightness);
				target.filters = [mtrx.filter];
			}
			
			public static function colorize(target:*, rgb:*, amount:*):void {
				var mtrx:ColorAdjust;
				mtrx = new ColorAdjust();
				mtrx.colorize(rgb, amount);
				target.filters = [mtrx.filter];
			}
			
			public static function size(target:*, width:Number, height:Number, widthFirst:Boolean = true):void 
			{
				if (!target) return;
				
				if (widthFirst) {
					toWidth();
					toHeight();
				}else {
					toHeight();
					toWidth();
				}
				
				function toWidth():void {
					if (target.width > width) 
					{
						target.width = width;
						target.scaleY = target.scaleX;
					}
				}
				function toHeight():void {
					if (target.height > height) 
					{
						target.height = height;
						target.scaleX = target.scaleY;
					}
				}
			}
	}

}