package handler

import (
	"fmt"
	"time"

	"app/application"
	"app/domain"
)

func Execute(req domain.RequestParam) (string, error) {
	now := time.Now()
	fmt.Printf("-- Start Function: %s --\n", now.Format("2006-01-02 15:04:05"))

	// メイン処理
	if err := application.Sample(10); err != nil {
		fmt.Printf("%v\n", err)
		return "", err
	}

	fmt.Printf("ParamA: %v\n", req.ParamA)
	fmt.Printf("ParamB: %v\n", req.ParamB)

	fmt.Println("Time: ", time.Since(now).Milliseconds(), "ms")
	fmt.Printf("-- Exit Function: %s --\n", now.Format("2006-01-02 15:04:05"))

	return "", nil
}
