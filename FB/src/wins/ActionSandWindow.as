package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import com.adobe.images.BitString;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import utils.ActionsHelper;
	/**
	 * ...
	 * @author ...
	 */
	public class ActionSandWindow extends Window 
	{
		private var _descriptionSprite:Sprite;
		private var _actionImageSprite:Sprite;
		private var _bubblesSprite:Sprite;
		private var _pID:Object;
		private var _premiumItem:Object;
		private var _action:Object;
		private var _priceBttn:Button;
		private var _items:Array;
		private var _tween:TweenLite;
		private var _timeOutId:Array;
		
		private var descText:TextField
		private var descPrms:Object;
		public function ActionSandWindow(settings:Object=null) 
		{
			_pID = settings.pID;
			_action = App.data.actions[_pID];
			_action['id'] = _pID;
			
			if (settings == null) {
				settings = { };
			}
			
			for (var i:String in _action.items) {
				_premiumItem = App.data.storage[i];
			}
			initDesc();
			settings['background'] 			= 'capsuleWindowBacking';
			settings['hasPaginator'] 		= false;
			settings['exitTexture'] 		= 'closeBttnMetal';
			settings['ribbon'] 				= 'ribbonGrenn';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x116011;
			settings['borderColor'] 		= 0x116011;
			settings['shadowBorderColor']	= 0x116011;
			settings['fontSize'] 			= 42;
			settings['fontBorderSize'] 		= 2;
			settings['title'] 				= (_action.text1) ? _action.text1 : _premiumItem.title;
			settings['width'] 				= 500;				
			settings['height'] 				= 400 + descText.height;					
			
			
			super(settings)
			
		}
		
		private function initDesc():void 
		{
			descPrms = {
				color			:0x804015,
				borderSize		:0,
				width			:400,
				//height			:descriptionBg.height - 50,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:22
			}
			if (_action.text2)
				descText = Window.drawText(_action.text2, descPrms); 
			else
				descText = Window.drawText(_premiumItem.description, descPrms);
		}
		
		override public function drawBody():void 
		{
			exit.y -= 25;
			
			drawActionPicture();
			drawDescription();
			drawPriceButton();
			drawBubbles();
			build();
			drawRibbon();
			titleLabel.y = -55;

		}
		
		private function build():void 
		{
			_actionImageSprite.x = (settings.width - _actionImageSprite.width) / 2;
			_actionImageSprite.y = 0;
			
			_descriptionSprite.x = (settings.width - _descriptionSprite.width) / 2;
			_descriptionSprite.y = _actionImageSprite.y + _actionImageSprite.height + 5;
			
			_priceBttn.x = (settings.width - _priceBttn.width) / 2;
			_priceBttn.y = settings.height - _priceBttn.height - 18;
			
			bodyContainer.addChild(_actionImageSprite);
			bodyContainer.addChild(_descriptionSprite);
			bodyContainer.addChild(_priceBttn);
			bodyContainer.addChild(_bubblesSprite);
		}
		
		private function drawActionPicture():void 
		{
			_actionImageSprite = new Sprite();
			var actionImageBg:Bitmap = backing2(settings.width - 80 , 250, 45, 'calImgUp', 'calImgBot');
			var maska:Shape = new Shape();
			var actionImage:Bitmap = new Bitmap(new BitmapData(actionImageBg.width, actionImageBg.height));
			
			actionImageBg.x = 0
			actionImageBg.y = 0
			_actionImageSprite.addChild(actionImageBg);
			Load.loading( Config.getImage('actions', _action.picture, 'jpg'), function(data:Bitmap):void {
				
				var point:Point = new Point(Math.abs(data.width - actionImageBg.width) / 2, Math.abs(data.height - actionImageBg.height) / 2);
				actionImage.bitmapData.copyPixels(data.bitmapData, new Rectangle(point.x, point.y, actionImageBg.width, actionImageBg.height), new Point(0, 0));
				
				maska.graphics.beginFill(0xFFFFFF, 1);
				maska.graphics.drawRoundRect(0, 0, actionImageBg.width-8, actionImageBg.height-8, 40, 40);
				maska.graphics.endFill();
				
				actionImage.x = (actionImageBg.width - actionImage.width) / 2;
				actionImage.y = (actionImageBg.height - actionImage.height) / 2;;
				maska.x = (actionImageBg.width - maska.width) / 2;
				maska.y = (actionImageBg.height - maska.height) / 2;
				
				maska.cacheAsBitmap = true;
				actionImage.mask = maska;
				
				if (_action.hasOwnProperty('picture'))
				{
					_actionImageSprite.addChild(maska);
					_actionImageSprite.addChild(actionImage);
				}
				drawRibbon();
				titleLabel.y = -54;
				data = null;
			});
		}
		
		private function drawDescription():void 
		{
			var descTextSprite:Sprite = new Sprite();
			_descriptionSprite = new Sprite();
			
			var price:Number = _action.price[App.social];                                     
				price = price / (1 - _action.profit * .01);
				price = Math.round(price);
			var priceLabel:Object = ActionsHelper.priceLable(price);
			var back:Shape = new Shape();
			
			var descriptionBg:Bitmap = Window.backing(settings.width - 80, 80 + descText.height, 45, 'itemBacking');

			//if (descText.height > 130) descText.height = 130;
			back.graphics.beginFill(0xfff6db, 1);
		    back.graphics.drawRect(0, 0, descriptionBg.width - 90, descText.textHeight + 15);
		    back.graphics.endFill();
		   
		    back.filters = [new BlurFilter(20, 0, 2)];
			
			var oldPriceText:TextField = Window.drawText(Locale.__e('flash:1407398101201'), {
				color			:0xffffff,
				borderColor		:0x9d6638,
				textAlign		:'center',
				fontSize		:30
			});	
			oldPriceText.width = oldPriceText.textWidth + 5;
			var oldPrice:TextField = Window.drawText(Locale.__e(priceLabel.text, [priceLabel.price]), {
				color			:0xffe610,
				borderColor		:0x7f3d0e,
				textAlign		:'center',	
				fontSize		:36
			});	
			oldPrice.width = oldPrice.textWidth + 5;
			
			var redLine:Bitmap = new Bitmap(Window.textures.redLines);
				redLine.scaleX = redLine.scaleY = 3;
				Size.size(redLine, oldPrice.textWidth, oldPrice.height);
				redLine.smoothing = true;
				
			back.x = (descriptionBg.width - back.width) / 2 ;
			back.y = 15;
			
			
			
			/*oldPriceText.x = descriptionBg.x + (descriptionBg.width - oldPriceText.width) / 2;
			oldPriceText.y = descriptionBg.height - oldPriceText.height - 10;*/
			oldPrice.x = oldPriceText.x + oldPriceText.width + 10
			oldPrice.y = oldPriceText.y - Math.abs(oldPriceText.height - oldPrice.height) + 2;
			
			redLine.x = oldPrice.x + (redLine.width - oldPrice.width) / 2;
			redLine.y = oldPrice.y  + 5;/*+ (redLine.height - oldPrice.textHeight) / 2;*/
				
			_descriptionSprite.addChild(descriptionBg);
		    _descriptionSprite.addChild(back);
		    _descriptionSprite.addChild(descText);
			if (_action.profit > 0)
			{
				descTextSprite.addChild(oldPriceText);
				descTextSprite.addChild(oldPrice);
				descTextSprite.addChild(redLine);
				
				descTextSprite.x = descriptionBg.x + (descriptionBg.width - descTextSprite.width) / 2;
				descTextSprite.y = descriptionBg.height - descTextSprite.height - 10;
				
				_descriptionSprite.addChild(descTextSprite);
			
			}
			trace();
		}
		
		private function drawPriceButton():void 
		{			
			var price:Number = _action.price[App.social];
			var priceLable:Object = ActionsHelper.priceLable(price);
			
			var bttnSettings:Object = {
				fontSize	:((App.isJapan())) ? 20 : 28,
				width		:186,
				height		:52,
				hasDotes	:false,
				caption		:Locale.__e(priceLable.text, [priceLable.price])
			};
			
			_priceBttn = new Button(bttnSettings);
			
			if (Payments.byFants) {
				
				_priceBttn.fant();
			}
			
			if(App.isSocial('MX')){
				var mixiLogo:Bitmap = new Bitmap(Window.textures.mixieLogo);
				_priceBttn.topLayer.addChild(mixiLogo);
				_priceBttn.fitTextInWidth(_priceBttn.width - (mixiLogo.width + 10));
				_priceBttn.textLabel.width = _priceBttn.textLabel.textWidth + 5;
				_priceBttn.textLabel.x = (_priceBttn.width - (_priceBttn.textLabel.width + mixiLogo.width + 5)) / 2 + mixiLogo.width + 5;
				mixiLogo.x = _priceBttn.textLabel.x - mixiLogo.width - 5 ;
				mixiLogo.y = (_priceBttn.height - mixiLogo.height) / 2;
			}
			
			_priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
		}
		override public function drawBubbles():void 
		{
			_items = [];
			_timeOutId = [];
			_bubblesSprite = new Sprite();
			var Xs:int = -50;
			var Ys:int = 50;
			//var treasure:String = (_premiumItem.treasure == '' || _premiumItem.treasure == null) ? _premiumItem.shake :_premiumItem.treasure
			var items:Array = Numbers.objectToArraySidCount(_action.bonus);
			//var items:Array = Numbers.objectToArraySidCount(Treasures.convertToObject(treasure));
			var counter:int = 0;
			for (var i:int = 0; i < items.length; i++) 
			{
				var item:BubbleItem = new BubbleItem(items[i]);
				_bubblesSprite.addChild(item)
				item.x = (_actionImageSprite.width - item.width) / 2;
				item.y = (_actionImageSprite.height - item.height) / 2;
				item.alpha = 0;
				_items.push(item)
				
				var	timeOut:uint = setTimeout(function ():void {
					_tween = TweenLite.to(_items[counter], .55, {x:Xs, y:Ys, alpha:1, scaleX:1, scaleY:1});
					if ((counter + 2) % 2 == 0)
					{
						Xs = settings.width - 50;
					}else{
						Ys += _items[counter].width + 15;
						Xs = -50
					}
					counter++
				}, i * 100);
				_timeOutId.push(timeOut);
			}
		}
		
		override public function drawBackground():void 
		{
			var sand:Bitmap = new Bitmap(Window.textures.sandImage);
			sand.x = (settings.width - sand.width) / 2;
			sand.y = (settings.height - sand.height) + 80;
			layer.addChild(sand)
			super.drawBackground(); 
			
			
		}
		private function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
			for (var _sid:* in _action.items) {
				if (App.data.storage.hasOwnProperty(_sid)){
					if (_action.checkstock && _action.checkstock == 1 && Stock.isExist(_sid)){
						return;
					}
				}
			}	
			e.currentTarget.state = Button.DISABLED;
			
			switch(App.social) {
				case 'PL':
					if(App.user.stock.take(Stock.FANT, _action.price[App.social])){
						Post.send({
							ctr:'Promo',
							act:'buy',
							uID:App.user.id,
							pID:_action.id,
							ext:App.social
						},function(error:*, data:*, params:*):void {
							onBuyComplete();
						});
					}else {
						close();
					}
					break;
				case 'AM':
					Post.send({
						ctr:'Orders',
						act:'createOrder',
						uID:App.user.id,
						type:"promo", 
						pos: _action.id
					}, function(error:*, data:*, params:*):void {
						navigateToURL(new URLRequest(data.transactionUrl),"_parent");
					});
					break;
				case 'SP':
					if(App.user.stock.take(Stock.FANT, _action.price[App.social])){
						Post.send({
							ctr:'Promo',
							act:'buy',
							uID:App.user.id,
							pID:_action.id,
							ext:App.social
						},function(error:*, data:*, params:*):void {
							if (!error)
								onBuyComplete();
						});
					}else {
						close();
					}
					break;
				default:
					var object:Object;
					if (App.social == 'FB') {
						ExternalApi.apiNormalScreenEvent();
						object = {
							id:		 		_action.id,
							type:			'promo',
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback:		onBuyComplete
						};
					}else{
						object = {
							count:			1,
							money:			'promo',
							type:			'item',
							item:			'promo_' + _action.id,
							votes:			_action.price[App.social],
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback: 		onBuyComplete
						}
					}
					ExternalApi.apiPromoEvent(object);
					break;
			}
		}
		
		private function onBuyComplete(e:* = null):void 
		{
			_priceBttn.state = Button.DISABLED;
			var showWindow:Boolean = true;
			
			if (!User.inExpedition)
			{
				App.user.stock.addAll(_action.items);				
				var bonus:BonusItem = new BonusItem(_premiumItem.sID, 1);
				var point:Point = Window.localToGlobal(_premiumItem);
				bonus.cashMove(point, App.self.windowContainer);				
			}
			
			App.user.updateActions();
			App.user.buyPromo(String(_pID));
			App.ui.salesPanel.createPromoPanel();
			
			close();
			
			if(showWindow){
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					title:Locale.__e("flash:1382952379735"),
					text:Locale.__e("flash:1382952379990")
				}).show();
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			_items = [];
			_priceBttn.removeEventListener(MouseEvent.CLICK, buyEvent);
			for (var i:int = 0; i < _timeOutId.length; i++) 
			{
				//clearTimeout(i);
				clearTimeout(_timeOutId[i]);
			}
			if (_timeOutId)
				_timeOutId = [];
			if (_tween && _tween.active)
			{
				_tween.kill();
				_tween = null;
			}
		}
	}
}

import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import silin.bitmap.DistortBitmap;
import ui.UserInterface;
import wins.Window;

internal class BubbleItem extends Sprite
{
	
	public var count:uint;
	public var sID:uint;
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	
	private var preloader:Preloader = new Preloader();
	private var bonus:Boolean = false;
	private var sprite:LayerX;
	
	public function BubbleItem(item:Object)
	{
		sID = Numbers.firstProp(item).key;
		count = Numbers.firstProp(item).val;
		var type:String = App.data.storage[sID].type;
		var preview:String = App.data.storage[sID].preview;
		
		sprite = new LayerX();
		addChild(sprite);
		drawBg();
		Load.loading(Config.getIcon(type, preview), onIconLoad);
	}
	
	private function drawBg():void
	{
		background = new Bitmap(Window.textures.bubbleBackingBig);
		Size.size(background, 100, 100)
		background.smoothing = true;
		sprite.addChild(background);
	}
	private function onIconLoad(data:Bitmap):void
	{
		bitmap = new Bitmap();
		bitmap.bitmapData = data.bitmapData;
		Size.size(bitmap, background.width * 0.75, background.height * 0.75);
		bitmap.smoothing = true;
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
		
		sprite.tip = function():Object
		{
			return {title: App.data.storage[sID].title, text: App.data.storage[sID].description};
		}
		sprite.addChildAt(bitmap, 0);
		drawCount();
	}
	
	private function drawCount():void
	{
		var countText:TextField = Window.drawText('x' + String(count), {color: 0xffffff, borderColor: 0x603024, textAlign: "left", autoSize: "left", fontSize: 32, multiline: true});
		countText.x = background.width - 40;/*- countText.width*/;
		countText.y = background.height - countText.height;
		sprite.addChild(countText);
	}
}