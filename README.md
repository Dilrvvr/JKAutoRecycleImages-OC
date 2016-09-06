# JKAutoRecycleImages-OC
###自动自动无限循环轮播图-OC
###点击查看[Swift版](https://github.com/Jacky-An/JKAutoRecycleImages-Swift/ "Title") 
***
![image](https://github.com/Jacky-An/JKAutoRecycleImages-OC/raw/master/introductionimages/introduction.gif)
***
* 之前的实现思路都是在别人的博客中看到的，也下载了他们的demo。无一例外都是先创建好左中右三个imageView，然后切换图片。

* 实际体验中发现该方案存在一个问题：<font color=#DC143C size=3 face="黑体">随意方向拖动一点即切换下一张</font>。在下载的demo中都有这样的问题。

* 之后稍做了一点优化，解决了拖动一点即切换下一张的问题，但是又出现了新的问题：<font color=#DC143C size=3 face="黑体">快速滑动时最多能滑动两张，再下一张会变成空白，划不动，且pageControl的索引会错乱</font>。虽然过一会自动循环会恢复正常，但是不能快速滑动，真的不完美！

* 于是开始漫长时间的折腾。终于试出了<font color=#DC143C size=3 face="黑体">较为完美的解决办法</font>。因为不知道这种方案的内存和性能怎样，所以称“较为完美”。
	* 1、根据外接传入的数据先创建好所有的imageView，保存到数组中。
	* 2、每次滚动后根据算好的索引，从数组中取出当前左中右三个imageView，添加到scrollView上。注意之前先清空scrollView子控件。
	
###### 对应的Swift版也已经写出来了，欢迎批评指正。
	
###### 如果有更好的实现方案，希望大神能不吝分享。