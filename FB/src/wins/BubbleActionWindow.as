package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import utils.ActionsHelper;
	/**
	 * ...
	 * @author ...
	 */
	public class BubbleActionWindow extends AddWindow 
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
		private var _atype:int;
		private var _leftTimeContainer:Sprite = new Sprite;
		private var _leftTimeText:TextField
		private var _leftTimeBack:Bitmap
		public function BubbleActionWindow(settings:Object=null) 
		{
			this._aID = settings.pID;
			this._atype = ActionsHelper.getActionType(_aID);
			this._action = App.data.actions[settings.pID];
			this._actionItem = Numbers.firstProp(_action.items).key
			settings["width"]				= 480;
			drawDescription()
			settings["height"] 				= needRewardPerTime?430 + _description.textHeight:295 + _description.textHeight;
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
			super(settings);
			
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
			drawReward();
			drawButton();
			drawLeftTime()
			build();
		}
		
		private function drawLeftTime():void 
		{
			_leftTimeBack = new Bitmap(Window.textures.popupBack)
			Size.size(_leftTimeBack, 128, 120)
			_leftTimeBack.smoothing = true;
			_leftTimeContainer.addChild(_leftTimeBack);
			
			
			var timeLeft:uint = _action.time + _action.duration * Numbers.HOUR - App.time;
			_leftTimeText = Window.drawText(Locale.__e('flash:1393581955601') + '\n' + TimeConverter.timeToDays(timeLeft),{
				fontSize		:32,
				color			:0xfff330,
				borderColor		:0x224076,
				borderSize		:3,
				textAlign		:'center',
				width:115
			})
			_leftTimeText.x = (_leftTimeBack.width - _leftTimeText.width) / 2;
			_leftTimeText.y = (_leftTimeBack.height - _leftTimeText.height) / 2;
			_leftTimeContainer.addChild(_leftTimeText)
			App.self.setOnTimer(actionTimer)
		}
		
		private function actionTimer():void 
		{
			var timeLeft:uint = _action.time + _action.duration * Numbers.HOUR - App.time;
			if (timeLeft < 0)
			{
				close();
				App.user.updateActions();
				App.self.setOffTimer(actionTimer);
				return;
			}
			_leftTimeText.text = Locale.__e('flash:1393581955601') + '\n' + TimeConverter.timeToDays(timeLeft)
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
			_labelBack.y = 125;
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
			
			var _bonusTimerText:TextField = Window.drawText(TimeConverter.timeToDays(App.data.storage[_actionItem].time),{
				fontSize		:24,
				color			:0xffffff,
				borderColor		:0x224076,
				borderSize		:3,
				textAlign		:'center'
			})
			_bonusTimerText.width = _bonusTimerText.textWidth + 5;
			
			var _lifeTimerText:TextField = Window.drawText(App.data.storage[_actionItem].lifetime?TimeConverter.timeToDays(App.data.storage[_actionItem].lifetime):String('∞'),{
				fontSize		:24,
				color			:0xffffff,
				borderColor		:0x224076,
				borderSize		:3,
				textAlign		:'center'
			})
			_lifeTimerText.width = _lifeTimerText.textWidth + 5;
			var _lifeTimerInfinity:Bitmap = new Bitmap(Window.textures.infinity);
			
			var _bonusLabel:TextField = Window.drawText(Locale.__e('flash:1519295603909'),{
				fontSize		:24,
				color			:0xfff330,
				borderColor		:0x224076,
				borderSize		:3,
				textAlign		:'center'
			})
			_bonusLabel.width = _bonusLabel.textWidth + 5;
			
			var _lifeLabel:TextField = Window.drawText(Locale.__e('flash:1519295640115'),{
				fontSize		:24,
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
				width			:390,
				multiline		:true,
				wrap			:true
			});
		}
		
		
		private function drawReward():void
		{
			if (!needRewardPerTime)
				return;
			_rewardTitle = Window.drawText(_action.rewardpertime.text,{
				fontSize		:28,
				color			:0xfff330,
				borderColor		:0x224076,
				borderSize		:4,
				textAlign		:'center',
				width			:settings.width - 90
			})
			_rewardDesc = Window.drawText(Locale.__e('flash:1519398814696'),{
				fontSize		:16,
				color			:0x224076,
				border			:false,
				textAlign		:'center',
				width			:settings.width - 90
			})
			
			content = Treasures.bonusPerTime(_actionItem, _action.rewardpertime.time);
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
			switch (_atype)
			{
				case ActionsHelper.CURRENCY:
					var price:Number = _action.price[App.social];
					var priceLable:Object = ActionsHelper.priceLable(price);
					var bttnSettings:Object = {
						fontSize	:((App.isJapan())) ? 20 : 28,
						width		:168,
						height		:55,
						hasDotes	:false,
						caption		:Locale.__e(priceLable.text, [priceLable.price])
					};
					_bttn = new Button(bttnSettings);
					if (Payments.byFants)
						_bttn.fant();
					
					if(App.isSocial('MX')){
						var mixiLogo:Bitmap = new Bitmap(Window.textures.mixieLogo);
						_bttn.topLayer.addChild(mixiLogo);
						_bttn.fitTextInWidth(_bttn.width - (mixiLogo.width + 10));
						_bttn.textLabel.width = _bttn.textLabel.textWidth + 5;
						_bttn.textLabel.x = (_bttn.width - (_bttn.textLabel.width + mixiLogo.width + 5)) / 2 + mixiLogo.width + 5;
						mixiLogo.x = _bttn.textLabel.x - mixiLogo.width - 5 ;
						mixiLogo.y = (_bttn.height - mixiLogo.height) / 2;
					}
					_bttn.addEventListener(MouseEvent.CLICK, buyEvent);
					break;
				case ActionsHelper.MATERIAL:
					_bttn = new MoneyButton({
						caption			: Locale.__e('flash:1382952379751') + '\n',
						width			:168,
						height			:55,
						fontSize		:30,
						fontCountSize	:30,
						radius			:20,
						countText		:String(Numbers.firstProp(_action.mprice[App.social]).val),
						mID				:Numbers.firstProp(_action.mprice[App.social]).val, 
						multiline		:false,
						wrap			:false,
						notChangePos	:true,
						iconScale		:.7,
						iconDY			:2,
						bevelColor		:[0xcce8fa, 0x3b62c2],
						bgColor			:[0x65b7ef, 0x567ed0]
					});
					_bttn.addEventListener(MouseEvent.CLICK, buyEvent);
			}

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
			
				
			_description.y = _itemInfoContainer.y + _itemInfoContainer.height + 3;
			_description.x = (settings.width - _description.width) / 2;
			bodyContainer.addChild(_description);
			
			if (needRewardPerTime)
			{
				_rewardTitle.x = (settings.width - _rewardTitle.width) / 2;
				_rewardTitle.y = _description.y + _description.textHeight + 5;
				
				_rewardContainer.x = (settings.width - _rewardContainer.width) / 2;
				_rewardContainer.y = _rewardTitle.y + _rewardTitle.height;
				
				_rewardDesc.x = (settings.width - _rewardDesc.width) / 2;
				_rewardDesc.y = _rewardContainer.y + _rewardContainer.height + 5;
				bodyContainer.addChild(_rewardTitle);
				bodyContainer.addChild(_rewardContainer);
				bodyContainer.addChild(_rewardDesc);
			}
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 50;
			
			bodyContainer.addChild(_bttn);
			
			_leftTimeContainer.x = 0;
			_leftTimeContainer.y = -60;
			bodyContainer.addChild(_leftTimeContainer);
		}
		
		override public function drawPromoPanel():void {return; }
	
		private function get needRewardPerTime():Boolean
		{
			if (_action.hasOwnProperty('rewardpertime') && _action.rewardpertime.hasOwnProperty('text') && _action.rewardpertime.text != '' &&
				_action.rewardpertime.hasOwnProperty('time') && _action.rewardpertime.time != '')
				return true;
			return false;
		}
		
		
	}
}
import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.text.TextField;
import wins.Window;

internal class RewardItem extends LayerX
{
	private var _settings:Object = {
		side:	71
	}
	private var _sid:int;
	private var _count:int;
	private var _info:Object;
	private var _back:Bitmap;
	private var _icon:Bitmap;
	private var _countText:TextField;

	public function RewardItem(item:Object)
	{
		this._sid = Numbers.firstProp(item).key
		this._count = Numbers.firstProp(item).val
		this._info = App.data.storage[_sid];
		drawBack();
		drawIcon();
		drawCount();
		build();
		this.tip = function():Object{
				return{
					title:_info.title,
					text:_info.description
				}
			}
	}
	
	private function drawBack():void 
	{
		_back = Window.backing(SIDE, SIDE, 30, 'blueBackSmall');
	}
	
	private function drawIcon():void 
	{
		Load.loading(Config.getIcon(_info.type, _info.preview), onLoad)
	}
	
	private function onLoad(data:Bitmap):void 
	{
		_icon = new Bitmap(data.bitmapData);
		Size.size(_icon, 45, 45);
		_icon.smoothing = true;
		addIcon();
	}
	
	private function addIcon():void 
	{
		if (_icon && _icon.parent)
			_icon.parent.removeChild(_icon)
		_icon.x = (SIDE - _icon.width) / 2;
		_icon.y = (SIDE - _icon.height) / 2 - 5;
		addChild(_icon)
		drawCount();
	}
	
	private function drawCount():void
	{
		if (_countText && _countText.parent)
			_countText.parent.removeChild(_countText);
		_countText = Window.drawText('x'+String(_count),{
			fontSize		:22,
			color			:0xffffff,
			borderColor		:0x224076,
			textAlign		:'center',
			width			:SIDE
		});
		_countText.x = (SIDE - _countText.width) / 2;
		_countText.y = SIDE - 30;
		addChild(_countText)
	}
	
	private function build():void 
	{
		addChild(_back);
		if (_icon)
			addIcon();
	}
	
	public function get SIDE():int{return _settings.side;}
}