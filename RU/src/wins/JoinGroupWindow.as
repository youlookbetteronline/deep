package wins 
{
	import api.ExternalApi;
	import api.OKApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import strings.Strings;
	
	/**
	 * ...
	 * @author Maks
	 */
	public class JoinGroupWindow extends Window
	{
		private var _fieldInfo:Shape;
		private var _bgdJoiningGroup:Sprite;
		private var _titleBackingBmap:Bitmap;
		private var _paperClearField:Bitmap
		private var groupLink:String;
		private var noShowCheck:CheckboxButton
		public function JoinGroupWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			//action = App.data.freebie[settings['ID']];
			
			settings['width'] = 590;
			settings['height'] = 440;
			settings['title'] = Locale.__e('flash:1481298339658'); // action.title;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontSize'] = 40;
			settings['fontBorderSize'] = 2;
			settings["fontColor"] = 0xffffff;
			settings["fontBorderColor"] = 0x276a12;
			settings["shadowColor"] = 0x00276a12;
			settings['background'] = 'capsuleWindowBacking';
			settings['exitTexture'] = 'closeBttnMetal';
			super(settings);
		}
		

		override public function drawBody():void 
		{
			
			exit.scaleX = exit.scaleY = 1;
			exit.y = -10;
			exit.x += -10;
			
			_paperClearField = new Bitmap();
			_paperClearField = backing(524, 370, 20, 'paperClear');
			bodyContainer.addChild(_paperClearField);
			_paperClearField.x = (settings.width - _paperClearField.width) / 2;
			_paperClearField.y += -10;
			
			_titleBackingBmap = backingShort(360, 'ribbonGrenn', true, 1.3);
			_titleBackingBmap.x = (settings.width -_titleBackingBmap.width) / 2;
			_titleBackingBmap.y = -75;
			bodyContainer.addChild(_titleBackingBmap);
			
			//	ставляем фот дильфина
			
			backgroundJoiningGroup();
			
			_fieldInfo = new Shape();
			_fieldInfo.graphics.beginFill(0xefebb3, .6);
			_fieldInfo.graphics.drawRect(0, 0, 430, 90);
			_fieldInfo.graphics.endFill();	
			_fieldInfo.x = (settings.width - _fieldInfo.width) / 2;
			_fieldInfo.y = (settings.height - _fieldInfo.height) / 2 + 22;
			_fieldInfo.filters = [new BlurFilter(20, 0, 2)];
			bodyContainer.addChild(_fieldInfo);
			
			var infoField:TextField = drawText(Locale.__e('flash:1493371690817'), {
				fontSize	:28,
				textAlign	:"center",
				color		:0x704421,
				borderColor	:0xf6f4f4,
				multiline	:true,
				wrap		:true,
				width		:285
			});
			
			infoField.width = 310;
			infoField.x = _fieldInfo.x + 130
			infoField.y = _fieldInfo.y;
			bodyContainer.addChild(infoField);
			
			// ставляем подарок
			var giftBox:Bitmap = new Bitmap(Window.textures.giftBox);
			bodyContainer.addChild(giftBox);
			giftBox.x += 15;
			giftBox.y -= 20;
			
			// ставляем рибку
			var decFish2:Bitmap = new Bitmap(Window.textures.decFish2);
			bodyContainer.addChild(decFish2);
			decFish2.x = settings.width + 20;
			decFish2.y = settings.height - 120;
			decFish2.scaleX = -1;
			//decFish2.scaleY = 1.6;
			//decFish2.smoothing = true;
			
			//	ставляем чекбокс
			noShowCheck = new CheckboxButton({
				fontSize			:24,
				fontSizeUnceked		:24,
				fontColor			:0x905832,
				border				:false,
				multiline			:false,
				wordWrap			:false,
				captionChecked		:Locale.__e('flash:1493374787828'),
				captionUnchecked	:Locale.__e('flash:1493374787828')
			});

			bodyContainer.addChild(noShowCheck);
			noShowCheck.y = settings.height - 120;
			noShowCheck.x = (settings.width - noShowCheck.width) / 2 + 10;
			checkGroup();
			//drawInfoBttn();
			
			drawGoBttn();
			
			//
			
			
			titleLabel.y -= 8; 
		}
		
		private function checkGroup():void 
		{
			switch (App.social) 
			{
				case 'DM':
				groupLink = 'https://vk.com/club134271154';	
				break;
				case 'VK':
				groupLink = 'https://vk.com/club134271154';	
				break;
				case 'OK':
				groupLink = 'http://ok.ru/group/53483724406972'
				break;
				case 'FS':
				groupLink = 'http://fotostrana.ru/public/344947'
				break;
				case 'MM':
				groupLink = 'http://my.mail.ru/community/deepfarm'
				break;
				case 'FB':
				groupLink = 'https://facebook.com/Deepsea-Story-Community-1493576820663172/'	
				break;
			default:
				groupLink = '';
			}
		}
		
		private function drawGoBttn():void 
		{
			var goGroup:MenuButton = new MenuButton( {
			title:				Locale.__e("flash:1417427832679"),
			fontSize:				32,
			height:					54,
			width:					168,
			multiline:				true,
			bgColor: 			[0xfed131, 0xf8ab1a],
			bevelColor: 		[0xf7fe9a, 0xcb6b1e],
			fontColor: 			0xffffff,
			fontBorderColor:	0x7f3d0e,
			active:{
				bgColor:				[0xfed131, 0xf8ab1a],
				fontSize: 				36,
				bevelColor:				[0xcb6b1e, 0xf7fe9a],
				fontColor:				0xffffff,
				fontBorderColor:		0x7f3d0e			//Цвет обводки шрифта		
				}
			});
			goGroup.addEventListener(MouseEvent.CLICK, onGoEvent);							
			bodyContainer.addChild(goGroup);
			goGroup.x = (settings.width - goGroup.width) / 2;
			goGroup.y = settings.height - 75;
		}
		
		
		private function onGoEvent(e:MouseEvent = null):void
		{
			if (noShowCheck.checked == CheckboxButton.CHECKED) 
				App.user.storageStore('groupInvite', 1);
			navigateToURL(new URLRequest(groupLink));
			Window.closeAll();
		}
		
		private var _outBackgroundJoiningGroup:Shape;
		private var _backgroundJoiningGroup:Bitmap;
		private var _maskBackgroundJoiningGroup:Shape;
		private function backgroundJoiningGroup():void 
		{
			var paddingX:int = 6;
			var paddingY:int = 6;
			
			_bgdJoiningGroup = new Sprite();
			
			_backgroundJoiningGroup = new Bitmap(Window.textures.backgroundJoiningGroup);
			_backgroundJoiningGroup.height = 280;
			_backgroundJoiningGroup.width = 480;
			_backgroundJoiningGroup.x = (settings.width - _backgroundJoiningGroup.width) / 2;
			_backgroundJoiningGroup.y = (settings.width - _backgroundJoiningGroup.width) / 2 - 30;
			
			_outBackgroundJoiningGroup = new Shape();
			_outBackgroundJoiningGroup.graphics.beginFill(0xe0a779);
			_outBackgroundJoiningGroup.graphics.drawRoundRect(_backgroundJoiningGroup.x, _backgroundJoiningGroup.y, _backgroundJoiningGroup.width + paddingX / 2,  _backgroundJoiningGroup.height + paddingY / 2, 40, 40);
			_outBackgroundJoiningGroup.graphics.endFill();
			_bgdJoiningGroup.addChild(_outBackgroundJoiningGroup);
			
			_bgdJoiningGroup.addChild(_backgroundJoiningGroup);
			
			_maskBackgroundJoiningGroup = new Shape();
			_maskBackgroundJoiningGroup.graphics.beginFill(0xe0a779);
			_maskBackgroundJoiningGroup.graphics.drawRoundRect(_backgroundJoiningGroup.x + paddingY / 2, _backgroundJoiningGroup.y + paddingY / 2, _backgroundJoiningGroup.width - paddingX / 2, _backgroundJoiningGroup.height - paddingX / 2, 40, 40);
			_maskBackgroundJoiningGroup.graphics.endFill();
			_bgdJoiningGroup.addChild(_maskBackgroundJoiningGroup);
			
			_backgroundJoiningGroup.mask = _maskBackgroundJoiningGroup;
			
			bodyContainer.addChild(_bgdJoiningGroup);
		}
	}

}