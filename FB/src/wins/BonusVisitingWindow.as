package wins {
	
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;

	public class BonusVisitingWindow extends Window 
	{
		public var bonus:Object = { };
		private var wakeUpBonus:Boolean = false;
		private var descBg:Shape;
		private var giftSprite:Sprite;
		private var getBttn:Button;
		
		public function BonusVisitingWindow(settings:Object = null) 
		{
			if (settings == null)
				settings = new Object();
			
			if (settings.hasOwnProperty('bonus'))
				bonus = settings.bonus;
				
			if (settings.hasOwnProperty('wakeUpBonus'))
				wakeUpBonus = settings.wakeUpBonus;
			
			//bonus = { 100:10,
				//117:20,
				//135:30,
				//164:40,
				//179:50,
				//181:60,
				//182:70,
				//183:80,
				//184:90
			//}
			
			//{"bonus":{"29":{"25":1},"26":{"250":1},"28":{"5":1},"147":{"1":1}}
			
			// descr flash:1432548679747
			// title flash:1432548660284
			settings['faderAsClose'] = true;
			settings['faderClickable'] = false;
			settings['escExit'] = false;
			settings['hasExit'] = true;
			settings['hasTitle'] = true;
			settings['fontSize'] = 48;
			settings['width'] = 575;
			settings['height'] = 370;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings["fontSize"] = 34;
			settings["fontColor"] = 0xfdff54;
			settings["fontBorderColor"] = 0x7b4315;
			
			if (wakeUpBonus == true) 
			{
				settings["title"] = Locale.__e("flash:1432548660284"); //1429693439093
				bonus = Treasures.convert2(bonus);
			} else 
			{
				settings["title"] = Locale.__e("flash:1429693439093"); //1432548660284
			}
			
			if (Numbers.countProps(bonus) == 4)
				settings['width'] = 718;
			
			if (Numbers.countProps(bonus) >= 5)
				settings['width'] = 861;
			
			if (Numbers.countProps(bonus) > 5) 
			{
				settings['hasPaginator'] = true;
				settings["itemsOnPage"] = 5;
			}
			
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 50, 'paperScroll');
			layer.addChild(background);
		}
		
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
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
			
			settings.borderColor = 0xa35514;
			settings.color = 0xa35514;
			var textShadow3:TextField = Window.drawText(settings.title, settings);
			textShadow3.wordWrap = true;
			textShadow3.width = settings.width;
			textShadow3.height = textLabel.textHeight + 2;
			textShadow3.cacheAsBitmap = true;
					
			var textShadow4:TextField = Window.drawText(settings.title, settings);
			textShadow4.wordWrap = true;
			textShadow4.width = settings.width;
			textShadow4.height = textLabel.textHeight + 2;
			textShadow4.cacheAsBitmap = true;
			
			cont2.addChild(shadow);
			shadow.addChild(textShadow3);
			shadow.addChild(textShadow4);
			cont2.addChild(cont);
			
			//cont.addChild(textShadow);
			//cont.addChild(textShadow2);
			
			cont.addChild(textLabel);
			textFilter = new GlowFilter(0xa35514, 1, 2, 2, 8, 1);
			cont.filters = [textFilter];
			
			shadowFilter = new BlurFilter(2,2,1);
			shadow.filters = [shadowFilter];
			
			
			textShadow.y = 1;
			textShadow3.y = 2;
			textShadow3.x = 1;
			textShadow4.y = 2;
			textShadow4.x = -1;
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont2;
		}
		
		private var giftsBackground:Bitmap;
		override public function drawBody():void 
		{
			exit.x = settings.width - 60;
			exit.y = -10;
			titleLabel.y += 10;
			
			/*var glow:Bitmap = new Bitmap(Window.textures.sharpShining, "auto", true);
			glow.scaleX = glow.scaleY = 3.5;
			glow.smoothing = true;
			glow.x = (settings.width - glow.width) / 2;
			glow.y = -180;
			layer.addChildAt(glow, 0);*/
			
			var bitmap:Bitmap = new Bitmap(Window.textures.chestTukan, "auto", true);
			bitmap.smoothing = true;
			bitmap.x = (settings.width - bitmap.width) / 2;
			bitmap.y = -bitmap.height + 42;
			layer.addChildAt(bitmap, 0);
			
			drawDescription();
			
			//giftsBackground = Window.backing(settings.width - 90, 208, 10, 'storageInnerBacking');
			//giftsBackground.x = (settings.width - giftsBackground.width) / 2;
			//giftsBackground.y = descBg.y + descBg.height + 10;
			//bodyContainer.addChild(giftsBackground);
			
			var titleBackingBmap:Bitmap = backingShort(380, 'ribbonGrenn',true,1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -49;
			titleBackingBmap.filters = [new DropShadowFilter(5.0, 90, 0, 0.3, 4.0, 4.0, 1, 3, false, false, false)];
			bodyContainer.addChild(titleBackingBmap);
			
			contentChange();
			
			drawButtons();
			
			this.y += 110;
			fader.y -= 110;
		}
		
		private function drawDescription() : void 
		{
			descBg = new Shape();
			descBg.graphics.beginFill(0xfce79c, 1);
			descBg.graphics.drawRect(0, 0, settings.width - 120, 70);
			descBg.graphics.endFill();
			descBg.filters = [new BlurFilter(40, 0, 2)];
			descBg.x = (settings.width - descBg.width)/2;
			descBg.y = 42;
			bodyContainer.addChild(descBg);
			
			var descText:TextField = Window.drawText((wakeUpBonus)?Locale.__e("flash:1432548679747"):Locale.__e("flash:1429693518287"), {
				fontSize	:26,
				color		:0x6e411e,
				border		:false,
				textAlign	:"center",
				multiline	:true,
				width		:475,
				wrap		:true,
				autoSize	:"center"
			});
			
			descText.x = (settings.width - descText.width) / 2;
			descText.y = descBg.y + 10;
			bodyContainer.addChild(descText);
		}
		
		override public function contentChange():void 
		{
			if (rewards != null && rewards.parent)
				rewards.parent.removeChild(rewards);
			
			if (Numbers.countProps(bonus) <= 5) 
			{
				drawGift(bonus);
			} else if (Numbers.countProps(bonus) > 5) 
			{
				var bonusArr:Array = new Array();
				for (var b:Object in bonus) 
				{
					bonusArr.push(b);
				}
				
				var gift:Object = new Object();
				var endCount:int = paginator.finishCount;
				if (endCount > bonusArr.length)
					endCount = bonusArr.length;
				for (var i:int = paginator.startCount; i < endCount; i++ ) 
				{
					gift[bonusArr[i]] = bonus[bonusArr[i]];
				}
				drawGift(gift);
			}
		}
		
		override public function drawArrows():void 
		{
			super.drawArrows();
			paginator.arrowLeft.x += 80;
			paginator.arrowLeft.y += 18;
			paginator.arrowRight.y += 18;
		}
		
		private var rewards:RewardListC;
		private function drawGift(gifts:Object) : void 
		{
			rewards = new RewardListC(gifts, false, 0, {itemHasBacking:false, itemWidth:135, itemHeight:173});
			rewards.x = (settings.width - rewards.backing.width) / 2;
			rewards.y = descBg.y + descBg.height + 40;
			rewards.title.visible = false;
			bodyContainer.addChild(rewards);
		}
		
		private function drawButtons() : void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379786"),
				fontSize:32,
				width:155,
				height:50
			};
			getBttn = new Button(bttnSettings);
			getBttn.x = (settings.width - getBttn.width) / 2;
			getBttn.y = settings.height - 75;
			getBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(getBttn);
			getBttn.addEventListener(MouseEvent.CLICK, onTakeEvent);
		}
		
		private function onTakeEvent(e:MouseEvent):void 
		{
			getBttn.state = Button.DISABLED;
			
			if (wakeUpBonus) {
				if (!User.inExpedition) 
				{
					App.user.stock.addAll(bonus);
					take(bonus, getBttn);
				}
				//timeoutClose(1000);
				close();	
			} else 
			{
				Post.send({
					ctr:'bonus',
					act:'lack',
					uID:App.user.id
				}, function(error:int, data:Object, params:Object):void 
				{
					exit.visible = true;
					if (error || !data.bonus) 
					{
						close();
					}else 
					{
						if (!User.inExpedition) 
						{
							App.user.stock.addAll(data.bonus);
							take(data.bonus, getBttn);	
						}
						//timeoutClose(1000);
						close();
					}
				});
			}
			
			if (settings.onTake != null)
				settings.onTake();
			
		}
		
		private function take(items:Object, target:*):void 
		{
			for (var i:String in items) 
			{
				var item:BonusItem = new BonusItem(uint(i), items[i]);
				var point:Point = Window.localToGlobal(target);
				item.cashMove(point, App.self.windowContainer);
			}
		}
		
		public override function dispose():void	
		{
			super.dispose();
		}
	}
}