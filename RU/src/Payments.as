package  
{
	import api.ExternalApi;
	import core.Log;
	import core.Post;
	import wins.HistoryWindow;
	public class Payments 
	{		
		
		public static var history:Array = [];
		
		public function Payments() 
		{
			
		}
		
		public static function getHistory(show:Boolean = true):void {
			
			Post.send({
				'ctr':'orders',
				'act':'get',
				'uID':App.user.id
			}, function(error:*, result:*, params:*):void {
				
				if (error) {
					//trace(error);
					return;
				}
				history = [];
				for each(var item:Object in result.history) {
					history.push(item);
				}
				history.sortOn('transaction_time', Array.DESCENDING);
				
				App.self.setOffTimer(onExpirePayment);
				App.self.setOnTimer(onExpirePayment);
				
				if(show){
					new HistoryWindow( { content:history,forcedClosing:true,
							popup:true } ).show();
				}
			});
		}
		
		public static function onExpirePayment():void {
			for each(var item:Object in history) {
				//txnid
				if (item.status == 0 && item.transaction_end < App.time) {
					Post.send({
						'ctr':'orders',
						'act':'expire',
						'uID':App.user.id
					}, function(error:*, result:*, params:*):void {
						if (!error) {
							for each(var txnid:String in result.orders) {
								for(var id:* in history) {
									if (history[id].txnid == txnid) {
										history[id].status = 1;
									}
								}	
							}
							if(result[Stock.FANT] != undefined){
								App.user.stock.put(Stock.FANT, result[Stock.FANT]);
							}
						}
					});
					break;
				}
			}
			
		}
		
		public static function price(price:*, type:String = 'default'):String {
			var text:String = '%d';
			
			switch(App.social) {
				case "VK":
				case "DM":
					text = 'flash:1382952379985';
				break;
				case "OK":
					text = 'Купить за %d ОК';
				break; 
				case "MM":
					text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
				break;
				case "NK":
					text = '%d €GB'; 
				break;
				case "YN":
					text = String(price) + ' USD'; 
					break;
				break;
				case "FS":
					text = '%d ФМ'; 
				break;
				case "HV":
					price = int(price) / 100;
					text = '%d €';
				break;
				case "YB":
				case "PL":
					text = 'flash:1421404546875'; 
				break;
				case "MX":
					text = "%d pt.";
				break;	
				case "AM":
					text = "%d C";
				break;
				case "FB":
					price = price * App.network.currency.usd_exchange_inverse;
					price = int(price * 100) / 100;
					text = price + ' ' + App.network.currency.user_currency; 
				break;
				case 'AI':
					if (type == 'bank') text += ' aコイン';
					break;
			}
			
			return Locale.__e(text, [price]);
		}
		
		public static function get byFants():Boolean {
			if (App.social == 'PL' || App.social == 'SP' /*|| App.social == 'AI'*/)
				return true;
			
			return false;
		}
		
		public static function buy(params:Object = null):void {
			Log.alert(params);
			if (!params) return;
			
			Log.alert('BEGIN BUY ACTION');
			
			if (!params['type']) params['type'] = 'promo';
			
			var object:Object;
			
			if (params.type == 'promo') {
				
				switch(App.social) {
					case 'PL':
					//case 'YB':
						if (App.user.stock.take(Stock.FANT, params.price, function():void {
							Post.send({
								ctr:'Promo',
								act:'buy',
								uID:App.user.id,
								pID:params.price || 0,
								ext:App.social
							},function(error:*, data:*, addon:*):void {
								if (params.callback != null)
									callback();
							});
						})){
							Post.send({
								ctr:'Promo',
								act:'buy',
								uID:App.user.id,
								pID:params.price || 0,
								ext:App.social
							},function(error:*, data:*, addon:*):void {
								if (params.callback != null)
									callback();
							});
						}else {
							if (params.error != null)
								params.error();
						}
						break;
					default:
						if (App.social == 'FB') {
							ExternalApi.apiNormalScreenEvent();
							object = {
								id:		 		params.id,
								type:			'promo',
								title: 			params['title'] || '',
								description: 	params['description'] || '',
								callback:		callback
							};
						}else{
							object = {
								count:			1,
								money:			'promo',
								type:			'item',
								item:			'promo_'+params.id,
								votes:			params.price,
								title: 			params['title'] || '',
								description: 	params['description'] || '',
								tnidx:			App.user.id + App.time + '-' + params['money'] + "_" + params.id,
								callback: 		callback,
								icon:			params['icon'] || ''
							}
						}
						ExternalApi.apiPromoEvent(object);
						break;
				}
				
			}else if (params.type == 'bigsale') {
				
				switch(App.social) {
					case 'PL':
					//case 'YB':
						if (App.user.stock.take(Stock.FANT, params.price, function():void {
							Post.send({
								ctr:'Stock',
								act:'bigsale',
								uID:App.user.id,
								sID:params.id.substring(0,params.id.indexOf('_')),
								pos:params.id.substring(params.id.indexOf('_')+1,params.id.length)
							},function(error:*, data:*, addon:*):void {
								if(!error){
									App.user.stock.add(params.sID, params.count, true);
									if (params.callback != null)
										callback();
								}
							});
						})){
							Post.send({
								ctr:'Stock',
								act:'bigsale',
								uID:App.user.id,
								sID:params.id.substring(0,params.id.indexOf('_')),
								pos:params.id.substring(params.id.indexOf('_')+1,params.id.length)
							},function(error:*, data:*, addon:*):void {
								if(!error){
									App.user.stock.add(params.sID, params.count, true);
									if (params.callback != null)
										callback();
								}
							});
						}else {
							if (params.error != null)
								params.error();
						}
						return;
					default:
						if (App.social == 'FB') {
							object = {
								id:		 		params.id.replace('_','#'),//window.action.id+'#'+item.id,
								type:			params.type,
								callback:		callback
							};
						}else{
							object = {
								count:			params.count,
								money:			params.type,
								type:			'item',
								item:			params.type + '_' + params.id,
								votes:			params.price,
								title: 			params['title'] || '',
								description: 	params['description'] || '',
								tnidx:			App.user.id + App.time + '-' + params['money'] + "_" + params.id,
								callback: 		callback
							}
						}
						ExternalApi.apiBalanceEvent(object);
				}
				
			}else if (params.type == 'item') {
				
				switch(App.social) {
					/*case 'YB':
						object = {
							id:		 	params.money + '_' + params.id + '_' + params.extra,
							item:		params['money'] + '_' + params.id,
							price:		params.price,
							type:		params.type,
							count: 		params.count,
							callback:	callback
						};
						Log.alert(object);
						break;*/
					case 'FB':
						object = {
							id:		 		params.id,
							type:			params.money,
							callback:		callback
						};
						break;
					default:
						object = {
							money: 			params['money'] || '',
							type:			params.type,
							item:			params['money'] + '_' + params.id,
							votes:			params.price,
							sid:			params.id,
							count:			params.count,
							title: 			params['title'] || '',
							description: 	params['description'] || '',
							icon:			params['icon'] || '',
							tnidx:			App.user.id + App.time + '-' + params['money'] + "_" + params.id,
							callback:		callback
						}
				}
				
				ExternalApi.apiBalanceEvent(object);
			}
			function callback():void {
				if (params.callback != null)
					params.callback();
			}
		}
		
		public static function itemPrice(sid:*):Object {
			if (!App.data.storage[sid]) return null;
			
			var item:Object = App.data.storage[sid];
			
			if (item.hasOwnProperty('instance')) {
				if (item.instance.hasOwnProperty('cost')) {
					if (item.instance.level && App.self.getLength(item.instance.level) < World.getBuildingCount(sid) + 1) {
						return item.instance.cost[App.self.getLength(item.instance.level)];
					}
					
					return item.instance.cost[World.getBuildingCount(sid) + 0];
				}else {
					for (var level:* in item.instance) {
						return item.instance[level].cost;
					}
				}
			}else if (item.hasOwnProperty('price')) {
				return item.price;
			}
			
			return null;
		}
	}

}