package wins 
{
	import buttons.Button;
	import buttons.CheckboxButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	import units.Pigeon;

	public class NewsWindow extends Window
	{
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		private var priceBttn:Button;
		private var okBttn:Button;
		private var descriptionLabel:TextField;
		private var updateLabel:TextField;
		private var canTell:Boolean = false;
		private var tellBttn:CheckboxButton;
		private var back:Shape = new Shape();
		
		public function NewsWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			action = settings['news'];
			settings['width'] = 470;
			settings['height'] = 320; 
			var text:String = Locale.__e(action.description);
			
			text = text.replace(/\r/g, '');
			
			descriptionLabel = drawText(text + "\n", {
				fontSize:26,
				autoSize:"left",
				textAlign:"left",
				color:0x7f3d0e,
				border:false,
				multiline:true
			});
			
			descriptionLabel.wordWrap = true;
			descriptionLabel.width = 380;
			descriptionLabel.height = descriptionLabel.textHeight;
			descriptionLabel.y = 280;
			descriptionLabel.x = 50;
			
			if (descriptionLabel.numLines > 4)
			{
				var delta:int = (descriptionLabel.numLines - 4) * 30;
				settings['height'] = 320 + delta;
			}
						
			settings['title'] = action.title;
			settings['hasExit'] = false;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontSize'] = 42;
			settings['fontBorderSize'] = 4;
			settings['exitTexture'] = 'closeBttnMetal';
			
			if (App.isSocial('DM', 'VK') && App.user.settings.hasOwnProperty('upd')) {
				var array:Array = App.user.settings.upd.split('_');
				if (!array[2] || array[2] == '0') canTell = true;
			}
			if (Config.admin)
				canTell = true;
			
			super(settings);
		}
		
		override public function drawBackground():void {		
			//var background:Bitmap = backing(settings.width, settings.height, 45, "questsSmallBackingTopPiece");
			//layer.addChild(background);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 28,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x4b7915,			
				borderSize 			: 3,					
				shadowColor			: 0x085c10,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center'
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5 - 3;
			titleLabel.y = -4;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		public var extra:ExtraReward;
		override public function drawBody():void {
			
			//var heightBgTxt:int = descriptionLabel.height + 40;
			//var heightWin:int = heightBgTxt + 145;
			drawExit();
			exit.y -= 23;
			background = backing(settings.width, settings.height, 45, "capsuleWindowBacking"/*, "questsSmallBackingBottomPiece"*/);
			//layer.addChild(background);
			//drawMirrowObjs('decSeaweed', settings.width + 56, - 56, settings.height - 175, true, true, false, 1, 1, layer);
			bg = Window.backing(settings.width - 70, settings.height - 70, 30, 'paperClear');
			bg.x = (settings.width - bg.width) / 2;
			bg.y = (settings.height - bg.height) / 2 - 34;
			bodyContainer.addChild(bg);	
			
			//Огрызки
			
			var snailLT:Bitmap = new Bitmap(Window.textures.snailLT);
			snailLT.x = -23;
			snailLT.y = -109;
			bodyContainer.addChild(snailLT);
			
			var seawheatLB:Bitmap = new Bitmap(Window.textures.seawheatLB);
			seawheatLB.x = -75;
			seawheatLB.y = settings.height - seawheatLB.height - 35;
			bodyContainer.addChild(seawheatLB);
			
			var snailLB:Bitmap = new Bitmap(Window.textures.snailLB);
			snailLB.x = 25;
			snailLB.y = settings.height - snailLB.height - 35;
			bodyContainer.addChild(snailLB);
			
			var seawheatRB:Bitmap = new Bitmap(Window.textures.seawheatRB);
			seawheatRB.x = settings.width - 66;
			seawheatRB.y = settings.height - seawheatRB.height - 28;
			bodyContainer.addChild(seawheatRB);
			
			var snailRB:Bitmap = new Bitmap(Window.textures.snailRB);
			snailRB.x = settings.width - 25;
			snailRB.y = settings.height - snailRB.height - 30;
			bodyContainer.addChild(snailRB);
			
			var bubbleRT:Bitmap = new Bitmap(Window.textures.bubbleRT);
			bubbleRT.x = settings.width - 22;
			bubbleRT.y = bubbleRT.height + 10;
			layer.addChild(bubbleRT);
			
			layer.addChild(background);
			
			var ribbon:Bitmap = backingShort(360, 'ribbonGrenn',true,1.3);
			ribbon.x = settings.width / 2 -ribbon.width / 2;			
			ribbon.y = -49;
			bodyContainer.addChild(ribbon);
			
			back.graphics.beginFill(0xfffcb9, .9);
			back.graphics.drawRect(0, 0, 280, 40);
			back.graphics.endFill();
			back.x = (settings.width - back.width)/2;
			back.y = titleLabel.y + 60;
			back.filters = [new BlurFilter(20, 0, 2)];
			bodyContainer.addChild(back);
			
			updateLabel = drawText(Locale.__e("flash:1485340456870"), {
				fontSize:30,
				autoSize:"left",
				textAlign:"left",
				color:0xfedb39,
				borderColor:0x7f3d0e,
				multiline:true
			});
			
			updateLabel.wordWrap = true;
			updateLabel.width = 380;
			//updateLabel.height = descriptionLabel.textHeight;
			updateLabel.x = (settings.width - updateLabel.textWidth) / 2;
			updateLabel.y = back.y;
			bodyContainer.addChild(updateLabel);
		
			/*bodyContainer.addChild(titleLabel);
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = bg.y - titleLabel.height/2 + 5;*/
			descriptionLabel.x = (settings.width - descriptionLabel.textWidth) / 2;
			descriptionLabel.y = titleLabel.y + 110;
		
			/*drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, titleLabel.y + 10, true, true);
			drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, background.y + 75, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, background.y + background.height - 70);*/
			
			bodyContainer.addChild(descriptionLabel);
			drawImage();
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1382952380228'),
				fontSize:34,
				width:(App.lang=="en")?185:170,
				height:54,
				hasDotes:false
			});
				
			bodyContainer.addChild(okBttn);
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - okBttn.height - 10;
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
			
			if (!canTell) return;
			
			tellBttn = new CheckboxButton( {
				checked			:CheckboxButton.CHECKED,
				uncheked		:CheckboxButton.UNCHECKED,
				fontSize		:24,
				fontSizeUnceked	:24,
				multiline		:false,
				wordWrap		:false,
				border			:false,
				fontColor		:0x7f3d0e
			} );
			//tellBttn.x = 60;
			//tellBttn.y = settings.height - 126 + (60 - tellBttn.height) / 2;
			tellBttn.x = 150;//(settings.width - tellBttn.width)/2 + ((App.lang=="en")?95:55);
			tellBttn.y = settings.height - 130;
			//tellBttn.checkedBg.x -= 190;
			//tellBttn.checkedBg.y += 3;
			//tellBttn.uncheckedBg.x -= 190;
			//tellBttn.uncheckedBg.y += 3;
			bodyContainer.addChild(tellBttn);
			
			var items:Object = { 3:1 };
			
			
			var textField:TextField = Window.drawText(Locale.__e('flash:1402902582833'), {
				color:			0xF0E0E0,
				borderColor:	0x222222,
				fontSize:		21,
				autoSize:		'left'
			});
			textField.x = tellBttn.x + tellBttn.width + 12;
			textField.y = tellBttn.y + 6;
			//bodyContainer.addChild(textField);				
			
			var extra:ExtraReward = new ExtraReward(action.reward);
			bodyContainer.addChild(extra);
			extra.x = settings.width - extra.bg.width + 200;
			extra.y = background.height - extra.height - 220;
			
			//var rewards:RewardList = new RewardList(/*66, 66,*/ items, false, 0, "", 1, 44, 16, 44, "x", 0.6, -20, 10, 0x005571/*, { padding:16 }*/);
			//rewards.x = extra.x - 170;
			//rewards.y = extra.y + 135;
			//
			//bodyContainer.addChild(rewards);
		}
		
		private function onOkBttn(e:MouseEvent):void {
			
			if (okBttn.mode == Button.DISABLED) {
				return;
			}
			
			if (canTell && tellBttn.checked == CheckboxButton.CHECKED) {
				sendPost();
			}else {
				//new ShopWindow( { section:100, page:0, glowUpdate:true, currentUpdate:settings.news.nid} ).show();
			}
			
			new ShopWindow( { section:100, page:0, glowUpdate:true, currentUpdate:settings.news.nid} ).show();
			close();
			
			//Pigeon.pigeon.parent.removeChild(Pigeon.pigeon);
			
			//Pigeon.dispose();
		}
		
		private var preloader:Preloader = new Preloader();
		private var background:Bitmap;
		private var bg:Bitmap;
		private var image:Bitmap;
		private function drawImage():void {
			
			//bodyContainer.addChild(preloader);
			preloader.x = (settings.width )/ 2;
			preloader.y = 50;
			
			Load.loading(Config.getImageIcon('updates/images', action.preview, 'jpg'), function(data:Bitmap):void 
			{
				//bodyContainer.removeChild(preloader);
				image = new Bitmap(data.bitmapData);
				//bodyContainer.addChildAt(image, 0);
				//image.x = (settings.width - image.width) / 2;
				//image.y = -image.height;
			});
		}
		
		private var randomKey:String;
		public function sendPost():void {
			okBttn.state = Button.DISABLED;
			
			/*randomKey = Config.randomKey;
			var linkType:String = '?ref=';
			if (App.isSocial('VK','MM')) linkType = '#';
			var url:String = Config.appUrl + linkType + 'oneoff' + randomKey + 'z';*/
			
			if (image != null) {
				WallPost.makePost(WallPost.UPDATE, {btm:image});
			}			
		}
		
		private function onPostComplete(result:*):void {
			okBttn.state = Button.NORMAL;
			
			if (!result || result == 'null') return;
			
			var items:Object = { };
			items[Stock.FANT] = 1;
			
			tellBttn.state = CheckboxButton.UNCHECKED;
			tellBttn.disable();
			
			App.user.stock.addAll(extra.extra);
			App.ui.upPanel.update(/*['fants']*/);
			canTell = false;
			
			if (App.user.settings.hasOwnProperty('upd')) {
				var array:Array = App.user.settings.upd.split('_');
				if (!array[2] || array[2] == '0') {
					array[2] = 1;
					App.user.storageStore('upd', array.join('_'), true, { tell:1} );
				}
			}
			
			//Post.send( {
				//ctr:	'oneoff',
				//act:	'set',
				//uID:	App.user.id,
				//id:		randomKey
				////news:	1					// +1 fant
			//}, function(error:int, data:Object, params:Object):void {});
			
			new ShopWindow( { section:100, page:0, glowUpdate:true, currentUpdate:settings.news.nid} ).show();
		}
	}
}

import core.Numbers;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.NewsWindow;
import wins.RewardList;
import wins.Window;
import wins.ExtraBonusList;

internal class ExtraReward extends Sprite
{
	public var extra:Object = new Object();
	public var bg:Bitmap;
	
	public function ExtraReward(reward:Object) 
	{
		for (var i:int = 1; i <= Numbers.countProps(reward.c);i++)
		{
			extra[reward.m[i]] = reward.c[i];
		}
		//extra = {27:1};
		
		bg = Window.backing(210, 125, 50, "tipUp");
		addChild(bg);
		bg.y += 80;
		//bg.y = window.okBttn.y;
		
		drawTitle();
		drawReward();
	}
	
	private function drawTitle():void 
	{
		var title:TextField = Window.drawText(Locale.__e("flash:1428049916402"), {
			fontSize	:18,
			color		:0xffffff,
			borderColor	:0x005571,
			textAlign   :'center',
			multiline   :true,
			wrap        :true
		});
		title.width = bg.width - 50;
		title.x = 23;
		title.y = 95;
		
		addChild(title);
	}
	
	private function drawReward():void 
	{
		var reward:ExtraBonusList = new ExtraBonusList(extra, false);
		addChild(reward);
		reward.x = bg.x + (bg.width - reward.width) / 2 - 10;
		reward.y = bg.height - reward.height + 50;
		
		/*var icon:Bitmap = new Bitmap(Window.textures.viralAborigine);
		addChild(icon);
		icon.x = 140;
		icon.y = 20;*/
	}
}