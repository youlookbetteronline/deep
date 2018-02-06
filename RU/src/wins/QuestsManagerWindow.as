package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.UpgradeButton;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.QuestIcon;
	import ui.QuestsChaptersIcon;
	
	public class QuestsManagerWindow extends Window
	{
		private var time:int = 0;
		
		public var background:Bitmap;
		public var bttnBackToChapters:Button;
		public var chapterCharacter:Bitmap;
		public var chapterDescTextLabel:TextField;
		public var bonusList:BonusList;
		public var currentQuests:Array = [];
		public var sections:Object = new Object();
		public var items:Vector.<QuestIcon> = new Vector.<QuestIcon>();
		public var questType:String;
		public var backIcon:Shape = new Shape();
		public var rewardTextLabel:TextField;
		
		public function QuestsManagerWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			//App.data;
			//App.user;
			
			settings['width'] = 720;
			settings['height'] = 180;			
			settings['hasTitle'] = true;
			settings['hasButtons'] = true;
			settings['hasPaginator'] = true;
			settings['callback'] = settings.callback || null;	
			settings['find'] = settings.find || null;			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;			
			settings['popup'] = true;
			settings['questID'] = settings.questID;
			settings['updatePreview'] = settings.updatePreview;
			settings['pesonage'] = settings.personage;
			settings['questTitle'] = settings.questTitle;
			settings['questDescription'] = settings.questDescription;
			settings['questBonus'] = settings.questBonus;
			settings["itemsOnPage"] = 6;
			settings["openedQuests"] = settings.openedQuests;
			settings["closedQuests"] = settings.closedQuests;
			settings["hasButtons"] = false;
			settings["hasExit"] = false;
			
			super(settings);
			
			createContent();
		}
		
		override public function close(e:MouseEvent = null):void {
			clearTimeout(time);
			settings.chapterItem.findArray = null;
			settings.chapterItem.window.settings.find = [];
			for each(var _item:QuestIcon in items) {
				_item.dispose();
			}
			super.close();
		}		
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 62, 'questsManagerBackingTop', 'questsManagerBackingBot', 0, -1);
			
			layer.addChild(background);			
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.questTitle,
				color				: 0xffdf34,
				multiline			: settings.multiline,
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x7e3e13,			
				borderSize 			: settings.fontBorderSize,						
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = ((settings.width - titleLabel.width) * .5);
			titleLabel.y = -20;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			bodyContainer.addChild(titleLabel);
			//headerContainer.y = -10;
			//headerContainer.mouseEnabled = false;
		}
		
		
		override public function drawBody():void 
		{
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 + 120, settings.width / 2 + settings.titleWidth / 2 + 120, -40, true, true);
			drawBackground();
			drawBttns();
			
			bttnBackToChapters.addEventListener(MouseEvent.CLICK, close);
			//item
			chapterCharacter = new Bitmap();
			Load.loading(Config.getImageIcon('updates/icons', settings.updatePreview,'jpg'),
				function(data:Bitmap):void {
					chapterCharacter.bitmapData = data.bitmapData;
					
					chapterCharacter.x = background.x - chapterCharacter.width + 30;
					chapterCharacter.y = (background.y - (chapterCharacter.height / 2)) + 130;
					//layer.addChild(chapterCharacter);	
				}
			);	
			/*switch (settings.personage) 
			{
				case 3:
					chapterCharacter = new Bitmap(Window.textures.goalsCharGirl, "auto", true);
				break;
				case 4:
					chapterCharacter = new Bitmap(Window.textures.goalsCharBoy, "auto", true);
				break;
				case 6:
					chapterCharacter = new Bitmap(Window.textures.goalsCharSpirit, "auto", true);
				break;
				case 2:
					chapterCharacter = new Bitmap(Window.textures.goalsCharProf, "auto", true);
				break;
				case 1:
					chapterCharacter = new Bitmap(Window.textures.goalsCharChief, "auto", true);
				break;
				case 8:
					chapterCharacter = new Bitmap(Window.textures.goalsCharZikimus, "auto", true);
				break;	
				case 10:
					chapterCharacter = new Bitmap(Window.textures.goalsCharShaman, "auto", true);
				break;	
				case 11:
					chapterCharacter = new Bitmap(Window.textures.goalsCharZikimund, "auto", true);
				break;
				default:
					chapterCharacter = new Bitmap(Window.textures.goalsCharSpirit, "auto", true);
				break
			}*/
					
			
			//bonusList = new BonusList(settings.questBonus, true, { hasTitle: false});
			//layer.addChild(bonusList);
			//bonusList.x = background.x + (background.width / 2) - (bonusList.width / 2);
			//bonusList.y = (background.y + (background.height / 2) - (bonusList.height / 2)) + 5;
			
			//rewardTextLabel = Window.drawText(Locale.__e('flash:1382952380000'), {
				//width		:280,
				//fontSize	:25,
				//textAlign	:"left",
				//color:0xffffff,
				//borderColor:0x643a00,
				//multiline	:true,
				//wrap		:true
			//});
			//
			//layer.addChild(rewardTextLabel);
			//rewardTextLabel.x = bonusList.x + bonusList.width - (rewardTextLabel.width / 2);
			//rewardTextLabel.y = bonusList.y - 20;
			
			chapterDescTextLabel = Window.drawText(settings.questDescription, {
				width		:420,
				fontSize	:22,
				textAlign	:"center",
				color		:0x743f17,
				borderColor	:0xffffff,
				multiline	:true,
				wrap		:true
			});
			
			//layer.addChild(chapterDescTextLabel);
			chapterDescTextLabel.x = background.x + (background.width - chapterDescTextLabel.width) / 2;
			chapterDescTextLabel.y = (titleLabel.y + titleLabel.height);
			chapterDescTextLabel.visible = true;
			
			backIcon.graphics.beginFill(0xf0e9e0);
		    backIcon.graphics.drawRect(0, 0, settings.width - 100, settings.height - 50);
			backIcon.y = 27;
			backIcon.x = (settings.width - backIcon.width) / 2;
		    backIcon.graphics.endFill();
			backIcon.filters = [new BlurFilter(40, 0, 2)];
		    layer.addChild(backIcon);
			
			findActiveOnPage();
			
			contentChange();
			if (settings.find)
				findQuest(settings.find);
		}
		
		private function drawBttns():void {
			
			bttnBackToChapters = new Button( {
				caption			:Locale.__e("flash:1446190749867"),//Назад
				width			:150,
				height			:48,
				borderColor:	[0xfed031,0xf8ac1b],
				fontBorderColor	:0x7f3d0e,
				countText		:"",
				fontSize		:32,
				radius			:20,
				textAlign		:'left',
				autoSize		:'left'
			});
			bttnBackToChapters.textLabel.x = (bttnBackToChapters.width - bttnBackToChapters.textLabel.width)/2;
			bttnBackToChapters.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			layer.addChild(bttnBackToChapters);
			
			bttnBackToChapters.x = background.x + (background.width - bttnBackToChapters.width) / 2;
			bttnBackToChapters.y = (background.y + background.height - (bttnBackToChapters.height / 2)) + 5;
		}
		
		private function onBackToChapters (e:Event = null):void 
		{
			close();
		}	
		
		public function createContent():void {
			
			if (sections["all"] != null) return;
			
			sections = {				
				"all"		:{items:new Array(),page:0}
			};
			
			for (var fID:* in settings.finishedQuests) {
				settings.finishedQuests[fID].id = settings.finishedQuests[fID].ID;
				settings.finishedQuests[fID].questType = 'finished';
				if (settings.finishedQuests[fID].type == 0) 
				{
					settings.content.push(settings.finishedQuests[fID]);
					sections["all"].items.push(settings.finishedQuests[fID]);
				}			
			}
			
			for (var ID:* in settings.openedQuests) {
				settings.openedQuests[ID].id = settings.openedQuests[ID].ID;
				settings.openedQuests[ID].questType = 'opened';
				if (settings.openedQuests[ID].type == 0) 
				{
					settings.content.push(settings.openedQuests[ID]);
					sections["all"].items.push(settings.openedQuests[ID]);
				}				
			}
			
			for (var cID:* in settings.closedQuests) {
				settings.closedQuests[cID].id = settings.closedQuests[cID].ID;
				settings.closedQuests[cID].questType = 'closed';
				if (settings.closedQuests[cID].type == 0) 
				{
					settings.content.push(settings.closedQuests[cID]);
					sections["all"].items.push(settings.closedQuests[cID]);
				}			
			}			
		}
		
		public function findQuest(_quests:Array):void 
		{
			for (var itm:* in settings.content)
			{
				if (_quests.indexOf(settings.content[itm].id) != -1)
				{
					paginator.page = itm / paginator.onPageCount;
					paginator.update();
					contentChange();
					break;
				}
			}
			for each(var _itm:* in items)
			{
				if (_quests.indexOf(_itm.qID) != -1){
					_itm.showPointing("top", 0, 0, _itm.parent);
					_itm.showGlowingOnce();
					//_itm.showGlowing();
					time = setTimeout(_itm.clear, 5000);
				}
			}
		}
		
		public function findActiveOnPage():void 
		{
			for (var itm:* in settings.content)
			{
				if (settings.content[itm].questType == 'opened')
				{
					paginator.page = itm / paginator.onPageCount;
					paginator.update();
					break;
				}
			}
		}
		override public function contentChange():void {
			
			for each(var _item:QuestIcon in items) {
				_item.dispose();
				//bodyContainer.removeChild(_item);
				//_item = null;
			}
			
			items = new Vector.<QuestIcon>();
			var Xs:int = 80;
		
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{				
				var item:QuestsChaptersIcon = new QuestsChaptersIcon(settings.content[i], 0, settings.content[i].questType);				
				bodyContainer.addChild(item);
				items.push(item);
				
				item.y = 66;
				item.x = Xs + 20;
				Xs += 90;
			}
			
			sections["all"].page = paginator.page;
			settings.page = paginator.page;
		}
		
		override public function drawArrows():void 
		{			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 46;
			paginator.arrowLeft.x = 40;
			paginator.arrowLeft.y = y - 40;
			
			paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 20;
			paginator.arrowRight.y = y - 40;
			
			paginator.x = int((settings.width - paginator.width)/2 - 20);
			paginator.y = int(settings.height - paginator.height + 40);
		}
	}
}