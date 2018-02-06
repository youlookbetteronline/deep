package wins {
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import wins.elements.MaterialBox;

	public class CtributeChargeWindow extends Window 
	{
		/*
		 * Ctribute-start - когда запускаем его и отправляем энергию.
		 * Ctribute-storage - когда собираем монетку
		 * Ctribute-boost - когда ускоряем круг
		*/
		
		public static const ENERGY_TYPE:int = 1;
		public static const MATERIAL_TYPE:int = 2;
		public static const MATERIAL_QTTY:int = 1;
		
		public static var energySelector:MaterialBox;
		public static var outItemCount:TextField;
		public static var outItem:MaterialBox;
		
		private var chargeButton:Button;
		private var youWillGetText:TextField;
		private var youNeedToGiveText:TextField;
		private var infoIcon:Bitmap;
		private var infoBttn:ImageButton;
		private var workItem:WorkerItem;
		private var materialItemBack:Bitmap 
		private var count:int; 
		private var back1:Bitmap; 
		private var backText:Shape = new Shape(); 
		private var backItem:Shape = new Shape(); 
		private var sprite:LayerX;
		
		public function CtributeChargeWindow(settings:Object = null)
		{
			settings["width"] = 495;
			settings["height"] = 500;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['background'] = "capsuleWindowBacking";
			settings['exitTexture'] = 'closeBttnMetal';
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			super(settings);
		}
		
		override public function drawBody():void 
		{
			
			drawMirrowObjs('decSeaweed', settings.width + 55, - 55, settings.height - 175, true, true, false, 1, 1, layer);
			exit.y -= 20;
			titleLabel.y += 30;
			titleLabel.visible = false;
			
			back1 = backing(settings.width - 70, settings.height - 70, 40, 'paperClear');
			back1.x = (settings.width - back1.width) / 2;
			back1.y = (settings.height - back1.height) / 2;
			layer.addChild(back1);
			
			backText.graphics.beginFill(0xfef3e9);
		    backText.graphics.drawRect(0, 0, settings.width - 140, 160);
			backText.y = 210;
			backText.x = (settings.width - backText.width) / 2;
		    backText.graphics.endFill();
			backText.filters = [new BlurFilter(30, 0, 2)];
			backText.alpha = 1;
		    bodyContainer.addChildAt(backText, 0);
			
			/*var dev1:Bitmap = Window.backingShort(settings.width - 130, "dividerTop", false);
			dev1.x = (settings.width - dev1.width) / 2;
			dev1.y = backText.y - dev1.height;
			bodyContainer.addChild(dev1);
			
			var dev2:Bitmap = Window.backingShort(settings.width - 130, "dividerTop", false);
			dev2.x = (settings.width - dev2.width) / 2;
			dev2.y = backText.y + backText.height;
			bodyContainer.addChild(dev2);*/
			
			var dev:Shape = new Shape();
			dev.graphics.beginFill(0xc0804d);
			dev.graphics.drawRect(0, 0, settings.width - 110, 2);
			dev.graphics.endFill();
			
			var dev1:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev1.bitmapData.draw(dev);
			dev1.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			dev1.x = (settings.width - dev1.width) / 2;
			dev1.y = backText.y - dev1.height;
			bodyContainer.addChild(dev1);
			
			var dev2:Bitmap = new Bitmap(new BitmapData(dev.width, dev.height * 2 + 1));
			dev2.bitmapData.draw(dev);
			dev2.bitmapData.draw(dev, new Matrix(1, 0, 0, 2, 0, 3));
			//var dev2:Bitmap = Window.backingShort(settings.width - 110, "dividerTop", false);
			dev2.x = (settings.width - dev2.width) / 2;
			dev2.y = backText.y + backText.height;
			bodyContainer.addChild(dev2);
			
			if (settings.type == ENERGY_TYPE) 
			{
				drawEnergySelector();
			}else if (settings.type == MATERIAL_TYPE) 
			{
				drawWorkItem();
			}
			
			
			drawOutItem();
			drawChargeButton();
			//drawInfoButton();
			drawYouNeedToGiveText();
		}
		
		public function drawEnergySelector():void 
		{
			energySelector = new MaterialBox(Stock.FANTASY, {
				backing:	'itemBackingGold',
				width:		150,
				height:		150,
				noCounter:	true,
				plusButtons:true,
				ctribute:	true,
				blockMode:	20
			});
			
			energySelector.background.visible = false;
			
			energySelector.x = settings.width / 2 - energySelector.width / 2 + 15;
			energySelector.y = 180;
			bodyContainer.addChild(energySelector);
		}
		
		protected function onStockChange(e:AppEvent):void 
		{
			//drawOutItem();
			drawWorkItem();
			checkButtonState();
			
		}
		
		public function drawYouNeedToGiveText():void 
		{
			youNeedToGiveText = drawText(Locale.__e('flash:1473146530533'), {//Нужно отдать:
				textAlign:		'left',
				fontSize:		32,
				borderSize:		4,
				borderColor:	0x6e411e,
				color:			0xffffff
			});
			
			youNeedToGiveText.width = youNeedToGiveText.textWidth + 5;
			youNeedToGiveText.x = (settings.width - youNeedToGiveText.width) / 2;
			youNeedToGiveText.y = 188;
			bodyContainer.addChild(youNeedToGiveText);
		}
		
		public function drawWorkItem():void 
		{
			/*materialItem = new MaterialItem({
				sID:settings.inItem,
				need:MATERIAL_QTTY,
				window:this, 
				type:MaterialItem.IN,
				color:0x5a291c,
				borderColor:0xfaf9ec,
				bitmapDY: -4,
				bgItemY:0,
				bgItemX:0,
				ctribute:true
			});*/
			if (workItem && workItem.parent)
				workItem.parent.removeChild(workItem);
			var that:* = this;
			Load.loading(Config.getIcon(App.data.storage[settings.inItem].type, App.data.storage[settings.inItem].preview), function(data:Bitmap):void{
				var cnt:int = int(Numbers.countProps(settings.target.info.instance.devel['1'].req));
				workItem = new WorkerItem({
					sID:settings.inItem,
					need:/*MATERIAL_QTTY*/Numbers.getProp(settings.target.info.instance.devel['1'].req, cnt-1).val['mcount'],
					window:that
				});
				
				workItem.checkStatus();
				workItem.background.visible = false;
				workItem.title.visible = false;
				workItem.x = -3 + (settings.width - workItem.width) / 2;
				workItem.y = backText.y + 15;
				workItem.wishBttn.visible = false;
				workItem.buyBttn.height = 38;
				workItem.buyBttn.width = 126;
				workItem.buyBttn.x += 11;
				workItem.askBttn.x += 23;
				workItem.askBttn.y += -1;
				workItem.askBttn.height = 38;
				workItem.askBttn.width = 100;
				workItem.bitmap.scaleX = workItem.bitmap.scaleY = 1.7;
				Size.size(workItem.bitmap, 100, 100);
				workItem.vs_txt.y = workItem.bitmap.y + 41;
				workItem.count_txt.y = workItem.bitmap.y + 41;
				workItem.need_txt.y = workItem.bitmap.y + 41;
				workItem.vs_txt.x += 60;
				workItem.count_txt.x += 60;
				workItem.need_txt.x += 60;
				workItem.searchBttn.visible = false;
				bodyContainer.addChild(workItem);
			});	
			
		}
		
		public static function outItemCounterListener():void 
		{
			if (outItemCount && energySelector) 
			{
				outItemCount.text = "x" + energySelector.count.toString();
				outItemCount.width = outItemCount.textWidth + 5;
				outItemCount.x = outItem.x + outItem.width / 2 - outItemCount.width / 2 - 5;
			}
		}
		
		public function drawOutItem():void 
		{
			sprite = new LayerX();
			bodyContainer.addChild(sprite);
			outItem = new MaterialBox(settings.outItem, {
				backing:	'backBigTurtle',
				width:		150,
				height:		150,
				noCounter:	true,
				light:		true
			});
			outItem.background.visible = false;
			
			
			backItem.graphics.beginFill(0xfef3e9);
			backItem.graphics.drawCircle(0, 0, 70);
			backItem.graphics.endFill();
			backItem.x = (settings.width) / 2;
			backItem.y = 117;
			bodyContainer.addChild(backItem);
			
			outItem.x = backItem.x - outItem.width/2;
			outItem.y = backItem.y -outItem.height/2;
			bodyContainer.addChild(outItem);
			
			outItemCount = drawText("x" + settings.outCount, {
				textAlign:		'left',
				fontSize:		32,
				borderSize:		4,
				borderColor:	0x6e411e,
				color:			0xffdf34
			});
			
			outItemCount.width = outItemCount.textWidth + 5;
			outItemCount.x = backItem.x + backItem.width / 2 - 25;
			outItemCount.y = outItem.y + outItem.height - 55;
			bodyContainer.addChild(outItemCount);
			
			youWillGetText = drawText(Locale.__e('flash:1473090871653'), {//Вы получите:
				textAlign:		'left',
				fontSize:		34,
				borderSize:		4,
				borderColor:	0x6e411e,
				color:			0xffdf34
			});
			
			youWillGetText.width = youWillGetText.textWidth + 5;
			youWillGetText.x = settings.width - settings.width / 2 - youWillGetText.width / 2;
			youWillGetText.y = outItem.y - 25;
			bodyContainer.addChild(youWillGetText);
		}
		
		public function drawChargeButton():void 
		{		
			chargeButton = new Button( {
				caption:		Locale.__e('flash:1382952380010'),//Зарядить
				width:			150,
				height:			45,
				fontSize:		28
			});
			
			chargeButton.addEventListener(MouseEvent.CLICK, onCharge);
			chargeButton.x = settings.width / 2 - chargeButton.width / 2;
			chargeButton.y = settings.height - chargeButton.height - 32;
			bodyContainer.addChild(chargeButton);
			checkButtonState();
		}
		
		
		
		public function checkButtonState():void 
		{	
			if (!chargeButton) 
			{
				return;
			}
			
			if (settings.type == MATERIAL_TYPE)
			{
				if (!App.user.stock.check(settings.inItem)) 
				{
					chargeButton.state = Button.DISABLED;
				}else 
				{
					chargeButton.state = Button.NORMAL;
				}
			}else if (settings.type == ENERGY_TYPE) 
			{
				if (!App.user.stock.check(Stock.FANTASY)) 
				{
					chargeButton.state = Button.DISABLED;
				}else 
				{
					chargeButton.state = Button.NORMAL;
				}
			}
		}
		
		public function drawInfoButton():void 
		{
			infoIcon = new Bitmap(new BitmapData(75,75, true, 0), 'auto', true);
			infoBttn = new ImagesButton(infoIcon.bitmapData);
			
			infoBttn.addEventListener(MouseEvent.CLICK, onHelp);
			Load.loading(Config.getImageIcon("quests/icons", "helpBttn"), function(data:Bitmap):void {
				infoBttn.bitmapData = data.bitmapData;
				infoBttn.initHotspot();
			});
			
			infoBttn.x = exit.x - infoBttn.width - 5;
			infoBttn.y = exit.y - 35;
			bodyContainer.addChild(infoBttn);
		}
		
		public function onCharge(e:MouseEvent):void 
		{
			if (chargeButton.mode == Button.DISABLED)
				return;
			var insta:int = settings.target.instanceNumber();
			
			if (settings.type == MATERIAL_TYPE) 
			{
				//var cnt:int = int(Numbers.countProps(settings.target.info.instance.devel['1'].req));
				count =	1;// Numbers.getProp(settings.target.info.instance.devel['1'].req, cnt - 1).val['mcount'];
			}else if (settings.type == ENERGY_TYPE) 
			{
				count = energySelector.count
			}
			
			Post.send({
				ctr:settings.target.type,
				act:'start',
				uID:App.user.id,
				id:settings.target.id,
				wID:App.user.worldID,
				sID:settings.target.sid,
				iid:insta,
				count:count
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				settings.callback(data.crafted);
				
				if (settings.type == MATERIAL_TYPE) 
				{
					var cnt:int = int(Numbers.countProps(settings.target.info.instance.devel['1'].req));
					var matCount:int = Numbers.getProp(settings.target.info.instance.devel['1'].req, cnt - 1).val['mcount'];
					
					App.user.stock.take(settings.inItem, matCount);
				}else if (settings.type == ENERGY_TYPE) 
				{
					App.user.stock.take(Stock.FANTASY, count);
				}
				
				close();
			});
		}
		
		public function onHelp(e:MouseEvent):void 
		{
			new SimpleWindow( {
				height: 		300,
				popup:			true,
				hasDecoration:	false,
				text:			settings.helpMessage
			}).show();
		}
	}
}