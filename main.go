package main

import "net/http"

func main() {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Stats endpoint - DEPLOYED VIA ROBOT"))
	})

	http.ListenAndServe(":8080", handler)
}