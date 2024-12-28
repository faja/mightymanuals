- add `trace.Start` to your go program
    ```go
    package main

    import (
        "fmt"
        "os"
        "runtime/trace"
    )

    func main() {

        tout, err := os.Create("./t.out")
        if err != nil {
            fmt.Println(err)
            return
        }

        trace.Start(tout)
        defer trace.Stop()

        // for profiling
        // pprof.StartCPUProfile(os.Stdout)
        // defer pprof.StopCPUProfile()

        fmt.Println("ok")
    }
    ```

- open trace file with `go` tool
    ```sh
    go tool trace t.out
    ```
