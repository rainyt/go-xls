## 使用方法
将需要转换的格式，先使用文本储存准备好：
```json
[
["1","2","3"],
["k1","v2","v4"]
]
```
然后再通过命令转换：
```shell
./go-xls.exe --json data.json --out test.xlsx
```

## SWC使用方法
在配置中引入`bin/as3tools.swc`文件
然后在代码里调用：
```actionscript3
var array = [
	["1","2","3"],
	["4","5","6"]
]
As3Tools.jsonToXlsx(array, "testfile2.xlsx",function(){
	trace("保存完成");
});
```

## SWC编译说明
如果需要编译SWC，请先准备go-xls/go-xls.exe两个文件。