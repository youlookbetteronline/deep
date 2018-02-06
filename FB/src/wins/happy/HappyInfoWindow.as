package wins.happy 
{
	import buttons.Button;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class HappyInfoWindow extends Window {
	
		public var items:Array = new Array();
		private var back:Bitmap;
		private var okBttn:Button;
		//public var currentDayItem:FriendRewardItem;
	//	public var friendsCount:int = 6;
		public var giftStage:int = 3;
		
		public function HappyInfoWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 				= 740;
			settings['height'] 				= 310;
			settings['title'] 				= /*settings.target.info.title || */Locale.__e('flash:1443707065028');;
			settings['hasPaginator'] 		= false;
			settings['content'] 			= [];
			settings['fontSize'] 			= 44;
			settings['escExit'] 			= true;
			settings['autoClose'] 			= true;
			settings['popup'] 				= true;
			settings['shadowBorderColor']   = 0x372e26;
			settings['fontBorderSize'] 		= 4;
			settings['background'] 			= 'questBacking';
			
			countReward = Numbers.countProps(App.data.storage[settings.sid].tower);
			if (App.data.storage[settings.sid].type == 'Thappy')
			{
				countReward = Numbers.countProps(App.data.storage[settings.sid].top.tr) - 1;
			}
			settings.width = (countReward  > 2)? (countReward * 120 + 60) : (3 * 120 + 60);
			super(settings);
		}
		
		override public function drawBody():void {
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -44, true, true);
			drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, settings.height - 120 + 6);
			drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, 35, false, false, false, 1, -1);
			
			var descLabel:TextField = Window.drawText(Locale.__e("flash:1450194731590"), {
				fontSize	:28,
				color		:0x6e461e,
				borderColor	:0xffffff,
				textAlign	:"center"
			});
			descLabel.width = descLabel.textWidth + 20;
			descLabel.x = titleLabel.x + (titleLabel.width - descLabel.width) / 2;
			descLabel.y = 0;
			bodyContainer.addChild(descLabel);
			
			if (App.lang != 'ru') descLabel.visible = false;
			
			drawItems();
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1382952379995'),
				fontSize:28,
				width:168,
				height:44
			});
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height - 82;
			bodyContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, close);
			exit.y -= 15;
		}
		
		private var container:Sprite;
		private var countReward:int = 0;
		private function drawItems():void {
			var __width:int = (countReward  > 2)? (countReward * 120 + 20) : (3 * 120 + 20);
			var bk2:Bitmap = Window.backing(__width, 190, 50, 'windowDarkBacking');
			bk2.x = (settings.width - bk2.width) / 2;
			bk2.y = 35;
			bodyContainer.addChild(bk2);
			
			container = new Sprite();
			
			var X:int = 0;
			var Y:int = -10;
			var arrItems:Array = new Array();
			
			for (var i:int = 1; i <= countReward + 1; i++) {
				
				var item:HappyInfoItem = new HappyInfoItem(getReward(i), getIndex(i));
				item.x = X;
				item.y = Y;
				item.scaleX = item.scaleY = 0.9;
				container.addChild(item);
				arrItems.push(item);
				
				X += item.bg.width - 18;
				
				if (settings.update + 1 == i) {
					item.rewardCont.showGlowing();
				}
			}
			
			container.x = (settings.width - container.width) / 2;
			container.y = 65;
			bodyContainer.addChild(container);
		}
		
		protected function getIndex(index:int):int {
			if (index == countReward ) return 100;
			if (index == countReward + 1) return 10;
			
			return index;
		}
		
		protected function getReward(i:int):int 
		{
			if (App.data.storage[settings.sid].hasOwnProperty('tower') &&  App.data.storage[settings.sid].tower.hasOwnProperty(i)) {
				var items:Object = App.data.treasures[App.data.storage[settings.sid].tower[i].t][App.data.storage[settings.sid].tower[i].t].item;
				for each(var s:* in items) {
					if (['Decor', 'Golden', 'Clothing', 'Box', 'Walkgolden'].indexOf(App.data.storage[s].type) >= 0) 
						return int(s);
				}
			}
			var __info:Object = App.data.storage[settings.sid];
			var tresure:String = '';
			if (__info.top && __info.top.tr && __info.top.tr.hasOwnProperty(i-1)) {
				items = App.data.treasures[ __info.top.tr[i-1]][__info.top.tr[i-1]].item;
				for each(s in items) {
					if (['Decor', 'Golden', 'Clothing', 'Box', 'Walkgolden'].indexOf(App.data.storage[s].type) >= 0) 
						return int(s);
				}
			}
			if ((settings.sid == 2486) && i == 6) return 2491;
			if ((settings.sid == 3225) && i == 6) return 3230;
			if (settings.sid == 2877 && i == 7) return 2925;
			
			return 0;// details[sid].defaultReward;
		}
	}
}



import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import ui.UserInterface;
import wins.FriendsRewardWindow;
import wins.Window;	

internal class HappyInfoItem extends LayerX {
	
	private var item:Object;
	public var bg:Bitmap;
	public var win:FriendsRewardWindow;
	private var title:TextField;
	private var title2:TextField;
	private var sID:uint;
	private var count:uint;
	private var bitmap:Bitmap;
	public var status:int = 0;
	public var itemDay:int;
	private var check:Bitmap = new Bitmap(Window.textures.checkmarkSlim);
	private var layer:LayerX;
	private var intervalPluck:int;
	public var isCurrent:Boolean = false;
	protected var rewardDescLabel:TextField;
	private var sidI:int;
	
	public function HappyInfoItem(it:int, ind:int) {
		sidI = it;

		bg = Window.backing(120, 175, 10, "itemBacking");
		addChild(bg);
		
		updateReward();
		
		if (sidI != 0) {
			rewardDescLabel = Window.drawText(App.data.storage[sidI].title, {
				textAlign:		'center',
				fontSize:		22,
				color:			0x6e461e,
				borderColor:	0xffffff,
				width:			bg.width - 10,
				distShadow:		0,
				wrap:			true,
				multiline:		true
			});	
			
			addChild(rewardDescLabel);
			rewardDescLabel.x = 5;
			rewardDescLabel.y = 15;
		}
		
		var text:String = Locale.__e('flash:1418735019900', [ind]);
		if (ind == 100) {
			text = Locale.__e('flash:1447777838042');
			text = text.replace('10', ind.toString());
			//text = Locale.__e('flash:1447777838042');
		}else if (ind == 10) {
			text = Locale.__e('flash:1443607405764');
		}
		
		title = Window.drawText(text, {
			textAlign:		'center',
			fontSize:		26,
			color:			0x6e461e,
			borderColor:	0xffffff,
			width:			bg.width
		});
		title.y = bg.y - 15;
		addChild(title);
		
	}
	
	public var rewardCont:LayerX;
	private var reward:Bitmap;
	private function updateReward():void 
	{
		var sid:int = sidI;
		
		if (!rewardCont) {
			rewardCont = new LayerX();
			rewardCont.tip = function():Object {
				if (sid == 0) {
					return {
						title:title.text,
						text:''
					}
				}
				
				return {
					title:App.data.storage[sid].title,
					text:App.data.storage[sid].description
				}
			}
			addChild(rewardCont);
			
			reward = new Bitmap();
			reward.bitmapData = null;
			rewardCont.addChild(reward);
		}
		
		if (App.data.storage[sid]) {
			var link:String = Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview);
			
			Load.loading(link, function(data:Bitmap):void {
				reward.bitmapData = data.bitmapData;
				reward.smoothing = true;
				
				Size.size(reward, bg.width * 0.85, bg.height * 0.75);
				
				rewardCont.x = bg.x + (bg.width - reward.width) / 2;
				rewardCont.y = bg.y+(bg.height - reward.height)/ 2 + 15;
			});
		}else {
			var symbolLabel:TextField = Window.drawText('?', {
				fontSize:		128,
				autoSize:		'center',
				color:			0x6e461e,
				borderColor:	0xffffff
			});
			addChild(symbolLabel);
			symbolLabel.x = bg.x + bg.width * 0.5 - symbolLabel.width * 0.5;
			symbolLabel.y = bg.y + bg.height * 0.5 - symbolLabel.height * 0.5 + 15;
		}
	}
	
	public function dispose():void {}
}

