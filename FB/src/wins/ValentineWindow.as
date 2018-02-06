package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Hints;
	import units.Building;
	import units.Techno;
	import units.Unit;
	import wins.elements.OutItem;
	public class ValentineWindow extends PergamentWindow
	{
		private var sID:uint;
		public var container:Sprite = new Sprite();
		
		public var items:Vector.<ValentineItem> = new Vector.<ValentineItem>;
		
		public function ValentineWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
				settings = new Object();
			}
			
			settings["width"] = 500;
			settings["height"] = 340;
			settings["popup"] = true;
			settings["title"] = Locale.__e('flash:1486375488486');
			settings["fontSize"] = 38;
			settings["fontColor"] = 0xfffa74
			settings["faderAlpha"] = 0.2;
			settings["textLeading"] = -5;
			settings["callback"] = settings["callback"] || null;
			settings["dontCheckTechno"] = settings["dontCheckTechno"] || false;
			settings["hasPaginator"] = false;
			settings["description"] = '';
			settings['shadowBorderColor'] = 0xffffff;
			settings['description'] = Locale.__e('flash:1486553641849');
			
			super(settings);	
		}
		
		override public function drawExit():void
		{
			super.drawExit();
			
			exit.x = settings.width - exit.width;
			exit.y = -3;
		}
	
			
		override public function drawBody():void 
		{			
			drawDescription();
			createItems(settings.content);
		}
		
		private var preloader:Preloader = new Preloader();
		private var count:int = 0;
		
		protected function createItems(materials:Object):void
		{
			var dX:int = 0;
			var count:int = 0;
			
			for(var _sID:* in materials) 
			{
				var inItem:ValentineItem = new ValentineItem({
					sid			:_sID
				}, this);
				
				items.push(inItem);
				
				container.addChild(inItem);
				inItem.x = dX;
				inItem.y = 0;
				count++;
				
				dX += 270;
			}

			bodyContainer.addChild(container);
			container.y = 120;
			container.x = 60;
		}
		
		private function clear():void 
		{
	
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		
	}	
}
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import wins.SimpleWindow;
	import wins.BanksWindow;
	import wins.ValentineWindow;
	import wins.AskRewardsWindow;
	import wins.AskWindow;
	import wins.Window;

	internal class ValentineItem extends LayerX
	{	
		public var window:*;
		public var item:Object;
		public var bg:Bitmap;
		public var bttn:Button;
		
		private var bitmap:Bitmap;
		private var count:uint;
		private var nodeID:String;
		public var friend:String;
		private var type:uint;
		private var k:uint;
		private var sID:uint;
		private var icon:Bitmap;
		private var sprite:LayerX;
		private var socialPriceButton:Button;
		public var info:Object;
		private var stockCount:TextField;
		
		public var callBack:Function = new Function();
		public function ValentineItem(obj:Object, window:*) 
		{
			this.sID = obj.sid;
			this.item = App.data.storage[sID];
			this.window = window;
			type = obj.t;
			
			bg = Window.backing(110, 110, 20, 'itemBacking');
			//addChild(bg);
			
			bitmap = new Bitmap();
			//addChild(bitmap);

			info = App.data.storage[sID];
			//drawTitle();
			drawBttn();
			
			
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
			
			tip = function():Object {
				return {
					title: item.title,
					text: item.description
				}
			}
		}
		/*private function get price():int 
		{
			if (type == 2) 
			{
				for (var s:* in item.price) break;
				return item.price[s];
			}
			
			return 1;
		}*/
		
		private function drawBttn():void
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379978"),
				width:160,
				height:50,
				fontSize:24
			}
			
			/*if (item.real == 0 || type == 1)
			{
				bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
				bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
				bttnSettings['fontColor'] = 0x453b5f;
				bttnSettings['fontBorderColor'] = 0xe3eff1;
				
				bttn = new Button(bttnSettings);
			}
			*/
			if (item.price) 
			{
				bttnSettings['bgColor'] = [0x66b9f0, 0x567ace];
				bttnSettings['borderColor'] = [0xcce8fa, 0x4465b6];
				bttnSettings['bevelColor'] = [0xf8d8b5, 0x4465b6];
				bttnSettings['fontColor'] = 0xffffff;
				bttnSettings['fontBorderColor'] = 0x2b4a84;
				bttnSettings['fontCountColor'] = 0xffffff;
				bttnSettings['fontCountSize'] = 24;
				bttnSettings['fontCountBorder'] = 0x2b4a84;
				bttnSettings['countText']	= item.price[Stock.FANT];
				
				bttn = new MoneyButton(bttnSettings);
				
				bttn.x = -30;
				bttn.y = 110;
				addChild(bttn);
				callBack = onClick;
				bttn.addEventListener(MouseEvent.CLICK, chooseFriend);
				checkButtonsStatus();
			}
			if (item.socialprice) 
			{
				/*bttnSettings['bgColor'] = [0x66b9f0, 0x567ace];
				bttnSettings['borderColor'] = [0xcce8fa, 0x4465b6];
				bttnSettings['bevelColor'] = [0xf8d8b5, 0x4465b6];
				bttnSettings['fontColor'] = 0xffffff;
				bttnSettings['fontBorderColor'] = 0x2b4a84;
				bttnSettings['fontCountColor'] = 0xffffff;
				bttnSettings['fontCountSize'] = 24;
				bttnSettings['fontCountBorder'] = 0x2b4a84;
				bttnSettings['countText']	= item.price[Stock.FANT];
				
				bttn = new MoneyButton(bttnSettings);*/
				drawSocialPriceBttn();
			}
			
			/*if (type == 3) 
			{
				bttn = new Button(bttnSettings);
			}*/
			
		}
		
		public function drawSocialPriceBttn():void 
		{
			if (item.hasOwnProperty('socialprice') && item.socialprice.hasOwnProperty(App.social)) 
			{
				var _count:Number = item.socialprice[App.social];
				
				socialPriceButton = new Button( {
					caption:Payments.price(_count),
					width:160,
					height:50,
					fontSize:24,
					shadow:true,
					type:"green",
					bgColor:[0xfed131, 0xf8ab1a],
					borderColor:[0xf7fe9a, 0xcb6b1e],
					bevelColor:[0xfaed73, 0xcb6b1e],
					fontColor:0xffffff,
					fontBorderColor:0x7f3d0e,
					fontCountColor:0xffffff,
					fontCountSize:24,
					fontCountBorder:0x7f3d0e	
				});
				
				switch(App.SOCIAL)
				{
					case 'AI':
					case 'GN':
						socialPriceButton.caption = Payments.price(_count) + ' ゲソコイン';
						break;
					default:
						socialPriceButton.caption = Payments.price(_count);
						break;
				}
				
				addChild(socialPriceButton);
				callBack = onSocialBuyClick;
				socialPriceButton.addEventListener(MouseEvent.CLICK, chooseFriend)
				socialPriceButton.x = -25;
				socialPriceButton.y = 110;
				
			}
		}
		
		private function onSocialBuyClick():void 
		{
			//if (e.currentTarget.mode == Button.DISABLED) return;
			
			var bObject:Object;
			
			if (App.social == 'FB') 
			{
				bObject = {
					id:		 	item.sID,
					type:		'Energy',
					callback: socialCallback
				};
			}else if (App.social == 'GN') 
			{
				bObject = {
					itemId:		item.type+"_" + item.sID,
					price:		int(item.socialprice[App.social]),
					amount:		1,
					itemName:	item.title,
					callback:	socialCallback
				};
			}else if (App.social == 'MX') 
			{
				bObject = {
					money: 		item.type,
					type:		'item',
					item:		item.type+"_"+item.sID,
					votes:		int(item.socialprice[App.social]),
					sid:		item.sID,
					count:		1,
					title:		item.title,
					description:item.description,
					tnidx:		App.user.id + App.time + '-' + item.type + "_" + item.sID,
					callback:	socialCallback
				}
			}else 
			{
				bObject = {
					money: 		'Energy',
					type:		'item',
					item:		'energy'+"_"+item.sID,
					votes:		int(item.socialprice[App.social]),
					sid:		item.sID,
					count:		1,
					title:		Locale.__e('flash:1396521604876'),
					description:Locale.__e('flash:1393581986914'),
					icon:		Config.getIcon(item.type, item.preview),
					tnidx:		App.user.id + App.time + '-' + 'energy' + "_" + item.sID,
					callback:	onPay
				}
			}
			ExternalApi.apiBalanceEvent(bObject);
		}
		
		public function chooseFriend(e:MouseEvent = null):void 
		{
			new AskRewardsWindow(AskWindow.MODE_ASK,  {
				title		:Locale.__e('flash:1382952379978'), 
				desc		:Locale.__e("flash:1486475439221"),
				target		:this,
				width		:705,
				itemsOnPage	:12,
				descY		:30,
				height		:530,
				itemsMode	:5
			}).show();
		}
		
		public function socialCallback():void 
		{
			//App.user.stock.add(item.out, item.count);
			//Window.closeAll();
			
			//onPay();
			/*Post.send( {
				ctr:		'user',
				act:		'sendval',
				uID:		App.user.id,
				wID:		App.map.id,
				sID:		item.sID,
				fID:		App.user.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				//if (data['users']) settings.target.usersLength = data.users;
			});*/
			//{"ctr": "user", "act": "sendval", "uID": " - ", "sID": " - ", "fID": " - "}
		}
		
		
		public function onPay():void
		{
			Window.closeAll();
			Post.send( {
				ctr:		'Walkgift',
				act:		'giftsend',
				uID:		App.user.id,
				wID:		App.map.id,
				pID:		item.sID,
				sID:		1179 /*App.data.storage[item.sID].out*/,
				fID:		friend
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				App.user.stock.takeAll(data.__take)
				
				new SimpleWindow( {
					hasTitle:true,
					height:300,
					title:Locale.__e("flash:1382952379735"),
					text:Locale.__e("flash:1486477799296")
				}).show();
					//if (data['users']) settings.target.usersLength = data.users;
			});
			//window.settings.target
		}
		protected function onBuySocialComplete(sID:uint, rez:Object = null):void
		{
			var currentTarget:Button;
			if (socialPriceButton) currentTarget = socialPriceButton;
			var X:Number = App.self.mouseX - currentTarget.mouseX + currentTarget.width / 2;
			var Y:Number = App.self.mouseY - currentTarget.mouseY;
			
			Hints.plus(item.sID, 1, new Point(X,Y), true, App.self.tipsContainer);
		}
		
		private function onLoadIcon(data:Bitmap):void
		{
			icon.bitmapData = data.bitmapData;
			icon.scaleX = icon.scaleY = 0.35;
			icon.x = 20;
			icon.y = 4;
			icon.smoothing = true;
		}
		
		public function checkButtonsStatus():void
		{		
			if (App.user.stock.count(Numbers.firstProp(item.price).key) < Numbers.firstProp(item.price).val) 
			{
				bttn.state = Button.DISABLED;
			}else {
				bttn.state = Button.NORMAL;
			}
		}
		
		private function onClick():void 
		{
			//if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (App.user.stock.count(Numbers.firstProp(item.price).key) < item.price[Stock.FANT])
			{
				window.close();
				BanksWindow.history = {section:'Reals',page:0};
				new BanksWindow().show();
				return;
			}
			onPay();
			/*if (type == 3 && App.user.stock.count(sID) < 1 && ShopWindow.findMaterialSource(sID))
			{
				window.close();
				return;
			}*/
			
			//window.blockItems();
			//window.settings.target.kickAction(sID, onKickEventComplete);
		}
		
		
		private function onLoad(data:Bitmap):void 
		{
			sprite = new LayerX();
			sprite.tip = function():Object {
				return {
					title: item.title,
					text: item.description
				};
			}
			
			bitmap = new Bitmap(data.bitmapData);
			Size.size(bitmap, 160, 160);
			bitmap.smoothing = true;
			sprite.x = (bg.width - bitmap.width) / 2;
			sprite.y = (bg.height - bitmap.height) / 2;
			sprite.addChild(bitmap);
			addChildAt(sprite, 0);
			
			sprite.addEventListener(MouseEvent.CLICK, searchEvent);
		}
		
		private function searchEvent(e:MouseEvent):void 
		{
			//ShopWindow.findMaterialSource(sID);
		}
		
		public function dispose():void 
		{
			bttn.removeEventListener(MouseEvent.CLICK, onClick);
		}
		
		/*public function drawTitle():void
		{
			var title:TextField = Window.drawText(item.title, {
				color:0x814f31,
				borderColor:0xffffff,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				textLeading:-6,
				multiline:true,
				distShadow:0
			});
			
			title.wordWrap = true;
			title.width = bg.width - 5;
			title.height = title.textHeight;
			title.x = 5;
			title.y = 1;
			addChild(title);
			title.visible = false;
		}*/
		
		
	}
