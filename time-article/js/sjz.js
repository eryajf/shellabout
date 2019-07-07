$(function(){
	// 时间轴
	var timerNum = 0;
	var space = 210; // 移动间距
	var length = $('.timer-scale-cont').length, numL;
	// 分辨率
	if(window.screen.width > 1500) {
		numL = length - 4
	} else if(window.screen.width < 1500) {
		numL = length - 3
	}
	// 点击左侧
	$('.timer-left').on('click', function () {
		if(timerNum > 0) {
			timerNum -= 1;
			moveL(timerNum, numL)
		}
		tags(timerNum);
	})
	// 点击右侧
	$('.timer-right').on('click', function () {
		if(timerNum < length - 1) {
			timerNum += 1;
			tags(timerNum);
		}
		moveL(timerNum, numL)
	})
	// 点击年
	$('.time-circle').each(function (index) {
		$(this).on('click', function () {
			timerNum = index;
			moveL(timerNum, numL)
			tags(timerNum);
		})
	})
	function tags(num){
		$('.timer-scale-cont').eq(num).addClass('hov').siblings().removeClass('hov');
		$('.shaft-detail-cont').eq(num).show().siblings().hide();
	}
	function moveL(num, len) {
		if (num < len) {
			moveLeft = -num * space;
			$('.timer-scale').animate({left:moveLeft}, 700);
		}
	}
})