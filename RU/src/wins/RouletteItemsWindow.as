package wins 
{
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import silin.gadgets.Preloader;
	public class RouletteItemsWindow extends Window 
	{
		
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		private var back:Shape = new Shape();
		public var finished:uint = 0;
		
		
		public function RouletteItemsWindow(settings:Object=null) 
		{
			
			if (!settings) settings = { };
			
			settings['width'] = 440;
			settings['height'] = 530;
			settings['title'] = settings.title || Locale.__e('flash:1456331748077');//Выиграй!
			settings['description'] = settings.description || null;//Выиграй!
			settings['hasPaginator'] = true;
			settings["itemsOnPage"] = 9;
			settings['content'] = [];
			settings['background'] = 'paperScroll';
			settings['fontSize'] = 40;
			
			for each (var item:* in settings.items) 
			{
				if (item.hasOwnProperty('sid')) {
					settings.content.push(item);
				}else {
					for (var sid:* in item) {
						settings.content.push({sid:sid, count:item[sid]});
					}
				}
			}
			
			var fixArr:Array = [];
			var decorArr:Array = [];
			var otherArr:Array = [];
			
			if (fixArr.length != 0)
			{
				var buf:Array = fixArr.concat(decorArr).concat(otherArr);
				
				settings.content = [];
				settings.content = buf;
			}
			super(settings);
		}
		
		override public function drawArrows():void 
		{
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 10;
			
			paginator.arrowLeft.x = 130 - paginator.arrowLeft.width;
			paginator.arrowLeft.y = y - 18;
			
			paginator.arrowRight.x = settings.width - 50;
			paginator.arrowRight.y = y - 18;
			
			paginator.x = (settings.width - paginator.width) / 2 - 15;
			paginator.y = settings.height - 20;
		}
		
		
		
		override public function drawBody():void 
		{
			
			drawMirrowObjs('decSeaweed', settings.width + 35, - 35, settings.height - 172, true, true, false, 1, 1);
			
			paginator.onPageCount = settings.itemsOnPage;
			paginator.update();
			
			//var upBack:Bitmap = new Bitmap();			
			//upBack = Window.backing(400, 400, 40, "cloverInnerBacking"); //внутренняя подложка за айтемами
			//upBack.x = settings.width / 2 - upBack.width / 2;
			//upBack.y = 50;
			//layer.addChild(upBack);
			
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -50, true, true);
			exit.y -= 30;
			
			contentChange();
			
			var titleBackingBmap:Bitmap = backingShort(336, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -50;
			bodyContainer.addChild(titleBackingBmap);
			
			back.graphics.beginFill(0xfff4b9, .9);
		    back.graphics.drawRect(0, 0, settings.width - 180, 120);
		    back.graphics.endFill();
			back.height = 54;
		    back.x = (settings.width - back.width) / 2 ;
		    back.y = 40;
		    back.filters = [new BlurFilter(70, 0, 2)];
		    bodyContainer.addChild(back);
			
			var desc:String = (settings.description) ? settings.description : Locale.__e("flash:1481022879397", [settings.title]);
			
			var descLabel:TextField = Window.drawText(desc, {
				fontSize		:28,
				color			:0x6e411e,
				//borderColor 	:0x7f3d0e,
				border			:false,
				textAlign		:"center",
				multiline		:true,
				width			:settings.width - 40,
				wrap			:true
				/*width			:back.width,
				height			:back.height + 30*/
		    });
		    //descLabel.width = descLabel.textWidth + 20;
		    //descLabel.border = true;
		    descLabel.x = back.x + (back.width - descLabel.width) / 2;
		    descLabel.y = back.y + (back.height - descLabel.height) / 2 + 3;
		    bodyContainer.addChild(descLabel);
		}
		
		private var items:Array;
		private var itemsContainer:Sprite = new Sprite();
		
		override public function contentChange():void 
		{
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			bodyContainer.addChild(itemsContainer);
			var target:*;
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 0;
			itemsContainer.x = 40;
			itemsContainer.y = 120;
			if (settings.content.length < 1) return;
			var cnt:int = 0;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:RouletteItem = new RouletteItem(this, { item:settings.content[i] } );
				item.x = Xs + 13;
				item.y = Ys - 5;
				items.push(item);
				itemsContainer.addChild(item);
				
				Xs += item.bg.width + 15;
				
				cnt++;
				
				if (cnt == 3) {
					Xs = 0;
					Ys += item.bg.height + 15;
					cnt = 0;
				} 
			}
			
			if (settings.content.length < 4) itemsContainer.x = (settings.width - itemsContainer.width) / 2;
		}
		
		override public function dispose():void
		{
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			super.dispose();
		}	
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xf9fdff,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x5c9900,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: 0x235b00,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -12;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		
		
		override public function titleText(settings:Object):Sprite
		{
			if (!settings.hasOwnProperty('width'))
				settings['width'] = 300;
				
			var cont:Sprite = new Sprite();
			var cont2:Sprite = new Sprite();
			var shadow:Sprite = new Sprite();
			
			var fontBorder:int = settings.fontBorderSize;
			settings.fontBorderSize = fontBorder;
			var fontBorderGlow:int = settings.fontBorderGlow;
			settings.fontBorderGlow = fontBorderGlow;
			
			
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			this.settings['titleWidth'] = textLabel.textWidth;
			this.settings['titleHeight'] = textLabel.textHeight;
			textLabel.wordWrap = true;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;
			
			var borderColor:uint = settings.borderColor
			settings.borderColor = borderColor;//settings.shadowBorderColor;
			settings.color = borderColor;
			
			var textShadow:TextField = Window.drawText(settings.title, settings);
			textShadow.wordWrap = true;
			textShadow.width = settings.width;
			textShadow.height = textLabel.textHeight + 4;
			
			textShadow.cacheAsBitmap = true;
			textLabel.cacheAsBitmap = true;

			var textShadow2:TextField = Window.drawText(settings.title, settings);
			textShadow2.wordWrap = true;
			textShadow2.width = settings.width;
			textShadow2.height = textLabel.textHeight + 4;
			textShadow2.cacheAsBitmap = true;
			
			settings.borderColor = 0x2a5e0b;
			settings.color = 0x2a5e0b;
			var textShadow3:TextField = Window.drawText(settings.title, settings);
			textShadow3.wordWrap = true;
			textShadow3.width = settings.width;
			textShadow3.height = textLabel.textHeight + 4;
			textShadow3.cacheAsBitmap = true;
					
			var textShadow4:TextField = Window.drawText(settings.title, settings);
			textShadow4.wordWrap = true;
			textShadow4.width = settings.width;
			textShadow4.height = textLabel.textHeight + 4;
			textShadow4.cacheAsBitmap = true;
			
			cont2.addChild(shadow);
			shadow.addChild(textShadow3);
			shadow.addChild(textShadow4);
			cont2.addChild(cont);
			
			//cont.addChild(textShadow);
			//cont.addChild(textShadow2);
			
			cont.addChild(textLabel);
			textFilter = new GlowFilter(0x579705, 1, 3,3, 10, 1);
			cont.filters = [textFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			shadowFilter = new BlurFilter(2,2,1);
			shadow.filters = [shadowFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			
			textShadow.y = 1;
			textShadow2.y = -2;
			textShadow3.y = 4;
			textShadow3.x = 1;
			textShadow4.y = 4;
			textShadow4.x = -1;
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont2;
		}
	}

}
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.geom.Point;
import flash.text.TextField;
import wins.Window;

internal class RouletteItem extends LayerX
{
	private var preloader:Preloader = new Preloader();
	public var bg:Bitmap;
	public var sID:int;
	public var count:int;
	private var icon:Bitmap = new Bitmap();
	public function RouletteItem(window:*, data:Object)
	{
		/*for (var ts:* in data) {
			
			sID = ts.sid;
			count = ts.count;
		}*/
		sID = data.item.sid;
		count = data.item.count;
		
		sID;
		count;
		
		//bg = Window.backing(120, 120, 50, 'itemBackingClover');
		//addChild(bg);
		var backgroundShape:Shape = new Shape();
		backgroundShape.graphics.beginFill(0xe59e79);
		backgroundShape.graphics.drawCircle(50, 50, 50);
		backgroundShape.graphics.endFill();
		
		bg = new Bitmap(new BitmapData(100, 100, true, 0));
		bg.bitmapData.draw(backgroundShape);
		//bg = new Bitmap(Window.textures.bgOutItem);
		addChild(bg);
		
			addChild(preloader);
			preloader.x = (bg.width)/ 2;
			preloader.y = (bg.height)/ 2;
			
		
		if (App.data.storage[sID].type == 'Energy') {
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
		}else {
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].view), onLoad);
		}
		
		tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			}
		}
	}
	
	/*addChild(preloader);
			preloader.x = (settings.width - preloader.width)/ 2;
			preloader.y = (background.height - preloader.height) / 2 - 20 + background.y;
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);*/
	
	private function onLoad(data:*):void {
		removeChild(preloader);
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		Size.size(icon, 75, 75);
		icon.x = (bg.width - icon.width) / 2;
		icon.y = (bg.height - icon.height) / 2 + 5;
		addChild(icon);
		
		drawTitle();
		drawCount();
	}
		
		
	/*title = Window.drawTextX(fName, size.x, size.y, pos.x, pos.y, this, {
		//var name:TextField = Window.drawText(first_Name.substr(0, 15), App.self.userNameSettings( {
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0,
			textAlign:'center'
		});
		addChild(title);*/
		
	private function drawTitle():void {
		var size:Point = new Point(bg.width + 10, 70);
		var pos:Point = new Point(
			(width - size.x) / 2,
			-size.y / 2 + 2
		);
		var titletext:TextField = Window.drawTextX(App.data.storage[sID].title, size.x, size.y, pos.x, pos.y, this, {
			color		:0x502f06,
			borderColor	:0xf8f2e0,
			borderSize	:2,
			textAlign	:'center',
			multiline	:true,
			fontSize	:18,
			wrap		:true
		});
		addChild(titletext);
	}
	
	private function drawCount():void {
		var counttext:TextField = Window.drawText('x' + String(count), {
			color		:0xfffdff,
			borderColor	:0x773d18,
			width		:bg.width,
			textAlign	:'right',
			multiline	:true,
			wrap		:true,
			fontSize	:24
		});
		counttext.x = -15;
		counttext.y = bg.height - counttext.textHeight - 10;
		addChild(counttext);
	}
	
	public function dispose():void {
		
	}
}