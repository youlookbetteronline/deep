package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
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
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import utils.Locker;
	
	public class TechnoRecipeWindow extends RecipeWindow 
	{
		private var icon:Bitmap;
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		private var scale:Number;
		private var back:Shape = new Shape();
		
		public var buttonsContainer:Sprite = new Sprite();
		public static var fromElse:Boolean = false;
		
		public function TechnoRecipeWindow(settings:Object=null) 
		{
			if (settings == null) 
			{
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			settings["popup"] = true;
			settings["fontSize"] = 38;
			settings["faderAlpha"] = 0.000000001;
			settings["callback"] = settings["callback"] || null;
			settings["dontCheckTechno"] = settings["dontCheckTechno"] || false;
			settings["hasPaginator"] = false;
			settings["delay"] = 200;
			
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
			
			settings.width;
			super(settings);
			settings.width;
			
			settings["width"] = 960;
			settings["height"] = 900;
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.addEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);			
		}
		
		override public function drawTitle():void 
		{
			settings["title"] = settings.title;
			titleLabel = titleText( {
				title				: settings.title, //заменить
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
			titleLabel.y = +3;
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
			settings.borderColor = borderColor;
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
			cont.filters = [textFilter];
			
			shadowFilter = new BlurFilter(2,2,1);
			shadow.filters = [shadowFilter];			
			
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
		
		private var plankBmap:Bitmap = new Bitmap();
		//private var backgroundTitle:Bitmap = new Bitmap();
		private var downPlankBmap:Bitmap = new Bitmap();
		//private var background:Bitmap = new Bitmap();
		
		override public function drawBody():void {
			
			back.graphics.beginFill(0xd7a26e, .9);
		    back.graphics.drawRect(0, 0, 300, 120);
		    back.graphics.endFill();
			back.height = 40;
		    back.x = (settings.width - back.width) / 2 + 60;
		    back.y = settings.height - back.height + 130;
		    back.filters = [new BlurFilter(20, 0, 2)];
		    bodyContainer.addChild(back);
			
			var missionLeftText:TextField = Window.drawText(Locale.__e('flash:1481814370899'), { //заменить
				color		:0x7c3f15,
				border		:false,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:28
			});
			
			missionLeftText.y = back.y + 3;
			bodyContainer.addChild(missionLeftText);
			var bubbleCounter:Bitmap = new Bitmap(Window.textures.clearBubbleBacking_0);
			Size.size(bubbleCounter, 46, 46);
			bubbleCounter.y = missionLeftText.y - 6;
			bodyContainer.addChild(bubbleCounter);
			
			missionLeftText.x = back.x + (back.width - missionLeftText.width)/2 - bubbleCounter.width/2;
			bubbleCounter.x = missionLeftText.x + missionLeftText.width + 5;
			
			var missionCounter:TextField = Window.drawText(settings.target.capacity, { 
				color		:0xffffff,
				borderColor	:0x6e411e,
				textAlign	:"center",
				autoSize	:"center",
				fontSize	:28
			});
			missionCounter.x = bubbleCounter.x + (bubbleCounter.width - missionCounter.width) / 2;
			missionCounter.y = bubbleCounter.y + 8;
			bodyContainer.addChild(missionCounter);

			
			settings["width"] = 660;
			settings["height"] = 550;
			
			titleLabel.y = 0;
			
			var ln:uint = 0;
			var needRecs:Boolean = true;
			for (var cn:* in settings['materials'])
			{
				ln++;
			}
			
			backgroundWidth = settings.width;
			
			var backgroundShape:Shape = new Shape();
			backgroundShape.graphics.beginFill(0xe6b685);
			backgroundShape.graphics.drawCircle(50, 50, 50);
			backgroundShape.graphics.endFill();
			
			_background = new Bitmap(new BitmapData(100, 100, true, 0));
			_background.bitmapData.draw(backgroundShape);
			//_background = new Bitmap(Window.textures.bgItem);
			//bodyContainer.addChildAt(_background, 0);
			_background.x = padding;
			_background.y = 6;
			
			//_backLine = Window.backing(_background.width - 36, 48, 10, "recipte_line");
			//bodyContainer.addChildAt(_backLine, 1);
			//_backLine.x = _background.x + 18;
			//_backLine.y = _background.y + 12;
			
			drawButtons();
			if (settings['materials'].hasOwnProperty(28) || !settings['materials'] && ln < 2)
			{
				createItems(settings['requires']);
				needRecs = false;
			}else {
				createItems(settings['materials']);
			}
			
			settings.width = padding + backgroundWidth + ((partList.length) * 80)  + padding;
			
			background = backing2(settings.width, settings.height ,50, 'constructBackingUp', 'constructBackingBot');
			
			layer.addChild(background);
			
			Load.loading(Config.getImage('wigwam_techno', App.data.storage[settings.sID].preview), onLoadOut);
			
			var titleBackingBmap:Bitmap = backingShort(settings.titleWidth + 160, 'ribbonGrenn',true,1.3);
			titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
			titleBackingBmap.y = -39;
			titleBackingBmap.filters = [new DropShadowFilter(4.0, 90, 0, 0.5, 4.0, 4.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(titleBackingBmap);
			
			downPlankBmap = backingShort(300, 'shopPlankDown');
			downPlankBmap.x = settings.width/2 -downPlankBmap.width/2;
			downPlankBmap.y = settings.height - downPlankBmap.height -26;
			bodyContainer.addChild(downPlankBmap);
			bodyContainer.swapChildren(downPlankBmap, hireBttn);
			
			hireBttn.x = downPlankBmap.x + (downPlankBmap.width - hireBttn.width)/2;
			hireBttn.y = downPlankBmap.y + (downPlankBmap.height - hireBttn.height) - 11;
			
			drawMirrowObjs('decSeaweed', settings.width + 38, - 38, settings.height - 150 - 28, true, true);
			
			exit.x = settings.width - exit.width - 8;
			exit.y = 15;
			titleLabel.x = settings.width / 2 - titleLabel.width / 2;
			
			(needRecs)?drawRequirements(settings['requires']):null;
			
			container.y = 145;
			_background.y = 27;
			//_backLine.y = _background.y + 12;
			
			plankBmap = backingShort((partList.length)*64 + 240, 'helfBacking'); // надо будет заменить
			plankBmap.x = container.x + 240;
			plankBmap.y = 300;
			layer.addChild(plankBmap);
			titleLabel.y += 8;
			
			prePlus = new Bitmap(Window.textures.plus);
			layer.addChild(prePlus);
			prePlus.x = plankBmap.x + 10;
			prePlus.y = plankBmap.y - 33;
			
			backgroundTitle = Window.backingShort(settings.width - 140, 'questTaskBackingNew', true);
			backgroundTitle.x =  (settings.width - backgroundTitle.width)/2;
			backgroundTitle.y = 103;
			backgroundTitle.scaleY = .65;
			backgroundTitle.alpha = 1;
			
			layer.addChild(backgroundTitle);
			
			drawTDesc();
			
			
			buttonsContainer.x = settings.width - buttonsContainer.width;
			buttonsContainer.y = (settings.height - buttonsContainer.height) / 2 - 28;
			bodyContainer.addChild(buttonsContainer);
			container.x = padding + (background.width - ((partList.length * 2) * 100)) / 2 - 150; // 890-464  - 480
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
			//createItems(settings['materials']);
			
			/*if (outItem)
			{
				outItem.x = padding + backgroundWidth + 6;
				outItem.y = 90;
			}*/
			container.x = padding + (background.width - ((partList.length * 2) * 100)) / 2   - 150; // 40 790 1
			bodyContainer.swapChildren(buttonsContainer, icon);
			/*container.x = padding + (backgroundWidth - container.width) / 2;
			_equality.x = padding + backgroundWidth - _equality.width / 2 - 25;
			_equality.y += 39;*/
			
			findHelp();
		}
		
		private var chefButton:ImageButton;
		private var climberButton:ImageButton;
		private var hunterButton:ImageButton;
		private var minerButton:ImageButton;
		private var chefButtonActive:ImageButton;
		private var climberButtonActive:ImageButton;
		private var hunterButtonActive:ImageButton;
		private var minerButtonActive:ImageButton;
		private var buttonsGreenArray:Array;
		private var buttonsBlueArray:Array;
		private var hireBttn:Button;
		
		protected function drawButtons():void
		{
			if(settings.target.sid == 3140){ // для пирата
				buttonsGreenArray = ['aborMasterGreen', 'buttonChefGreen', 'macheteGreen'];
				buttonsBlueArray = ['aborMasterBlue', 'buttonChefBlue', 'macheteBlue'];
			}
			else if(settings.wSID == 8){ // для кальмаров
				buttonsGreenArray = ['buttonChefGreen', 'buttonHunterGreen', 'buttonMinerGreen'];
				buttonsBlueArray = ['buttonChefBlue', 'buttonHunterBlue', 'buttonMinerBlue'];
			}else if(settings.wSID == 783 && settings.target.sid != 2344){ // для осьминогов
				buttonsGreenArray = ['buttonAssistantGreen', 'buttonJewelerGreen', 'buttonEngineerGreen'];
				buttonsBlueArray = ['buttonAssistantBlue', 'buttonJewelerBlue', 'buttonEngineerBlue'];
			}else if(settings.wSID == 2178){ // для туземца
				buttonsGreenArray = ['aborHunterGreen', 'aborMasterGreen', 'aborWeaverGreen'];
				buttonsBlueArray = ['aborHunterBlue', 'aborMasterBlue', 'aborWeaverBlue'];
			}else if(settings.wSID == 783 && settings.target.sid == 2344){ // для натурала
				buttonsGreenArray = ['calculatorGreen', 'buttonEngineerGreen', 'buttonAssistantGreen'];
				buttonsBlueArray = ['calculatorBlue', 'buttonEngineerBlue', 'buttonAssistantBlue'];
			}else{ //по дефолту
				buttonsGreenArray = ['buttonChefGreen', 'buttonHunterGreen', 'buttonMinerGreen'];
				buttonsBlueArray = ['buttonChefBlue', 'buttonHunterBlue', 'buttonMinerBlue'];
			}
			
			chefButton = new ImageButton(Window.textures[buttonsBlueArray[0]]);
			hunterButton = new ImageButton(Window.textures[buttonsBlueArray[1]]);
			minerButton = new ImageButton(Window.textures[buttonsBlueArray[2]]);
			
			chefButtonActive = new ImageButton(Window.textures[buttonsGreenArray[0]]);
			hunterButtonActive = new ImageButton(Window.textures[buttonsGreenArray[1]]);
			minerButtonActive = new ImageButton(Window.textures[buttonsGreenArray[2]]);
			
			hireBttn = new Button( {
				width: 		140,
				height:		45,
				caption:	Locale.__e('flash:1382952380066'),
				eventPostManager:true
			});
			
			buttonsContainer.addChild(chefButton);
			buttonsContainer.addChild(hunterButton);
			buttonsContainer.addChild(minerButton);
			
			chefButton.tip = function():Object {
				return {
					title:App.data.storage[settings.craftData[0].sID].title,
					text:App.data.storage[settings.craftData[0].sID].description
				}
			}
			hunterButton.tip = function():Object {
				return {
					title:App.data.storage[settings.craftData[2].sID].title,
					text:App.data.storage[settings.craftData[2].sID].description
				}
			}
			minerButton.tip = function():Object {
				return {
					title:App.data.storage[settings.craftData[1].sID].title,
					text:App.data.storage[settings.craftData[1].sID].description
				}
			}
			
			chefButtonActive.tip = function():Object {
				return {
					title:App.data.storage[settings.craftData[0].sID].title,
					text:App.data.storage[settings.craftData[0].sID].description
				}
			}
			hunterButtonActive.tip = function():Object {
				return {
					title:App.data.storage[settings.craftData[2].sID].title,
					text:App.data.storage[settings.craftData[2].sID].description
				}
			}
			minerButtonActive.tip = function():Object {
				return {
					title:App.data.storage[settings.craftData[1].sID].title,
					text:App.data.storage[settings.craftData[1].sID].description
				}
			}
			
			buttonsContainer.addChild(chefButtonActive);
			buttonsContainer.addChild(hunterButtonActive);
			buttonsContainer.addChild(minerButtonActive);			
			
			hireBttn.addEventListener(MouseEvent.CLICK, onHire);
			
			chefButton.addEventListener(MouseEvent.CLICK, onFirst);
			hunterButton.addEventListener(MouseEvent.CLICK, onSecond);
			minerButton.addEventListener(MouseEvent.CLICK, onThird);			
			
			chefButton.x = 0;
			chefButton.y = 0;
			chefButtonActive.x = 0;
			chefButtonActive.y = 0;
			
			/*climberButton.x = 0;
			climberButton.y = chefButton.y + chefButton.height + 5;
			climberButtonActive.x = 0;
			climberButtonActive.y = chefButton.y + chefButton.height + 5;*/
			
			hunterButton.x = 0;
			hunterButton.y = chefButton.y + chefButton.height + 5;
			hunterButtonActive.x = 0;
			hunterButtonActive.y = chefButton.y + chefButton.height + 5;
			
			minerButton.x = 0;
			minerButton.y = hunterButton.y + hunterButton.height + 5;
			minerButtonActive.x = 0;
			minerButtonActive.y = hunterButton.y + hunterButton.height + 5;
			
			hireBttn.filters = [new DropShadowFilter(4.0, 90, 0, 0.5, 4.0, 4.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(hireBttn);
			
			switch(settings.fID)
			{
				case settings.craftData[0].fid:	
							chefButton.visible = false;
							chefButtonActive.visible = true;
							hunterButton.visible = true;
							hunterButtonActive.visible = false;
							minerButton.visible = true;
							minerButtonActive.visible = false;
							break;
				case settings.craftData[1].fid:	
							chefButton.visible = true;
							chefButtonActive.visible = false;
							hunterButton.visible = true;
							hunterButtonActive.visible = false;
							minerButton.visible = false;
							minerButtonActive.visible = true;
							break;
				case settings.craftData[2].fid:	
							chefButton.visible = true;
							chefButtonActive.visible = false;
							hunterButton.visible = false;
							hunterButtonActive.visible = true;
							minerButton.visible = true;
							minerButtonActive.visible = false;
							break;
			}
		}
		
		protected function onHire(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) {
				for (var i:int = 0; i < partList.length; i++ ) {
					partList[i].doPluck();
				}
				//requiresList.doPluck();				
				Hints.text(Locale.__e('flash:1382952379927') + "!", Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));//Нельзя!
				return;
			}
			e.currentTarget.state = Button.DISABLED;
			
			//trace(settings.fID);
			//trace("Рецепт выдает " + App.data.storage[App.data.crafting[settings.fID].out].title);
			//trace("Контроль " + App.data.storage[settings.sID].title);
			//trace("В этом домике хранится пацан c ID на карте " + settings.wID + ", и SID'ом " +  settings.wSID + ". То есть " + App.data.storage[settings.wSID].title);
			
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
				
				if (settings.returnCraft)
				{
					//if(RecipeWindow.rememberProduction)
						//new RecipeWindow(RecipeWindow.rememberProduction).show();
					if (RecipeWindow.rememberCraft)
					{
						new RecipeWindow(RecipeWindow.rememberCraft).show();
						RecipeWindow.rememberCraft = null;
					}
					//ShopWindow.findMaterialSource(settings.returnCraft, null, settings.returnBuildID);
				}
			});	
		}
		
		protected function onFirst(e:MouseEvent):void
		{
			//Povar
			settings.prodItem.recWin = new TechnoRecipeWindow( {
				title			:settings.title,
				fID				:settings.craftData[0].fid,
				busy			:false,
				hasDescription	:true,
				hasAnimations	:false,
				craftData		:settings.craftData,
				prodItem		:settings.prodItem,
				sID				:settings.craftData[0].sID,
				wID				:settings.wID,
				wSID			:settings.wSID,
				target			:settings.target,
				scaleW			:settings.scaleW
			});
			settings.prodItem.recWin.show();
			silentClose();
		}	
		
		protected function onSecond(e:MouseEvent):void
		{
			//Ahotnik
			settings.prodItem.recWin = new TechnoRecipeWindow( {
				title			:settings.title,
				fID				:settings.craftData[2].fid,
				busy			:false,
				hasDescription	:true,
				hasAnimations	:false,
				craftData		:settings.craftData,
				prodItem		:settings.prodItem,
				sID				:settings.craftData[2].sID,
				wID				:settings.wID,
				wSID			:settings.wSID,
				target			:settings.target,
				scaleW			:settings.scaleW
			});
			settings.prodItem.recWin.show();
			silentClose();
		}
		
		protected function onThird(e:MouseEvent):void{
			settings.prodItem.recWin = new TechnoRecipeWindow( {
				title			:settings.title,
				fID				:settings.craftData[1].fid,
				busy			:false,
				hasDescription	:true,
				hasAnimations	:false,
				craftData		:settings.craftData,
				prodItem		:settings.prodItem,
				sID				:settings.craftData[1].sID,
				wID				:settings.wID,
				wSID			:settings.wSID,
				target			:settings.target,
				scaleW			:settings.scaleW
			});
			settings.prodItem.recWin.show();
			silentClose();
		}	
		
		protected function drawTDesc():void
		{
			var title:TextField = Window.drawText(Locale.__e('flash:1382952380066'), { // заменить
				color:0xffffff,
				borderColor:0x7a4415,
				textAlign:"center",
				autoSize:"center",
				fontSize:30
			});
			var desc:TextField =  Window.drawText(App.data.storage[App.data.crafting[settings.fID].out].title, {
				color:0xf8c746,
				borderColor:0x7a4415,
				textAlign:"center",
				autoSize:"center",
				fontSize:34
			});
			
			bodyContainer.addChild(title);
			bodyContainer.addChild(desc);
			title.x = (settings.width - title.textWidth) / 2 - desc.textWidth;
			
			title.y = 80;
			title.width = 200;
			
			desc.x = title.x + title.textWidth + 10;
			desc.y = 77;
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
			requiresList = new RequiresList(requirements, false, { dontCheckTechno:true, separatorWidth: settings.width * 0.6 } );
			
			//icon.y = 160;
			
			bodyContainer.addChild(icon);
		}		
		
		private var offsetX:int = 200;
		private var offsetY:int = 0;
		private var outTechno:Bitmap;
		
		public static var technoIcon:LayerX;
		
		override protected function createItems(materials:Object):void
		{
			offsetX = 210;
			offsetY = 0;
			var dX:int = 0;			
			var pluses:Array = [];			
			var count:int = 0;
			
			for(var _sID:* in materials) 
			{
				if (App.data.storage[_sID].type == 'Techno')
					continue;
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
				inItem.width += 5;
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
			
			_equality = new Bitmap(Window.textures.equals);
			container.addChild(_equality);
			_equality.x = inItem.x + inItem.width;
			_equality.y = plus.y + 6;
			
			if (partList.length == 1)
			{
				inItem.x = offsetX - 175;
			}
			
			var firstPlus:Bitmap = pluses.shift();
			container.removeChild(firstPlus);
			
			//technoIcon = new LayerX();
			//container.addChild(technoIcon);
			
			
			
			bodyContainer.addChild(container);
			onUpdateOutMaterial();		
		}
		
		/*override public function change():void
		{
			outItem.flyMaterial();
			clear();
			bodyContainer.removeChild(outItem);
			contentChange();
		}*/
		
		override public function contentChange():void
		{		
			onUpdateOutMaterial();
		}
		
		private function onLoadOut(data:Bitmap):void
		{
			outTechno = new Bitmap();
			//technoIcon = new LayerX();
			outTechno.bitmapData = data.bitmapData;
			outTechno.smoothing = true;
			Size.size(outTechno, 200, 280);
			bodyContainer.addChild(outTechno);
			outTechno.x = settings.width - outTechno.width - 85;
			outTechno.y = settings.height - outTechno.height - 105;
			//container.addChild(technoIcon);				
			//technoIcon.x = _equality.x + _equality.width + 15;
			//technoIcon.y = container.height - technoIcon.height - 42;
		}
		private function onLoad(data:Bitmap):void
		{
			icon.bitmapData = data.bitmapData;
			icon.smoothing = true;
			Size.size(icon, 200, 280);
			//icon.scaleX = icon.scaleY = 0.9;
			icon.x = 60;
			icon.y = settings.height - icon.height - 105;
		}
		
		/*private function onLoad2(data:Bitmap):void
		{
			outTechno.bitmapData = data.bitmapData;
			outTechno.smoothing = true;			
			backgroundWidth = settings.width;			
			outTechno.scaleX = -0.8;
			outTechno.scaleY = 0.8;
			outTechno.x = offsetX + outTechno.width + 20;
			outTechno.y = 15;			
		}*/
		
		override public function findHelp():void 
		{
		}
		
		public override function close(e:MouseEvent = null):void {
			
			//if(settings.target.unFocus){
			if (fromElse)
			{
				//if (settings.returnCraft)
				//{
					//var sss:* = ShopWindow.findMaterialSource(settings.returnCraft, null, settings.returnBuildID);
				//}
				//unfocus(App.data.storage[App.data.crafting[settings.fID].out].sID /*settings.target*/);
			}else
			{
				unfocus( settings.target);
			}
			//}
			
			super.close();
		}		
		
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
			
			if (outState == MaterialItem.UNREADY) 
				hireBttn.state = Button.DISABLED;
			else if (outState != MaterialItem.UNREADY)
				hireBttn.state = Button.NORMAL;
			
			/*var openedSlots:int;
			openedSlots = settings.win.settings.target.openedSlots; //this
			if (settings.win.settings.target.queue.length >= openedSlots+1)
				hireBttn.state = Button.DISABLED;*/
			
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