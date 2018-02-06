package buttons 
{
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextFieldAutoSize;
	import wins.Window;
	
	public class CheckboxButton extends Button
	{
		public static var countOpens:int = 0;
		
		public static const CHECKED:int = 1;
		public static const UNCHECKED:int = 2;
		
		public var checkedBg:Bitmap;
		public var uncheckedBg:Bitmap;
		

		public function CheckboxButton(settings:Object = null) 
		{
			var text:String;
			if (App.social == 'FB')
				text = Locale.__e('flash:1493288771912');
			else
				text = Locale.__e('flash:1396608121799');
				
			var defaults:Object = {
				fontSize			:17,
				fontSizeUnceked		:17,
				fontColor			:0x885127,
				fontBorderColor		:0xffffff,
				border				:true,
				dY					:0,
				//width				:240,
				fontBorderSize		:3,
				captionChecked		:text,
				captionUnchecked	:text
			}
			if (settings && settings.hasOwnProperty('caption') && (settings.caption == false))
			{
				defaults.captionChecked = '';
				defaults.captionUnchecked = '';
				
			}
			if (settings == null) {
				settings = new Object();
			}
			
			for (var property:* in settings) {
				defaults[property] = settings[property];
			}
			
			/*if (countOpens > 1) {
				countOpens = 0;
				User.checkBoxState = CHECKED;
			}
			
			countOpens++;*/
			
			defaults['checked'] = settings.checked || User.checkBoxState;
			
			//if(!settings)
			settings = defaults;
			defaults = null;
			
			super(settings);
			textLabel.y = 6 + settings.dY;
			textLabel.width = settings.width;
			//textLabel.width = textLabel.textWidth + 10;

			//textLabel.filters = null;
			//textLabel.visible = false;
			addEventListener(MouseEvent.CLICK, onStatusChange);
		}
		
		override public function dispose():void {
			removeEventListener(MouseEvent.CLICK, onStatusChange);
			
			super.dispose();
		}
		
		public function freeze():void {
			removeEventListener(MouseEvent.CLICK, onStatusChange);
		}
		
		override protected function drawBottomLayer():void{
			if (settings.hasOwnProperty('brownBg') && settings.brownBg == true) 
			{
				var shapeBg:Shape = new Shape();
				shapeBg.graphics.beginFill(0xc0804d);
				shapeBg.graphics.drawRoundRect(0, 0, 36, 28, 24, 24);
				shapeBg.filters = [new DropShadowFilter(1.0, 90, 0, 0.5, 2.0, 2.0, 1.0, 2, true, false, false), new DropShadowFilter(1.0, 90, 0xffffff, 0.5, 2.0, 2.0, 1.0, 2, false, false, false)];
			
				var bd:BitmapData = new BitmapData( shapeBg.width + 50, shapeBg.height + 20, true, 0x0);
				var bd2:BitmapData = new BitmapData( shapeBg.width + 50, shapeBg.height + 20, true, 0x0);
				//new BitmapData( shapeBg.width, shapeBg.height, true, 0x0);
				//bd.draw( shapeBg );
				var matrix:Matrix = new Matrix(1, 0, 0, 1, 4, 12);
				bd.draw(shapeBg, matrix);
				uncheckedBg = new Bitmap(bd);
				
				bd2.draw(shapeBg, matrix);
				bd2.draw(Size.scaleBitmapData(Window.textures.checkmarkBig, .6));
				checkedBg = new Bitmap(bd2);
				if(textLabel)
					checkedBg.x =  textLabel.x + textLabel.textWidth + 8;
			}
			else{
				checkedBg = new Bitmap(Window.textures.checkBoxPress);
				if(textLabel)
					checkedBg.x =  textLabel.x + textLabel.textWidth + 8;
				uncheckedBg = new Bitmap(Window.textures.checkBox);
			}
			uncheckedBg.x = checkedBg.x;
			uncheckedBg.y = 0;
			
			if (settings.checked == CheckboxButton.CHECKED) {
				uncheckedBg.visible = false;
				checkedBg.visible = true;
			}else {
				uncheckedBg.visible = true;
				checkedBg.visible = false;
			}
			
			bottomLayer.addChild(checkedBg);
			bottomLayer.addChild(uncheckedBg);
			
			addChild(bottomLayer);
		}	
		
		public function set checked(status:int):void {
			if (status == CheckboxButton.CHECKED) {
				uncheckedBg.visible = false;
				checkedBg.visible = true;
				
				textLabel.text = settings.captionChecked;
				style.size = settings.fontSize;
				//textLabel.x = checkedBg.x + checkedBg.width;
				textLabel.x = 0;
			}else {
				uncheckedBg.visible = true;
				checkedBg.visible = false;
				
				textLabel.text = settings.captionUnchecked;
				style.size = settings.fontSizeUnceked;
				//textLabel.x = checkedBg.x + checkedBg.width;
				textLabel.x = 0;
			}
			settings.checked = status;
			
			textLabel.setTextFormat(style);
		}
		
		public function get checked():int {
			return int(settings.checked);
		}
		
		
		override protected function drawTopLayer():void {
			super.drawTopLayer();
			
			style.leading = -2;
			/*style.color = 0xffffff;
			style.border*/
			
			//textLabel.border = settings.border;
			if (!settings.border)
				textLabel.filters = null;
			textLabel.autoSize = TextFieldAutoSize.LEFT;
			textLabel.multiline = true;
			if (settings.hasOwnProperty('multiline'))
				textLabel.multiline = settings.multiline
				
			textLabel.wordWrap = true;
			if (settings.hasOwnProperty('wordWrap'))
				textLabel.wordWrap = settings.wordWrap
			//textLabel.width = settings.width || 126;
			textLabel.x = 0;
			
			this.checked = settings.checked;
			
			textLabel.setTextFormat(style);	
			textLabel.y = checkedBg.y + (checkedBg.height - textLabel.textHeight) / 2;
			
			//checkedBg.x = textLabel.x + textLabel.textWidth + 5;
			//uncheckedBg.x = checkedBg.x;
		}
		
		public function onStatusChange(e:MouseEvent):void {
			if (mode == Button.DISABLED) {
				return;
			}
			
			if (settings.checked == CheckboxButton.CHECKED) {
				this.checked = CheckboxButton.UNCHECKED;
				User.checkBoxState = CheckboxButton.UNCHECKED;
			}else {
				this.checked = CheckboxButton.CHECKED;
				User.checkBoxState = CheckboxButton.CHECKED;
			}
		}
		
		override protected function MouseOver(e:MouseEvent):void {
			if(mode == Button.NORMAL){
				effect(0.1);
			}
		}
		
		override protected function MouseOut(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect(0);
			}
		}
		
		override protected function MouseDown(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect( -0.1);
				SoundsManager.instance.playSFX(settings.sound);	
				if(onMouseDown != null){
					onMouseDown(e);
				}					
			}
		}
		
		override protected function MouseUp(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect(0.1);
				if(onMouseUp != null){
					onMouseUp(e);
				}
			}
		}	
		
				
	}

}