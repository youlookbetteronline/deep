package wins
{
	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import core.Numbers;
	import core.Size;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	//import fl.transitions.Tween;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import wins.elements.OutItem;
	
	public class CapsuleWindow extends RecipeWindow
	{	
		private var bttnSkin:Button;
		public function CapsuleWindow(settings:Object = null)
		{			
			settings["fontBorderSize"] = 5;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowColor'] = 0x116011;
			settings['fontSize'] = 42;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 2;
			settings["width"] = 850;
			settings["height"] = 550;
			settings['exitTexture'] = 'closeBttnMetal';
			
			super(settings);
			//settings["fontColor"] = 0xfffa74;
		}
		
		override protected function createItems(materials:Object):void
		{			
			var offsetX:int = 0;
			var offsetY:int = 0;
			var dX:int = 0;
			if (needRecs == true)
			{
				dX = 0;
			}
			
			var pluses:Array = [];
			
			var count:int = 0;
			for (var _sID:* in materials)
			{
				var inItem:CapsuleItem = new CapsuleItem({sID: _sID, need: materials[_sID], window: this, border:false, type: CapsuleItem.IN, bitmapDY: +5, disableAll: disableAll});
				
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(inItem);
				
				container.addChild(inItem);
				
				//if (count < 4) 
				//{
				inItem.x = offsetX + dX - 100;
				inItem.y = offsetY + 0;
				
				if (count < 7) 
				{
					var plus:Bitmap = new Bitmap(Window.textures.plus);
					//pluses.push(plus)
					//plus.scaleX = plus.scaleY = .8;
					plus.smoothing = true;
					
					
					plus.x = inItem.x + inItem.width - 6;
					plus.y = inItem.y + inItem.background.height / 2 - plus.height / 2 + 0;
					container.addChild(plus);
				}
					//}else 
				//{
					//inItem.x = offsetX + dX - 670;
					//inItem.y = offsetY + 160;
				//}
				offsetX += inItem.background.width + 50;
				
				if (count == 3) 
				{
					offsetX = 0;
					offsetY = 160;
				}			
				
				
				//Size.size(plus, 37, 37);
				
				//}else 
				//{
					//plus.x = inItem.x - inItem.width / 2 + 13;
					//plus.y = inItem.background.height / 2 - plus.height / 2 + 160;
				//}				
				
				count++;
			}
			
			//var firstPlus:Bitmap = pluses.shift();
			//container.removeChild(firstPlus);
			
			outItem = new OutItem(onCook, {formula: formula, recipeBttnName: "", border:false, target: settings.target, sID: settings.sID,timeColor:0xffdf34});
			outItem.change(formula);
			container.addChild(outItem);
			
			outItem.x = inItem.x + inItem.width + 87;
			outItem.y = 55;
			
			_equality = new Bitmap(Window.textures.equals);
			container.addChild(_equality);
			//_equality.scaleX = _equality.scaleY = .8;
			_equality.smoothing = true;
			_equality.x = inItem.x + inItem.width + 30;
			_equality.y = inItem.y - 50;
			
			bodyContainer.addChild(container);
			
			container.x = 150;
			container.y = 110;
			//container.x = 0;
			onUpdateOutMaterial();		
		}
		
		override public function onUpdateOutMaterial(e:WindowEvent = null):void
		{
			var outState:int = CapsuleItem.READY;
			for each (var item:* in partList)
			{
				if (item.status != CapsuleItem.READY)
				{
					outState = item.status;
				}
			}
			
			if (requiresList && !requiresList.checkOnComplete())
				outState = CapsuleItem.UNREADY;
			
			if (outState == CapsuleItem.UNREADY)
				outItem.recipeBttn.state = Button.DISABLED;
			else if (outState != CapsuleItem.UNREADY)
				outItem.recipeBttn.state = Button.NORMAL;
			
			var openedSlots:int;
			openedSlots = settings.openedSlots;
			if (settings.queue.length >= openedSlots + 1)
				outItem.recipeBttn.state = Button.DISABLED;
			
			if (formula.out == Stock.JAM)
			{
				if (App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
					outItem.jamTick.visible = true;
				else
					outItem.jamTick.visible = false;
			}		
		}
		
		override protected function onStockChange(e:AppEvent):void 
		{
			if (requiresList && requiresList.parent) {
				requiresList.parent.removeChild(requiresList);
				requiresList.dispose();
				requiresList = null;
			}
			
			for (var i:int = 0; i < partList.length; i++ )
			{
				var itm:MaterialItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			if (_equality && _equality.parent)
			{
				_equality.parent.removeChild(_equality);
				_equality = null;
			}
			
			if (outItem && outItem.parent)
			{
				outItem.parent.removeChild(outItem);
				outItem = null;
			}
			
			for (i = 0; i < container.numChildren; i++ )
			{
				container.removeChildAt(0);
				i--;
			}
			
			if (container && container.parent) 
			{
				container.parent.removeChild(container);
			}
			
			createItems(settings['materials']);
			
			/*if (outItem)
			{
				outItem.x = padding + backgroundWidth + 6;
				outItem.y = 70;
			}*/
			
			/*container.x = 200;
			_equality.x = padding + backgroundWidth - _equality.width / 2 - 17;
			_equality.y = 103;*/
			
			findHelp();
		}
		
		/*protected function drawRibbon():void 
		{
			var ribbonWidth:int = settings.titleWidth + 180;
			if (ribbonWidth < 320)
				ribbonWidth = 320;
			var titleBackingBmap:Bitmap = backingShort(ribbonWidth, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -65;
			//titleBackingBmap.filters = [new GlowFilter(0xf3ff2c, .7, 11, 11, 3)];
			bodyContainer.addChild(titleBackingBmap);
			
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y + 6;
			
			bodyContainer.addChild(titleLabel);
		}*/
		
		override public function drawBody():void 
		{
			
			drawRibbon();
			titleBackingBmap.y -= 8;
			
			//if (settings.hasDescription) settings.height += 40;
			var ln:uint = 0;			
			var reqLength:* = Numbers.countProps(settings['requires']);
			
			if (reqLength > 0)
			{
				needRecs = true;
			}else{
				needRecs = false;
			}
			
			for (var cn:* in settings['materials']) {
				ln++;
			}
			if (settings['materials'].hasOwnProperty(28) || !settings['materials'] && ln < 2)
			{
				createItems(settings['requires']);
				needRecs = false;
			}else {
				createItems(settings['materials']);
			}
			
			backgroundWidth = partList.length * (partList[0].background.width + 45 + 24) ;
			
			if (needRecs)
			{
				backgroundWidth += 80;
			}
			if (backgroundWidth < _minWidth) backgroundWidth = _minWidth;
			
			
			
			var background:Bitmap = backing(settings.width, settings.height ,50, 'capsuleWindowBacking');
			layer.addChildAt(background, 0);
			
			var backgroundUp:Bitmap = backing(settings.width - 60, settings.height - 60 ,40, 'paperClear');
			layer.addChildAt(backgroundUp, 1);
			backgroundUp.x = 30;
			backgroundUp.y = 30;
			
			technoBackingUp = new Bitmap(Window.textures.technoBack);
			technoBackingUp.x = 26;
			technoBackingUp.y = (settings.height - technoBackingUp.height) / 2;
			
			technoBacking = new Bitmap(Window.textures.technoBackBack);
			technoBacking.x = technoBackingUp.x + (technoBackingUp.width - technoBacking.width)/2;
			technoBacking.y = technoBackingUp.y + (technoBackingUp.height - technoBacking.height)/2;
			
			/*if (needRecs)
			{				
				layer.addChild(technoBackingUp);
				layer.addChild(technoBacking);
			}*/
			var backgroundTitle:Shape = new Shape();
			backgroundTitle.graphics.beginFill(0xffffff, .4);
		    backgroundTitle.graphics.drawRect(0, 0, settings.width - 120, 300);
		    backgroundTitle.graphics.endFill();
			backgroundTitle.filters = [new BlurFilter(60, 0)];
			
			//var backgroundTitle:Bitmap = Window.backingShort(settings.width - 100, 'dailyBonusBackingDesc', true);
			backgroundTitle.x = (settings.width - backgroundTitle.width) / 2;
			backgroundTitle.y = 110;
			/*backgroundTitle.scaleY = .45;
			backgroundTitle.alpha = .7;*/
			
			layer.addChild(backgroundTitle);
			
			var descLabel:TextField = Window.drawText(Locale.__e("flash:1474278541686"), {
				fontSize	:32,
				color		:0xFFFFFF,
				borderColor	:0x7f3d0e,
				textAlign	:"center",
				multiline	:true,
				width 		:backgroundTitle.width - 40
			});
			descLabel.width = descLabel.textWidth + 20;
			//descLabel.border = true;
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 60;
			layer.addChild(descLabel);
			
			var skinDescLabel:TextField = Window.drawText(Locale.__e("flash:1492783228615"), {
				fontSize	:32,
				color		:0xFFFFFF,
				borderColor	:0x7f3d0e,
				textAlign	:"center",
				multiline	:true,
				wrap		:true,
				width 		:500
			});
			//skinDescLabel.width = skinDescLabel.textWidth + 20;
			//skinDescLabel.border = true;
			skinDescLabel.x = 50;
			skinDescLabel.y = backgroundTitle.y + backgroundTitle.height + 16;
			layer.addChild(skinDescLabel);
			
			bttnSkin = new Button( {
				caption			:Locale.__e('flash:1492783708294'),
				bgColor			:[0xd36efd, 0x9c32c8],
				bevelColor		:[0xef99fd, 0xe8117ad],
				fontColor 		:0xffdf34,
				fontBorderColor :0x6e039b,
				fontSize		:34,
				width			:210,
				height			:60
			});
			
			bodyContainer.addChild(bttnSkin);
			bttnSkin.x = settings.width - bttnSkin.width - 65;
			bttnSkin.y = settings.height - bttnSkin.height - 95;
			bttnSkin.addEventListener(MouseEvent.CLICK, onSkinEvent);
			
			
			exit.x = background.width - exit.width + 10;
			bodyContainer.addChild(countContainer);
			(needRecs)?drawRequirements(settings['requires']):null;
			
			//container.y = -20;		
			
			onUpdateOutMaterial();
			outItem.addGlow();
			
			arrowLeft = new ImageButton(Window.textures.arrow, {scaleX:-0.7,scaleY:0.7});
			arrowRight = new ImageButton(Window.textures.arrow, {scaleX:0.7,scaleY:0.7});
			
			arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onPrev);
			arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onNext);
			
			if (prev > 0)
			{
				bodyContainer.addChild(arrowLeft);
				arrowLeft.x = settings.width / 2 - 120;
				arrowLeft.y = titleLabel.y - 36;
			}
			
			if (next > 0)
			{
				bodyContainer.addChild(arrowRight);
				arrowRight.x = settings.width/2 + 150 - 50;
				arrowRight.y = titleLabel.y - 36;
			}
		}
		
		//override public function drawTitle():void 
		//{	
			//settings["fontSize"] = 42;
			//settings["fontBorderSize"] = 2;
			//titleLabel = titleText( {
				//title				: App.data.storage[settings.prodItem.sid].title,
				//color				: settings.fontColor,
				//multiline			: settings.multiline,	
				//fontSize			: settings.fontSize,		
				//textLeading	 		: settings.textLeading,	
				//borderColor 		: 0x70401d,
				//borderSize 			: settings.fontBorderSize,			
				//shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				//width				: settings.width,
				//textAlign			: 'center',
				//sharpness 			: 50,
				//thickness			: 50,
				//border				: true
			//})
			//
			//titleLabel.x = (settings.width - titleLabel.width) * .5 + 90;
			//titleLabel.y = -10;
			//bottomContainer.addChild(titleLabel);			
		//}
		
		override public function drawExit():void
		{
			super.drawExit();
			exit.y = -8;
		}
		
		protected function onSkinEvent(e:MouseEvent):void
		{
			/*if (!Config.admin)
			{
				new SimpleWindow( {
					title	:Locale.__e("flash:1474469531767"),
					label	:SimpleWindow.ATTENTION,
					text	:Locale.__e('flash:1481899130563'),
					popup	:true
				}).show();
				return;
			}*/
			new BuildingSkinWindow({
				title	:settings.prodItem.info.title,
				target	:settings.prodItem,
				popup	:true
			}).show();
		}
		override protected function onCook(e:MouseEvent):void
		{
			if (settings.busy)
			{
				App.ui.flashGlowing(settings.win.progressBacking, 0xFFFF00);
				Hints.text(Locale.__e("flash:1426782737630"), Hints.TEXT_RED, new Point(mouseX, mouseY), false, App.self.tipsContainer);
				return;
			}
			
			if (formula.out == Stock.JAM && App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
			{
				Hints.text(Locale.__e("flash:1382952380256"), Hints.TEXT_RED, new Point(mouseX, mouseY), false, App.self.tipsContainer);
			}
			
			if (e.currentTarget.mode == Button.DISABLED) 
			{
				for (var i:int = 0; i < partList.length; i++ ) 
				{
					partList[i].doPluck();
				}
				//requiresList.doPluck();
				Hints.text(Locale.__e('flash:1382952379927') + "!", Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Нельзя!
				return;
			}
			
			e.currentTarget.state = Button.DISABLED;			
			outItem.removeGlow();			
			
			/*var myTween:Tween;
			for (var t:* in partList)
			{
				//myTween = new Tween(partList[t].bitmap, "alpha", Strong.easeOut, 1, 0.2, 2, true);
				//superMegaEffect
				TweenMax.to( partList[t].bitmap, 2, { alpha:0.2, onComplete:function():void {
					//ТУТ ОН КОМПЛИТ
					//trace('1111')
				}});
			}*/
			
			var indexInPartList:int = 0;
			
			if (partList.hasOwnProperty('0') && partList[0].hasOwnProperty('bitmap')) 
			{
				addTweenMax();
			}
			
			function addTweenMax():void 
			{
				if (indexInPartList < partList.length)
				{
					TweenMax.to(partList[indexInPartList].bitmap, 1, { alpha: 0.2, onComplete: addTweenMax});
				}else 
				{
					settings.onCook(settings.fID);
				}
				indexInPartList++;   
			}			
			
			//settings.onCook(settings.fID);
		}
	}
}