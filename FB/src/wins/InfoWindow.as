package wins {
	
	import buttons.Button;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class InfoWindow extends Window 
	{
		public var info:Object;
		public function InfoWindow(tipID:uint,settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			info = App.data.tips[tipID];
			settings['background'] 		= 'helpWindowBacking';
			settings['width'] 			= 585;
			settings['height'] 			= 485;
			settings['title'] 			= Locale.__e('flash:1382952380254');
			settings['hasPaginator'] 	= false;
			settings['hasExit'] 		= false;
			settings['hasTitle'] 		= true;
			settings['faderClickable'] 	= true;
			settings['faderAlpha'] 		= 0.4;
			settings['popup'] 			= true;
			settings['caption'] 		= settings.caption || Locale.__e('flash:1382952380298');
			
			settings['height'] = 20 + HelpItem.backHeight * (Numbers.countProps(info.items.info) + 2);
			super(settings);
		}
		public static function showInformer(tipID:uint,windowSettings:Object = null, limit:Boolean = false, show:Boolean = true):InfoWindow // можно задать сколько раз пользователь увидет подсказку
		{
			var userOptions:Object = App.user.storageRead('InformerManager', { } );
			var totalOptions:Object = JSON.parse(App.data.options.InfoManager);
			if (!userOptions.hasOwnProperty(String(tipID)))
				userOptions[String(tipID)] = 0;
			if (limit && totalOptions.hasOwnProperty(String(tipID)) && totalOptions[tipID] <= userOptions[String(tipID)])
				return null;
			var window:InfoWindow = new InfoWindow(tipID, windowSettings);
			if (show)
				window.show();
			userOptions[String(tipID)]++;
			if (limit)
				App.user.storageStore('InformerManager',userOptions);
			return window;
		}
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = - titleLabel.height / 2;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			
			headerContainer.y = 32;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void {
			var items:Object = info.items.info;
			for (var i:int = 1; i < Numbers.countProps(items) + 1; i++ ) {
				if (!items.hasOwnProperty(i)) continue;
				var item:HelpItem = new HelpItem(i, items[i].text, items[i].image);
				item.x = 53;
				item.y = 40 + (i - 1) * (item.background.height + 30);
				bodyContainer.addChild(item);
			}
			
			var bttn:Button = new Button( {  width:194, height:53, caption:settings.caption } );
			bodyContainer.addChild(bttn);
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height - 25;
			bttn.addEventListener(MouseEvent.CLICK, onClick);
			
			if (App.user.quests.tutorial) {
				QuestsRules.addTarget(bttn);
				
				bttn.showGlowing();
				bttn.showPointing('bottom', 0, 80, bodyContainer);
			}
		}
		
		public function onClick(e:MouseEvent):void {
			if (settings.callback != null) settings.callback();
			
			var bttn:Button = e.currentTarget as Button;
			if (bttn.__hasGlowing) {
				bttn.hideGlowing();
				bttn.hidePointing();
			}
			
			close();
		}
		
		override public function close(e:MouseEvent = null):void {
			App.user.onStopEvent();
			if (settings.onClose != null) settings.onClose();
			super.close();
		}
	}
}

import buttons.ImageButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.InfoWindow;
import wins.GambleWindow;
import wins.Window;

internal class HelpItem extends Sprite {
	
	public var background:Shape = new Shape();
	public var iconBitmap:Bitmap = new Bitmap();
	public var descriptionLabel:TextField;
	public var helpNum:int;
	public var descText:String;
	public static const backHeight:uint = 92;
	public static const backWidth:uint = 480;
	
	public function HelpItem(helpNum:int, descText:String,image:String):void {		
		this.helpNum = helpNum;
		this.descText = descText;
		background.graphics.beginFill(0xffffff, 0);
		background.graphics.drawRect(0, 0, backWidth, backHeight);
		background.graphics.endFill();
		addChild(background);
		
		up_devider = new Bitmap(Window.textures.dividerLine);
		up_devider.x = 75;
		up_devider.y = 0;
		up_devider.width = background.width - 200;
		up_devider.alpha = 0.6;
		addChild(up_devider);
		
		down_devider = new Bitmap(Window.textures.dividerLine);
		down_devider.x = up_devider.x;
		down_devider.width = up_devider.width;
		down_devider.y = background.height - down_devider.height;
		down_devider.alpha = 0.6;
		addChild(down_devider);
		
		drawBackGradient();
		
		drawCircles();
		addChild(iconBitmap);
		drawDescription();
		
		Load.loading(Config.getImageIcon('help',image, 'png'), onLoad);
	}
	
	private var circle:Shape;
	public function drawCircles():void {
		circle = new Shape();
		circle.graphics.beginFill(0xb1c0b9, 1);
		circle.graphics.drawCircle(0, 0, 46);
		circle.graphics.endFill();
		circle.x = background.width - 70;
		circle.y = background.height / 2;
		addChild(circle);
	}
	
	public function drawDescription():void {
		var numPrms:Object = {
				color			:0xf7ffe8,
				borderColor		:0xb77e24,
				shadowColor		:0x50413e,
				shadowSize		:4,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:70
		};
		var numberLabel:TextField = Window.drawText(String(helpNum), numPrms);
		numberLabel.width = numberLabel.textWidth + 5;
		numberLabel.x = 30;
		numberLabel.y = (background.height - numberLabel.textHeight) / 2;
		addChild(numberLabel);
		
		var size:Point = new Point(280, 80);
		var pos:Point = new Point(80, (background.height - size.y) / 2 + 2);
		
		Window.drawTextX(descText, size.x, size.y, pos.x, pos.y, this, {
					color			:0x5a2e09,
					border			:false,
					multiline		:true,
					wrap			:true,
					textAlign		:'left',
					fontSize		:26
			});
	}
	private function drawBackGradient():void
	{
		var bg:Shape = new Shape();
		var bgR:Shape = new Shape();
		bg.x = 73;
		bg.y = up_devider.y + up_devider.height;
		bg.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [0.08, 0.47],[132, 255]);
		bg.graphics.drawRect(0, 0, backWidth * 0.5 - bg.x, down_devider.y - bg.y);
		bg.graphics.endFill();
		
		bgR.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [0.47, 0.08],[132, 255]);
		bgR.graphics.drawRect(0, 0, backWidth * 0.5 - bg.x, down_devider.y - bg.y);
		bgR.graphics.endFill();
		bgR.x = bg.x + bg.width;
		bgR.y = bg.y;
		
		addChild(bg);
		addChild(bgR);
	}
	private var scaleCirc:Number = 1.2;
	private var sprite:LayerX = new LayerX();
	private var down_devider:Bitmap;
	private var up_devider:Bitmap;
	public function onLoad(data:Bitmap):void {
		addChild(sprite);
		
		iconBitmap.bitmapData = data.bitmapData;
		iconBitmap.x = circle.x - iconBitmap.width / 2;
		iconBitmap.y = circle.y - iconBitmap.height / 2;
		
		sprite.addChild(iconBitmap);
	}
}