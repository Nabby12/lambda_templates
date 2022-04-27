package application

import (
	"time"
	// "app/domain"
)

func Sample(second int) error {
	time.Sleep(time.Duration(second) * time.Second)

	// 必ず失敗する致命的なエラー（キューを削除する）
	// err := &domain.FatalErr{Message: "fatal error."}
	// fmt.Printf("%+v\n", err)

	// return err

	return nil
}
