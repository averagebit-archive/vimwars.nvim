package main

import (
	"log"
)

func main() {
	if err := run(); err != nil {
		log.Fatalf("Service stopped: %s", err)
	}
}
