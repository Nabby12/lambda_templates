package handler

import (
	"fmt"
	"time"

	"app/application"
	"app/domain"
)

func Execute(req domain.RequestParam) (string, error) {
	start := time.Now()
	fmt.Printf("-- Start Function: %s --\n", start.Format("2006-01-02 15:04:05"))
	defer func(start time.Time) {
		fmt.Println("Time: ", time.Since(start).Milliseconds(), "ms")
		fmt.Printf("-- Exit Function: %s --\n", time.Now().Format("2006-01-02 15:04:05"))
	}(start)

	// メイン処理
	if err := application.Sample(10); err != nil {
		fmt.Printf("%v\n", err)
		return "", err
	}

	fmt.Printf("ParamA: %v\n", req.ParamA)
	fmt.Printf("ParamB: %v\n", req.ParamB)

	return "", nil
}
