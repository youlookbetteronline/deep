package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class SimpleConstructWindow extends ConstructWindow 
	{
		
		public function SimpleConstructWindow(settings:Object=null) 
		{
			settings["width"] = 420 || settings["width"];
			settings["height"] = 430;
			super(settings);
		}
		
		override public function drawBackground():void
		{
			if (resources.length > 2)
				settings["width"] = 420 + 176 * (resources.length - 2);
			var background:Bitmap = backing(settings.width, settings.height, 50, "paperWithBacking");
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			exit.y -= 10;
			exit.x += 10;
			drawBackImage();
			resizeBack();			
			level = settings.target.level + 1;
			totallevels = settings.target.totalLevels;
			
			var needTxt:TextField = Window.drawText(Locale.__e("flash:1382952380004", [level, totallevels]), {
				fontSize:34,
				color:0xffffff,
				borderColor:0x7f3d0e,
				textAlign:"center"
			});
			needTxt.width = needTxt.textWidth + 10;
			
			needTxt.x = (settings.width - needTxt.width) / 2;
			needTxt.y = 10;
			//drawBackgrounds()
			drawReward();
		
			bodyContainer.addChild(needTxt);	
			drawBttn();
			
			createResources();
			recNeedTxt();
			
			if (prices.length > 0)
				drawDescription();
			bodyContainer.addChildAt(container,numChildren - 1);	
			bttnContainer.y = settings.height - bttnContainer.height; 
			windowUpdate();
		}
		
		override public function drawTitle():void 
		{	
			if (resources.length > 2)
				settings["width"] = 420 + 165 * (resources.length - 2);
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xfaff78,
				multiline			: settings.multiline,			
				fontSize			: 32,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			var titleBackgr:Bitmap = Window.backingShort(titleLabel.width + 14, "titleBgNew");
			titleBackgr.x = (settings.width - titleBackgr.width)/2;
			titleBackgr.y = -7;
			headerContainer.addChild(titleBackgr);
			titleLabel.x = titleBackgr.x + (titleBackgr.width - titleLabel.width) * .5;
			titleLabel.y = titleBackgr.y + (titleBackgr.height - titleLabel.height) / 2;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		override public function createResources():void
		{
			var offsetX:int = 0;
			var offsetY:int = 0;
			var dX:int = 0;
			var count:int = 0;
			
			
			
			for each(var sID:* in resources) 
			{
				var inItem:MaterialItem = new MaterialItem({
					sID					:sID,
					need				:settings.request[sID],
					window				:this, 
					type				:MaterialItem.IN,
					mode				:MaterialItem.CONSTRUCT,
					background			:'banksBackingItem',
					color				:0x5a291c,
					borderColor			:0xfaf9ec,
					bitmapDY			:0,
					bitmapSize			:90
				});
				
				inItem.title.multiline = true;
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(inItem);
				container.addChild(inItem);
				
				count++;
				
				inItem.x = offsetX;
				inItem.y = offsetY;
				
				offsetX += inItem.background.width - inItem.background.x + 13;
			}
			container.x = 3 + (settings.width - container.width)/2;
			container.y = 95;
			findHelp();
			inItem.dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
		}
		
		override protected function recNeedTxt():void
		{
			needTxt = drawText(Locale.__e("flash:1433345292234"), {
				fontSize:30,
				color:0x7f3d0e,
				border:false
			});
			bodyContainer.addChild(needTxt);
			needTxt.width = needTxt.textWidth + 5;
			needTxt.height = needTxt.textHeight;
			needTxt.y = needTxt.height + 10;
			needTxt.x = (settings.width - needTxt.width) / 2;
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
			
			if (App.user.quests.tutorial)
			{
				if (App.user.quests.currentQID == 5)
				{
					QuestsRules.quest5_1();
				}
				
				if (App.user.quests.currentQID == 12)
				{
					if (QuestsRules.crill.level == 0)
						QuestsRules.quest12_2_1();
						
					if (QuestsRules.crill.level == 1)
						QuestsRules.quest12_2_2();
				}
			}
			
			if (upgBttn) 
			{
				upgBttn.removeEventListener(MouseEvent.CLICK, onUpgrade);
				upgBttn.dispose();
				upgBttn = null;
			}
			
			for (var i:int = 0; i < arrBttns.length; i++ ) 
			{
				var bttn:Button = arrBttns[i];
				if (bttn.order == 1) bttn.removeEventListener(MouseEvent.CLICK, showFantasy);
				else if (bttn.order == 2)bttn.removeEventListener(MouseEvent.CLICK, showBankCoins);
				else if (bttn.order == 3)bttn.removeEventListener(MouseEvent.CLICK, showBankReals);
				else if (bttn.order == 4)bttn.removeEventListener(MouseEvent.CLICK, showTechno);
				bttn.dispose();
				bttn = null;
			}
			arrBttns.splice(0, arrBttns.length);
	
			for (i = 0; i < partList.length; i++ ) 
			{
				var itm:MaterialItem = partList[i];
				if (itm.parent) 
					itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			super.dispose();
		}
		
	}
	
}