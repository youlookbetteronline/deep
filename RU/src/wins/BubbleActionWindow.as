package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class BubbleActionWindow extends Window 
	{
		private var _aID:int;
		private var _action:Object;
		private var _actionItem:int;
		private var _itemImage:Bitmap;
		private var _glowImage:Bitmap;
		private var _labelBack:Bitmap;
		private var _label:TextField;
		private var _description:TextField;
		private var _itemInfoContainer:Sprite = new Sprite;
		private var _rewardTitle:TextField;
		private var _rewardDesc:TextField;
		private var _rewardContainer:Sprite = new Sprite;
		private var _rewardItem:RewardItem;
		private var _rewardItems:Vector.<RewardItem>;
		private var _bttn:Button;
		public function BubbleActionWindow(settings:Object=null) 
		{
			this._aID = settings.pID;
			this._action = App.data.actions[settings.pID];
			this._actionItem = Numbers.firstProp(_action.items).key
			settings = settingsInit(settings);
			super(settings);
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			
			settings["width"]				= 480;
			settings["height"] 				= 520;
			settings["background"]			= 'bubbleBlueBacking'
			settings['fontColor'] 			= 0x004762;
			settings['fontBorderColor'] 	= 0xffffff;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 40;
			settings['exitTexture'] 		= 'blueClose';
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 80, settings.background);
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			drawItem();
			drawItemInfo();
			drawDescription();
			drawReward();
			drawButton();
			build();
		}
		
		private function drawItem():void 
		{
			TweenPlugin.activate([TransformAroundPointPlugin]);
			
			_glowImage = new Bitmap(Window.textures.glowYellowStrong);
			Size.size(_glowImage, 350, 350);
			_glowImage.smoothing = true;
			_glowImage.x = (settings.width - _glowImage.width) / 2;
			_glowImage.y = -140;
			bodyContainer.addChild(_glowImage)
			
			var tPoint:Point = new Point(_glowImage.x + _glowImage.width / 2, _glowImage.y + _glowImage.height / 2);
			var sTween:TweenMax = new TweenMax(_glowImage, 10, {rotation:_glowImage.rotation + 360, transformAroundPoint: { point:tPoint}, repeat:-1, ease: Linear.easeNone});
		
			Load.loading(Config.getImage('actions', _action.picture), onImageLoad)
		}
		
		private function onImageLoad(data:Bitmap):void 
		{
			_itemImage = new Bitmap(data.bitmapData);
			Size.size(_itemImage, 220, 220);
			_itemImage.smoothing = true;
			addImage();
		}
		
		private function addImage():void 
		{
			if (_itemImage && _itemImage.parent)
				_itemImage.parent.removeChild(_itemImage);
			_itemImage.x = (settings.width - _itemImage.width) / 2;/*_glowImage.x + (_glowImage.width - _itemImage.width) / 2 - 23;*/
			_itemImage.y = _glowImage.y + (_glowImage.height - _itemImage.height) / 2 + 10;
			bodyContainer.addChild(_itemImage);
			drawActionTitle();
		}
		
		private function drawActionTitle():void 
		{
			_label = Window.drawText(App.data.storage[_actionItem].title,{
				fontSize		:32,
				color			:0xffffff,
				borderColor		:0x643b1a,
				borderSize		:3,
				textAlign		:'center'
			})
			_label.width = _label.textWidth + 5;
			
			_labelBack = backingShort(_label.width + 80, 'actionRibbonBg', true, 1);
			_labelBack.scaleY = .6;
			_labelBack.smoothing = true;

			_labelBack.x = (settings.width - _labelBack.width) / 2;
			_labelBack.y = _glowImage.y + _glowImage.height - 100;
			_labelBack.filters = [new DropShadowFilter(3, 90, 0x000000, .2, 1, 1, 1, 1)]
			
			_label.x = _labelBack.x + (_labelBack.width - _label.width) / 2;
			_label.y = _labelBack.y + (_labelBack.height - _label.height) / 2;
			
			bodyContainer.addChild(_labelBack);
			bodyContainer.addChild(_label);
			
			
		}
		
		private function drawItemInfo():void 
		{
			var _bonusTimerIcon:Bitmap = new Bitmap(Window.textures.blueClock)
			Size.size(_bonusTimerIcon, 30, 30);
			_bonusTimerIcon.smoothing = true;
			var _lifeTimerIcon:Bitmap = new Bitmap(Window.textures.blueClock)
			Size.size(_lifeTimerIcon, 30, 30);
			_lifeTimerIcon.smoothing = true;
			
			var _bonusTimerText:TextField = Window.drawText(TimeConverter.timeToCuts(App.data.storage[_actionItem].time),{
				fontSize		:26,
				color			:0xffffff,
				borderColor		:0x224076,
				borderSize		:3,
				textAlign		:'center'
			})
			_bonusTimerText.width = _bonusTimerText.textWidth + 5;
			
			var _lifeTimerText:TextField = Window.drawText(App.data.storage[_actionItem].lifetime?TimeConverter.timeToCuts(App.data.storage[_actionItem].lifetime):String('∞'),{
				fontSize		:26,
				color			:0xffffff,
				borderColor		:0x224076,
				borderSize		:3,
				textAlign		:'center'
			})
			_lifeTimerText.width = _lifeTimerText.textWidth + 5;
			var _lifeTimerInfinity:Bitmap = new Bitmap(Window.textures.infinity);
			
			var _bonusLabel:TextField = Window.drawText(Locale.__e('flash:1519295603909'),{
				fontSize		:26,
				color			:0xfff330,
				borderColor		:0x224076,
				borderSize		:3,
				textAlign		:'center'
			})
			_bonusLabel.width = _bonusLabel.textWidth + 5;
			
			var _lifeLabel:TextField = Window.drawText(Locale.__e('flash:1519295640115'),{
				fontSize		:26,
				color			:0xfff330,
				borderColor		:0x224076,
				borderSize		:3,
				textAlign		:'center'
			})
			_lifeLabel.width = _lifeLabel.textWidth + 5;
			
			_itemInfoContainer.addChild(_bonusLabel);
			
			_bonusTimerIcon.x = _bonusLabel.x + _bonusLabel.width + 5;
			_bonusTimerIcon.y = _bonusLabel.y + (_bonusLabel.textHeight - _bonusTimerIcon.height) / 2;
			
			_bonusTimerText.x = _bonusTimerIcon.x + _bonusTimerIcon.width + 5;
			_bonusTimerText.y = _bonusLabel.y + (_bonusLabel.height - _bonusTimerText.height) / 2;
			
			_lifeLabel.x = _bonusTimerText.x + _bonusTimerText.textWidth + 15;
			_lifeLabel.y = _bonusLabel.y + (_bonusLabel.height - _lifeLabel.height) / 2;
			
			_lifeTimerIcon.x = _lifeLabel.x + _lifeLabel.width + 5;
			_lifeTimerIcon.y = _lifeLabel.y + (_lifeLabel.textHeight - _lifeTimerIcon.height) / 2;
			
			_lifeTimerText.x = _lifeTimerIcon.x + _lifeTimerIcon.width + 5;
			_lifeTimerText.y = _lifeLabel.y + (_lifeLabel.height - _lifeTimerText.height) / 2;
			
			_lifeTimerInfinity.x = _lifeTimerIcon.x + _lifeTimerIcon.width + 5;
			_lifeTimerInfinity.y = _lifeTimerIcon.y + (_lifeTimerIcon.height - _lifeTimerInfinity.height) / 2;
			
			_itemInfoContainer.addChild(_bonusTimerIcon);
			_itemInfoContainer.addChild(_bonusTimerText);
			_itemInfoContainer.addChild(_lifeLabel);
			_itemInfoContainer.addChild(_lifeTimerIcon);
			
			if (App.data.storage[_actionItem].lifetime)
				_itemInfoContainer.addChild(_lifeTimerText);
			else
				_itemInfoContainer.addChild(_lifeTimerInfinity);
			
			_itemInfoContainer.x = (settings.width - _itemInfoContainer.width) / 2;
			_itemInfoContainer.y = 185;
			
			bodyContainer.addChild(_itemInfoContainer);
		}
		
		private function drawDescription():void
		{
			_description = Window.drawText(_action.text2, {
				fontSize		:24,
				color			:0xffffff,
				borderColor		:0x224076,
				borderSize		:4,
				textAlign		:'center',
				width			:settings.width - 90,
				multiline		:true,
				wrap			:true
			});
			
			_description.y = _itemInfoContainer.y + _itemInfoContainer.height + 3;
			_description.x = (settings.width - _description.width) / 2;
			bodyContainer.addChild(_description);
		}
		
		
		private function drawReward():void
		{
			_rewardTitle = Window.drawText('За 2 месяца можно получить до:',{
				fontSize		:28,
				color			:0xfff330,
				borderColor		:0x224076,
				borderSize		:4,
				textAlign		:'center',
				width			:settings.width - 90
			})
			_rewardDesc = Window.drawText('*включает награду за обмен собраных коллекций:',{
				fontSize		:16,
				color			:0x224076,
				border			:false,
				textAlign		:'center',
				width			:settings.width - 90
			})
			
			content = Treasures.bonusPerTime(_actionItem);
			settings.content = Numbers.objectToArraySidCount(content);
			disposeChilds(_rewardItems);
			_rewardItems = new Vector.<RewardItem>
			var X:int = 0;
			for (var i:int = 0; i < settings.content.length; i++) 
			{
				_rewardItem = new RewardItem(settings.content[i]);
				_rewardItem.x = X;
				_rewardContainer.addChild(_rewardItem);
				_rewardItems.push(_rewardItem);	
				X += _rewardItem.SIDE + 10;
			}
		}
		
		private function drawButton():void 
		{
			_bttn = new MoneyButton({
				caption			: Locale.__e('flash:1518780998508') + '\n',
				width			:168,
				height			:55,
				fontSize		:30,
				fontCountSize	:30,
				radius			:20,
				countText		:10,
				/*boostsec		:1,
				mID				:Numbers.firstProp(_item.price).key, */
				multiline		:false,
				wrap			:false,
				notChangePos	:true,
				iconDY			:2,
				bevelColor		:[0xcce8fa, 0x3b62c2],
				bgColor			:[0x65b7ef, 0x567ed0]
			})
		
			_bttn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void 
		{
			
		}
		
		private function build():void 
		{
			titleLabel.y += 45;

			exit.y += 13;
			exit.x -= 15;
			
			if (_itemImage)
				addImage();
				
			_rewardTitle.x = (settings.width - _rewardTitle.width) / 2;
			_rewardTitle.y = 335;
			
			_rewardContainer.x = (settings.width - _rewardContainer.width) / 2;
			_rewardContainer.y = 370;
			
			_rewardDesc.x = (settings.width - _rewardDesc.width) / 2;
			_rewardDesc.y = _rewardContainer.y + _rewardContainer.height + 5;
			bodyContainer.addChild(_rewardTitle);
			bodyContainer.addChild(_rewardContainer);
			bodyContainer.addChild(_rewardDesc);
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 50;
			
			bodyContainer.addChild(_bttn);
		}
	}
}
import flash.display.Bitmap;
import wins.Window;

internal class RewardItem extends LayerX
{
	private var _settings:Object = {
		side:	71
	}
	private var _back:Bitmap
	public function RewardItem(item:Object)
	{
		drawBack();
		build();
	}
	
	private function drawBack():void 
	{
		_back = Window.backing(SIDE, SIDE, 30, 'blueBackSmall');
	}
	
	private function build():void 
	{
		addChild(_back);
	}
	
	public function get SIDE():int{return _settings.side;}
}