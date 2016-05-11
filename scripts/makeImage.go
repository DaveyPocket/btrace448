// GoLang rar tracer
// Bradley Boccuzzi
// 2016
package main

import (
	"bufio"
	"fmt"         // Think of this as "stdio"
	"image"       // Image package
	"image/color" // For RGB colors
	"image/png"   // For encoding image as PNG
	"math"
	"os" // For file manipulation
)

type screen struct {
	width, height int
}

func main() {
	var err error
	var resultColor color.Color
	testBenchInput, err := os.Open("../../results.resl")
	if err != nil {
		panic(err)
	}
	defer testBenchInput.Close()
	myfile, err := os.Create("test_result.png")
	if err != nil {
		panic(err)
	}
	defer myfile.Close()
	fmt.Println("Running...")
	myScreen := screen{320, 240}
	output := image.NewRGBA(image.Rect(0, 0, myScreen.height, myScreen.width))

	resultScanner := bufio.NewScanner(testBenchInput)
	for row := 0; row < myScreen.height; row++ {
		for column := 0; column < myScreen.width; column++ {
			resultScanner.Scan()
			//resultLine = resultScanner.Text()
			resultColor = getColorFromText(resultScanner.Text())
			output.Set(row, column, resultColor)
		}
	}
	err = png.Encode(myfile, output)
	if err != nil {
		panic(err)
	}
}

func getColorFromText(in string) color.Color {
	var temp1, temp2, temp3 int = 0, 0, 0
	for i, val := range in[0:4] {
		if val == '1' {
			temp1 += int(math.Pow(2, float64(3-i)))
		}
	}
	for i, val := range in[4:8] {
		if val == '1' {
			temp2 += int(math.Pow(2, float64(3-i)))
		}
	}
	for i, val := range in[8:12] {
		if val == '1' {
			temp3 += int(math.Pow(2, float64(3-i)))
		}
	}
	return color.RGBA{uint8(temp1) << 4, uint8(temp2) << 4, uint8(temp3) << 4, 255}
}
