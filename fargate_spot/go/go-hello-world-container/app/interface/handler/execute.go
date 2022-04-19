package handler

import (
	"fmt"
	"time"
)

func Execute(req RequestParam) (string, error) {
	now := time.Now()
	fmt.Printf("-- Start Function: %s --\n", now.Format("2006-01-02 15:04:05"))

	// メイン処理
	// time.Sleep(1 * time.Minute)
	fmt.Printf("ParamA: %v\n", req.ParamA)
	fmt.Printf("ParamB: %v\n", req.ParamB)

	fmt.Println("Time: ", time.Since(now).Milliseconds(), "ms")
	fmt.Printf("-- Exit Function: %s --\n", now.Format("2006-01-02 15:04:05"))

	return "", nil
}
