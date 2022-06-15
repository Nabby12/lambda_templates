package handler

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"time"

	"app/domain"
	"app/infrastructure/queue"
)

func Handler(ctx context.Context) {
	qr, err := queue.NewQueueRepository()
	if err != nil {
		fmt.Printf("%v\n", err)
		return
	}

	for {
		select {
		case <-ctx.Done():
			fmt.Println("!!! Task Canceled !!!")
			return
		default:
			var req domain.RequestParam

			message, err := qr.ReceiveMsg(os.Getenv("TRIGGER_QUEUE_URL"))
			if err != nil {
				fmt.Println(err)
			}
			if len(message) == 0 {
				fmt.Println("--- Empty Receive ---")
				continue
			}

			for _, msg := range message {
				if err := json.Unmarshal([]byte(*msg.Body), &req); err != nil {
					fmt.Println(err)
					continue
				}
			}

			result, err := Execute(req)
			if err != nil {
				fmt.Printf("execute failed: %v\n", err)

				// カスタムエラーごとの処理
				if domain.IsSome(err) {
					fmt.Println("some thing wrong.")
				}

				// 必ず失敗する致命的なエラーの場合は、メッセージ削除
				if domain.IsFatal(err) {
					fmt.Println("fatal error")
					if err := qr.DeleteMsg(os.Getenv("TRIGGER_QUEUE_URL"), message...); err != nil {
						fmt.Printf("dlq send failed: %v\n", err)
					}
					time.Sleep(2 * time.Second)
				}

				continue
			}
			fmt.Printf("%v\n", result)

			if err := qr.DeleteMsg(os.Getenv("TRIGGER_QUEUE_URL"), message...); err != nil {
				fmt.Printf("dlq send failed: %v\n", err)
			}
			time.Sleep(2 * time.Second)
		}
	}
}
