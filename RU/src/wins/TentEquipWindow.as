package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Building;
	
	public class TentEquipWindow extends RecipeWindow 
	{
		private var icon:Bitmap;
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		private var scale:Number;
		private var back:Shape = new Shape();
		
		public var buttonsContainer:Sprite = new Sprite();
		public static var fromElse:Boolean = false;
		
		public function TentEquipWindow(settings:Object=null) 
		{
			if (settings == null) 
			{
				settings = new Object();
			}
			
			settings['background'] = 'tentBacking';
			settings['sID'] = settings.sID || 0;
			settings["width"] = 900;
			settings["height"] = 505;
			settings["popup"] = true;
			settings["fontSize"] = 60; 
			settings["faderAlpha"] = 0.000000001;
			settings["callback"] = settings["callback"] || null;
			settings["dontCheckTechno"] = settings["dontCheckTechno"] || false;
			settings["hasPaginator"] = false;
			settings["delay"] = 200;
			settings["fontColor"] = 0xffffff;
			settings['exitTexture'] = 'tentFlagRed';
			
			formula = App.data.crafting[settings.fID];			
			
			sID = formula.out;
			
			settings["scaleW"] = settings["scaleW"] || App.map.scaleX;
			
			scale = settings.scaleW;
			settings["title"] = settings.title;
			
			if (settings.win != undefined) 
			{
				var crafting:Object = {};
				for (var itm:* in settings.win.craftData) 
				{
					if (settings.win.craftData[itm].lvl <= settings.win.settings.target.level - (settings.win.settings.target.totalLevels - settings.win.settings.target.craftLevels))
					{
						crafting[itm] = settings.win.craftData[itm].fid;
					}
				}
			}
			
			var requiresCount:int = 0;
			var requires:Object = { };
			var materialsCount:int = 0;
			var materials:Object = { };
			
			for (var sID:* in formula.items) 
			{
				switch(sID) 
				{
					case Stock.COINS:
					case Stock.FANTASY:
					case Stock.FANT:
					case Stock.GUESTFANTASY:
					case App.data.storage[App.user.worldID].techno[0]:
					case App.data.storage[App.user.worldID].cookie[0]:
							requiresCount ++;
							requires[sID] = formula.items[sID];
						break;
					default:
							materialsCount ++;
							materials[sID] = formula.items[sID];
						break;	
				}
			}
			
			settings['requires'] = requires;
			settings['materials'] = materials;
			
			if (materialsCount == 0)
			{
				settings['materials'][Stock.FANTASY] = requires[Stock.FANTASY];
				delete settings['requires'][Stock.FANTASY];
			}	
			
			//settings.width;
			super(settings);
			//settings.width;
			
			//settings["width"] = 960;
			//settings["height"] = 900;
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.addEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);			
		}
		
		override public function drawBackground():void 
		{
			background = backingShort(settings.width, settings.background);
			layer.addChild(background);	
		}
		
		override public function drawExit():void 
		{
			exit = new ImageButton(textures[this.settings.exitTexture]);
			layer.addChildAt(exit,0);
			exit.x = 0;
			exit.y = 0;
			
			exit.addEventListener(MouseEvent.CLICK, close);
		}
		
		private function drawInfoBttn(infoBttnX:Number,infoBttnY:Number):void 
		{
			var infoBttn:ImageButton = new ImageButton(textures.aksBttnNew);
				bodyContainer.addChild(infoBttn);
				infoBttn.x = infoBttnX;
				infoBttn.y = infoBttnY;
				infoBttn.addEventListener(MouseEvent.CLICK, onHelpClick);
		}
		
		private function onHelpClick(e:MouseEvent):void 
		{
			var hintWindow:ExpeditionHintWindow = new ExpeditionHintWindow( {
				popup: true,
				hintsNum:3,
				hintID:2,
				height:540
			});
			hintWindow.show();
		}
		private var white:Shape;
		override public function drawBody():void 
		{
			drawButtons();
			var ln:uint = 0;
			var needRecs:Boolean = true;
			for (var cn:* in settings['materials'])
			{
				ln++;
			}
			
			var backgroundShape:Shape = new Shape();
			backgroundShape.graphics.beginFill(0xe6b685);
			backgroundShape.graphics.drawCircle(50, 50, 50);
			backgroundShape.graphics.endFill();
			
			_background = new Bitmap(new BitmapData(100, 100, true, 0));
			_background.bitmapData.draw(backgroundShape);
			_background.x = padding;
			_background.y = 6;
			
			if (settings['materials'].hasOwnProperty(28) || !settings['materials'] && ln < 2)
			{
				createItems(settings['requires']);
				needRecs = false;
			}else {
				createItems(settings['materials']);
			}
			
			var titleBackingBmap:Bitmap = backingShort(settings.titleWidth + 110, 'actionRibbonBg',true,1);
			titleBackingBmap.scaleY = .8;
			titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
			titleBackingBmap.y = -40;
			titleBackingBmap.filters = [new DropShadowFilter(4.0, 90, 0, 0.5, 4.0, 4.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(titleBackingBmap);
			
			var seaweedLeftBmap:Bitmap = new Bitmap(Window.textures.tentSeaweedLeft);
			seaweedLeftBmap.x = - 10;
			seaweedLeftBmap.y = settings.height - seaweedLeftBmap.height + 12;
			layer.addChildAt(seaweedLeftBmap,0);
			
			var seaweedRightBmap:Bitmap = new Bitmap(Window.textures.tentSeaweedRight);
			seaweedRightBmap.x = settings.width - seaweedRightBmap.width + 25;
			seaweedRightBmap.y = settings.height - seaweedRightBmap.height + 12;
			layer.addChildAt(seaweedRightBmap, 0);
			
			var tentKarematBmap:Bitmap = new Bitmap(Window.textures.tentKaremat);
			tentKarematBmap.x = tentKarematBmap.width + 40;
			tentKarematBmap.y = settings.height - tentKarematBmap.height + 12;
			layer.addChild(tentKarematBmap);
			
			white = new Shape();
			white.graphics.beginFill(0xffffff, .5);
			white.graphics.drawRoundRect(0, 0, 400, 350, 30, 30);
			white.x = (settings.width - white.width) / 2;
			white.y = (settings.height - white.height) / 2 + 25;
			
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0);
			mask.graphics.drawRect(white.x, white.y+150, white.width, white.height);
			mask.graphics.endFill();
			mask.filters = [new BlurFilter(0, 80)];
			mask.cacheAsBitmap = true;
			white.cacheAsBitmap = true;
			white.mask = mask;
			layer.addChild(white);
			layer.addChild(mask);
			
			var tentBallBmap:Bitmap = new Bitmap(Window.textures.tentBall);
			tentBallBmap.x = seaweedRightBmap.x - 50;
			tentBallBmap.y = seaweedRightBmap.y + seaweedRightBmap.width;
			layer.addChild(tentBallBmap);
			
			exit.x = white.x + white.width - 70;
			exit.y = white.y - 55;
			
			restBttn.x = (settings.width -restBttn.width) / 2;
			restBttn.y = settings.height - 60 - restBttn.height / 2;
			
			workBttn.x = restBttn.x;
			workBttn.y = restBttn.y;
			
			prePlus = new Bitmap(Window.textures.tentPreplus);
			layer.addChild(prePlus);
			prePlus.x = white.x + (white.width - prePlus.width) / 2;
			prePlus.y = white.y + 30 + (white.height - prePlus.height) / 2;
			
			
			titleLabel.x = titleBackingBmap.x - 250;
			titleLabel.y = 0;
			(needRecs)?drawRequirements(settings['requires']):null;
			
			container.y = 145;
			_background.y = 27;
			
			drawTDesc();
			
			buttonsContainer.x = white.x + white.width;
			buttonsContainer.y = white.y + 50 + (white.height - buttonsContainer.height) / 2;
			layer.addChild(buttonsContainer);
			container.x = padding + (background.width - ((partList.length*2) * 100)) / 2   - 150;
		}
		
		override protected function onStockChange(e:AppEvent):void 
		{
			if (requiresList && requiresList.parent)
			{
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
			
			var ln:uint = 0;
			var needRecs:Boolean = true;
			for (var cn:* in settings['materials'])
			{
				ln++;
			}
			
			if (settings['materials'].hasOwnProperty(28) || !settings['materials'] && ln < 2)
			{
				createItems(settings['requires']);
				needRecs = false;
			}else {
				createItems(settings['materials']);
			}
			
			(needRecs)?drawRequirements(settings['requires']):null;
			
			container.x = padding + (background.width - ((partList.length * 2) * 100)) / 2   - 150;
			
			findHelp();
		}
		
		private var flagYellowButton:ImageButton;
		private var flagPurpleButton:ImageButton;
		
		private var restBttn:Button;
		private var workBttn:Button;
		
		protected function drawButtons():void
		{
			var tentFlagYellowBmap:Bitmap = new Bitmap(Window.textures.tentFlagYellow);
			
			
			var tentFlagPurpleBmap:Bitmap = new Bitmap(Window.textures.tentFlagPurple);
			
			var plusText:TextField = Window.drawText('+', {
				color:0xffffff,
				borderColor:0x6e411e,
				textAlign:"left",
				fontSize:40
			});
			
			var bd:BitmapData = new BitmapData(Window.textures.tentFlagYellow.width, Window.textures.tentFlagYellow.height, true, 0x0);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, 3, 13);
			bd.draw(Window.textures.tentFlagYellow);
			bd.draw(Size.scaleBitmapData(UserInterface.textures.smile,.85),new Matrix(1, 0, 0, 1, 25, 10));
			bd.draw(plusText, matrix);
			
			//calendarBttn	= new ImageButton(bd);
			
			flagYellowButton = new ImageButton(bd);
			
			var bd2:BitmapData = new BitmapData(Window.textures.tentFlagPurple.width, Window.textures.tentFlagPurple.height, true, 0x0);
			//var matrix2:Matrix = new Matrix(1, 0, 0, 1, 3, 13);
			bd2.draw(Window.textures.tentFlagPurple);
			bd2.draw(Size.scaleBitmapData(UserInterface.textures.backpack,.85),new Matrix(1, 0, 0, 1, 25, 10));
			//bd2.draw(plusText, matrix);
			
			flagPurpleButton = new ImageButton(bd2);
			
			restBttn = new Button( {
				width: 		168,
				height:		54,
				fontSize:	40,
				caption:	Locale.__e('flash:1495450201870'),
				
				eventPostManager:true
			});
			
			workBttn = new Button( {
				width			:168,
				height			:54,
				fontSize		:40,
				caption			:Locale.__e('flash:1495617035523'),
				bevelColor		:[0xd38fff, 0x744592],
				bgColor			:[0xcc81fc, 0x9c5dc3],
				fontColor		:0xffffff,
				fontBorderColor	:0x744592,
				
				eventPostManager:true
			});
			
			buttonsContainer.addChild(flagYellowButton);
			buttonsContainer.addChild(flagPurpleButton);		
			
			restBttn.addEventListener(MouseEvent.CLICK, onRest);
			workBttn.addEventListener(MouseEvent.CLICK, onWork);
			
			flagYellowButton.addEventListener(MouseEvent.CLICK, onFirst);
			flagPurpleButton.addEventListener(MouseEvent.CLICK, onSecond);		
			
			flagYellowButton.x = 0;
			flagYellowButton.y = 0;
			
			flagPurpleButton.x = 0;
			flagPurpleButton.y = flagYellowButton.y + flagYellowButton.height + 5;
			flagPurpleButton.scaleX = flagPurpleButton.scaleY = .8;
			
			restBttn.filters = [new DropShadowFilter(4.0, 90, 0, 0.5, 4.0, 4.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(restBttn);
			
			workBttn.filters = [new DropShadowFilter(4.0, 90, 0, 0.5, 4.0, 4.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(workBttn);
			workBttn.visible = false;
			
		}
		
		protected function onRest(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
			{
				for (var i:int = 0; i < partList.length; i++ ) 
				{
					partList[i].doPluck();
				}		
				Hints.text(Locale.__e('flash:1382952379927') + "!", Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Нельзя!
				return;
			}
			e.currentTarget.state = Button.DISABLED;
			
			fromElse = true;
			this.close();
			Post.send({
				ctr:settings.target.type,
				act:'dress',
				uID:App.user.id,
				fID:settings.fID,
				tSID:App.data.storage[App.data.crafting[settings.fID].out].sID,
				wID:App.user.worldID,
				sID:settings.target.sid,
				id:settings.target.id
			}, function(error:int, data:Object, params:Object):void 
			{
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				close();
				settings.target.changeWorker(data.worker);
				
				//Смотрим перечень айтемов в рецепте, выбрасываем Techno
				var payForTechno:Object = {};
				for (var zz:* in App.data.crafting[settings.fID].items)
				{
					if (App.data.storage[zz].type != "Techno") 
					{
						payForTechno[zz] = App.data.crafting[settings.fID].items[zz];
					}
				}
				
				App.user.stock.takeAll(payForTechno);
				
				//var builds:Array = Map.findUnitsByType(['Building']);
				//Building.TRAVEL_COURTS
				for each(var bSid:int in Building.TRAVEL_COURTS)
				{
					var build:Object = App.data.storage[bSid];
					if (Numbers.firstProp(App.data.crafting[build.devel[1].craft[0]].items).key == settings.target.workers[0])
					{
						var building:Building = Map.findUnits([bSid])[0];
						building.onCraftAction(build.devel[1].craft[0]);
						break;
					}
				}
			});	
		}
		
		protected function onWork(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
			{
				for (var i:int = 0; i < partList.length; i++ )
				{
					partList[i].doPluck();
				}			
				Hints.text(Locale.__e('flash:1382952379927') + "!", Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Нельзя!
				return;
			}
			e.currentTarget.state = Button.DISABLED;
			
			fromElse = true;
			this.close();
			Post.send({
				ctr:settings.target.type,
				act:'dress',
				uID:App.user.id,
				fID:settings.fID,
				tSID:App.data.storage[App.data.crafting[settings.fID].out].sID,
				wID:App.user.worldID,
				sID:settings.target.sid,
				id:settings.target.id
			}, function(error:int, data:Object, params:Object):void 
			{
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				close();
				settings.target.changeWorker(data.worker);
				
				//Смотрим перечень айтемов в рецепте, выбрасываем Techno
				var payForTechno:Object = {};
				for (var zz:* in App.data.crafting[settings.fID].items)
				{
					if (App.data.storage[zz].type != "Techno") 
					{
						payForTechno[zz] = App.data.crafting[settings.fID].items[zz];
					}
				}
				
				App.user.stock.takeAll(payForTechno);
				
			});	
		}
		
		public function onFirst(e:MouseEvent = null):void
		{
			restBttn.visible = true;
			workBttn.visible = false;
			flagYellowButton.scaleX = flagYellowButton.scaleY = 1;
			flagYellowButton.y = 0;
			flagPurpleButton.scaleX = flagPurpleButton.scaleY = .8;
		}	
		
		public function onSecond(e:MouseEvent = null):void
		{
			restBttn.visible = false;
			workBttn.visible = true;
			flagYellowButton.scaleX = flagYellowButton.scaleY = .8;
			flagYellowButton.y = 15;
			flagPurpleButton.scaleX = flagPurpleButton.scaleY = 1;
		}
		
		
		protected function drawTDesc():void
		{
			var title:TextField = Window.drawText(Locale.__e('flash:1495546122048'), {
				color:0xffffff,
				borderColor:0x7a4415,
				textAlign:"center",
				autoSize:"center",
				fontSize:45
			});
			
			var desc:TextField =  Window.drawText(String(App.user.stock.count(1684)), {
				color:0xf8c746,
				borderColor:0x7a4415,
				textAlign:"left",
				fontSize:45
			});
			
			var smileBmap:Bitmap = new Bitmap(UserInterface.textures.smile);
			//Load.loading(Config.getIcon(App.data.storage[1684].type, App.data.storage[1684].preview), function (data:Bitmap):void
			//{
				//smileBmap.bitmapData = data.bitmapData;
			Size.size(smileBmap, 46, 46);
			smileBmap.smoothing = true;
			//});
			
			bodyContainer.addChild(title);
			bodyContainer.addChild(desc);
			bodyContainer.addChild(smileBmap);
			
			title.x = (settings.width - title.textWidth) / 2 - desc.textWidth + 7;
			title.y = 80;
			
			title.width = 200;
			
			desc.x = title.x + title.textWidth + 10;
			desc.y = title.y + 3;
			
			smileBmap.x = desc.x + desc.textWidth + 9;
			smileBmap.y = desc.y + (desc.textHeight - smileBmap.height) / 2;
			
			drawInfoBttn(title.x - 85, title.y - 5);
			
			//bodyContainer.swapChildren(backgroundTitle, title);
			//bodyContainer.swapChildren(backgroundTitle, desc);
		}
		
		private var prePlus:Bitmap = new Bitmap();
		
		override protected function drawRequirements(requirements:Object):void 
		{
			for (var obj:* in App.data.crafting[settings.fID].items)
			{
				if ( App.data.storage[obj].type ==  'Techno')
					var characterPerv:String = App.data.storage[obj].preview;
		
			}
			icon = new Bitmap();
			Load.loading(Config.getImage('wigwam_techno', characterPerv),  onLoad);
			
			//Load.loading(Config.getIcon(App.data.storage[8].type, App.data.storage[8].preview), onLoad); //в тупую
			//Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoadIcon);
			requiresList = new RequiresList(requirements, false, { dontCheckTechno:settings.dontCheckTechno, separatorWidth: settings.width * 0.6 } );
			
			//icon.y = 160;
			
			bodyContainer.addChild(icon);
		}		
		
		private var offsetX:int = 200;
		private var offsetY:int = 0;
		private var outTechno:Bitmap;
		
		public static var technoIcon:LayerX;
		
		override protected function createItems(materials:Object):void
		{
			offsetX = 330;
			offsetY = 0;
			var dX:int = 0;			
			var pluses:Array = [];			
			var count:int = 0;
			
			for(var _sID:* in materials) 
			{
				var inItem:MaterialItem = new MaterialItem({
					sID:_sID,
					need:materials[_sID],
					window:this,
					bitmapDY: +5,
					disableAll:disableAll
				});
				
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(inItem);
				
				container.addChild(inItem);
				
				inItem.x = offsetX;
				inItem.y = 0 + 48;
				
				count++;
				
				inItem.background.visible = false;
				inItem.wishBttn.visible = false;
				inItem.searchBttn.visible = false;
		

				var plus:Bitmap = new Bitmap(Window.textures.plus);
				
				offsetX += inItem.background.width- 10 + dX + plus.width;
				
				container.addChild(plus);
				pluses.push(plus)
				plus.x = inItem.x - plus.width + 6;
				plus.y = inItem.background.height / 2 - plus.height / 2 + 58;
			}
			
			if (partList.length == 1)
			{
				inItem.x = offsetX - 175;
			}
			
			var firstPlus:Bitmap = pluses.shift();
			container.removeChild(firstPlus);
			
			bodyContainer.addChild(container);
			onUpdateOutMaterial();		
		}
		override public function contentChange():void
		{		
			onUpdateOutMaterial();
		}
		
		
		private function onLoad(data:Bitmap):void
		{
			icon.bitmapData = data.bitmapData;
			icon.smoothing = true;
			Size.size(icon, 200, 280);
			//icon.x = restBttn.x - 175;
			icon.x = white.x - 45;
			//icon.y = restBttn.y - 240;
			icon.y = white.y + 30 + (white.height - icon.height) / 2;
		}
		
		
		override public function findHelp():void 
		{}
		
		public function focusAndShow():void 
		{
			App.map.focusedOnCenter(settings.target, false, function():void 
			{
				//settings.win.settings.target.visible = false;
				show();
			}, true, 1, true, 0.5);
		}
		
		public function unfocus(tarrget:*):void 
		{
			if (scale != 1)
			{
				App.map.focusedOnCenter(tarrget, false, null, true, scale, true, 0.3);
			}
			//settings.target = null;
			//scale = 1;
		}
		
		override public function onUpdateOutMaterial(e:WindowEvent = null):void 
		{
			var outState:int = MaterialItem.READY;
			for each(var item:* in partList) 
			{
				if (item.status != MaterialItem.READY)
				{
					outState = item.status;
				}
			}
			
			/*if (requiresList && !requiresList.checkOnComplete())
				outState = MaterialItem.UNREADY;*/
			if (!restBttn)
				return;
			if (outState == MaterialItem.UNREADY)
			{
				restBttn.state = Button.DISABLED;
				workBttn.state = Button.DISABLED;
			
			}
			else if (outState != MaterialItem.UNREADY)
			{
				restBttn.state = Button.NORMAL;
				workBttn.state = Button.NORMAL;
			}
			
			/*var openedSlots:int;
			openedSlots = settings.win.settings.target.openedSlots; //this
			if (settings.win.settings.target.queue.length >= openedSlots+1)
				restBttn.state = Button.DISABLED;*/
			
			//if (settings.busy && settings.fID != settings.win.settings.target.fID)
				//outItem.recipeBttn.state = Button.DISABLED;
				
			//if (formula.out == Stock.JAM && App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
				//outItem.recipeBttn.state = Button.DISABLED;
				
			/*if (formula.out == Stock.JAM){
				if (App.user.stock.count(Stock.JAM) >= App.data.levels[App.user.level].jam)
					outItem.jamTick.visible = true;
				else
					outItem.jamTick.visible = false;
			}	*/
		
			
		}
	}
}