package buttons 
{
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import silin.filters.ColorAdjust;
	import ui.UserInterface;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class UpgradeButton extends Button
	{
		public static const TYPE_ON:int = 1;
		public static const TYPE_OFF:int = 2;
		public static const TYPE_R:int = 3;
		
		public var type:int;
		
		public var countText:String = '99';
		public var countLabel:TextField;
		
		public var coinsIcon:Bitmap;
		
		private var countStyle:TextFormat = new TextFormat(); 
		
		public function UpgradeButton(type:int, settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			this.type = type;
			
			coinsIcon = new Bitmap();
			
			if (settings.type != "gem") {
				if(settings.icon)
				coinsIcon.bitmapData = settings.icon;
			}else {
				coinsIcon = new Bitmap(UserInterface.textures.blueCristal, "auto", true);
			}
			
			if (settings.iconScale)
			{
				coinsIcon.scaleX = settings.iconScale;
				coinsIcon.scaleY = settings.iconScale;
			}
			
			
			
			settings["widthButton"] = settings.widthButton || 290;
			//settings["heightButton"] = settings.heightButton || bitmapData.height;
			settings["fontCountColor"]	= settings.fontCountColor || 0xffffff;				//Цвет шрифта	          0xDCFA9B
			settings["fontCountBorder"] = settings.fontCountBorder || 0x252273;//0x354321;				//Цвет обводки шрифта	
			settings['iconScale'] = settings.iconScale || 0.55;
			
			settings["countText"] 		= settings.countText || "";	
			
			
			
			settings["fontCountSize"] = settings.fontCountSize || 23;
			settings["fontBorderCountSize"] = 5;
			
			super(settings);
			
			mouseChildren = false;
		}
		
		override public function disable():void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(0);
			top.filters = [mtrx.filter];
			
			this.mouseChildren = false;
						
		}
		
		override public function enable():void {
			this.filters = [];
			top.filters = [];
			//this.mouseChildren = true;
			super.redrawBottomLayer();
			//effect(0,1);
		}
		
		override protected function drawTopLayer():void {
			super.drawTopLayer();
			
			countLabel = new TextField();
			countLabel.mouseEnabled = false;
			countLabel.mouseWheelEnabled = false;
			
			countLabel.antiAliasType = AntiAliasType.ADVANCED;
			countLabel.embedFonts = true;
			countLabel.sharpness = 100;
			countLabel.thickness = 50;

			countLabel.text = settings.countText;
			
			countStyle.color = settings.fontCountColor; 
			countStyle.size = settings.fontCountSize * App._fontScale;
			countStyle.font = settings.fontFamily;
			countStyle.align = TextFormatAlign.CENTER;
			
			countLabel.setTextFormat(countStyle);
			
			var countFilter:GlowFilter = new GlowFilter(settings.fontCountBorder,1,settings.fontBorderCountSize,settings.fontBorderCountSize,10,1);
			countLabel.filters = [countFilter];	
			
			textLabel.y = (settings.height - textLabel.textHeight) / 2;
			
			
			
			if (settings.isIconFilter) {
				var filterIcon:GlowFilter = new GlowFilter(settings.iconFilter, 1, 2, 2, 10, 1);
				var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,0xab8226,1,2,8,2,1);
				coinsIcon.filters = [filterIcon, shadowFilter];
			}
			countLabel.width = countLabel.textWidth + 6;
			
			if (settings.type == "gem") {
			textLabel.y = 14;
			}
			else 
			{
			textLabel.y = 24;	
			}
			textLabel.x = 40;
			/*if (type == TYPE_R) {
				textLabel.x = 0;
			}*/
			
			
			coinsIcon.x = (bottomLayer.width - (countLabel.textWidth + coinsIcon.width)) / 2;// - countLabel.textWidth;//+ countLabel.textWidth + 6;
			coinsIcon.y = textLabel.y + 30;
			//countLabel.x = coinsIcon.x + 9;
			countLabel.x = coinsIcon.x + coinsIcon.width + 4;
			countLabel.y = coinsIcon.y;
			textLabel.text = textLabel.text +" " + countLabel.text;
			topLayer.addChild(coinsIcon);
			topLayer.addChild(countLabel);
			
			
			
		}
		
		private var top:Bitmap;
		override protected function drawBottomLayer():void
		{
			addChildAt(bottomLayer, 0);
			
			var bg:Bitmap = Window.backingShort(settings.widthButton+59, 'donatBttnBacking');
			//bottomLayer.addChild(bg);
			
			var typeTop:String;
			
			if (type == TYPE_R) {				
				typeTop = "donatBttnTurquoise";
			} else if(type == TYPE_ON)
				typeTop = "donatbttnYellow";
			else 
				typeTop = "donatbttnYellowActive";
				
			top = Window.backingShort(settings.widthButton - 27, typeTop);
			bottomLayer.addChild(top);
			
			//var leave1:Bitmap = new Bitmap(Window.textures.upgradeBttnDec);
			//bottomLayer.addChild(leave1);
			
			//var leave2:Bitmap = new Bitmap(Window.textures.upgradeBttnDec);
			//leave2.scaleX = -1;
			//bottomLayer.addChild(leave2);
			
			bg.y = 6;
			
			//top.x = (bg.width - top.width) / 2;
			top.y = bg.y + (bg.height - top.height) / 2 - 6;
			//leave1.x = 14;
			//leave2.x = bg.width - 14;
		}
		
		public function set countLabelText(count:String):void {
			countText = count;
			countLabel.text = countText + "";
			countLabel.setTextFormat(countStyle);
		}
		
		public function get countLabelText():String {
			return countText;
		}
		
		public function set count(number:String):void {
			countLabel.text = number;
			countLabel.setTextFormat(countStyle);
			countLabel.width = countLabel.textWidth + 6;
		//	textLabel.text = textLabel.text +" " + countLabel.text;
		//	textLabel.setTextFormat(style); textLabel.height = 50;
			//updatePos();
		}
		
		private function updatePos():void 
		{
			if (settings.notChangePos) return;
			
			countLabel.y = (bottomLayer.height - countLabel.textHeight) / 2;
			textLabel.y = (bottomLayer.height - textLabel.height) / 2 - 3;
			coinsIcon.y = (bottomLayer.height - coinsIcon.height) / 2;
			
			topLayer.x = (settings.width - topLayer.width) / 2;
			
			if (settings.hasDotes)
				topLayer.x += 10;
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
		
		override public function effect(count:Number, saturation:Number = 1):void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(saturation);
			mtrx.brightness(count);
			top.filters = [mtrx.filter];
		}
	}

}