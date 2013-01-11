iOS JSON parser. Optimized for devices and faster than JSONKit and NSJSONSerialization.
============
Regarding [this post](http://www.bonto.ch/blog/2011/12/08/json-libraries-for-ios-comparison-updated) JSONKit is fastes JSON parsing library. But after releasing iOS 6.0 these results must be updated.
So was created test application for testing JSONKit and NSJSONSerialization on device(not on emulator) and winner is NSJSONSerialization.
But this is not all: after seveveral days was created custom parser called OKJSONParser which is faster NSJSONSerialization on real device.
For testing was used iPhone 4 with iOS Version 6.0.1 (10A523) and the results is listed bellow:

<img src="https://github.com/OlehKulykov/OKJSONParser/blob/master/TestResultCharts/iph4release.png?raw=true" width="410" height="285" alt="Release version" />
<img src="https://github.com/OlehKulykov/OKJSONParser/blob/master/TestResultCharts/iph4debug.png?raw=true" width="410" height="285" alt="Debug version" />

Screenshots with test results from device:
<br><b>Release mode:</b><br>
<img src="https://github.com/OlehKulykov/OKJSONParser/blob/master/TestResultCharts/iph4r100.png?raw=true" width="200" height="305" alt=""/>
<img src="https://github.com/OlehKulykov/OKJSONParser/blob/master/TestResultCharts/iph4r200.png?raw=true" width="200" height="305" alt=""/>
<img src="https://github.com/OlehKulykov/OKJSONParser/blob/master/TestResultCharts/iph4r500.png?raw=true" width="200" height="305" alt=""/>
<img src="https://github.com/OlehKulykov/OKJSONParser/blob/master/TestResultCharts/iph4r1000.png?raw=true" width="200" height="305" alt=""/>
<br><b>Debug mode:</b><br>
<img src="https://github.com/OlehKulykov/OKJSONParser/blob/master/TestResultCharts/iph4d100.png?raw=true" width="200" height="305" alt=""/>
<img src="https://github.com/OlehKulykov/OKJSONParser/blob/master/TestResultCharts/iph4d200.png?raw=true" width="200" height="305" alt=""/>
<img src="https://github.com/OlehKulykov/OKJSONParser/blob/master/TestResultCharts/iph4d500.png?raw=true" width="200" height="305" alt=""/>
<img src="https://github.com/OlehKulykov/OKJSONParser/blob/master/TestResultCharts/iph4d1000.png?raw=true" width="200" height="305" alt=""/>
<br>

So in result: for the current moment OKJSONParser is ~30% faster in Release mode than NSJSONSerialization.
<b>For improving this results any optimizations and suggestions are welcome.</b>