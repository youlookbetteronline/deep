package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	
	//new ReferalRewardWindow({pID:81, desc:Locale.__e("flash:1400850022498")}).show();
	 
	public class ReferalRewardWindow extends Window
	{
		
		public var bonus:Object = { };
		private var wakeUpBonus:Boolean = false;
		private var descBg:Shape;
		private var giftSprite:Sprite;
		private var getBttn:Button;
		
		
		//private var descriptionLabel:TextField;
		
		
		public function ReferalRewardWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 445;
			settings['height'] = 270;
			settings["itemsOnPage"] = 1;		
			settings['title'] = Locale.__e("flash:1406554897349");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['faderClickable'] = false;
			
			super(settings);
			
			var blData:Object;
			if (settings.bonus)
				blData = settings.bonus;
			else 
				blData = App.data.blinks[App.blink].bonus;
			
			/*for(var _sid:* in blData){
				bonus['sid'] = _sid;
				bonus['count'] = blData[_sid];
			}*/
			bonus = blData;
		}
		
		override public function drawExit():void 
		{
			
		}
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 50, 'paperScroll');
			layer.addChild(background);
		}
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 44,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x4b7915,			
				borderSize 			: 3,					
				shadowColor			: 0x085c10,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center'
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5 - 3;
			titleLabel.y = -19;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		private var giftsBackground:Bitmap;
		override public function drawBody():void 
		{
			//exit.x = settings.width - 60;
			//exit.y = -10;
			titleLabel.y += 10;
			
			var bitmap:Bitmap = new Bitmap(Window.textures.crabenChest, "auto", true);
			bitmap.smoothing = true;
			bitmap.x = (settings.width - bitmap.width) / 2;
			bitmap.y = -bitmap.height + 90;
			layer.addChildAt(bitmap, 0);
			
			//drawDescription();
			
			var titleBackingBmap:Bitmap = backingShort(settings.titleWidth + 170, 'ribbonGrenn',true,1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -39;
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
			rewards.y = 15;
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
			getBttn.y = settings.height - 68;
			getBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			bodyContainer.addChild(getBttn);
			getBttn.addEventListener(MouseEvent.CLICK, onTakeEvent);
		}
		
		private function onTakeEvent(e:MouseEvent):void 
		{
			getBttn.state = Button.DISABLED;
			if (settings.mode == 'oneoff') {
				App.user.stock.addAll(settings.bonus);
				take(settings.bonus, getBttn);			
				close();
				return;
			}			
			
			if (settings.bonus) {
				var obj:Object = {
					ctr:	'user',
					act:	settings.mode,
					uID:	App.user.id,
					wID: 	App.user.worldID
				};
				obj[settings.mode] = settings.id;
				
				Post.send(obj, onBlink);
			}
			
		}
		
		public function onBlink(error:int, data:Object = null, params:Object = null):void {
			if (error) {
				close();
				return;
			}
			//if (!User.inExpedition) 
			//{
			if (settings.bonus) {
				App.user.stock.addAll(settings.bonus);
				take(settings.bonus, getBttn);
			}
			else {
				App.user.stock.addAll(App.data.blinks[App.blink].bonus);
				take(App.data.blinks[App.blink].bonus, getBttn);
			}
			//}
			close();
		}
		private function take(items:Object, target:*):void {
			for(var i:String in items) {
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