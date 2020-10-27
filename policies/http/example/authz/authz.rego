package http.example.authz

default allow = false

allow {
    input.method == "GET"
    input.path == "/health"
}
