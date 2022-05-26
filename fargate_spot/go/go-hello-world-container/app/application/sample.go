package application

import (
	"fmt"
	"sync"
	"time"
	// "app/domain"
)

func Sample(second int) error {
	time.Sleep(time.Duration(second) * time.Second)

	// 必ず失敗する致命的なエラー（キューを削除する）
	// err := &domain.FatalErr{Message: "fatal error."}
	// fmt.Printf("%+v\n", err)

	// return err

	// go routine で並列実行
	loopItems := [...]string{"0", "1", "2"}
	errChan := make(chan error, len(loopItems))
	wg := new(sync.WaitGroup)
	for _, item := range loopItems {
		wg.Add(1)

		item := item // go routine 起動よりも for ループ終了の方が早いため変数の代入が必要
		go func(wg *sync.WaitGroup) {
			defer wg.Done()

			if err := SamplePrint(item); err != nil {
				fmt.Printf("%v\n", err)
				errChan <- err
			}
		}(wg)
	}
	wg.Wait()
	close(errChan)

	for err := range errChan {
		if err != nil {
			fmt.Printf("%v\n", err)
			return err
		}
	}

	return nil
}

func SamplePrint(item string) error {
	fmt.Printf("pritn start: %s \n", time.Now().Format("2006-01-02 15:04:05"))
	fmt.Printf("print item: %v\n", item)

	// go routineで並列実行する処理
	time.Sleep(time.Duration(2) * time.Second)

	fmt.Printf("pritn end: %s \n", time.Now().Format("2006-01-02 15:04:05"))
	return nil
}
