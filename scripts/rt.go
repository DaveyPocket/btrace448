// GoLang rar tracer
// Bradley Boccuzzi
// 2016
package main

import (
	"fmt"         // Think of this as "stdio"
	"image"       // Image package
	"image/color" // For RGB colors
	"image/png"   // For encoding image as PNG
	"os"          // For file manipulation

	"math" //**Contains SQRT function********
)

type point struct {
	x, y, z float64
}

type vector struct {
	p0, p1 point
}

func (v vector) magnitude() float64 {
	var dx, dy, dz float64
	dx = v.p1.x - v.p0.x
	dy = v.p1.y - v.p0.y
	dz = v.p1.z - v.p0.z
	return math.Sqrt((dx * dx) + (dy * dy) + (dz * dz))
}

func (v vector) scale(a float64) vector {
	p1 := point{v.p1.x * a, v.p1.y * a, v.p1.z * a}
	p0 := point{v.p0.x * a, v.p0.y * a, v.p0.z * a}
	return vector{p0, p1}
}

func (v vector) unit() vector {
	var dx, dy, dz float64
	dx = (v.p1.x - v.p0.x) / v.magnitude()
	dy = (v.p1.y - v.p0.y) / v.magnitude()
	dz = (v.p1.z - v.p0.z) / v.magnitude()
	np := point{v.p0.x + dx, v.p0.y + dy, v.p0.z + dz}
	return vector{v.p0, np}
}

func (v vector) dot(u vector) float64 {
	var dx0, dy0, dz0 float64
	dx0 = v.p1.x - v.p0.x
	dy0 = v.p1.y - v.p0.y
	dz0 = v.p1.z - v.p0.z
	var dx1, dy1, dz1 float64
	dx1 = u.p1.x - u.p0.x
	dy1 = u.p1.y - u.p0.y
	dz1 = u.p1.z - u.p0.z
	return (dx0 * dx1) + (dy0 * dy1) + (dz0 * dz1)
}

type ray struct {
	origin    point
	direction vector // Must be unit vector
}

type sphere struct {
	center   point
	radius   float64
	maxcolor color.Color
}

/*
type cube struct {
	center   point
	p0, p1   point
	maxColor color.Color
}*/

type plane struct {
	p0, p1   point
	maxColor color.Color
}

/*
func (p plane) collision(r ray) {
	planeVect := vector{p.p0, p.p1}
	normal := vector{p.p0,
}
*/

func (s sphere) getColor() color.Color {
	return s.maxcolor
}

func (v vector) actualPoint(start point) point {
	var dx0, dy0, dz0 float64
	dx0 = v.p1.x - v.p0.x + start.x
	dy0 = v.p1.y - v.p0.y + start.y
	dz0 = v.p1.z - v.p0.z + start.z
	return point{dx0, dy0, dz0}
}

func (s sphere) reflect(r ray, o []object, pLight point) color.Color {
	pointp := r.direction.unit().actualPoint(r.origin)
	pointp1 := vector{r.origin, pointp}.unit().scale(s.collision(r)).actualPoint(r.origin)
	normal := vector{s.center, pointp1}
	normalScale := -r.direction.unit().dot(normal.unit()) * 2
	pP := normal.unit().scale(normalScale).p1
	rPoint := r.direction.unit().actualPoint(pP)
	rRay := ray{pointp1, vector{rPoint, pointp1}}
	for _, n := range o {
		if n.collision(rRay) > 0 {
			cc := n.shade(rRay, pLight)
			return cc
		}
	}
	return s.shade(r, pLight)
}

func (s sphere) shade(r ray, pLight point) color.Color {
	pointp := r.direction.unit().actualPoint(r.origin)
	pointp1 := vector{r.origin, pointp}.unit().scale(s.collision(r)).actualPoint(r.origin)
	lightvect := vector{s.center, pLight}
	normal := vector{s.center, pointp1}
	y := normal.unit().dot(lightvect.unit())
	gcr, gcg, gcb, gca := s.getColor().RGBA()

	cr, cg, cb, ca := uint8((255*gcr)/65535), uint8((255*gcg)/65535), uint8((255*gcb)/65535), uint8((255*gca)/65535)

	if y > 0 {
		b := color.RGBA{uint8(float64(cr) * y), uint8(float64(cg) * y), uint8(float64(cb) * y), uint8(ca)}
		return b
	}
	return color.RGBA{0, 0, 0, 255}
}

func (s sphere) collision(r ray) float64 {
	v := vector{s.center, r.origin}
	q := v.dot(r.direction.unit()) // Must be unit vector
	//fmt.Println(r.direction.unit())
	//fmt.Println(r.direction.unit())
	//fmt.Println(r.direction, r.direction.unit()) //, (q * q), v.dot(v))
	//fmt.Println(-q, q*q, (v.dot(v)))
	t1 := -q + math.Sqrt((q*q)-(v.dot(v)-(s.radius*s.radius)))
	t2 := -q - math.Sqrt((q*q)-(v.dot(v)-(s.radius*s.radius)))
	if t1 < t2 {
		return t1
	}
	return t2
}

type screen struct {
	width, height int
	camera        point
	//buf           [][]int
}

func (s screen) getRay(y, z int) (r ray) {
	//xx := float64(0) + s.camera.x
	yy := float64(y) - (float64(s.width / 2)) + s.camera.y
	zz := float64(z) - (float64(s.height / 2)) + s.camera.z
	// Camera centered
	r.origin = point{0, yy, zz}
	p0 := s.camera
	p1 := point{0, yy, zz}
	r.direction = vector{p0, p1}
	return
}

type object interface {
	collision(ray) float64
	getColor() color.Color
	shade(r ray, pLight point) color.Color
	reflect(r ray, o []object, pLight point) color.Color
}

func main() {
	pointList := []object{}
	myfile, err := os.Create("test.png")
	if err != nil {
		panic(err)
	}
	defer myfile.Close()
	fmt.Println("Running...")
	myObjects := [2]object{sphere{point{500, -200, -150}, 80, color.RGBA{255, 255, 255, 255}},
		sphere{point{150, 100, 100}, 100, color.RGBA{200, 200, 00, 255}},
		//sphere{point{-10, 30, -80}, 50, color.RGBA{255, 0, 00, 255}},
	}
	//mySphere := sphere{point{100, 0, 0}, 80, myColor{255, 0, 0}}
	myScreen := screen{800, 800, point{-5000, 0, 0}}
	output := image.NewRGBA(image.Rect(0, 0, myScreen.width, myScreen.height))
	for row := 0; row < myScreen.width; row++ {
		for column := 0; column < myScreen.height; column++ {
			r := myScreen.getRay(column, row)
			for _, obj := range myObjects {
				if obj.collision(r) > 0 {
					if len(pointList) == 0 {
						pointList = append(pointList, obj)
					} else if obj.collision(r) < pointList[0].collision(r) {
						pointList[0] = obj
					}
				}
			}
			if len(pointList) > 0 {
				//fmt.Println(obj.collision(r))
				_, _, BB, _ := pointList[0].getColor().RGBA()
				if BB == 65535 {
					output.Set(row, column, pointList[0].reflect(r, myObjects[1:], point{10, -80, -80}))
				} else {
					output.Set(row, column, pointList[0].shade(r, point{10, -80, -80}))
				}
			} else {
				output.Set(row, column, color.RGBA{80, 80, 80, 255})
			}
			pointList = []object{} // Clear pointList
		}
	}
	err = png.Encode(myfile, output)
	if err != nil {
		panic(err)
	}
}
