<?php 

	$update = false;
	$works = false;
	
	if($_GET['logged_user_id'] == '550402787062' || $_GET['logged_user_id'] == '565449872326' || $_GET['logged_user_id'] == '573120685704'
	|| $_GET['logged_user_id'] == '583221773578' || $_GET['logged_user_id'] == '566378776010'){
	    $works = $update = false;
	}
    
    $adver = $_SERVER['DOCUMENT_ROOT'] . '/console.php';
    exec('php '.$adver.' -ctr Adver -act install -uID '.$_GET['logged_user_id'].' -query "'.base64_encode($_SERVER['QUERY_STRING']).'"');
?>	

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ru" xml:lang="ru">
  
<head>
    <title>Сны</title>  
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />	
    <script type="text/javascript" src="js/swfobject.js"></script>
    <script type="text/javascript" src="js/jquery-2.1.3.min.js"></script>
    <script type="text/javascript" src="js/jquery.cookie.js"></script>	
    <script type="text/javascript" src="js/game.js?6"></script>	
    
    <script type="text/javascript" src="//api.odnoklassniki.ru/js/fapi5.js"></script>
    	
    <script type="text/javascript">	
    
		function getGame() {
			if (navigator.appName.indexOf("Microsoft") != -1) {
				return window["game"];
			} else {
				return document["game"];
			}
		}
		function getID() {
			getGame().getIDCallback({id:uid});
		}	
        function shuffle(o){
            for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
            return o;
        }
		
		
		$.fapi = $.Deferred(); 
		setTimeout(function() {
			if ($.fapi.state()!=='resolved') {
				$.fapi.reject();
			}
		}, 2000);
		$(function(){
			var rParams = FAPI.Util.getRequestParameters();
            console.log(rParams);
			FAPI.init(rParams["api_server"], rParams["apiconnection"],
				function() {
					//success
					//if(status && data) {
						//$.profileData = data;
						//$.fapi.resolve();
					//} else {
						//$.fapi.reject();
					//}
					
					FAPI.UI.setWindowSize(0,900); 
					getMe(function(){
						getAppUsers(function(){
							getFriends(function(){
								getInvitableFriends(function(){
									console.log('CACHE::::::');
									console.log(cache);
									$.fapi.resolve();
								});
							});
						});
					});
					
					
				},
				function(error) {
					$.fapi.reject();
				}
			);
		
			$.when($.fapi, $.ready).then(function() {
			
				setTimeout(showSocialPromo, 10000);
				
				var uid = "<?php echo $_GET['logged_user_id'] ?>";
				var url = document.location.toString().split('?');
				var query = (url[1] ? url[1] : '');			
				
				//var lang = navigator.language || navigator.userLanguage;
				//lang = lang.split('-')[0];
				lang = 'ru';
				
				//var version = Math.random()*999999;
				
				var _mainIP = shuffle(['r-ok1.islandsville.com','r-ok1.islandsville.com']);
				var _resIP = shuffle(['r-ok-static.islandsville.com','r-ok-static.islandsville.com']);
				var flashvars = {
					'social':'OK',
					'group':'https://ok.ru/group/53290312794300',
					'mainIP':encodeURIComponent(JSON.stringify(_mainIP)),
					'resIP':encodeURIComponent(JSON.stringify(_resIP)),
					'game':'Diamond_20_01_1.swf',
					'preloader':'preloader.swf',
					'testMode':0,
					'lang':lang,
					'secure':location.protocol,
					'version_swf' :1008162,
					'version_ui' :1008162,
					'version_icons' :1008162
				};
				console.log(flashvars);
				if (uid == '585935667507')
					flashvars['game'] = 'Diamond.swf';
				if(query != ''){
					query = query.replace(/\&amp;/,'&').split('&');
					for(var key in query){
						var value = query[key].split('=');
						flashvars[value[0]] = value[1] || '';
					}
				}
				
				if(flashvars['custom_args'] != undefined){
					var args = unescape(flashvars['custom_args']).split('&');
					for(var key in args){
						var param = args[key].split('=');
						if(param[0] == 'ref'){
							flashvars['ref'] = param[1];
							break;
						}
					}
				}
				
				<?php if(preg_match('/(viral|bonus|blink|oneoff)([^z]{12,99}+)z/', $_SERVER['QUERY_STRING'].$_SERVER['HTTP_REFERER'], $mm) === 1):
					switch($mm[1]){
						case "bonus":
						case "blink": 
							print 'flashvars["blink"] = "'.$mm[2].'";';
							break;  
						default:
							print 'flashvars["'.$mm[1].'"] = "'.$mm[2].'";'; 
							break;                  
					}            
				endif;?>
				
				var params = {
					width: "100%",
					height: "700",
					menu: "false",
					scale: "noScale",
					allowFullscreen: "true",
					allowFullScreenInteractive: "true",
					allowScriptAccess: "always", 
					bgcolor: "#000000",
					wmode: "window"
				};
				var attributes = {id:"game"};
				
				swfobject.embedSWF("LOADER.swf?v=5","game", "100%", "700", "11.1.0","expressInstall.swf", flashvars, params, attributes);
			}).fail(function() {
				console.log('Big big fail!!!!');
			});;
		
		
		});
		function getID() {
			var uid = "<?php echo $_GET['logged_user_id'] ?>";
			getGame().getIDCallback({id:uid});
		}
		function showSocialPromo() {
			FAPI.invokeUIMethod("showPaymentPromo");
		}
		
		function reset()
		{
			location.reload();
		}
		
		function sendmail(data)
		{
			$.ajax({
			  type: "POST",
			  url: "some.php",
			  data:{data:data}
			});
		}
		
		function getCookie(name){
			if(name == null ||name == ''){
				return $.cookie();
			}else{
				return $.cookie(name);
			}
		}
		
		function setCookie(name, data, expires){
			if(!expires) expires = 1;
			
			var date = new Date();
			date.setTime(date.getTime() + (expires * 24 * 36001000));
			
			$.cookie(name, data, { expires: date});
		}
		
		function removeCookie(name){
			$.removeCookie(name);
		}

		function showInviteBox()
		{
			getGame().showInviteBox();
		}
			
    </script>
	
    
	<style>
		html, body { height:900px;} 
		body { margin:0; }
        .bar{
            background: url("images/BackingPiece.png") repeat-x bottom;
            height:60px;
            line-height:60px;
            margin-bottom: -7px;
        }
        .bar .lc{
            background: url("images/BackingCornL.png") no-repeat left bottom;
            height:60px;
            line-height:60px;
            margin-left: -14px;
            margin-right: 6px;
        }

        .bar .rc{
            background: url("images/BackingCornR.png") no-repeat right bottom;
            height:60px;
            line-height:60px;
            text-align:center;
            margin-right: -21px;
            margin-left: -5px;
        }

        a.button {
            display:inline-block;
            border:none;
            cursor:pointer;
            vertical-align:top;
            height: 41px;
        }
        a img {
            margin-right: -5px;
        }

        .btn2,.btn3{
            margin-right: -8px;
        }
        .btn6{
            margin-left: -12px;
        }
        #game{
            height:700px;
        }
	</style>
</head>
<body id='body'>
	<?php if(!$works):?>
	
		<div id="ourgames" align="center">
			<iframe style="margin: 0 auto; border: 0 none;  height: 100px;  width: 900px;" src="//dreams.islandsville.com/banner2/index.php?net=OK&game=diamond"></iframe>
        </div>
    
		<div class="bar">
			<div class="lc">
				<div class="rc">
					<a href="javascript:;" onclick="getGame().openBank();" class="button btn1"><img src="./images/AddBucksR.png" /></a>
					<a href="https://ok.ru/group/53290312794300/topic/65729431025084" target="_blank" class="button btn2"><img src="./images/FAQR.png" /></a>
					<a href="javascript:;" onclick="showInviteBox();" class="button btn3"><img src="./images/InviteR.png" /></a>
					<a href="javascript:;" onclick="getGame().openGifts();" class="button btn5"><img src="./images/GiftsR.png" /></a>
					<a href="https://ok.ru/group/53290312794300" target="_blank" class="button btn6"><img src="./images/CommunityR.png" /></a>
				</div>
			</div>
		</div>
		
		
        <div id="game" align = "center">
			<a href="//www.adobe.com/go/getflashplayer">
				<img src="//www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player"/>
			</a>
		</div>
		<div style="border-top:2px solid #cea053;margin-top:10px;padding:5px 16px;">
			Ваш ID: <?php echo $_GET['logged_user_id']?>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		</div>
	<?php else:?>
		<table style="background:#FFFFFF;" width="100%" height="100%">
		<tr>
			<td align="center">
				<img src="//e-vk2.islandsville.com/iframe/images/maintenance.jpg" alt="Ведуться технические работы" title="Ведуться технические работы" />
			</td>
		</tr>
		</table>
	<?php endif;?>
</body>
</html>
