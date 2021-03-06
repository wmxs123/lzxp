<%@page import="java.net.URLDecoder"%>
<%@page import="com.etc.lzxp.entity.Users"%>
<%@page import="com.etc.lzxp.entity.Goods"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<!--
    	作者：offline
    	时间：2017-10-12
    	描述：小类页
    -->
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>零嘴小铺</title>
		<script type="text/javascript" src="js/jquery.min.js"></script>
		<script type="text/javascript" src="js/common.js"></script>
		<script type="text/javascript" src="js/jquery.cookie.js"></script>	
		<link rel="stylesheet" href="css/layout-style.css">
		<style>
			.pages .page-num .on{
				background-color:#005aa0;
				color:white;
			}
			
		</style>
		
<script type="text/javascript">    
	//页面加载的时候  调用函数onload() 
	$().ready(function(){			
   		 onload();	
	});
	
  //函数中使用Ajax局部刷新页面
   function onload(){	  
	  //先获取从大类传递过来的小类 类型名称	
	  var  keyword= '<%=request.getParameter("keyword")%>';	 
	  $(".sch-key").val(keyword);
	   /* alert(keyword);	 */  	     
		 $.post("GetAllGoodsServlet",{"op":"queryAll","keyword":keyword},function(pd,status){ 
			 //先判断pd.data是否有返回值  
			 if(pd.data==""){
   	    	     noResult();
			    	
			     }else{
			     //调用显示商品数据的方法
					Showgoods(pd,status);		 
			     }
	      }); 	 	   
	   //获取商品名查询的关键字
	   //获取值时在编码一下
  } /* function onload() */
  //分页查询
   $(function(){   
	   //先获取从大类传递过来的小类 类型Id
		 var keyword = '<%=request.getParameter("keyword")%>'; 
		
	   //获取动态标签的点击事件
	     $(document).on('click','.pageNoAjax',function(){		  
		  //获取当前标签的值
		  var page = $(this).text();	
		  var keyword = $(".sch-key").val();  		 
	       //Ajax请求
			  $.post("GetAllGoodsServlet",{"op":"queryAll","page":page,"keyword":keyword},function(pd,status){		  
				//调用显示商品数据的方法
				 Showgoods(pd,status);	
			 
			  });	
		
	  }); 
	  //点击确定按钮进行分页页面跳转
	  $(document).on('click','.pg_btn',function(){
		  var keyword = $(".sch-key").val();
		  var page = $(".pg_txt").val();
		
		 $.post("GetAllGoodsServlet",{"op":"queryAll","page":page,"keyword":keyword},function(pd,status){		    
				//调用显示商品数据的方法
				Showgoods(pd,status);
			 
		 });
		 
	  });
	  
	  //点击上一页或者下一页按钮进行分页跳转
	 $(document).on('click','.pg_prev',function(){
		var keyword = $(".sch-key").val();
		var pageStr = $("#page-num li a.on").text();
		var page = parseInt(pageStr)-1;
		if(page!=0){		
		/* alert("当前页："+page); */
		 $.post("GetAllGoodsServlet",{"op":"queryAll","page":page,"keyword":keyword},function(pd,status){				
				//调用显示商品数据的方法
				Showgoods(pd,status);			 
		 });
		}else{
			alert("已经是首页了");
		}
	 });
	  //下一页
	 $(document).on('click','.pg_next',function(){
		 var pageStr = $("#page-num li a.on").text();
		 var keyword = $(".sch-key").val();
		 var page = parseInt(pageStr)+1;	
			/* alert(pageStr); */
			 $.post("GetAllGoodsServlet",{"op":"queryAll","page":page,"keyword":keyword},function(pd,status){									   
				 if(page<=pd.totalPage){
				    //调用显示商品数据的方法
					Showgoods(pd,status);
				   }else{
					   alert("已经是最后一页了");
				   }
			 });	
		 }); 
	  
	  //点击搜索按钮进行模糊查询
	  $(".sch-btn").click(function(){		  		   
		   var keyword = $(".sch-key").val();
		   
		   if(keyword=="商品搜索"||keyword==" "){
			   alert("请输入关键字！");
		   }else{
			  $.post("GetAllGoodsServlet",{"op":"queryAll","keyword":keyword},function(pd,status){						 
				  //先判断pd.data是否有返回值  
					 if(pd.data==""){
		   	    	     noResult();
					    	
					     }else{
					     //调用显示商品数据的方法
							Showgoods(pd,status);		 
					     }
			    });
		   }
	  });
	  
	//点击热门 关键字进行商品的模糊查询
		 $(function(){
			$(".hot_sh").click(function(){					
				var hotword = $(this).text();
				$(".sch-key").val(hotword);
				/* alert("hotword:"+hotword); */
				 $.post("GetAllGoodsServlet",{"op":"queryAll","keyword":hotword},function(pd,status){						 
					  //先判断pd.data是否有返回值  
						 if(pd.data==""){
			   	    	     noResult();
						    	
						     }else{
						     //调用显示商品数据的方法
								Showgoods(pd,status);		 
						     }
				    });
			});
		 });
	  
	  //跳转商品的详情页面
	  $(document).on('click','.goodsId',function(){
		  var goodsId = $(this).parent('.pt').children('#goodsId').val();		  
		  location.href = "GetAllGoodsServlet?op=queryGoodsById&goodsId="+goodsId;	  
	  });
  }); 
  
 //封装Ajax请求返回的数据显示的方法  
   function Showgoods(pd,status){
	  /*  <div class="no-result" id="no-result">	
		</div> */
	 //先将原先的样式删除掉
		 $('#content_ul').find('li').remove();
		 $('#content_ul').find('#no-result').remove();
		 $('#page-num').find('li').remove();
		//遍历pd中的data
		 $.each(pd.data,function(index,showgoods){			
			 $("#content_ul").append('<li><div class="pt">'
		    		 +'<a href="#" title="'+showgoods.GOODSNAME+'" class="pic goodsId"> <img src="'+showgoods.PICTUREADDRESS+'"></a>'
		    		 +'<input type="hidden" value="'+showgoods.GOODSID+'" id="goodsId"/>'
		    		 +'<a href="#" title="'+showgoods.GOODSNAME+'" class="tit goodsId">'+showgoods.GOODSNAME+'</a>'
		    		 +'<p class="prom" title="'+showgoods.GOODSCONTENT+'">'+showgoods.GOODSCONTENT+'</p>'
		    		 +'</div><div class="price"><span>￥<i>'+showgoods.GOODSPRICE+'</i></span> </div>'
					 +'<div class="part"><div class="cart">	<a class="add" href="#">加购物车</a>'
					 +'<a class="atte" href="#">加关注</a></div><div class="meta"> <span class="sale">已售：<i>356</i></span>'
					 +'<div class="comm"> <span class="tx">评分：</span> <span class="score-star"><i class="star05"></i></span></div>	</div>'
					 +'</div><input type="hidden" value="'+showgoods.GOODSID+'" id="goodsId"/></li>');  
		 });/*$.each  */
		 //显示分页
		 $("#page-num").append('<li><a href="javascript:void(0)" class="pg_prev">上页</a></li>');
		 for(var curPage = 1;curPage<=pd.totalPage;curPage++){   		 
	    		 if(pd.page==curPage){
	    			 
	    			 $("#page-num").append('<li ><a href="javascript:void(0)" class=" on pageNoAjax">'+curPage+'</a></li>');
	    			 
	    		 }else{
	    			 
	    			 $("#page-num").append('<li><a href="javascript:void(0)" class="pageNoAjax">'+curPage+'</a></li>');
	    	   }
	    	 }
		 $("#page-num").append('<li><a href="javascript:void(0)" class="pg_next">下页</a></li>');
		
		 $("#page-num").append('<li><small class="sum">共<b>'+pd.totalPage+'</b>页</small><i>到第</i><input class="pg_txt" type="text" value="1" name="curPage" id="turnPage"><i>页</i><input class="pg_btn" type="button" value="确定" id="pg_btn"></li>');	
 }
 //商品搜索不存在  调用函数
   function noResult(){
	   //刷新之前  先将原来的样式删除掉
	   $("#content_ul").find('#no-result').remove();   
	   $('#content_ul').append('<div class="no-result" id="no-result"><div class="nores-cont" id="nores-cont"><div class="nores-tit">'	                                    
	           +'<strong>抱歉，没有找到与"<span>您搜索的关键字</span>"相关的商品</strong></div>'	           
	           +'</div>'
	           +'</div>');
  	
   }
   
   
</script>
<script type="text/javascript">	
		 //是否显示有货
			var hasStock = false;
			$().ready(function() {
				var $productForm = $("#productForm");
				var $brandId = $("#brandId");
				var $promotionId = $("#promotionId");
				var $orderType = $("#orderType");
				var $pageNumber = $("#pageNumber");
				var $pageSize = $("#pageSize");
				var $filter = $("#filter dl");
				var $lastFilter = $("#filter dl:eq(2)");
				var $hiddenFilter = $("#filter dl:gt(2)");
				var $moreOption = $("#filter dd.moreOption");
				var $moreFilter = $("#moreFilter a");
				var $tableType = $("#tableType");
				var $listType = $("#listType");
				var $orderSelect = $("#orderSelect");
				var $brand = $("#filter a.brand");
				var $attribute = $("#filter a.attribute");
				var $previousPage = $("#previousPage");
				var $nextPage = $("#nextPage");
				var $size = $("#layout a.size");
				var $tagIds = $("input[name='tagIds']");
				var $sort = $("#sort a");
				var $startPrice = $("#startPrice");
				var $endPrice = $("#endPrice");
				var $result = $("#result");
				var $productImage = $("#result img");
				$productForm.submit(function() {
					if($brandId.val() == "") {
						$brandId.prop("disabled", true)
					}
					if($promotionId.val() == "") {
						$promotionId.prop("disabled", true)
					}
					if($orderType.val() == "" || $orderType.val() == "topDesc") {
						$orderType.prop("disabled", true)
					}
					if($pageNumber.val() == "" || $pageNumber.val() == "1") {
						$pageNumber.prop("disabled", true)
					}
					if($pageSize.val() == "" || $pageSize.val() == "12") {
						$pageSize.prop("disabled", true)
					}
					if($startPrice.val() == "" || !/^\d+(\.\d+)?$/.test($startPrice.val())) {
						$startPrice.prop("disabled", true)
					}
					if($endPrice.val() == "" || !/^\d+(\.\d+)?$/.test($endPrice.val())) {
						$endPrice.prop("disabled", true)
					}
				});

				$productImage.lazyload({
					threshold: 100,
					effect: "fadeIn"
				});

				$.pageSkip = function(pageNumber) {
					$pageNumber.val(pageNumber);
					$productForm.submit();
					return false;
				}
			});
			
		</script>
		
</head>
  
	<body class="listpage">
		<!-- header include -->
		<script src="http://tjs.sjs.sinajs.cn/open/api/js/wb.js" type="text/javascript" charset="utf-8"></script>
		<script type="text/javascript" src="js/base.js"></script>
		<!--页面初始化-->
		<script type="text/javascript">
			
		</script>

		<!-- header -->
		<div class="toolbar">
			<div class="toolbar-cont wrap">
				<ul class="fl">
					<li id="headerUsername" class="headerUsername"></li>
					<% 
						if(request.getSession().getAttribute("user")!=null){
							//如果有传递过来用户信息
							Users user = (Users)request.getSession().getAttribute("user");
							%>
								<li>欢迎<span class="log username"><%=user.getUSERNAME() %></span>来到零嘴小铺官方商城！</li>
							<%
						}else{
							%>
							<li>欢迎来到零嘴小铺官方商城！</li>
							<%
						}
					%>
					<li id="headerLogin" class="headerLogin none">
						<a class="log" href="#">[登录]</a>
					</li>
				
					<li id="headerRegister" class="headerRegister none">
						<a class="reg" href="#">[注册]</a>
					</li>
					<!--如果用户已经登录，当点击退出时处理用户注销并跳转登录页面-->
					<li id="headerLogout" class="headerLogout none">
						<a class="log" href="#">[退出]</a>
					</li>

				</ul>
				<ul class="fr">
					<li class="thover ">
						<div class="top-user-info">
							<a class="my-lppz dorp-title">我的零嘴<i class="arrow"></i></a>
							<div class="my-lppz-layer">
								<div class="dorp-spacer"></div>
								<div class="user-info">
									<div class="m-pic">
										<img id="avatarImg" src="img/avatar.png" alt="用户头像" />
									</div>
									<div class="m-name" id="divlogin">
										<a class="nick" href="http://home.lppz.com/member/index.jhtml" id="username"></a>
										<a class="level" href="###" title="" id="levelName"></a>
									</div>
									<!--<div class="m-phone" id="mobile"></div>-->
									<div class="m-name" id="divnologin">
										
										<c:if test="${sessionScope.user != null }">
										<!-- 如果用户不为空 -->
											<a href="${path }UsersServlet?op=userInfo">${sessionScope.user.USERNAME}已登录</a>
										</c:if>
										<c:if test="${sessionScope.user == null }">
										<!-- 如果用户为空 -->
											<a href="login.jsp">您还未登录</a>
										</c:if>
										
									</div>
								</div>
								<div class="menu-list">
									<div class="m-nav">
										<div class="item">
											<a href="myorder.html">我的订单</a>
										</div>
										<div class="item">
											<a href="#">我的关注</a>
										</div>
										<div class="item">
											<a href="#">我的优惠券<span id="spancouponcount">(<span class="num red" id="couponCount"></span>)</span>
											</a>
										</div>
										<div class="item">
											<a href="#">我的积分</a>
										</div>
									</div>
									<div class="m-btn">
										<div class="item">
											<a clstag="" href="#">签到有好礼</a>
										</div>
										<div class="item">
											<a clstag="" href="#">购物指南</a>
										</div>
									</div>
								</div>
								<div class="view-list">
									<div class="vl-title">
										<h4>最近浏览</h4>
										<a class="more" href="#">更多&nbsp;&gt;</a>
									</div>
									<ul class="vl-cont" id="ulHistory"></ul>
								</div>
							</div>
						</div>
					</li>
				</ul>
			</div>
		</div>
		<div class="header">
			<div class="head-main wrap clearfix">
				<!--该href地址应该跳转至商城首页-->
				<div class="logo">
					<a href="index.jsp">零嘴小铺-BESTORE</a><span>官方商城</span></div>
				<div class="hd-search">
					<!--该搜索的href应该是我们自己的servlet-->
					<div class="hot-tag">
						<span>热门搜索：</span>
							<a class="red hot_sh" href="javascript:void(0)">饼干</a>
							<a class = "hot_sh"  href="javascript:void(0)">牛肉</a>
							<a class = "hot_sh"  href="javascript:void(0)">豆干</a>
							<a class = "hot_sh"  href="javascript:void(0)">进口</a>
							<a class = "hot_sh"  href="javascript:void(0)">话梅</a>
							<a class = "hot_sh"  href="javascript:void(0)">瓜子</a>
					</div>
					<!-- 搜索框 -->
					<div class="search-area">
						<!--<form id="productSearchForm" action="#" method="get" target="_blank">-->
						<input class="sch-key" type="text" name="keyword" id="keyword" value="" onfocus="if (value =='商品搜索'){value =''}" onblur="if (value ==''){value='商品搜索'}">
						<input class="sch-btn"  id = "sch-btn" type="button" >
						<!--</form>-->
					</div>
				</div>
				<div class="hd-user">
					<!-- <div class="user-lppz"><a href="http://home.lppz.com/member/index.jhtml">我的良品</a></div> -->
					<div class="user-shoping">
						<a class="us-btn indexcart" href="#">购物车</a>
						<span class="us-num cart-cache-num"><b>0</b></span>
						<div class="cart-list cart-list-body">
							<span class="tit">最新加入的商品</span>
							<div class="cart-roll">
								<ul class="goods"></ul>
							</div>
							<div class="total">								
							</div>
						</div>
					</div>
				</div>
			</div>

			
			<div class="menu">
				<div class="menu-main wrap">
					<ul class="menu-list">
						<li>
							<a href="GetGoodsServlet?op=queryAllGoods">首页</a>
						</li>

						<li>
							<a href="javascript:void(0)">上新尝鲜</a>
						</li>
					</ul>
				</div>
			</div>
		</div>
		<!-- list page ad -->
		<!-- content -->
		<div class="container wrap">
			<form id="productForm" action="#" method="get">
				<input type="hidden" id="brandId" name="brandId" value="" />
				<input type="hidden" id="promotionId" name="promotionId" value="" />
				<input type="hidden" id="orderType" name="orderType" value="" />
				<input type="hidden" id="pageNumber" name="pageNumber" value="" />
				<input type="hidden" id="pageSize" name="pageSize" value="" />
				<input type="hidden" id="keyword_top" name="keyword_top" />
				<input type="hidden" id="keyword_body" name="keyword_body" />
				<input type="hidden" id="keyword_bottom" name="keyword_bottom" />
				<input type="hidden" id="keyword1" name="keyword" />
				<!--公共部分刷新时可能需要用到ajax-->
				<div class="place-site">
					<a class="home" href="GetGoodsServlet?op=queryAllGoods">首页</a><span>&gt;</span>
				     <!-- 判断是否从小类进入该页面 -->
				    <%-- <c:if test="${requestScope.ltype!null}"> --%>			      	
					  <a href="javascript:void(0)">商品搜索</a><span>&gt;</span><em></em>
				     <%-- </c:if> --%>
				</div>
				<div class="filtrate">
					<div class="fitl-txt">
						<div class="ft-tit">
							<h2><span>商品筛选</span></h2><i class="icon">&gt;</i></div>&nbsp;&nbsp;&nbsp;		
					</div>
					<div class="sift-selected clearfix">
						<div class="label">已选条件：</div>
						<ul id="condition"></ul>
						<div class="revoke">
							<a href="#">全部撤销</a>
						</div>
					</div>
					<div class="filt-area" id="filter_all">
						<div class="filt-cate" id="1">
							<span class="sort">品牌：</span>
							<ul>
								<li>
									<a href="#">零嘴小铺</a>
								</li>
							</ul>
						</div>
						<div class="filt-cate" id="2">
							<span class="sort">包装形式：</span>
							<ul>
								<li>
									<a href="javascript:void(0)">散装</a>
								</li>
								<li>
									<a href="javascript:void(0)#">盒装</a>
								</li>
								<li>
									<a href="javascript:void(0)">罐装</a>
								</li>
								<li>
									<a href="javascript:void(0)">瓶装</a>
								</li>
								<li>
									<a href="javascript:void(0)">礼盒装</a>
								</li>
								<li>
									<a href="javascript:void(0)">趣味装</a>
								</li>
								<li>
									<a href="javascript:void(0)">手抓包</a>
								</li>
								<li>
									<a href="javascript:void(0)">小袋装</a>
								</li>
								<li>
									<a href="javascript:void(0)">大袋装</a>
								</li>
								<li>
									<a href="javascript:void(0)">单粒装</a>
								</li>
								<li>
									<a href="javascript:void(0)">单个装</a>
								</li>
								<li>
									<a href="javascript:void(0)">中袋装</a>
								</li>
							</ul>
						</div>
						<div class="filt-cate" id="3">
							<span class="sort">产源：</span>
							<ul>
								<li>
									<a href="javascript:void(0)">国产</a>
								</li>
								<li>
									<a href="javascript:void(0)">原装进口</a>
								</li>
								<li>
									<a href="javascript:void(0)">国外原料国内分装</a>
								</li>
							</ul>
						</div>
						<div class="filt-cate" id="99">
							<span class="sort">价格：</span>
							<ul>
								<li>
									<a href="javascript:void(0)">9.9元以下</a>
								</li>
								<li>
									<a href="javascript:void(0)">10-19.9元</a>
								</li>
								<li>
									<a href="javascript:void(0)">20-29.9元</a>
								</li>
								<li>
									<a href="javascript:void(0)">30-50元</a>
								</li>
								<li>
									<a href="javascript:void(0)">51-100元</a>
								</li>
								<li>
									<a href="javascript:void(0)">100元以上</a>
								</li>
							</ul>
						</div>
					</div>
					<div class="filt-order">
						<div class="fo-txt">排序：</div>
						<ul class="fo-rank">
							<li class="curr" id="sort_page">
								<a class="zh" href="javascript:sort_page();">综合排序</a>
							</li>
							<li id="sort_page_xl">
								<a class="xl" href="javascript:sort_page_xl();">销量<i class="icon"></i></a>
							</li>
							<li id="sort_page_jg">
								<a class="jg" href="javascript:sort_page_jg();">价格<i class="icon"></i></a>
							</li>
							<li id="sort_page_pl">
								<a class="pl" href="javascript:sort_page_pl();">评分<i class="icon"></i></a>
							</li>
							<!--
					<li class="sj" id="sort_page_sj"><a href="javascript:sort_page_sj();">上架时间<i class="icon"></i></a></li>
					-->
						</ul>
						<input id="showStock" name="showStock" type="checkbox" />仅显示有货的
					</div>
				</div>
			</form>
			<!--商品展示层-->
			<div class="content">
    
				<!-- 异步分页 -->
				<div id="showControlPage">
					<ul class="producrt-list clearfix" id="content_ul">
						
                    </ul>
				</div>	
				<!--搜索商品无结果显示  -->	
					
				<!--分页显示  -->	
				<div id="pageBar" class="pages"><!--pages  -->
					<ul class="page-num" id = "page-num" >
						
					</ul>
				</div><!--pages  -->
			</div><!-- content -->
		</div><!--container wrap  -->

		<!-- list page left ad -->
		<!--广告图片位置-->
		<div class="lp-lft-ad">
			<a title="列表页－包邮" href="javascript:void(0)" target="_blank"><img src="img/style/adss.jpg" alt="列表页－包邮" /></a>
			<a href="javascript:void(0)" class="close-ad"><i>关闭</i></a>
		</div>

		<!-- 右侧功能菜单 -->
		<div class="right-navbar">
			<ul class="rnb-list">
				<li class="kf">
					<a class="hvr" id="ntkf_chat_entrance" href="javascript:void(0)"><span>客服咨询</span><i class="icon">▪</i></a>
				</li>
				<li class="gw">
					<a href="javascript:void(0)"><i class="icon">▪</i><span>购物车</span><small class="sum" id="cartcount">0</small></a>
				</li>
				<li class="hy">
					<a class="hvr" href="javascript:void(0)"><span>会员中心</span><i class="icon">▪</i></a>
				</li>
				<li class="yh">
					<a class="hvr" href="javascript:void(0)"><span>我的优惠券</span><i class="icon">▪</i></a>
				</li>
				<li class="sc">
					<a class="hvr" href="javascript:void(0)"><span>我的关注</span><i class="icon">▪</i></a>
				</li>
			
			</ul>
			<ul class="rnb-link">
				<li class="qr">

				</li>
				<li class="goback">
					<a class="hvr" href="javascript:void(0)"><span>返回顶部</span><i class="icon">▪</i></a>
				</li>
			</ul>
		</div>
		<div id="out"></div>
		<!--客服模块js-->
		<script type="text/javascript" src="http://116.211.81.199:8090/WebChatClient/js/init.js" charset="utf-8"></script>
		<script language="javascript" type="text/javascript" charset="utf-8">
			NTKF_PARAM = {
				siteid: "lppz_netinfo",
				uid: username || '',
				uname: username || ''
			};
		</script>
		<script type="text/javascript" src="http://download.ntalker.com/t2d2/ntkfstat.js?" charset="utf-8"></script>
		<!-- footer include -->
		<!-- footer -->
		<div class="footer">
			<div class="foot-service">
				<ul>
					<li class="zp"><em>100%</em>
						<p>正品保证</p>
					</li>
					<li class="th"><em>10天</em>
						<p>无理由退换货</p>
					</li>
					<li class="by"><em>满68元</em>
						<p>全程包邮</p>
					</li>
					<li class="jf"><em>积分抵现金</em>
						<p>100积分=1元</p>
					</li>
					<li class="yh"><em>开箱验货</em>
						<p>先验货再签收</p>
					</li>
					<li class="sd"><em>多仓就近发货</em>
						<p>快速直达</p>
					</li>
				</ul>
			</div>
			<div class="foot-area">
				<div class="foot-cont clearfix">

					<div class="fc-link">
						<dl>
							<dt><strong>购物指南</strong></dt>
							<dd>
								<a href="javascript:void(0)">安全账户</a>
								<a href="javascript:void(0)">购物流程</a>
								<a href="javascript:void(0)">生日礼购物流程</a>
								
							</dd>

						</dl>
						<dl>
							<dt><strong>物流配送</strong></dt>
							<dd>
								<a href="javascript:void(0)">配送说明</a>
								<a href="javascript:void(0)">签收与验货</a>
							</dd>

						</dl>
						<dl>
							<dt><strong>付款说明</strong></dt>
							<dd>
								<a href="javascript:void(0)">发票制度</a>
								<a href="javascript:void(0)">公司转账</a>
								<a href="javascript:void(0)">在线支付</a>
							</dd>

						</dl>
						<dl>
							<dt><strong>客户服务</strong></dt>
							<dd>
								<a href="javascript:void(0)">退换货服务</a>
								<a href="javascript:void(0)">联系我们</a>
								<a href="javascript:void(0)">退款说明</a>
							</dd>

						</dl>
						<dl>
							<dt><strong>会员专区</strong></dt>
							<dd>
								<a href="javascript:void(0)">优惠券使用规则</a>
								<a href="javascript:void(0)">积分制度</a>
								<a href="javascript:void(0)">会员须知</a>
							</dd>

						</dl>
					</div>
					<!--fc-link-->

				</div>
				<!--foot-cont clearfix-->

				<div class="foot-nav">
					<ul>
						<li>
							<a href="javascript:void(0)">关于我们</a>
							|
						</li>
						<li>
							<a href="javascript:void(0)">联系我们</a>
							|
						</li>
						<li>
							<a href="javascript:void(0)">客户服务</a>
							|
						</li>
						<li>
							<a href="javascript:void(0)">诚聘英才</a>
							|
						</li>
						<li>
							<a href="javascript:void(0)">商务合作</a>
							|
						</li>
						<li>
							<a href="javascript:void(0)">媒体报道</a>
							|
						</li>
						<li>
							<a href="javascript:void(0)">网站地图</a>
							|
						</li>
						<li>
							<a href="javascript:void(0)">站长招募</a>

						</li>
					</ul>
				</div>
				<!--foot-nav-->
				<div class="foot-copyright">
					Copyright@2007-2017 零嘴小铺电子商务有限公司 All rights Reserved<br/>
					<a href="javascript:void(0)">闽ICP备15022981号</a>
				</div>
			</div>
			<!--foot-area-->
		</div>
		<!--footer-->
		<script src="//configch2.veinteractive.com/tags/B105FE22/510E/4163/911D/0A070929DD44/tag.js" type="text/javascript" async></script>
		<script type="text/javascript" src="js/lp_public.js"></script>
		<script type="text/javascript" src="http://track.blueview.cc/lppz?pid=1&cid=1047&cha=85&clientId=c68c0a5c5b016f241a3dc9ea512698c4"></script>
		<!-- 筛选 -->
		<script type="text/javascript">
			function showaog(sku) {
				if(username) {
					notifysku = sku;
					$.ajax({
						/*这里url应该改成我们自己的servlet请求--跳转用户登录*/
						url: "http://www.lppz.com/member/email.jhtml",
						type: "GET",
						dataType: "jsonp",
						jsonp: "callback",
						cache: false,
						success: function(message) {
							if(message) {
								$('#notifyEmail').val(message);
							} else {
								$('#notifyEmail').val('');
							}
							hasUp($('#aogMessage'));
						}
					});
				} else {
					$.loginIframe({
						id: sku,
						operation: 'notify'
					}); // 调用登录方式
				}
				return null;
			}

			function showaog1(sku) {
				notifysku = sku;
				$.ajax({
					url: "http://www.lppz.com/member/email.jhtml",
					type: "GET",
					dataType: "jsonp",
					jsonp: "callback",
					cache: false,
					success: function(message) {
						if(message) {
							$('#notifyEmail').val(message);
						} else {
							$('#notifyEmail').val('');
						}
						hasUp($('#aogMessage'));
					}
				});
			}
			//列表页筛选样式
			var abc = [];
			var strvalue = new Array();
			var sort = "";
			$(function() {
				// 显示有货的
				$("#showStock").click(function() {
					if($("#showStock").attr("checked")) {
						hasStock = true;
					} else {
						hasStock = false;
					}
					curPage = 1;
					relist(strvalue, sort, true, hasStock);
				});
				// 全部撤消
				$(".sift-selected .revoke a").click(function() {
					$("#filter_all .filt-cate").show();
					$("#condition").find("li").remove();
					$(this).parents(".sift-selected").hide();
					$("#showStock").removeAttr("checked");
					strvalue = new Array();
					relist(strvalue, "", true, false);
				})
				// 添加
				$("#productCategory ul li a").click(function() {
					var needhide = $(this);
					needhide.parents(".filt-cate").hide();
					abc.push(needhide);
					var lab = $(this).parent().parent().prev().html().replace(/ /g, "kongge");
					var val = $(this).html().replace(/ /g, "kongge");
					var theid = $(this).attr('id');
					var currid = $(this).parents(".filt-cate").attr('id');
					strvalue[theid] = "productCategory:" + theid;
					var condition = '<li><a class="onst" rel="' + currid + '" onclick=deleteC("' + currid + '","' + lab + '","' + theid + '")>' + lab + '<span>' + $(this).html() + '</span><i class="icon"></i></a></li>';
					$("#condition").append(condition);
					$("#condition").each(function() {
						var t = $(this).html();
						t = t.replace(/[\r\n]/g, "").replace(/[ ]/g, "");
						if(t !== '') {
							$(this).parent(".sift-selected").show();
						}
					});
					relist(strvalue, sort, true, hasStock);
				});

				// 添加
				$("#filter_all ul li a").click(function() {
					var needhide = $(this);
					needhide.parents(".filt-cate").hide();
					abc.push(needhide);
					var val = $(this).html().replace(/ /g, "kongge");
					var lab = $(this).parent().parent().prev().html().replace(/ /g, "kongge");
					var theid = $(this).parents(".filt-cate").attr('id');
					if(theid == 99) {
						if(val == "9.9元以下") {
							strvalue[theid] = "price:[0 TO 9.99]";
						} else if(val == "10-19.9元") {
							strvalue[theid] = "price:[10 TO 19.99]";
						} else if(val == "20-29.9元") {
							strvalue[theid] = "price:[20 TO 29.99]";
						} else if(val == "30-50元") {
							strvalue[theid] = "price:[30 TO 50]";
						} else if(val == "51-100元") {
							strvalue[theid] = "price:[51 TO 100]";
						} else if(val == "100元以上") {
							strvalue[theid] = "price:[101 TO *]";
						}
					} else {
						strvalue[theid] = "attrJson:*" + val + "*";
					}
					var condition = '<li><a class="onst" rel="' + theid + '" onclick=deleteC("' + theid + '","' + lab + '","' + theid + '")>' + lab + '<span>' + $(this).html() + '</span><i class="icon"></i></a></li>';
					$("#condition").append(condition);
					$("#condition").each(function() {
						var t = $(this).html();
						t = t.replace(/[\r\n]/g, "").replace(/[ ]/g, "");
						if(t !== '') {
							$(this).parent(".sift-selected").show();
						}
					});
					relist(strvalue, sort, true, hasStock);
				});
			});
			// 删除
			function deleteC(v, lab, theid) {
				var val = v.replace(/kongge/g, " ");
				strvalue[theid] = null;
				$("#condition li").find("a[rel='" + val + "']").parent("li").remove();
				$("#" + val).show();
				$("#condition").each(function() {
					var t = $(this).html();
					t = t.replace(/[\r\n]/g, "").replace(/[ ]/g, "");
					if(t == '') {
						$(this).parent(".sift-selected").hide();
					}
				});
				relist(strvalue, sort, true, hasStock);
			};

			// 综合排序
			function sort_page() {
				if($("#sort_page").hasClass("curr")) {
					sort = "1";
				} else {
					sort = "";
				}
				relist(strvalue, sort, true, hasStock);
			}

			// 销量
			function sort_page_xl() {
				if($("#sort_page_xl").hasClass("curr")) {
					sort = "5";
				} else {
					sort = "4";
				}
				relist(strvalue, sort, true, hasStock);
			}

			// 价格
			function sort_page_jg() {
				if($("#sort_page_jg").hasClass("down")) {
					sort = "3";
				}
				if($("#sort_page_jg").hasClass("rise")) {
					sort = "2";
				}
				relist(strvalue, sort, true, hasStock);
			}

			// 评论
			function sort_page_pl() {
				if($("#sort_page_pl").hasClass("curr")) {
					sort = "13";
				} else {
					sort = "";
				}
				relist(strvalue, sort, true, hasStock);
			}

			// 上架时间
			function sort_page_sj() {
				if($("#sort_page_sj").hasClass("rise")) {
					sort = "4";
				}
				if($("#sort_page_sj").hasClass("down")) {
					sort = "5";
				}
				relist(strvalue, sort, true, hasStock);
			}
		</script>

		<script type="text/javascript">
			var curPage = 1,
				pageSize = 12;
			$(function() {
				relist();
			});

			//列表页筛选内容加载
			function relist(strlist, strbuttom, pageBtnClick, hasStock) {
				if(!pageBtnClick) {
					curPage = 1;
				}
				var keyword_top = $("#keyword").val();
				if(keyword_top == "商品搜索") {
					keyword_top = "";
				}
				var keyword_body = "";
				if(strlist != null) {
					keyword_body = strlist.join(",");
				}
				if(!strbuttom) {
					strbuttom = '';
				}
				var keyword_bottom = strbuttom;
				var productCategoryId = '100101';
				submitData = "curPage=" + curPage + "&pageSize=" + pageSize + "&keyword_top=" + keyword_top + "&keyword_body=" + keyword_body + "&keyword_bottom=" + keyword_bottom + "&productCategoryCode=" + productCategoryId;
				if(hasStock) {
					submitData = submitData + "&hasStock=1";
				}
				$.ajax({
					type: "POST",
					url: "http://search.lppz.com/product/prolist.jhtml",
					dataType: "json",
					data: submitData,
					beforeSend: function(XMLHttpRequest) {
						$("#loadingMessage").html("&nbsp;&nbsp;&nbsp;&nbsp;<span>请稍后，数据加载中！</span>");
						$("#loadingMessage").css({
							display: ""
						});
					},
					success: function(data) { //如果调用成功
						$("#showControlPage").html(data.content);
						$("#loadingMessage").css({
							display: "none"
						});
						$("#pageBar").html(data.pageBar);
						$("#count").html(data.count);
					},
					error: function() {
						$("#loadingMessage").css({
							display: ""
						});
						<!--$("#loadingMessage").html("<span class=\"errorFont\">数据加载遇到错误，请稍后再试</span>");-->
					}
				});
			}

			function showProPages(curPageUser) {
				curPage = curPageUser;
				relist(strvalue, sort, true, hasStock);
			}
		</script>
		<!--通知弹窗-->
		<div class="msg-popups" id="aogMessage" style="width:460px">
			<div class="msg-wrap">
				<div class="msg-tit"><span><i class="icon"></i>到货通知</span>
					<a href="javascript:;" class="shut-btn close">关闭</a>
				</div>
				<div class="msg-cont">
					<div class="msg-aog">
						<div class="aog-cue">一旦商品在30日内到货，您将收到邮件
							<!--、短信和手机-->推送消息！
							<!--通过手机客户端消息提醒，购买更便捷~-->
						</div>
						<ul class="msg-form">
							<!--<li><span class="lb-txt">手机号码：</span><input class="tx-ipt" type="text" name="" id="" /></li>-->
							<li><span class="lb-txt">邮箱地址：</span><input class="tx-ipt" type="text" name="" id="notifyEmail" />
								<!--<b class="red">*</b><label for="" class="fieldError">邮箱格式不对</label>--></li>
						</ul>
					</div>
				</div>
				<div class="msg-btn">
					<input class="confirm" type="button" value="确 定" />
					<input class="shut-btn cancel" type="button" value="取 消" />
				</div>
			</div>
		</div>
		<script type="text/javascript">
			$(".msg-popups .shut-btn").click(function() {
				$(".msg-popups,.mask-layer").hide();
			});
			$('.confirm').click(function() {
				var email = $('#notifyEmail').val();
				var reg = /^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/;
				if(!reg.test(email)) {
					$.message('error', '请输入正确的邮箱地址!');
					return;
				}
				$.ajax({
					url: "http://www.lppz.com/product_notify/save.jhtml",
					type: "GET",
					data: {
						sku: notifysku,
						email: email
					},
					cache: false,
					jsonp: "callback",
					dataType: "jsonp",
					success: function(message) {
						$(".msg-popups,.mask-layer").hide();
						$.message(message);
					}
				});
			});
		</script>
		<script type="text/javascript">
			var _ozprm = "keyword=" + $("#word").val();
		</script>

		<script type="text/javascript" src="js/o_code.js"></script>
		
				<script type="text/javascript">
		//页面加载时初始化购物车中的信息
			$(".goods").empty();
			$(".total").empty();
			$("#goodsnum").text("");
			var sumgoods = 0;
			var sumprice = 0;
			var username = $('.username').text();
			$.post("${path}GoodsCartServlet",{"op":"queryShopCart","UserName":username},function(listgc,status){
				$.each(listgc,function(index,data){
					/* 购物车的的item- */							
					$(".goods").append("<li><input type='hidden' id='GOODSID' class='goodsiddel' value='"+data.GOODSID+"' /><div class='gd-lft'><a class='pic'><img src='"+data.GOODSPICTURE+"'/></a><p class='tit'>"+data.GOODSNAME+"</p></div><div class='gd-price'><span>￥"
						+data.GOODSPRICE+"<small>x"+data.GOODSCOUNT+"</small></span><a href='javascript:;' class='delete'>删除</a></div></li>");
			   	   sumgoods += data.GOODSCOUNT;
			   	   sumprice += (sumgoods*data.GOODSPRICE);
				});			
				$(".total").append("<p>共<span class='red'>"+sumgoods+"</span>件商品，共计<span class='sum+'>￥"+sumprice.toFixed(2)+"</span></p><a class='settle' href='javascript:;'>去购物车结算</a>");
				$("#goodsnum").text(sumgoods);
			});	

			
		</script>	
		
				<script type="text/javascript">
			//购物车中删除
			$(document).on("click",'.delete',function(index){
				var sumgoods = 0;
				var sumprice = 0;
				var username = $('.username').text();
				var goodsiddel=$(this).parent().parent().find("#GOODSID").val();
				var flag=confirm("是否要删除");
				if(flag){
					$(".goods").empty();
					$(".total").empty();
					$("#goodsnum").text("");
					$.post("${path}GoodsCartServlet",{"op":"queryGoodsDelete","UserName":username,"GoodsID":goodsiddel},function(listgc,status){			
					$.each(listgc,function(index,data){
					/* 购物车的的item- */							
					$(".goods").append("<li><input type='hidden' id='GOODSID' class='goodsiddel' value='"+data.GOODSID+"' /><div class='gd-lft'><a class='pic'><img src='"+data.GOODSPICTURE+"'/></a><p class='tit'>"+data.GOODSNAME+"</p></div><div class='gd-price'><span>￥"
					+data.GOODSPRICE+"<small>x"+data.GOODSCOUNT+"</small></span><a href='javascript:;' class='delete'"+data.GOODSID+"'>删除</a></div></li>");
					sumgoods += data.GOODSCOUNT;
					sumprice += (sumgoods*data.GOODSPRICE);
					});			
					$(".total").append("<p>共<span class='red'>"+sumgoods+"</span>件商品，共计<span class='sum+'>￥"+sumprice.toFixed(2)+"</span></p><a class='settle' href='javascript:;'>去购物车结算</a>");
					$("#goodsnum").text(sumgoods);
					});
				}else{
					
				}
			});

		</script>
		<script type="text/javascript">
		//购物车结算按钮的点击
		var username = $('.username').text();
		$(document).on("click",'.settle',function(index){
							$.post("${path}GoodsCartServlet",{"op":"submitOrder","UserName":username},function(result,status){
								if(result == true){
									//如果登录成功,页面跳转
									location.href="http://localhost:8080/lzxp/myorder2.jsp";
								}else{
									//如果失败
									location.href="http://localhost:8080/lzxp/login.jsp";
								}
							});
						});
		</script>
	</body>
</html>