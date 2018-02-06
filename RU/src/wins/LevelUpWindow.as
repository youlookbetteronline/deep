package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Numbers;
	import core.Post;
	import core.WallPost;
	import effects.Particles;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import effects.Particles;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import strings.Strings;
	import ui.UserInterface;
	import units.Hero;
	import units.Unit;
	import units.WaterFloat;
	import utils.Effects;
	
	public class LevelUpWindow extends Window
	{
		public static const USUAL_LEVEL:uint = 1;
		public static const KEY_LEVEL:uint = 2;
		public static const NEXT_LEVEL:uint = 3;
		public var items:Array = new Array();
		public var label:Bitmap;
		public var tellBttn:Button;
		public var bg:Bitmap;
		public var screen:Bitmap;
		public var okBttn:Button;
		public var openTxt:TextField;
		public var background:Bitmap;
		public var bgHeight:int;
		
		
		public var checkBox:CheckboxButton;
		public var mode:uint = 1;
		public var viewLevel:int = 1;
		public var nextLevel:int = 1;
		public static var keyLevels:Object;
		public function LevelUpWindow(settings:Object = null):void
		{
			setKeyLevels();
			mode = USUAL_LEVEL;
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 500;
			settings['height'] = 410;			
			settings['hasTitle'] = false;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['itemsOnPage'] = 3;
			settings['priority'] = 30;			
			settings['escExit'] = false;
			settings['faderClickable'] = false;
			settings["hasBubbles"] = true;
			settings["bubblesCount"] = 10;
			
			viewLevel = settings.forceLevel ? settings.forceLevel : App.user.level;
			
			for each(var k:* in keyLevels.levelList) {
				if (int(k) > App.user.level) {
					nextLevel = int(k);
					break;
				}
			}
			
			if (settings.nextKeyLevel) {
				viewLevel = nextLevel;
			}else {
				if (keyLevels.levelList.indexOf(viewLevel) != -1) {
					mode = KEY_LEVEL;
				}
			}
			
			settings['bonus'] = App.data.levels[viewLevel].bonus;
			settings['content'] = [];
			settings['openSound'] = 'sound_7';			
			
			if (mode == KEY_LEVEL) 
			{
				for (var ls:* in keyLevels[App.user.level].bonus) {
					var blInfo:Object = { };
					blInfo[int(ls)] = keyLevels[App.user.level].bonus[ls];
					settings.content.push(blInfo);
				}
			}else 
			{				
				var contentLevel:int = settings.currentLevel ? viewLevel:nextLevel;
				for (var s:* in keyLevels[contentLevel].bonus) {
					var bInfo:Object = { };
					bInfo[int(s)] = keyLevels[contentLevel].bonus[s];
					settings.content.push(bInfo);
				}					
			}			
			
			if (settings.nextKeyLevel) mode = NEXT_LEVEL;
			
			super(settings);
		}
		
		private function setKeyLevels():void {
			if (!keyLevels) 
			{
				keyLevels = {levelList:[] };
				for (var lvID:* in App.data.levels)
				{
					var bonusData:Object = App.data.levels[lvID].bonus;
					if (bonusData && bonusData.hasOwnProperty(Stock.FANT) && bonusData[Stock.FANT] >= 2)
					{
						keyLevels['levelList'].push(int(lvID));
						keyLevels[lvID] = {bonus:Numbers.copyObject(bonusData),extra:Numbers.copyObject(App.data.levels[lvID].extra)}
					}
				}
			}
		}
		
		override public function show():void {
			if(!App.user.quests.tutorial)
				super.show();
			initBox();
		}
		
		//private var background:Bitmap;
		override public function drawBackground():void {
			
		}
		
		override public function drawArrows():void 
		{	
			if(paginator.pages > 1){
				paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -0.6, scaleY:0.6 } );
				paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:0.6, scaleY:0.6 } );
				
				var y:Number = (settings.height - paginator.arrowLeft.height) / 2;
				paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 44;
				paginator.arrowLeft.y = 218;
				
				paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 24;
				paginator.arrowRight.y = 218;
			}
			
		}
		
		
		override public function drawBody():void {
			exit.visible = false;
			
			bgHeight = settings.height;
			switch(mode) {
				case NEXT_LEVEL://По клику на бар
					//bgHeight = 260;
					this.y += 80;
					fader.y -= 80;
					bgHeight -= 80;
				break;
				case USUAL_LEVEL://Обычный левелап
					this.y += 80;
					fader.y -= 80;
					bgHeight -= 40;
				break;
				case KEY_LEVEL://Ключевой левелап
					this.y += 80;
					fader.y -= 80;
					bgHeight -= 40;
				break;
			}
			
			var octopusBack:Bitmap = new Bitmap(Window.textures.levelUpBackingOctopusFish);
			layer.addChildAt(octopusBack, 0);
			octopusBack.x = - 50;
			octopusBack.y = -octopusBack.height / 2 - 5;
			
			background = backing2(settings.width, bgHeight, 80, 'levelUpBackingUp', 'levelUpBackingBot');
			layer.addChildAt(background, 1);
			
			var paperBack:Bitmap = backing(400, bgHeight - 112, 40, 'paperClear');
			layer.addChildAt(paperBack, 2);
			paperBack.x = (settings.width - paperBack.width) / 2;
			paperBack.y = 50;
			
			var levelCrab:Bitmap = new Bitmap(Window.textures.levelUpCrab);
			layer.addChild(levelCrab);
			levelCrab.x = 35;
			levelCrab.y = bgHeight - levelCrab.height;
			
			var tentacle1:Bitmap = new Bitmap(Window.textures.tentacle3);
			bodyContainer.addChild(tentacle1);
			tentacle1.x = -42;
			tentacle1.y = 65;
			
			var tentacle2:Bitmap = new Bitmap(Window.textures.tentacle4);
			bodyContainer.addChild(tentacle2);
			tentacle2.x = -42;
			tentacle2.y = 175;
			
			var fish1:Bitmap = new Bitmap(Window.textures.decFish1);
			fish1.scaleX =-fish1.scaleX;
			fish1.x = settings.width + 30;
			fish1.y = - 10;
			
			var fish2:Bitmap = new Bitmap(Window.textures.decFish2);
			fish2.x = settings.width - 85;
			fish2.y = -85;
			
			layer.addChildAt(fish1, 0);
			layer.addChild(fish2);	
			
			var rewLabel:TextField = Window.drawText(Locale.__e('flash:1382952380000'), {
				width:376,
				fontSize:34,
				color:0xfdfeec, 
				borderColor:0x235a82,
				textAlign:'center'
			});
			bodyContainer.addChild(rewLabel);
			rewLabel.x = (settings.width - rewLabel.width) / 2;
			rewLabel.y = 60;
			
			paginator.itemsCount = Numbers.countProps(settings.bonus);
			paginator.update();
			
			drawBonusInfo();
			drawLevelInfo();
			okBttn = new Button( {
				borderColor:			[0xfeee7b,0xb27a1a],
				fontColor:				0xffffff,
				fontBorderColor:		0x814f31,
				bgColor:				[0xf5d159, 0xedb130],
				width:162,
				height:50,
				fontSize:32,
				hasDotes:false,
				caption:Locale.__e("flash:1393581174933")
			});
			bodyContainer.addChild(okBttn);
			
			okBttn.addEventListener(MouseEvent.CLICK, onTellBttn);
			
			okBttn.x = (settings.width - okBttn.width)/2;
			okBttn.y = bgHeight - okBttn.height + 16;
			okBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			
			if (mode != NEXT_LEVEL) 
			{
				checkBox = new CheckboxButton({
					multiline				:false,
					wordWrap				:false,
					//width					:145,
					fontSize				:22,
					fontSizeUnceked			:22
				});
				
				if (!App.isSocial('SP','AM')) 
				{
					bodyContainer.addChild(checkBox);
				}	
				checkBox.x = okBttn.x + (okBttn.width - checkBox.width) / 2;
				checkBox.y = okBttn.y - checkBox.height - 45;
			}
			
			
			if(App.user.quests.tutorial){
				checkBox.checked = CheckboxButton.UNCHECKED;
				okBttn.showGlowing();
				okBttn.showPointing('right', 0,0, bodyContainer);	
			}
			//contentChange();
			
			
			var that:LevelUpWindow = this;
			var time:int = 150;			
			var cnt:* = layer;			
			var extra:ExtraItem;
			if (App.data.levels[viewLevel].extra) {
				extra = new ExtraItem(this);
				bodyContainer.addChild(extra);
				extra.x = settings.width - extra.bg.width/2;
				extra.y = background.height - bodyContainer.y - extra.bg.height + 72;
			}
			/*if (settings.nextKeyLevel) {
				if (checkBox) {
					checkBox.checked = CheckboxButton.UNCHECKED;
					checkBox.state = Button.DISABLED;
					checkBox.visible = false;
				}
				if (extra) {
					extra.visible = false;
				}
			}*/
			
			if (mode != NEXT_LEVEL) 
			{
				Effects.confeti(layer, time,{});
				
				//intervalEff = setInterval(function():void 
				//{
					//var particle:Particles = new Particles();
					//particle.init(layer, new Point(coordsEff[countEff].x, coordsEff[countEff].y));
					//countEff++;
					//if (countEff == 12)
						//clearInterval(intervalEff);
				//},time);
				
			}			
		}
		
		private function onTellBttn(e:MouseEvent):void
		{
			if (mode == NEXT_LEVEL) 
			{
				close();
				return;
			}
			
			if (checkBox.checked == CheckboxButton.CHECKED)
			{
				WallPost.makePost(WallPost.LEVEL, {btm:screen, callBack:getExtraBonus});
			}
			
			App.user.updateActions();
			App.user.checkOpenNew();
			
			bonusList.take();
			close();
		}
		
		private function getExtraBonus(result:* = null):void 
		{
			//return;
			/*if (App.isSocial("MM", "MX", "YN")) {
				return;
			}*/
			
			Post.addToArchive('\n getExtraBonus: ' + JSON.stringify(result));
			
			if (/*App.social == 'VK' &&*/ !(result != null && result.hasOwnProperty('post_id')) && !App.isSocial('OK', 'FS'))
				return;
			if (App.social == 'MM' && !result.hasOwnProperty('post_id'))
				return;
				
			Post.send({
				'ctr':'user',
				'act':'viral',
				'uID':App.user.id,
				'type':'tell'
			}, function(error:*, data:*, params:*):void {
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				
				var rewData:Object = { };
				rewData['character'] = 1;
				rewData['title'] = Locale.__e('flash:1406554650287');
				rewData['description'] = Locale.__e('ffff');
				rewData['bonus'] = { };
				rewData['bonus']['materials'] = data.bonus;
				
				new QuestRewardWindow( {
					quest:rewData,
					levelRew:true,
					strong:true,
					callback:function():void{}
				}).show();
				if (!User.inExpedition) 
				{
					App.user.stock.addAll(data.bonus);
					
				}
				var matSID:int;
				for (var mater:* in data.bonus)
				{
					matSID = mater;
					break;
				}
				if (matSID == Stock.FANT)
					Treasures.wauEffect(matSID, true);	
					
				
			});
			
			return;
		}
		
		/*override public function close(e:MouseEvent = null):void 
		{
			super.close(e);
			if (App.user.level == 10);
			
		}*/
		
		public var contentSprite:Sprite = new Sprite();
		override public function contentChange():void {
			
			/*if (!contentSprite.parent) {
				
				bodyContainer.addChild(contentSprite);
				//contentSprite.addChild(backing(350, 150, 80, "backingPaginator"));
				
				var rewLabel:TextField;
				var rewText:String;
				var rewLabelSettings:Object;
				if (mode == NEXT_LEVEL) {
					rewText = Locale.__e('flash:1382952380000');//Награда
					rewLabelSettings = {
						width:376,
						fontSize:28,
						color:0xfdfeec, 
						borderColor:0x235a82,
						textAlign:'center'
					}
				}
				if(mode == USUAL_LEVEL){
					rewText = Locale.__e('flash:1471955139458', [String(nextLevel)] + ":");//Награда на %s уровне
					rewLabelSettings = {
						width:376,
						fontSize:27,
						color:0xfdfeec, 
						borderColor:0x235a82,
						textAlign:'center'
					}
				}
				if (mode == KEY_LEVEL) {
					rewText = Locale.__e('flash:1382952380000');//Награда
					rewLabelSettings = {
						width:376,
						fontSize:30,
						color:0xfdfeec, 
						borderColor:0x235a82,
						textAlign:'center'
					}
				}
				rewLabel = drawText(rewText, rewLabelSettings);
				rewLabel.y = -rewLabel.height / 2;
				rewLabel.x -= 12;
				contentSprite.addChild(rewLabel);
				//addMirrowObjs(contentSprite, 'diamondsTop', (rewLabel.width - rewLabel.textWidth) / 2 - textures.diamondsTop.width - 13, (rewLabel.width - rewLabel.textWidth) / 2 + rewLabel.textWidth + textures.diamondsTop.width - 10, rewLabel.y + (rewLabel.textHeight - textures.diamondsTop.height) / 2);
			}
			
			for each(var _item:* in items) {
				contentSprite.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				var item:OpenedItem = new OpenedItem(settings.content[i], this);
				contentSprite.addChild(item);
				items.push(item);
				var allX:int = (376 - (paginator.finishCount - paginator.startCount) * 115) / 2;
				item.x = (i - paginator.startCount) * 110 + allX + 0;
				item.y = 17;
			}
			
			contentSprite.x = (settings.width - contentSprite.width) / 2 + 10;
			contentSprite.y = (mode != USUAL_LEVEL ? 50 : 150);//Контейнер с наградой ключевого
			
			if (mode == NEXT_LEVEL) {
				contentSprite.y += 23;
			}
			
			if (mode == KEY_LEVEL) {
				contentSprite.y += 30;
			}*/
		}
		
		private var bonusList:CollectionBonusList;
		public var rewardSprite:Sprite = new Sprite();
		private function drawBonusInfo():void
		{
			var ssz:* = Numbers.getProp(settings.bonus, 1);
			var ssd:* = Numbers.getProp(settings.bonus, 0);
			var reward:Object = new Object();
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				reward = new Object();
				reward[Numbers.getProp(settings.bonus, i).key] =  Numbers.getProp(settings.bonus, i).val;
				var item:OpenedItem = new OpenedItem(reward, this);
				rewardSprite.addChild(item);
				items.push(item);
				var allX:int = (376 - (paginator.finishCount - paginator.startCount) * 115) / 2;
				item.x = (i - paginator.startCount) * 110 + /*allX*/ + 0;
				item.y = 17;
			}
			bodyContainer.addChild(rewardSprite);
			rewardSprite.x = (settings.width - rewardSprite.width) / 2  /*- rewardSprite.width/2*/;
			rewardSprite.y = (100);//Контейнер с наградой ключевого
			
			bonusList = new CollectionBonusList(settings.bonus, false, {borderSize: 2, iconBacking: false});		
			//bonusList = new RewardList(settings.bonus, true, 384, Locale.__e("flash:1382952380000"), 0.4, 30, 30, 65, "", 0.95);
			//bonusList.itemsSprite.y += 5;
			//bonusList.visible = (mode == USUAL_LEVEL);
			//bodyContainer.addChild(bonusList);
			//bonusList.x = (settings.width - bonusList.width) / 2 - 50;
			//bonusList.y = 60;//Бонуслист с наградой за текущий вместе с подложкой
			
			/*var bonusListBacking:Bitmap = Window.backingShort(bonusList.width + 80, 'backingGrad', true);
			bonusListBacking.scaleY = 1;
			bonusListBacking.alpha = .7;
			bonusListBacking.smoothing = true;
			bonusListBacking.x = bonusList.x + (bonusList.width - bonusListBacking.width) / 2 + 50;
			bonusListBacking.y = bonusList.y + (bonusList.height - bonusListBacking.height) / 2 + 17;
			
			bodyContainer.addChild(bonusListBacking);*/
			//bodyContainer.swapChildren(bonusListBacking, bonusList);
		}
		
		public var labelHeader:Bitmap;
		private function drawLevelInfo():void
		{
			var sprite:Sprite = new Sprite();
			var wSprite:Sprite = new Sprite();
			
			label = new Bitmap(Window.textures.levelUp);
			sprite.addChild(label);
			/*labelHeader = new Bitmap(UserInterface.textures.expIco);
			labelHeader.x = 235;
			labelHeader.y = 155;
			sprite.addChild(labelHeader);*/
			sprite.x = settings.width / 2 - label.width / 2;
			sprite.y = - 214;
			
			bodyContainer.addChild(sprite);
			
			var textSettings:Object = 
			{
				//title			:String(viewLevel),
				fontSize		:24,
				color			:0xfbff99,
				width 			:110,
				borderColor		:0xcf4603,
				borderSize		:3,
				fontBorderGlow	:4
				
			}
			
			var levelText:TextField = Window.drawText(Locale.__e("flash:1393581217883"), {
				fontSize		:45,
				color			:0xf9ff64,
				borderColor		:0x7f3d0e,
				borderSize		:3,
				fontBorderSize	:1
			});
			levelText.width = levelText.textWidth +5;
			levelText.height = levelText.textHeight;
			levelText.x = (sprite.width - levelText.width ) / 2 -5;
			levelText.y = 143;
			
			//levelText.filters = [new DropShadowFilter(2.0, 225, 0, 0.8, 2.0, 2.0, 1.0, 3, true, false, false)];
			//levelText.filters = [new DropShadowFilter(4.0, 45, 0x44ddcd, 0.8, 4.0, 4.0, 1.0, 3, false, false, false), new DropShadowFilter(2.0, 225, 0, 0.8, 2.0, 2.0, 1.0, 3, true, false, false)];
			sprite.addChild(levelText);
				
			textSettings.fontSize = 50;
			textSettings['textAlign'] = 'center';
			
			//var leveleTitle:Sprite = titleText(textSettings);	
			var leveleTitle:TextField = Window.drawText(String(viewLevel), textSettings);
			leveleTitle.x = (sprite.width - leveleTitle.width)/2 + 2;
			leveleTitle.y = 25 + (sprite.height - leveleTitle.width) / 2;
			//leveleTitle.filters = [new DropShadowFilter(2.0, 45, 0, 0.8, 2.0, 2.0, 1.0, 3, true, false, false)];
			
			sprite.addChild(leveleTitle);
			
			/*if (mode == NEXT_LEVEL) 
			{
				levelText.width += 200;
				levelText.text = Locale.__e("flash:1471955207243");//Следующий ключевой уровень!
				leveleTitle.x = (sprite.width - leveleTitle.width) / 2 - 15;
				levelText.x -= 85;
			}*/
			var wPost:Bitmap = new Bitmap(Window.textures.newLvl);
			wSprite.addChild(wPost);
			
			textSettings.fontSize = 80;
			var levelPTitle:TextField = Window.drawText(String(viewLevel), textSettings);
			levelPTitle.x = (wPost.width - levelPTitle.width)/2 + 2;
			levelPTitle.y = -20 + (wPost.height - levelPTitle.width) / 2;
			wSprite.addChild(levelPTitle);
			
			//bodyContainer.addChild(wSprite);
			
			screen = new Bitmap(new BitmapData(wSprite.width, wSprite.height));
			screen.bitmapData.draw(wSprite);			
		}
		
		override public function dispose():void
		{	
			super.dispose();
			//animBox();
			//buyBox();
		}
		
		
		
		private function initBox():void
		{
			for (var lvl:* in App.data.levels)
			{
				if (App.data.levels[lvl].hasOwnProperty('box') && App.data.levels[lvl].box && App.data.levels[lvl].box.sID != '' && lvl == App.user.level)
				{
					if (App.user.worldID == User.LAND_1)
						animBox(App.data.levels[lvl].box.sID, {x:App.data.levels[lvl].box.x, z:App.data.levels[lvl].box.z});
					else
						buyBox(App.data.levels[lvl].box.sID, {x:App.data.levels[lvl].box.x, z:App.data.levels[lvl].box.z});
				}
			}
		}
		private function buyBox(sid:int, coords:Object):void
		{
			var postObject:Object = {
				ctr:App.data.storage[sid].type,
				act:'buy',
				uID:App.user.id,
				wID:4,
				sID:sid,
				x:coords.x,
				z:coords.z
			}
			Post.send(postObject, function():void{});
			new CongratultaionWindow({
				search: sid
			}).show();
		}
		
		private function animBox(sid:int, coordss:Object):void
		{
			//var coords:Object = App.user.hero.findPlaceNearTarget(App.user.hero., 5);
			//var target:Unit = Map.findUnits([500]).shift();
			//var place:Object = App.user.hero.findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:target.coords.x, z:target.coords.z}}, 20);
			var box:Unit = Unit.add({
				sid:sid,
				x:coordss.x,
				z:coordss.z
			});
			box.y -= 600;
			TweenLite.to(box, 7, { x:box.x, y:box.y + 600, scaleX: 1, scaleY: 1, alpha: 1, onComplete: function():void{
				box.buyAction();
				box.take();
				box.showPointing('top', -35, -30);
				box.startBlink();
				setTimeout(function():void 
				{
					box.hidePointing();
					box.stopBlink();
				}, 7000);
			}});
			new CongratultaionWindow({
				search: sid,
				popup:	true
			}).show();
		}
	}
}

import core.BDTransformer;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import wins.Window;

internal class OpenedItem extends LayerX
{
	public var bg:Bitmap = Window.backing(104, 124, 30, "banksBackingItem");
	public var sID:uint;
	public var count:uint;
	public var bitmap:Bitmap = new Bitmap();
	public var window:*;
	private var preloader:Preloader = new Preloader();
	
	public function OpenedItem(bData:Object, window:*)
	{
		for (var i:* in bData) {
			this.sID = i;
			this.count = bData[i];
			break;
		}
		this.window = window;
		var backBitmap:Bitmap = Window.backing(105, 130, 35, 'levelUpItemBacking');//Подложка под айтемами из ключевого
		backBitmap.filters = [new GlowFilter(0xb8946c, .7, 4, 4, 10)]; 
		addChild(backBitmap);
		addChild(bitmap);
		drawTitle();
		drawCount();
		addChild(preloader);
		Size.size(preloader, 75, 75);
		preloader.x = backBitmap.x + (backBitmap.width - preloader.width) / 2 + 36;
		preloader.y = backBitmap.y + (backBitmap.height - preloader.height) / 2 + 40;
		tip = function():Object {
			var item:Object = App.data.storage[sID];
			return { title:item.title,
					text:item.description};
		}
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
	}
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		bitmap.bitmapData = BDTransformer.fitIn(data.bitmapData, 73, 81);
		bitmap.x = (bg.width - bitmap.width) / 2 + 3;
		bitmap.y = (bg.height - bitmap.height) / 2 + 5;
		bitmap.scaleX = bitmap.scaleY = 0.9;
		bitmap.smoothing = true;
	}
	
	private function drawTitle():void
	{
		var title:TextField = Window.drawText(App.data.storage[sID].title, {
			color:0x814f31,
			textLeading: -5,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:18,
			multiline:true
		});
		
		title.wordWrap = true;
		title.width = bg.width;
		title.y = 6;
		title.x = -2;
		addChild(title);
	}
	
	private function drawCount():void
	{
		var countLabel:TextField = Window.drawText('x' + String(this.count), {
			color:0x814f31,
			width:bg.width,
			textLeading: -5,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:18,
			multiline:true
		});
		
		countLabel.y = bg.height - countLabel.height - 10;
		countLabel.x -= 15;
		addChild(countLabel);
	}
}

import wins.CollectionBonusList;
import wins.ExtraBonusList;


internal class ExtraItem extends Sprite
{
	public var extra:Object;
	public var bg:Bitmap;
	private var title:TextField;
	private var extraReward:ExtraBonusList;
	
	public function ExtraItem(window:*) 
	{
		extra = App.data.levels[App.user.level].extra;
		drawReward();
		
		bg = Window.backing((extraReward.width < 150) ? 200 : extraReward.width + 50, 130, 50, "tipUp");
		addChild(bg);
		swapChildren(bg, extraReward);
		extraReward.x = bg.x + (bg.width - extraReward.width) / 2 - 10;
		drawTitle();
		
	}
	
	private function drawTitle():void 
	{
		title = Window.drawText(Locale.__e("flash:1428049916402"), {
			fontSize	:18,
			color		:0xffffff,
			borderColor	:0x673a1f,
			textAlign   :'center',
			borderSize 	:2,
			multiline   :true,
			wrap        :true
		});
		//title.border = true;
		title.width = bg.width - 50;
		title.x = bg.x + (bg.width - title.width) / 2;
		title.y = bg.y + 14;
		extraReward.y = title.y + title.textHeight - 12;
		addChild(title);
	}
	
	private function drawReward():void 
	{
		//var reward:RewardList = new RewardList(extra, false, 0, '', 1, 44, 16, 40, "x", 0.6, -3, 7);
		extraReward = new ExtraBonusList(extra, false);
		
		addChild(extraReward);
		extraReward.x = 15;
		
		
		/*var icon:Bitmap = new Bitmap(Window.textures.viralAborigine);
		addChild(icon);
		icon.x = 140;
		icon.y = -58;*/
	}
}
