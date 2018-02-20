package tree
{
	
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class Tips extends Sprite
	{
		private static const sizes:Object = {"90":1,'180':3,'240':5,'320':6};
		
		private static const fontSize:uint = 17;
		
		private static const padding:uint = 3;
		private static const color:uint = 0x000000;
		
		private static var textLabel:TextField;
		private static var titleLabel:TextField;
		private static var descLabel:TextField;
		private static var countLabel:TextField;
		
		private static var icon:Bitmap;
		
		private var target:DisplayObject;
		
		private var timer:Timer = new Timer(400,1);
		private var tween:TweenLite;
		
		public static var self:Tips;
		
		public function Tips() 
		{
			
			textLabel = UI.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize,
				//textLeading:-2,
				wrap: true
			});
			
			textLabel.wordWrap = true;
			
			titleLabel = UI.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize+2
			}); 
			
			descLabel = UI.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize+2
			}); 
			
			countLabel = UI.drawText("", {
				color:0xffdb65,
				borderColor:0x775002,
				multiline:true,
				fontSize:fontSize+3
			}); 
		}
		
		public function init():void {
			
			textLabel = UI.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize,
				textLeading:-5
			});
			
			textLabel.wordWrap = true;
			
			titleLabel = UI.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize+2
			}); 
		}
		
		private function dispose():void {
			timer.stop();
			if(tween){
				tween.complete(true);
				tween.kill();
				tween = null;
			}
			//if(App.self.tipsContainer && App.self.tipsContainer.contains(this)){
				//App.self.tipsContainer.removeChild(this);
			//}
			while (numChildren > 0) {
				removeChildAt(0);
			}
			target = null;
			//App.self.setOffTimer(rewrite);
		}
		
		public function hide():void {
			dispose();
		}
		
		public function show(object:DisplayObject):void {
			
			while (true) {
				if (!(object is LayerX) && object.parent != null) {
					object = object.parent;
				}else {
					if (!object.hasOwnProperty('tip') || object['tip'] == null ) {
						dispose();
						return;
					}
					break;
				}
			}
			
			if (object is Bitmap && Bitmap(object).bitmapData.getPixel(object.mouseX, object.mouseY) == 0) {
				dispose();
				return;
			}else if (object && object is Node){
				var unit:Node = object as Node;
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
		
		private function draw():void {
			var iconScale:Number = 1;
			
			var title:String = '';
			var text:String = '';
			var desc:String = '';
			var count:String = '';
			if (target['tip'] is Function) {
				var tip:Object = target['tip']();
				title = tip.title || "";
				text = tip.text || "";
				desc = tip.desc || "";
				count = tip.count || "";
				icon = tip.icon || null;
				//if (tip.timer) {
					//App.self.setOnTimer(rewrite);
				//}
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
			
			titleLabel.text = title;
			titleLabel.autoSize = TextFieldAutoSize.LEFT;
			
			textLabel.text = text;
			textLabel.autoSize = TextFieldAutoSize.LEFT;
			textLabel.width = textWidth;
			
			descLabel.text = desc;
			descLabel.autoSize = TextFieldAutoSize.LEFT;
			
			countLabel.text = count;
			descLabel.autoSize = TextFieldAutoSize.LEFT;
			
			var iconW:Number = 0;
			if (icon) iconW = icon.width * iconScale;
			var maxWidth:int = Math.max(titleLabel.textWidth, textLabel.textWidth, descLabel.textWidth + iconW + countLabel.textWidth + 11) + padding * 2;
			textLabel.width = maxWidth + 5;
			var iconH:Number = 0;
			if (icon) iconH = icon.height * iconScale;
			
			var maxHeight:int = titleLabel.height + textLabel.height + descLabel.textHeight + iconH + 10;
			//maxWidth = Math.max(titleLabel.textWidth, textLabel.textWidth) + padding*2;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(maxWidth + padding * 2, maxHeight + padding + 5, (Math.PI / 180) * 90, 0, 0);
			
			var shape:Shape = new Shape();
			//shape.graphics.lineStyle(2, 0x2a2509, 0.8, true);//0xc4e7f3, 0xb8e4f3
			shape.graphics.beginGradientFill(GradientType.LINEAR, [0xeed4a6, 0xeed4a6], [1, 1], [0, 255], matrix);  //[0xe9e0ce, 0xd5c09f]
			shape.graphics.drawRoundRect(0, 0, maxWidth + padding * 2, maxHeight + padding, 15);
			shape.graphics.endFill();
			shape.filters = [new GlowFilter(0x4c4725, 1, 4, 4, 3, 1)];
			shape.alpha = 0.8;
						
			addChild(shape);
			
			titleLabel.x = padding;
			titleLabel.y = padding;
			
			textLabel.x = padding;
			textLabel.y = titleLabel.height;
			
			descLabel.x = padding;
			descLabel.y = textLabel.y + textLabel.height;
			
			if (icon) {
				if (!icon.bitmapData)
				{
					var uicon:Bitmap =  new Bitmap();
					uicon.width = 25;
					uicon.height = 25;
					addChild(uicon);
					uicon.x = descLabel.x + descLabel.textWidth + 8;
					uicon.y = descLabel.y + (descLabel.height - uicon.height)/2;
					countLabel.x = uicon.x + uicon.width + 3;
					countLabel.y = uicon.y + (uicon.height - countLabel.textHeight) / 2;
				}
				icon.scaleX = icon.scaleY = iconScale;
				if (icon.width > 25 )
				{
					icon.width = 25;
				}
				if (icon.height > 25 )
				{
					icon.height = 25;
				}
				icon.smoothing = true;
				
				addChild(icon);
				icon.x = descLabel.x + descLabel.textWidth + 8;
				icon.y = descLabel.y + (descLabel.height - icon.height)/2;
				countLabel.x = icon.x + icon.width + 3;
				countLabel.y = icon.y + (icon.height - countLabel.textHeight) / 2;
			}else {
				countLabel.x = descLabel.x  ;
				countLabel.y = descLabel.y + descLabel.height;
			}
			addChild(descLabel);
			addChild(countLabel);
			
			if(titleLabel.text != ""){
				addChild(titleLabel);
			}else {
				textLabel.y = padding;
			}
			addChild(textLabel);
			textLabel.wordWrap = true;
			textLabel.height = textLabel.textHeight + 5;
			relocate();
			
			//App.self.tipsContainer.addChild(this);
		}
		
		public function rewrite():void {
			var tip:Object = target['tip']();
			
			textLabel.text = tip.text;
			textLabel.autoSize = TextFieldAutoSize.LEFT;
			
			//if (tip.timer != null && tip.timer == false) {
				//App.self.setOffTimer(rewrite);
			//}
		}
		
		public function relocate():void {
			
			x = App.self.stage.mouseX + 32;
			y = App.self.stage.mouseY + 32;
			
			if (App.self.stage.stageWidth - App.self.stage.mouseX < width + 20) {
				x -= width + 45;
			}
			
			if (App.self.stage.stageHeight - App.self.stage.mouseY < height + 50) {
				y -= height + 45;
			}
		}
		
	}

}