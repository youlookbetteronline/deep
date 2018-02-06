package wins 
{
	import buttons.CheckboxButton;
	import core.IsoConvert;
	import core.Post;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class TutorialRewardWindow  extends LevelUpWindow
	{
		
		public var rewardTut:Object;
		public function TutorialRewardWindow(settings:Object = null) 
		{
			if (settings) 
			{
				settings['hasPaginator'] = false;	
			}
		
			//settings.hasExit = false;
			super(settings);
		}
			
		
		override protected function addOpenTxt():void 
		{
			var font:int = 28;
			do{
			openTxt = Window.drawText(Locale.__e("flash:1421762046389"), {
					fontSize	:font,
					color		:0x4f3001,
					borderColor	:0xfffbc9,
					width: 360,
					//height:80,
					multiline: true,
					wrap: true,
					autoSize: 'center',
					textAlign: 'center'
					
					
				});
				openTxt.width = openTxt.textWidth+5;
				openTxt.height = openTxt.textHeight;
				openTxt.x = settings.width/2 - openTxt.width/2 + 4;
				openTxt.y = 92 - openTxt.textHeight / 2;
				font--;
				}
				while(openTxt.textHeight>90)
				bodyContainer.addChild(openTxt);
			
		}
		
		override protected function onFaderClick(e:MouseEvent):void {
			
			
		}
		
		override public function createContent(settings:Object = null):void 
		{
			settings['content'] = [];	
		}
		
		override protected function drawBonusInfo():void
		{
			rewardTut = JSON.parse(App.data.options.TutorialReward);
			bonusList = new RewardList(rewardTut, true, 384, Locale.__e("flash:1421923732514"), 0.4, 28, 30);
			bodyContainer.addChild(bonusList);
			bonusList.x = (settings.width - bonusList.width)/2;
			bonusList.y = background.height - 184;
			
			
		}
		
		override public function contentChange():void {
			
			
			
		}
		
		override protected function onTellBttn(e:MouseEvent):void
		{
			//var message:String = Locale.__e("flash:1382952380041 достиг %d уровня в игре \"flash:1382952379705\". %s", [int(App.user.level), Config.appUrl]);
			if(checkBox&&checkBox.checked == CheckboxButton.CHECKED){
				//var message:String = Strings.__e('LevelUpWindow_onTellBttn', [int(App.user.level), Config.appUrl]);
				//ExternalApi.apiWallPostEvent(ExternalApi.LEVEL, screen, App.user.id, message);
				WallPost.makePost(WallPost.GAME, {btm:screen});
			}
			//bonusList.take();
			Post.send( { ctr: 'stock', act: 'tutorial', uID: App.user.id }, function(error:int, data:Object, params:Object):void {
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				var position:Object = App.map.heroPosition;
				var position2:* = IsoConvert.isoToScreen(position.x, position.z,true);
				Treasures.bonus(Treasures.convert(rewardTut), new Point(App.map.x-300,App.map.y-300)/* new Point(position2.x,position2.y)*/);
				
			});
			close();
		}
		
		override protected function addCheckBox():void 
		{
			if (App.isSocial('SP') || App.isJapan) 
			{
				return
			}
			checkBox = new CheckboxButton();
			bodyContainer.addChild(checkBox);
			
			checkBox.x = okBttn.x + 14;
			//checkBox.x = (settings.width - inner_margin) / 2 - checkBox.width / 2 + inner_margin+5;
			//checkBox.width okBttn.x ;
			checkBox.y = okBttn.y - checkBox.height - 2;
			
				checkBox.checked = CheckboxButton.UNCHECKED;
				okBttn.showGlowing();
				okBttn.showPointing('right', 0,0, bodyContainer);	
			
		}
		
		override protected function isBodyShort():void 
		{
				addOpenTxt();
				bgHeight = openTxt.textHeight+210;// 340;
				this.y += 100;
				fader.y -= 100;
				settings['hasPaginator'] = false;
			
		
		}
		
		
		override protected function drawLevelInfo():void{
			var sprite:Sprite = new Sprite();
			
			label = new Bitmap(Window.textures.levelUp);
			sprite.addChild(label);
			labelHeader = new Bitmap(Window.textures.headerPortal);
			
			labelHeader.x = 105;
			labelHeader.y = 10;
			labelHeader.scaleX = labelHeader.scaleY = 1;
			sprite.addChild(label);
			sprite.addChild(labelHeader);
			sprite.x = settings.width / 2 - label.width / 2;
			sprite.y = - 280;
			
			bodyContainer.addChild(sprite);
			
			var textSettings:Object = 
			{
				title			:"",
				fontSize		:24,//32,
				color			:0xf8fce5,
				borderColor		:0x974a14,
				width 			:110,
				borderSize		:2,
				sharpness		:0,
				fontBorder		:0,
				fontBorderGlow	:0,
				textShadow		:0
			}
			
			var levelText:TextField = Window.drawText(Locale.__e("flash:1421762777687"), {
				fontSize	:44,//32,
				color		:0xfffde7,
				borderColor	:0x5b2a7a,
				fontBorderSize:1
				});
				levelText.width = levelText.textWidth +5;
				levelText.height = levelText.textHeight;
				levelText.x = sprite.width / 2 - levelText.width / 2 + 4;
				levelText.y = 260;//260; 
				sprite.addChild(levelText);
				
			textSettings.fontSize = 50;	
			//textSettings.color = 0x000000;
			//textSettings.borderColor = 0x000000;
			textSettings['textAlign'] = 'center';
			//textSettings.fontBorderSize = 12;
		
			var leveleTitle:Sprite = titleText(textSettings);	
				leveleTitle.x = (sprite.width - leveleTitle.width)/2 - 10;
				leveleTitle.y = 45 + (sprite.height - leveleTitle.width) / 2;
				
				sprite.addChild(leveleTitle);
			
			screen = new Bitmap(new BitmapData(sprite.width, sprite.height));
			screen.bitmapData.draw(sprite);
			
			
			
		}
		
	}

}