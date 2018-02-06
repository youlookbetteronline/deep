package wins {
	
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	import units.Anime;
	import units.Unit;

	public class InformerWindow extends Window {
		
		private var items:Array = new Array();
		private var container:Sprite;
		private var priceBttn:Button;
		private var okBttn:Button;
		private var descriptionLabel:TextField;
		private var informer:Object = { };
		public var windowType:int = 0;
		public var animate:Boolean = false;
		private const IMAGE_INDENT:int = 60;
		private const IMAGE_WIDTH:int = 70;
		
		public function InformerWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			
			informer = settings.informer;
			informer['utype'] = App.data.storage[informer.object].type;
			informer['uview'] = App.data.storage[informer.object].view;
			settings['width'] = settings.width || ((informer.winwidth) ? informer.winwidth : ((informer.type == 0) ? 450 : 650));
			settings['height'] = settings.height || ((informer.winheight) ? informer.winheight : 330);
			
			descriptionLabel = drawText(informer.text, {
				fontSize:26,
				autoSize:"left",
				//textAlign:TextFormatAlign.CENTER,
				color:0x502f06,
				borderColor:0x502f06,
				border:false,
				multiline:true
			});
			descriptionLabel.wordWrap = true;
			
			descriptionLabel.width = informer.width;
			descriptionLabel.height = descriptionLabel.textHeight;
			descriptionLabel.x = /*( settings.width - descriptionLabel.width) / 2;*/informer.padding + informer.left;
			
			if (descriptionLabel.numLines > 7)
			{
				var delta:int = (descriptionLabel.numLines - 7) * descriptionLabel.getLineMetrics(0).height;
				settings['height'] = 330 + delta;
			}
			
			settings['title'] = informer.title;
			settings['hasExit'] = false;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontColor'] = 0xffcc00;
			settings['fontSize'] = 60;
			settings['fontBorderColor'] = 0x705535;
			//settings['shadowBorderColor'] = 0x342411;
			//settings['fontBorderSize'] = 8;
			settings['autoClose'] = true;
			
			/*if (informer.utype == 'Golden')
				animate = true;*/
			
			super(settings);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, "paperBacking");
			layer.addChild(background);
		}
		
		override public function drawBody():void {
			bodyContainer.addChild(titleLabel);
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = 10;
			
			descriptionLabel.y = titleLabel.y + titleLabel.height + 30;
			
			bodyContainer.addChild(descriptionLabel);
			drawImage();
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1382952380228'),
				fontSize:22,
				width:200,
				height:40
			});
			if (informer.type == 2) {
				okBttn.x = (settings.width - okBttn.width) / 2;
				okBttn.y = settings.height - okBttn.height - 34;
			} else {
				okBttn.x = (settings.width - okBttn.width) / 2;
				okBttn.y = settings.height - okBttn.height - 15;
			}
			bodyContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
			
			if (descriptionLabel.height < bodyContainer.height) {
				descriptionLabel.y = Math.floor((bodyContainer.height - descriptionLabel.height) / 2) + 10;
			}
		}
		
		private function onOkBttn(e:MouseEvent):void {
		
			if (settings.hasOwnProperty('target') && settings.target) {
				App.map.focusedOn(settings.target, true);
				close();
				return
			}
			switch(informer['rel']) {
				case 2:
					new BanksWindow().show();
					break;
				case 1:
					/*if (App.user.mode == User.OWNER && App.user.worldID == 171) {
						var list:Array = Map.findUnits([1095]);
						if (list.length > 0) {
							list[0].find = informer.object;
							App.map.focusedOn(list[0], true, null, true);
							this.close();
						}else if(User.inUpdate(1095)){
							new ShopWindow( { find:[1095] } ).show();
						}
					}
					break;*/
				case 0:
					new ShopWindow( { find:[informer.object] } ).show();
					break;
				default:
			}
			
			close();
		}
		
		public static var showed:Boolean = false;
		public static function init():void {
			var cookie:Object = App.user.storageRead('inf', { } );
			
			if (showed || !App.data.hasOwnProperty('inform')) return;
			
			var informers:Array = [];
			for (var s:String in App.data.inform) {
				var isSocial:Boolean = false;
				if (App.data.inform[s]['social']) {
					for each(var soc:String in App.data.inform[s].social) {
						if ((soc is String) && soc == App.social)
							isSocial = true;
					}
				}
				
				if (isSocial && App.data.inform[s].enabled && App.data.inform[s].start < App.time && App.data.inform[s].finish > App.time) {
					App.data.inform[s]['id'] = s;
					if (cookie.hasOwnProperty(s) && cookie[s] > App.data.inform[s].count) continue;
					informers.push(App.data.inform[s]);
				}
			}
			informers.sortOn('order', Array.NUMERIC);
			showed = true;
			
			if (informers.length > 0) {
				setTimeout(function(object:Object):void {
					new InformerWindow( {
						informer:	object
					}).show();
					
					if (!cookie.hasOwnProperty(s))
						cookie[s] = 0;
					
					cookie[s]++;
					App.user.storageStore('inf', cookie);
				}, 10000, informers[informers.length - 1]);
			}
		}
		
		private function drawImage():void {
			if (animate) {
				Load.loading(Config.getSwf(informer.utype, informer.uview), function(data:*):void {
					var framesType:String = informer.view;
					for (framesType in data.animation.animations) break;
					
					var image:Sprite = new Sprite();
					image.x = informer.X;
					image.y = informer.Y;
					image.scaleX = image.scaleY = informer.scale;
					bodyContainer.addChildAt(image, 0);
					
					var bitmap:Bitmap = new Bitmap(data.sprites[data.sprites.length - 1].bmp, 'auto', true);
					bitmap.x = data.sprites[data.sprites.length - 1].dx;
					bitmap.y = data.sprites[data.sprites.length - 1].dy;
					image.addChild(bitmap);
					
					var anime:Anime = new Anime(data, framesType, data.animation.ax, data.animation.ay);
					image.addChild(anime);
					anime.frame = 0;
					anime.animate();
					//anime.startAnimation();
					
					/*var glow:Bitmap = new Bitmap(Window.textures.actionGlow, 'auto', true);
					glow.scaleX = glow.scaleY = 1.1;
					glow.x = informer.X + (anime.width - glow.width) / 2;
					glow.y = informer.Y + (anime.height - glow.height) / 2;
					bodyContainer.addChildAt(glow, 0);*/
				});
			} else {
				Load.loading(Config.resources + informer.image, function(data:Bitmap):void {
					var image:Bitmap = new Bitmap(data.bitmapData);
					image.smoothing = true;
					image.x = informer.X;
					image.y = informer.Y;
					image.scaleX = image.scaleY = Number(informer.scale);
					bodyContainer.addChildAt(image, 0);
					
					var glow:Bitmap = new Bitmap(Window.textures.actionGlow, 'auto', true);
					glow.scaleX = glow.scaleY = 1.1;
					glow.x = image.x + (image.width - glow.width) / 2;
					glow.y = image.y + (image.height - glow.height) / 2;
					bodyContainer.addChildAt(glow, 0);
				});
			}
		}
		
		override public function dispose():void {
			while (bodyContainer.numChildren > 0) {
				bodyContainer.removeChildAt(0);
			}
			
			super.dispose();
		}
	}
}