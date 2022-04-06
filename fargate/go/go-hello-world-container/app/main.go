package main

import (
	"fmt"
	"os"
	"time"
)

func main() {
	now := time.Now()
	fmt.Printf("-- Start Function: %s --\n", now.Format("2006-01-02 15:04:05"))

	fmt.Printf("Env: %s\n", os.Getenv("ENV"))

	fmt.Println("Time: ", time.Since(now).Milliseconds(), "ms")
	fmt.Printf("-- Exit Function: %s --\n", now.Format("2006-01-02 15:04:05"))
}
