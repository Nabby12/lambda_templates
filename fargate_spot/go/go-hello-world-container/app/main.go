package main

import (
	"context"
	"fmt"
	"os/signal"
	"syscall"

	"app/interface/handler"
)

func main() {
	// SIGTERM処理
	// SIGTERM受信から60秒後にコンテナ強制停止
	// SIGTERM受信前から動いている処理が60秒経っても処理中の場合、処理中断で再度コンシューマから受信可能になる
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()

	go func() {
		<-ctx.Done()
		fmt.Println("!!! Caught SIGTERM, shutting down !!!")
		stop()
	}()
	// SIGTERM処理

	// メイン処理実行
	handler.Handler(ctx)
}
