package wins 
{
	import buttons.Button;
	import core.Numbers;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import utils.TopHelper;
	public class TopWindow extends Window 
	{
		
		private var descLabel:TextField;
		private var back:Bitmap;
		private var container:Sprite;
		private var showMeBttn:Button;
		
		private var readMoreBttn:Button;	//	кнопка подробнее
		private var snailBitmap:Bitmap;		//	улитка
		
		public var sections:int = 0;
		public var max:int = 100;
		
		public function TopWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings['width'] || 800;
			settings['height'] = settings['height'] || 630;
			settings['title'] = /*(settings.hasOwnProperty('target')) ? settings.target.info.title : ''*/Locale.__e('flash:1486128802001');
			settings['true'] = false;
			settings['description'] = settings['description'];
			settings['exitTexture'] = 'closeBttnMetal';
			//settings['background'] = 'questBacking';
			
			max = settings['max'] || 100;
			sections = settings['sections'] || 5;
			
			var ownerHere:Boolean = false;
			for (var i:int = 0; i < settings.content.length; i++) {
				if (settings.content[i].uID == App.user.id) {
					ownerHere = true;
					//settings.content[i].attraction = settings.target.kicks;
				}
				/*if (settings.content[i].attraction < settings.target.kicksMax) {
					settings.content.splice(i, 1);
					i--;
				}*/
			}
			settings.content.sortOn('points', Array.NUMERIC | Array.DESCENDING);
			
			if (settings.content.length > max)
				settings.content.splice(max, settings.content.length - max);
			
			for (i = 0; i < settings.content.length; i++) {
				settings.content[i]['num'] = String(i + 1);
			}
			super(settings);
			
		}
		
		override public function drawBackground():void {
			if (settings.background!=null) 
			{
				var background:Bitmap = backing(settings.width, settings.height, 50, "capsuleWindowBacking")
				layer.addChild(background);	
			}
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 42,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x4b7915,			
				borderSize 			: 3,					
				shadowColor			: 0x085c10,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center'
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -23;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
			
		}
		
		private function drawBackDivider():void
		{
			var dev:Shape = new Shape();
			dev.graphics.beginFill(0xc0804d);
			dev.graphics.drawRect(0, 0, settings.width - 110, 2);
			dev.graphics.endFill();
			
			var dev1:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev1.bitmapData.draw(dev);
			dev1.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev1.x = (settings.width - dev1.width) / 2;
			dev1.y = back.y + 105;
			bodyContainer.addChild(dev1);
			
			var dev2:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev2.bitmapData.draw(dev);
			dev2.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev2.x = (settings.width - dev2.width) / 2;
			dev2.y = back.y + back.height - 65;
			bodyContainer.addChild(dev2);
		}

		
		public const MARGIN:int = 5;
		override public function drawBody():void 
		{
			drawMirrowObjs('decSeaweed', settings.width + 55, - 55, settings.height - 150 - 28, true, true, false, 1, 1, layer);
			
			exit.y -= 25;
			exit.scaleX = exit.scaleY = 1.1;
			
			//titleLabel.y -= 7;
			back = backing(settings.width - 75, settings.height - 70, 25, 'paperClear');
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2 - 40;
			// рисуем фон
			bodyContainer.addChild(back);
			drawBackDivider();
			drawTimer();
			
			// верхняя картинка
			var ribbon:Bitmap = backingShort(320, 'ribbonGrenn',true,1.3);
			ribbon.x = settings.width / 2 -ribbon.width / 2;			
			ribbon.y = -75;
			bodyContainer.addChild(ribbon);
			
			// верхняя строка	
			descLabel = drawText(settings.description, {
				textAlign:		'center',
				fontSize:		28,
				multiline:		true,
				wrap:			true,
				width:			450,
				color:			0x7e3e13,
				textLeading:	-3,
				borderColor:	0xffffff
			});
			
			//descLabel.width = 380;
			descLabel.wordWrap = true;
			//descLabel.border = true;
			descLabel.x = 80 + (settings.width - descLabel.width) / 2;
			descLabel.y = 23;
			bodyContainer.addChild(descLabel);
			
			
			/*var skip:Boolean = true;
			var posY:int = 30;
			for (var i:int = 0; i < sections+1; i++) 
			{
				var height:int = 76;
				if (i == 0 || i == 2) height += MARGIN;
				var bmd:Shape = new Shape();
				bmd.graphics.beginFill(0xfdedd6, .7);
				bmd.graphics.drawRect(50, 0, back.width-150, height);
				bmd.graphics.endFill();
				bmd.filters = [new BlurFilter(40, 0, 1)];
				bmd.cacheAsBitmap;
				//var bmd:BitmapData = new BitmapData(back.width, height, true, 0x77FFFFFF);
				if (!skip) {
					back.bitmapData.draw(bmd, new Matrix(1, 0, 0, 1, 0, posY));
					skip = true;
				}else {
					skip = false;
				}
				posY += bmd.height;
			}*/
			
			container = new Sprite();
			container.x = back.x;
			container.y = back.y + 110;
			bodyContainer.addChild(container);
			//var dev1:Bitmap = Window.backingShort(settings.width - 110, "dividerTop", false);
			//dev1.x = (settings.width - dev1.width) / 2;
			//dev1.y = container.y;
			//bodyContainer.addChild(dev1);
			
			/*showMeBttn = new Button( {
				width:		100,
				height:		36,
				caption:	Locale.__e('flash:1419439510724'),
				radius:		12,
				fontSize:	20
			});
			showMeBttn.x = 60;
			showMeBttn.y = settings.height - showMeBttn.height - 60;
			showMeBttn.addEventListener(MouseEvent.CLICK, showMe);
			bodyContainer.addChild(showMeBttn);*/
			
			var cont:Sprite = new Sprite();
			bodyContainer.addChild(cont);
			
			var rateDescLabel:TextField = drawText(Locale.__e('flash:1492678692660'), {
				//autoSize:		'center',
				textAlign:		'right',
				color:			0xffffff,
				borderColor:	0x7a4004,
				fontSize:		30
			});
			//rateDescLabel.border = true;
			rateDescLabel.x = bodyContainer.width - rateDescLabel.width - 200;
			rateDescLabel.y = -5;
			cont.addChild(rateDescLabel);
			
			// нижняя справа надпись
			var myPoints:int = 0;
			
			var istanceTop:int = TopHelper.getTopInstance(TopHelper.getTopID(settings.info.sID));
			
			if (Numbers.countProps(App.user.data.user.top[TopHelper.getTopID(settings.info.sID)]) > 0)
			{
				if (App.user.data.user.top[TopHelper.getTopID(settings.info.sID)][istanceTop])
				{
					myPoints = App.user.data.user.top[TopHelper.getTopID(settings.info.sID)][istanceTop]['count'];
				}
					
			}
			
			var rateLabel:TextField = drawText(String(myPoints), {
				//width:			200,
				textAlign:		'left',
				color:			0xa7f050,
				borderColor:	0x376202,
				fontSize:		34
			});
			//rateLabel.border = true;
			rateLabel.x = rateDescLabel.x + rateDescLabel.width + 4;
			rateLabel.y = rateDescLabel.y;
			cont.addChild(rateLabel);
			
			cont.x = 100;
			cont.y = settings.height - cont.height - 70;
			
			paginator.onPageCount = sections;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			paginator.x -= 20;
			paginator.y += 5;
			
			//	кнопка сверху слева
			readMoreBttn = new Button({
				width:	105,
				height:	40,
				caption:	Locale.__e('flash:1492674161395'),
				fontSize:	22,
				fontBorderColor: 0x7f3d0e,
				radius:		12
			});
			readMoreBttn.x = bodyContainer.width - (readMoreBttn.width + (readMoreBttn.width / 2) + 70);
			readMoreBttn.y = 30;
			//bodyContainer.addChild(readMoreBttn);
			
			
			//	рисуем улитку
			snailBitmap = new Bitmap(Window.textures.banksSnail);
			snailBitmap.smoothing = true;
			snailBitmap.x = -15;
			snailBitmap.y = bodyContainer.height - snailBitmap.height - 25;
			bodyContainer.addChild(snailBitmap);
			
			contentChange();
		}
		
		// таймер справа сверху
		private var timerLayer:LayerX;
		private var timerLabel:TextField;
		public function drawTimer():void
		{
			timerLayer = new LayerX();
			var glowing:Bitmap = new Bitmap(Window.textures.glowingBackingNew);
			glowing.alpha = .7;
			glowing.scaleX = 1.5;
			glowing.scaleY = 1.5;
			timerLayer.addChild(glowing);
			
			var titleLabel:TextField = drawText(Locale.__e('flash:1393581955601'),{
				width:			200,
				textAlign:		'center',
				color:			0xffffff,
				borderColor:	0x7e3e13,
				fontSize:		34
			});
			titleLabel.x = (glowing.width - titleLabel.width) / 2;
			//titleLabel.border = true;
			titleLabel.y = 50;
			
			
			timerLayer.addChild(titleLabel);
			
			//settings.top.expire.s = 1493922239;
			timerLabel = drawText(String(TimeConverter.timeToDays(Math.abs(((App.time - settings.top.expire.s)  % Numbers.WEEK) - Numbers.WEEK))), {//пока костыль
				width:			200,
				textAlign:		'center',
				color:			0xfed955,
				borderColor:	0x7a4004,
				fontSize:		40
			});
			timerLayer.addChild(timerLabel);
			App.self.setOnTimer(redrawTime);
			//timerLabel.border = true;
			timerLabel.x = (glowing.width - timerLabel.width) / 2;
			timerLabel.y = 90;
			
			timerLayer.x = 30;
			timerLayer.y = -45;
			
			bodyContainer.addChild(timerLayer);
			timerLayer.tip = function():Object {
				return {
					title:Locale.__e('flash:1486128802001'),
					text:Locale.__e('flash:1495014786745')
				}
			};	
		}
		public function redrawTime():void 
		{
			var time:uint = Math.abs(((App.time - settings.top.expire.s)  % Numbers.WEEK) - Numbers.WEEK);
			if(time > 0)
				timerLabel.text = TimeConverter.timeToDays(time);
			else{
				App.self.setOffTimer(redrawTime);
				TopHelper.showTopWindow(settings.info.sID);
				close();
			}
		}
		override public function drawArrows():void {
			super.drawArrows();
			paginator.arrowLeft.x += 40;
			paginator.arrowRight.x += 25;
			
			paginator.arrowLeft.y -= 35;
			paginator.arrowRight.y -= 35;
		}
		
		public function showMe(e:MouseEvent):void {
			for (var i:int = 0; i < settings.content.length; i++) {
				if (String(settings.content[i].uID) == App.user.id) {
					break;
				}
			}
			
			if (paginator.page != Math.floor(i / sections)) {
				paginator.page = Math.floor(i / sections);
				paginator.update();
				contentChange();
			}
		}
		
		public var items:Vector.<TopItem> = new Vector.<TopItem>;
		override public function contentChange():void 
		{
			clear();
			
			for (var i:int = 0; i < sections; i++) {
				if (paginator.page * sections + i >= settings.content.length) continue;
				var params:Object = settings.content[paginator.page * sections + i];
				
				params['width'] = back.width - 40;
				params['height'] = 77;
				params['backcount'] = i % 2;;
				
				var item:TopItem = new TopItem(params, this);
				item.x = 20;
				item.y = 0 + i * params['height']/* Math.floor((back.height - MARGIN * 2) / sections)*/;
				container.addChild(item);
				items.push(item);
			}
			
		}
		private function clear():void {
			while (items.length > 0) {
				var item:TopItem = items.shift();
				item.dispose();
			}
		}
		
		override public function dispose():void {
			clear();
			//showMeBttn.removeEventListener(MouseEvent.CLICK, showMe);
			
			super.dispose();
		}
	}

}
import buttons.Button;
import core.AvaLoad;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.text.TextField;
import ui.UserInterface;
import wins.TopWindow;
import wins.Window;

internal class TopItem extends LayerX {
	
	private var backing:Shape;
	private var imageBack:Sprite;
	public var image:Sprite;
	private var photoBack:Shape;
	private var numLabel:TextField;
	private var nameLabel:TextField;
	private var rateLabel:TextField;
	private var preloader:Preloader;
	private var travelBttn:Button;
	

	
	private var bgColor:uint = 0xFFFFFF;
	private var bgAlpha:Number = 0;
	
	public var uID:*;
	public var window:*;
	
	public function TopItem(params:Object, window:TopWindow) {
		
		uID = params['_id'];
		this.window = window;
		
		if (uID == App.user.id) {
			bgColor = 0x33cc00;
			bgAlpha = 0.2;
		}
		if (params.backcount != 0)
			bgAlpha = .7;
		
		backing = new Shape();
		backing.x = 5;
		backing.graphics.beginFill(bgColor, 1);
		backing.graphics.drawRect(0, 0, params.width - 10, params.height); //drawRect(0, 0, params.width, params.height);
		backing.graphics.endFill();
		backing.filters = [new BlurFilter(30, 0)];
		addChild(backing);
		backing.alpha = bgAlpha;
		
		// номерация предметов
		numLabel = Window.drawText(params.num, {
			color:			0x704320,
			borderColor:	0xffffff,
			fontSize:		40,
			textAlign:		'center',
			width:			140
		});
		numLabel.x = -10;
		numLabel.y = (backing.height - numLabel.height) / 2 + 4;
		addChild(numLabel);
		
		
		// характеристика предмета
		nameLabel = Window.drawText(params.aka /*'asfsdfsdfsdf \n sdfsdfdfsf'*//*params.first_name + '\n' + params.last_name*/, {
			color:			0x7f4015,
			border:			false,
			fontSize:		26,
			textAlign:		'center',
			autoSize:		'center',
			multiline:		true
			//width:		200
		});
		nameLabel.width = 160;
		nameLabel.wordWrap = true;
		nameLabel.x = 180;
		nameLabel.y = (backing.height - nameLabel.height) / 2 - 2;
		addChild(nameLabel);
		
		// цена надпись
		rateLabel = Window.drawText(params.points, {
			color:			0xa7f050,
			borderColor:	0x396304,
			fontSize:		44,
			textAlign:		'center',
			width:			240
		});
		rateLabel.x = nameLabel.x + nameLabel.width + 15;
		rateLabel.y = (backing.height - rateLabel.height) / 2 + 8;
		addChild(rateLabel);
		
		travelBttn = new Button( {
			width:		130,
			height:		44,
			caption:	Locale.__e('flash:1419440810299'),
			fontSize:	26,
			fontBorderColor: 0x7f3d0e,
			radius:		12
		});
		travelBttn.x = backing.width - travelBttn.width;
		travelBttn.y = (backing.height - travelBttn.height) / 2;
		travelBttn.addEventListener(MouseEvent.CLICK, travel);
		
		if (uID != App.user.id)
			addChild(travelBttn);
		

		
		if (params['take'] == 1) {
			var checkMark:Bitmap = new Bitmap(Window.textures.checkMark);
			checkMark.x = backing.width - checkMark.width - 50;
			checkMark.y = backing.y + (backing.height - checkMark.height) / 2;
			addChild(checkMark);
			
			travelBttn.visible = false;
			
		}else if (!App.user.friends.data.hasOwnProperty(uID)) {
			travelBttn.state = Button.DISABLED;
			travelBttn.y = (backing.height - travelBttn.height) / 2 - 8;
			
			var infoLabel:TextField = Window.drawText(Locale.__e('flash:1419500839285'), {
				color:			0x884a20,
				//borderColor:	0x7a4004,
				border:			false,
				fontSize:		20,
				textAlign:		'center',
				autoSize:		'center'
			});
			infoLabel.x = travelBttn.x + (travelBttn.width - infoLabel.width) / 2;
			infoLabel.y = travelBttn.y + travelBttn.height + 2;
			if (uID != App.user.id)
				addChild(infoLabel);
		}
		
		imageBack = new Sprite();
		imageBack.graphics.beginFill(0xba944d, 1);
		imageBack.graphics.drawRoundRect(0, 0, 68, 68, 20, 20);
		imageBack.graphics.endFill();
		imageBack.x = 110;
		imageBack.y = (backing.height - imageBack.height) / 2;
		addChild(imageBack);
		
		//	изображение
		image = new Sprite();
		addChild(image);
		
		// звезда
		var starr:Bitmap = new Bitmap(Window.textures.star);
		starr.x = imageBack.x + imageBack.width - (starr.width / 2);
		starr.y = imageBack.y + imageBack.height - (starr.height / 2 + 10);
		addChild(starr);
		
		//	число в звезде
		var numInStar:TextField = Window.drawText(String(params.level),{
			width:	30,
			textAling: 'center',
			color: 0xa804015,
			//borderColor: 0x376202,
			border: false,
			fontSize: 22
		});
		numInStar.x = starr.x + 4;
		//numInStar.border = true;
		numInStar.y = starr.y + 4;
		addChild(numInStar);
		
		preloader = new Preloader();
		preloader.scaleX = preloader.scaleY = 0.6;
		preloader.x = imageBack.x + imageBack.width / 2;
		preloader.y = imageBack.y + imageBack.height / 2;
		addChild(preloader);
		
		new AvaLoad(params.photo, onLoad);
		
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	private function onOver(e:MouseEvent):void {
		backing.alpha += 0.1;
	}
	private function onOut(e:MouseEvent):void {
		backing.alpha = bgAlpha;
	}
	
	private function travel(e:MouseEvent):void {
		if (travelBttn.mode == Button.DISABLED) return;
		Window.closeAll();
		App.ui.bottomPanel.showFriendsPanel();
		Travel.friend = App.user.friends.data[uID];
		
		var travelWorld:int = User.HOME_WORLD;
		if (window.settings.info.sID == 1591)
			travelWorld = User.HOLIDAY_LOCATION;
			
		Travel.trustFriendOpenWorld = travelWorld;
		Travel.onVisitEvent(travelWorld);
		
		//window.close();
		
	}
	
	private function onLoad(data:*):void {
		removeChild(preloader);
		preloader = null;
		
		var bitmap:Bitmap = new Bitmap(data.bitmapData, 'auto', true);
		bitmap.width = bitmap.height = 64;
		image.addChild(bitmap);
		
		var maska:Shape = new Shape();
		maska.graphics.beginFill(0xba944d, 1);
		maska.graphics.drawRoundRect(0, 0, 64, 64, 18, 18);
		maska.graphics.endFill();
		image.addChild(maska);
		
		bitmap.mask = maska;
		
		image.x = imageBack.x + (imageBack.width - image.width) / 2;
		image.y = imageBack.y + (imageBack.height - image.height) / 2;
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		
		if (parent) parent.removeChild(this);
	}
}