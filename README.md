# JKAutoRecycleImages-OC
### 无限轮播图-OC
### 点击查看[Swift版](https://github.com/Jacky-An/JKAutoRecycleImages-Swift/ "Title") 
***
![image](https://github.com/Jacky-An/JKAutoRecycleImages-OC/raw/master/introductionimages/introduction.gif)
***

* 之前的实现思路是使用UIScrollView。
	* 1、根据外界传入的数据先创建好所有的imageView，保存到数组中。
	* 2、每次滚动后根据算好的索引，从数组中取出当前左中右三个imageView，添加到scrollView上。注意之前先清空scrollView子控件。
    
* 现在已经改为使用UICollectionView实现！
    * 1、在正常数组的前后分别插入最后一个数据和第一个数据，此时数组总数+2。
    * 2、当滚动到总数组的最后一个时，自动调整到总数组的第二个。
    * 3、当滚动到总数组的第一个时，自动调整到总数组的倒数第二个。
