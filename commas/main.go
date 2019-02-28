package main

import (
	"fmt"
	"regexp"

	"github.com/ghodss/yaml"
	"k8s.io/helm/pkg/strvals"
)

func main() {
	run1()
	run2()
	run3()
}

func run1() {
	base := map[string]interface{}{}
	strvals.ParseIntoString("test=10.0.0.0/32,10.0.0.0/32", base)
	o, _ := yaml.Marshal(base)
	fmt.Println(string(o))
}

func run2() {
	base := map[string]interface{}{}
	strvals.ParseIntoString("test=10.0.0.0/32\\,10.0.0.0/32", base)
	o, _ := yaml.Marshal(base)
	fmt.Println(string(o))
}

func run3() {
	commas := regexp.MustCompile(`([^\\]),`)

	base := map[string]interface{}{}
	strvals.ParseIntoString(commas.ReplaceAllString("test1=10.0.0.0/32,10.0.0.0/32", "$1\\,"), base)
	strvals.ParseIntoString(commas.ReplaceAllString("test2=10.0.0.0/32\\,10.0.0.0/32", "$1\\,"), base)
	o, _ := yaml.Marshal(base)
	fmt.Println(string(o))
}
