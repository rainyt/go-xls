package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"

	"github.com/tealeg/xlsx"
)

var (
	OUT_FILE  = flag.String("out", "", "输出的xlsx文件路径")
	JSON_FILE = flag.String("json", "", "转换的json文件路径")
	APPEND    = flag.Bool("append", false, "是否将xlsx数据追加")
)

func main() {
	flag.Parse()
	f, e := os.OpenFile(*OUT_FILE, os.O_RDWR|os.O_CREATE, 0755)
	if e != nil {
		panic(e)
	}
	var file *xlsx.File
	oldFile, err := xlsx.OpenFile(*OUT_FILE)
	if err == nil {
		fmt.Println("存在旧文件")
		file = oldFile
	} else {
		file = xlsx.NewFile()
	}
	var offestY = 0
	var newSheet *xlsx.Sheet
	var useAppend = false
	oldSheet, sheetExist := file.Sheet["page1"]
	if sheetExist && *APPEND {
		fmt.Println("append模式")
		newSheet = oldSheet
		offestY = newSheet.MaxRow
		useAppend = true
	} else {
		newSheet2, createErr := file.AddSheet("page1")
		if createErr != nil {
			panic(createErr)
		}
		newSheet = newSheet2
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
		// 如果是追加模式，忽略第一行
		if useAppend && ix == 0 {
			continue
		}
		for iy, v2 := range childArray {
			newSheet.Cell(ix+offestY, iy).Value = v2.(string)
		}
	}
	file.Write(f)
}
