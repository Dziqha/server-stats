package main

import "net/http"

func main() {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Stats endpoint"))
	})

	http.ListenAndServe(":8080", handler)
}