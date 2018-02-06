package ui
{
	
	import com.greensock.TweenLite;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import units.Unit;
	import wins.Window;
	
	public class Tips extends Sprite
	{
		private static const sizes:Object = {"90":1,'180':3,'240':5,'320':6};
		
		private static const fontSize:uint = 17;
		
		private static const padding:uint = 15;
		private static const color:uint = 0x000000;
		private var fonttColor:uint;
		private var bordertColor:uint;
		
		private static var textLabel:TextField;
		private static var givesLabel:TextField;
		private static var titleLabel:TextField;
		private static var descLabel:TextField;
		private static var timerLabel:TextField;
		private static var timerLabel2:TextField;
		private static var countLabel:TextField;
		private static var countLabel2:TextField;
		private static var additionalDesc:TextField;
		//private static var orDesc:TextField;
		
		private static var icon:Bitmap;
		private static var icon2:Bitmap;
		
		private static var itemList:Array = [];
		
		private var target:DisplayObject;
		
		private var timer:Timer = new Timer(400,1);
		private var tween:TweenLite;
		private var iconW:Number = 40;
		private var iconH:Number = 40;
		private var iconW2:int = 0;
		
		public static var self:Tips;
		
		
		public function Tips() 
		{			
			/*textLabel = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize,
				textLeading:-5
			});
			
			textLabel.wordWrap = true;
			
			titleLabel = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize+6
			}); 
			
			descLabel = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize+2
			}); 
			
			additionalDesc = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize,
				textLeading:-5
			});
			
			orDesc = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize,
				textLeading:-5
			});
			
			countLabel = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize+3
			}); */
		}
		
		/*public function init():void {
			
			textLabel = Window.drawText("", {
				color:0xffffff,
				borderColor:0x0a4069,
				multiline:true,
				border:false,
				fontSize:fontSize,
				textLeading:-5
			});
			
			textLabel.wordWrap = true;
			
			titleLabel = Window.drawText("", {
				color:0xffffff,
				borderColor:0x0a4069,
				multiline:true,
				border:false,
				fontSize:fontSize+2
			}); 
		}*/
		
		private function dispose():void {
			timer.stop();
			if(tween){
				tween.complete(true);
				tween.kill();
				tween = null;
			}
			if(App.self.tipsContainer && App.self.tipsContainer.contains(this)){
				App.self.tipsContainer.removeChild(this);
			}
			while (numChildren > 0) {
				removeChildAt(0);
			}
			target = null;
			App.self.setOffTimer(rewrite);
		}
		
		public function hide():void {
			dispose();
		}
		
		//	Отрисовка подсказки
		public function show(object:DisplayObject):void {
			
			if (!object.hasOwnProperty('tip') || object['tip'] == null ) {
				dispose();
				return;
			}
			
			if (object is Bitmap && Bitmap(object).bitmapData.getPixel(object.mouseX, object.mouseY) == 0) {
				dispose();
				return;
			}else if (object is Unit){
				var unit:Unit = object as Unit;
				var bmp:Bitmap = unit.bmp;
				if(bmp.bitmapData && bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0) {
					dispose();
					return;			
				}
			}
			
			while (1) {
				if (object is LayerX){
					break;
				}else {
					if (object.parent == null) {
						dispose();
						return;
					}else {
						object = object.parent;
					}
				}
			}
			
			
			
			//Если мышка передвинулась, а объект не flash:1382952379993менился, то только передвигаем подсказку
			if (target && target == object) {
				relocate();
				return;
			}else {
				dispose();
			}
			
			target = object;
			
			timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
			timer.start();
		}
		
		private function onTimerEvent(e:TimerEvent):void {
			draw();
			alpha = 0;
			tween = TweenLite.to(this, 0.2, { alpha:1} );
		}
		
		private function setFontSettings():void{
			if(Window.isOpen){
				fonttColor = 0x55270f;
				bordertColor = 0xffffff;
			}else{
				fonttColor = 0xffffff;
				bordertColor = 0x0a4069;
			}
			
			textLabel = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize,
				textLeading:-5
			});
			
			textLabel.wordWrap = true;
			
			givesLabel = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize,
				textLeading:-5
			});
			
			givesLabel.wordWrap = true;
			
			titleLabel = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize+6
			}); 
			
			descLabel = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize+2
			}); 
			
			timerLabel = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize+4
			}); 
			
			timerLabel2 = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize+4
			}); 
			
			additionalDesc = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize,
				textLeading:-5
			});
			
			/*orDesc = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize,
				textLeading:-5
			});*/
			
			countLabel = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize+3
			}); 
			
			countLabel2 = Window.drawText("", {
				color:fonttColor,
				borderColor:bordertColor,
				multiline:true,
				fontSize:fontSize+3
			}); 
		}
		
		private var shape:Shape = new Shape();
		private var matrix:Matrix = new Matrix();
		private var bgimg:Bitmap = new Bitmap();
		private var blick1:Bitmap = new Bitmap();
		private var blick2:Bitmap = new Bitmap();
		private var blick3:Bitmap = new Bitmap();
		private var maxHeight:int = 0;
		private var maxWidth:int = 0;
		private var iconScale:Number = 1;
		private var iconScale2:Number = 1;
		private var titleOnly:Boolean = false;
		private	var gives:Array= [];
		private function draw():void {
			setFontSettings();
			var title:String = '';
			var text:String = '';
			var desc:String = '';
			var timerText:String = '';
			var timerText2:String = '';
			//var ordesc:String = '';
			var count1:String = '';
			var count2:String = '';
			var addDesc:String = '';
			//var itemList:Array = [];
			if (target['tip'] is Function) {
				var tip:Object = target['tip']();
				title =  tip.title || "";			//	Верхняя надпись
				text = tip.text || "";				//	Средняя надпись	
				desc = tip.desc || "";				//	Нижняя надпись
				timerText = tip.timerText || "";
				timerText2 = tip.timerText2 || "";
				//ordesc = tip.ordesc || "";
				count1 = tip.count1 || "";
				count2 = tip.count2 || "";
				icon = tip.icon || null;
				icon2 = tip.icon2 || null;
				itemList = tip.itemList || [];
				iconScale =  tip.iconScale || .37;
				iconScale2 =  tip.iconScale2 || .37;
				addDesc =  tip.addDesc || "";
				gives =  tip.gives || [];
				if (tip.timer) {
					App.self.setOnTimer(rewrite);
				}
				
				
			}else {
				text = target['tip'] as String;
			}
			
			for (var w:String in sizes) {
				var textWidth:int = int(w);
				var lineCount:int = Math.round((text.length * fontSize) / textWidth);
				//if (lineCount < sizes['width']) {
					//break;
				//}
			}
			if (title == text)
				text = '';
			
			titleLabel.text = title;
			titleLabel.autoSize = TextFieldAutoSize.LEFT;
			
			textLabel.text = text;
			textLabel.autoSize = TextFieldAutoSize.LEFT;
			textLabel.width = textWidth;
			
			givesLabel.text = givesDesc;
			//givesLabel.border = true;
			givesLabel.width = textWidth -20;
			
			givesLabel.autoSize = TextFieldAutoSize.LEFT;
			
			descLabel.text = desc;
			descLabel.autoSize = TextFieldAutoSize.LEFT;
			
			timerLabel.text = timerText;
			timerLabel.autoSize = TextFieldAutoSize.LEFT;
			
			timerLabel2.text = timerText2;
			timerLabel2.autoSize = TextFieldAutoSize.LEFT;
			
			countLabel.text = count1;
			countLabel.autoSize = TextFieldAutoSize.LEFT;
			
			countLabel2.text = count2;
			countLabel2.autoSize = TextFieldAutoSize.LEFT;
			
			additionalDesc.text = addDesc;
			additionalDesc.autoSize = TextFieldAutoSize.LEFT;
			
			if (text == '' && text == '' && desc == '' && count1 == '' && count2 == '' && addDesc == '')
			{
				titleOnly = true;
			}else
			{
				titleOnly = false;
			}
			
			//orDesc.text = ordesc;
			//orDesc.autoSize = TextFieldAutoSize.LEFT;
			blick1 = new Bitmap(Window.textures.blickUpLeft);
			blick2 = new Bitmap(Window.textures.blickUpRight);
			blick3 = new Bitmap(Window.textures.blickDownLeft);
			
			addChild(bgimg);
			if (!titleOnly)
			{
				addChild(blick1);
				addChild(blick2);
				addChild(blick3);
			}
			
			addChild(descLabel);
			
			countLabel.width = countLabel.textWidth;
			countLabel2.width = countLabel2.textWidth;
			if (titleLabel.text != "")
			{
				addChild(titleLabel);
			}else {
				textLabel.y = padding;
			}
			
			addChild(textLabel);
			//addChild(textLabel);
			//if (gives != []) {
			addChild(givesLabel);
			//}
			
			if (additionalDesc.text != "") {
				addChild(additionalDesc);
			}
			if (itemList) {
				var newHt:int = 0;
				//drawItems(itemList);
				drawItemsIntoDescription(itemList);
			}
			if (icon)
				icon.scaleX = icon.scaleY = iconScale;
			
			if (icon) 
			{
				if (icon) 
				{
					iconW = 40;//icon.width /** iconScale*/;
					iconH = 40;//icon.height;
				}
				if (icon2)
				{
					iconW2 = 40*iconScale2 + 20;//icon2.width /** iconScale*/ +20;
				}else
				{
					iconW2 = 0;
				}
			}
			redrawBackGround(1);
			titleLabel.x = (bgimg.width - titleLabel.width)/2;
			titleLabel.y = padding;
			
			textLabel.x = (bgimg.width - textLabel.width)/2;
			textLabel.y = titleLabel.y + titleLabel.height*1.2;
			
			additionalDesc.x = (bgimg.width - additionalDesc.width)/2;
			additionalDesc.y = textLabel.y + textLabel.height;
			
			givesLabel.y = textLabel.y + textLabel.textHeight + 2;
			
			descLabel.y = givesLabel.y + givesLabel.textHeight + 2;
			
			if (timerText) 
			{
				var bmap:Bitmap = new Bitmap(UserInterface.textures.tick);
				Size.size(bmap, 30, 30);
				bmap.smoothing = true;
				bmap.x = textLabel.x;
				bmap.y = textLabel.y + textLabel.height + 3;
				addChild(bmap);
				
				timerLabel.x = bmap.x + bmap.width + 2;
				timerLabel.y = bmap.y + (bmap.height - timerLabel.height) / 2;
				addChild(timerLabel);
			}
			if (icon) {
				//if (icon) {
					//iconW = 40*iconScale;//icon.width /** iconScale*/;
					//iconH = 40;//icon.height;
				//}
				//if (icon2){
					//iconW2 = 40*iconScale2 + 20;//icon2.width /** iconScale*/ +20;
				//}else{
					//iconW2 = 0;
				//}
				//if (icon && icon2) {
				descLabel.x = textLabel.x;
				givesLabel.x = textLabel.x;
				
				
				//}else{
				//descLabel.x = (bgimg.width - descLabel.width)/2 - 10;
				//}
				
				//descLabel.x -= iconW / 2;
				addChild(icon);
				icon.filters = [new GlowFilter(0xffffff, .7, 5, 5, 2)];
				descLabel.y += iconH / 2.4; 
				icon.x = descLabel.x + descLabel.textWidth + 8;
				icon.y = descLabel.y  + (descLabel.height - iconH) / 2;
				countLabel.x = icon.x + (iconW * iconScale) + 10;
				countLabel.y = icon.y + (iconH - countLabel.textHeight) / 2;
				addChild(countLabel);
				countLabel.filters = [new GlowFilter(bordertColor, 1, 5, 5, 6)];
				icon.smoothing = true;
				
				if (icon2) {
				icon2.smoothing = true;
				addChild(icon2);
				icon2.filters = [new GlowFilter(0xffffff, .7, 5, 5, 6)];
				icon2.x = icon.x + iconW/iconScale + 3;
				icon2.y = icon.y;
				countLabel2.x = icon2.x + (iconW * iconScale) + 10;
				countLabel2.y = icon.y + (iconH - countLabel2.textHeight) / 2;
				addChild(countLabel2);
				countLabel2.filters = [new GlowFilter(bordertColor, 1, 5, 5, 6)];
				}
				
			}else {
				iconW = 0;//icon.width /** iconScale*/;
				iconH = 0;//icon.height;
				//countLabel.x = padding;
				if (count1)
					addChild(countLabel);
				descLabel.x = textLabel.x;
				countLabel.x = descLabel.x + descLabel.textWidth;
				countLabel.y = descLabel.y ;
			}
			if (timerText2) 
			{
				descLabel.y = bmap.y + bmap.height + 3; 
				var bmap2:Bitmap = new Bitmap(UserInterface.textures.tick);
				Size.size(bmap2, 30, 30);
				bmap2.smoothing = true;
				bmap2.x = bmap.x;
				bmap2.y = descLabel.y + descLabel.textHeight + 3;
				addChild(bmap2);
				
				timerLabel2.x = bmap2.x + bmap2.width + 2;
				timerLabel2.y = bmap2.y + (bmap2.height - timerLabel2.height) / 2;
				addChild(timerLabel2);
			}
			
			relocate();
			redrawBackGround(1);
			App.self.tipsContainer.addChild(this);
		}
		
		//	Формирование строки Description
		private function get givesDesc():String
		{
			if (gives.length == 0)
				return "";
			
			var _sids:Array = gives;
			var _desc:String = Locale.__e('flash:1402650165308') + " ";
			//for (var _out:* in info.outs)
			//{
				//obj[_out] = App.data.storage[_out].title;
				//queue.push(_out);
			//}
			
			
			//for each(var _out2:* in App.data.treasures[info.treasure]['kick'].item)
			//{
				//if (_out2 == Stock.EXP) continue;
				//obj[_out2] = App.data.storage[_out2].title;
				//if(queue.indexOf(App.data.storage[_out2].title) == -1)
					//queue.push(App.data.storage[_out2].title);
			//}
			
			//for (var i:int = 0; i < queue.length; i++)
				//_desc += ' ' + queue[i] + ', ';
				
			for each(var _out3:* in _sids)
			{
				
				_desc += ' ' + App.data.storage[_out3].title + ', ';
			}
			
			_desc = _desc.substring(0, _desc.length - 2);
			
			return _desc;
		}
		
		private function redrawBackGround(desc:int = 0):void {
			bgimg.bitmapData = null;
			maxWidth =  Math.max(titleLabel.textWidth, timerLabel.textWidth, textLabel.textWidth, givesLabel.textWidth, descLabel.textWidth + iconW + iconW2 /*+ orDesc.width*/,countLabel.textWidth + iconW + iconW2 + descLabel.textWidth ,additionalDesc.textWidth) + padding;
			textLabel.width = maxWidth + 5;
			maxHeight = titleLabel.height + textLabel.textHeight + desc * descLabel.height + iconH * iconScale + additionalDesc.height + givesLabel.textHeight + timerLabel.height + timerLabel2.height + 8;
			var bgimg1:Bitmap = new Bitmap();

			if (Window.isOpen){
				if (titleOnly)
					bgimg1 = Window.backing(maxWidth + padding * 2 + 0, maxHeight + padding - 4, 30, 'tipMiniWin');
				else
					bgimg1 = Window.backing(maxWidth + padding * 2 + 40, maxHeight + padding + 26, 50, 'tipWindowUp');
			}else
			{
				if (titleOnly)
					bgimg1 = Window.backing(maxWidth + padding * 2 + 0, maxHeight + padding - 4, 30, 'tipMini');
				else
					bgimg1 = Window.backing(maxWidth + padding * 2 + 40, maxHeight + padding + 26, 50, 'tipUp');
			}
			/*if(blick1 != null){
				blick1 = null;
				blick2 = null;
				blick3 = null;
			}*/
			
			
			bgimg.bitmapData = bgimg1.bitmapData;
			
			blick1.x = 13;
			blick1.y = 14;
			
			blick2.x = bgimg.width - blick2.width - 15;
			blick2.y = 14;
			
			blick3.x = 16;
			blick3.y = bgimg.height - blick3.height - 15;
		}
		
		private function drawItemsIntoDescription(itemList:Array):int {
			if (!itemList.length) return 0;
			var cont:String = '';
			for (var i:String in itemList) {
				if(cont.indexOf(itemList[i].target.title)==-1)
					cont += itemList[i].target.title + ', ';
			}
			cont = cont.substr(0, cont.lastIndexOf(','));
			if (textLabel.text =="") 
			{
				textLabel.text = Locale.__e('flash:1425997881109')+'\n' + cont  + Locale.__e('flash:1454765948341');//а также многое другое!	
			}else 
			{
				textLabel.appendText('\n'+Locale.__e('flash:1425997881109')+'\n'+ cont);
			}
			redrawBackGround(1);
			return 1;
		}
		
		private function fitInWidth(textLbl:TextField, maxWd:int):void {
			var labStr:String = textLbl.text.split('\n').join('');
			var wordList:Array = labStr.split(' ');
			textLbl.text = '';
			textLbl.multiline = true;
			var wNum:int = 0;
			while (wNum < wordList.length-1) {
				var tempStr:String = textLabel.text;
				var toAdd:String = wordList[wNum] + ' ';
				textLbl.appendText(toAdd);
				if (textLbl.textWidth > maxWd) {
					var nTxt:String = '';
					textLbl.replaceText(tempStr.lastIndexOf(toAdd), toAdd.length, nTxt);
					textLbl.appendText("\n");
					continue;
				}
				wNum++;
			}
		}
		
		public function rewrite():void 
		{
			var tip:Object = target['tip']();
			if (!tip || !tip.timer)
				return;
			if (timerLabel.text != '')
			{
				timerLabel.text = tip.timerText;
				timerLabel.autoSize = TextFieldAutoSize.LEFT;
			}else
			{
				textLabel.text = tip.text;
				textLabel.autoSize = TextFieldAutoSize.LEFT;
			}
			if (timerLabel2.text != '')
			{
				timerLabel2.text = tip.timerText2;
				timerLabel2.autoSize = TextFieldAutoSize.LEFT;
			}
			
			
			/*fitInWidth(textLabel, 200);
			fitInWidth(titleLabel, 200);
			fitInWidth(descLabel, 200);*/
			

			if (tip.timer != null && tip.timer == false) {
				App.self.setOffTimer(rewrite);
			}
		}
		
		//	Показать окно возле указателя мыши
		public function relocate():void {
			
			x = App.self.stage.mouseX + 22;
			y = App.self.stage.mouseY + 22;
			
			if (App.self.stage.stageWidth - App.self.stage.mouseX < width + 20) {
				x -= width + 22;
			}
			
			if (App.self.stage.stageHeight - App.self.stage.mouseY < height +20) {
				y -= height + 22;
			}
			/*
			if (App.self.stage.mouseY < height + 20) {
				y = App.self.stage.mouseY - 45;
			}*/
		}
		
	}

}