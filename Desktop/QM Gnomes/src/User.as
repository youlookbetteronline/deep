package  
{
	import com.adobe.images.BitString;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.Animation;
	import core.BezieDrop;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class User extends EventDispatcher {
		
		public static const GUEST:Boolean 	= true;
		public static const OWNER:Boolean	= false;
		
		public static var checkBoxState:int = 1;
		
		public static var openExpJson:Object;
		public static var quests:Object = { };
		
		public var id:String = '0'; 
		public var worldID:int = 1; 
		public var aka:String = ""; 
		public var sex:String = "m"; 
		public var email:String = ""; 
		public var first_name:String; 
		public var last_name:String; 
		public var photo:String; 
		public var year:int; 
		public var city:String;
		public var country:String;
		public var level:uint = 1;
		public var timeHeroPosition:Object = {};
		private var _worlds:Object = {};
		public var maps:Array = [];
		public var units:Object;
		public var shop:Object = { };
		public var lastvisit:uint = 0;
		public var createtime:uint = 0;
		public var energy:uint = 0;
		public var freebie:Object = null;
		public var presents:Object = {};
		public var restore:int;
		public var promos:Array = [];
		public var promo:Object = { };
		public var boostPromos:Array = [];
		public var boostCompleteTime:int = 0;
		public var boostBlock:Boolean = false;
		public var oncePromos:Array = [];
		public var onceOfferShow:uint = 0;
		public var premiumPromos:Array = []; 
		public var money:int = 0; 
		public var pay:int = 0;
		public var countTechInInst:int = 0;
		public var blinks:Object = { };
		public var ministock:Object = { level:1 };
        private var timer:int = 0;
		public var plusMinus:uint = 0;
		public var currentGuestReward:Object;
		public var currentGuestLimit:uint = 0;
		public var wishlist:Array = [];
		public var gifts:Array = [];
		public var requests:Array = [];
		public var head:uint = 0;
		public var body:uint = 0;
		public var day:uint = 0;
		public var bonus:uint = 0;
		public var _6wbonus:Object = {};
		public var trialpay:Object = {};
		private var blinkContainer:Sprite;
		public var personages:Array = [];
		public var characters:Array = [];
		public var techno:Array = [];
		public var technoInInstance:Array = [];
		public var animals:Array = [];
		public var mode:Boolean = OWNER;
		public var trades:Object;
		private var _settings:String = '';
		public var settings:Object = {ui:"111", f:"0"};
		public var gift:Object = null;
		public var ach:Object = {};
		public var hidden:int = 0;
		public var mbonus:Object = { };
		public var calendar:Object = { };
		public var daylics:Object = { };
		public var auctions:Object = { };//Ahappy
		
		public var rooms:Object = {};
		public var wl:Object;
		
		public var diffvisit:int = 0;
		
		public var confirmDiamond:Boolean = false;
		
        private var One:Number = 0;
        private var Scale:Number = 8;
		private var PlusScale:Boolean = true;
		public var socInvitesFrs:Object = { }
		
		public var boosterTimer:int = 180 + Math.floor(120 * Math.random());
		public var boosterTimeouts:int = 900;
		public var boosterLimit:int = 4;
		
		public var topID:int = 0;
		public var top:Object = { };
		
		public var instance:Object = { };		//D gbuilding
		public var instanceWorlds:Object = {};	//D
		 
		public var ref:String = ""; 
		
		public function User()
		{
			
			//first_name 	= App.network.profile.first_name || 'Gamer';
			//last_name 	= App.network.profile.last_name || '';
			//sex 		= App.network.profile.sex;
			//photo		= App.network.profile.photo;
			//year		= App.network.profile.year || 0;
			//city		= App.network.profile.city || '';
			//country		= App.network.profile.country || '';
			//email		= App.network.profile.email || '';
		}
		
		public static var data:Object;	
		public static var daylics:Object;		
		public static var chapters:Array = [];
		public static var exclude:Object = { };
		public static function clear():void 
		{
			User.quests = new Object();
			User.data = new Object();
		}
		public static function initInfo(data:*):void 
		{
			User.data = data;
			User.daylics = data.daylics;
		}
		public static function getLocalValute(price:uint):String 
		{
			var text:String;
			switch(App.social) {
				case "VK":
				case "DM":
					text = '%d голосов';
				 break;
				case "OK":
					text = '%d ОК';
				break; 
				case "MM":
					text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
				break;
				case "FS":
					text = '%d ФМ'; 
				case "FB":
					//price = price * App.network.currency.usd_exchange_inverse;
					//price = int(price * 100) / 100;
					//text = price + ' ' + App.network.currency.user_currency; 
				break;
				/*case "NK":
					text = '%d €GB'; 
				break;
				case "PL":
					text = '%d'; 
				break;
				case "YB":
					text = 'flash:1421404546875'; 
				break;
				case "AI":
					text = 'flash:1438761831564';
					break;
				case "MX":
					text = '%d pt.'
					break;
				
				case "HV":
					price = int(price) / 100;
					text = '%d €';
				break;	
				case "YN":
					text = String(price) + ' USD'; 
				break;	
				
				case "FB":
					price = price * App.network.currency.usd_exchange_inverse;
					price = int(price * 100) / 100;
					text = price + ' ' + App.network.currency.user_currency; 
				break;*/
			}
			var priceVal:String = Locale.__e(text, [price]);
			return priceVal;
		}
		public static function init(data:*):void 
		{
			
			/*if(App.user.mode != User.OWNER)
				return;
			
			for each(var item:Object in App.data.updates) 
			{
				if (item['quests'] != undefined) 
				{					
					var qID:* = item['quests'];
					var has:Boolean = false;
					
					if (item['social'].hasOwnProperty(App.social))
						has = true;
					
					if (!has)
						exclude[qID] = qID;
				}
			}*/
			
			// Записываем главы, которые нам встречались
			for (id in data) 
			{
				if (App.data.quests[id] == null) 
				{
					delete data[id];
					continue;
				}
				//inNewChapter(App.data.quests[id].chapter)
			}
			
			for (var id:* in App.data.quests) 
			{
				if (exclude[id] != undefined) 
				{
					var parentID:int = App.data.quests[id].parent;
					var updateID:String = App.data.quests[id].update || null;
					//delete App.data.quests[id];
					//deletedQuests.push(id);
					//deleteAllChildrens(id, parentID, updateID);
					
				}
				//openChilds(id);
			}
			quests = data;
			
			//removeDeletedQuests();
			//getOpened();
			//pushPersonages();
			// Daylics
			//if(App.data.hasOwnProperty('daylics'))
				//getDaylics();
		}
	}
}

