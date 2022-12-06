package main

import (
	"encoding/json"
	"flag"
	"os"

	"github.com/tealeg/xlsx"
)

var (
	OUT_FILE  = flag.String("out", "", "输出的xlsx文件路径")
	JSON_FILE = flag.String("json", "", "转换的json文件路径")
)

func main() {
	flag.Parse()
	f, e := os.OpenFile(*OUT_FILE, os.O_RDWR|os.O_CREATE, 0755)
	if e != nil {
		panic(e)
	}
	file := xlsx.NewFile()
	newSheet, createErr := file.AddSheet("page1")
	if createErr != nil {
		panic(createErr)
	}
	// 读取JSON
	data, dataErr := os.ReadFile(*JSON_FILE)
	if dataErr != nil {
		panic(dataErr)
	}
	var jsonData any
	jsonErr := json.Unmarshal(data, &jsonData)
	if jsonErr != nil {
		panic(jsonErr)
	}
	// 解析数组
	array, arrayErr := jsonData.([]any)
	if !arrayErr {
		panic("JSON格式错误")
	}
	// fmt.Println(array)
	for ix, v := range array {
		childArray, b2 := v.([]any)
		if !b2 {
			panic("子对象格式错误")
		}
		for iy, v2 := range childArray {
			newSheet.Cell(ix, iy).Value = v2.(string)
		}
	}
	file.Write(f)
}
