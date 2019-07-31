package main

import (
    "bytes"
    _ "bufio"
    "io"
    "sync"
    "fmt"
    "io/ioutil"
    "log"
    "net/http"
    "os"
    "time"
    "os/exec"
)

func main() {
    awsLambdaRuntimeApi := os.Getenv("AWS_LAMBDA_RUNTIME_API")
    if awsLambdaRuntimeApi == "" {
            panic("Missing: 'AWS_LAMBDA_RUNTIME_API'")
    }
    for {
        // get the next event
        requestUrl := fmt.Sprintf("http://%s/2018-06-01/runtime/invocation/next", awsLambdaRuntimeApi)
        resp, err := http.Get(requestUrl)
        if err != nil {
            log.Fatal(fmt.Errorf("Expected status code 200, got %d", resp.StatusCode))
        }

        requestId := resp.Header.Get("Lambda-Runtime-Aws-Request-Id")
        // print the next event
        eventData, err := ioutil.ReadAll(resp.Body)
        if err != nil {
            log.Fatal(fmt.Errorf("Error: %s"), err)
        }
        fmt.Println("Received event:", string(eventData))

        // Assume API Gateway and respond with Hello World
        responseUrl := fmt.Sprintf("http://%s/2018-06-01/runtime/invocation/%s/response", awsLambdaRuntimeApi, requestId)

        ioutil.WriteFile("/tmp/out.nar.base64",eventData,0644);
        cmd := exec.Command("./myshell.sh")
        var stdoutBuf, stderrBuf bytes.Buffer
        stdoutIn, _ := cmd.StdoutPipe()
        stderrIn, _ := cmd.StderrPipe()

        var errStdout, errStderr error
        stdout := io.MultiWriter(os.Stdout, &stdoutBuf)
        stderr := io.MultiWriter(os.Stderr, &stderrBuf)
        err = cmd.Start()
        if err != nil {
            log.Fatalf("cmd.Start() failed with '%s'\n", err)
        }

        var wg sync.WaitGroup
        wg.Add(1)
        go func() {
            _, errStdout = io.Copy(stdout, stdoutIn)
            wg.Done()
        }()
        _, errStderr = io.Copy(stderr, stderrIn)
        wg.Wait()
        err = cmd.Wait()
        if err != nil {
            log.Fatalf("cmd.Run() failed with %s\n", err)
        }
        if errStdout != nil || errStderr != nil {
            log.Fatal("failed to capture stdout or stderr\n")
        }
        outStr, _ := string(stdoutBuf.Bytes()), string(stderrBuf.Bytes())
        //fmt.Printf("\nout:\n%s\nerr:\n%s\n", outStr, errStr)

        /*
        stdout, _ := cmd.StdoutPipe()

        scanner := bufio.NewScanner(stdout)
        scanner.Split(bufio.ScanLines)
        var out []byte
        for scanner.Scan() {
            m := scanner.Text()
            out = append(out,scanner.Bytes()...)
            fmt.Println(m)
        }
        cmd.Wait()
        */
        /*
        out, err := cmd.CombinedOutput()
        if err != nil {
            log.Fatalf("cmd.Run() failed with %s and %s\n", err,out)
        }
        fmt.Printf("combined out:\n%s\n", string(out))
        */
        //responsePayload := []byte(`{"statusCode": 200, "body": "Hello World!"}`)
        responsePayload := []byte(outStr)

        req, err := http.NewRequest("POST", responseUrl, bytes.NewBuffer(responsePayload))
        req.Header.Set("Content-Type", "application/json")

        client := &http.Client{}
        client.Timeout = time.Second * 1
        postResp, err := client.Do(req)
        if err != nil {
            log.Fatal(fmt.Errorf("Error %s", err))
        }
        body, _ := ioutil.ReadAll(postResp.Body)
        fmt.Println("Received response:", string(body))
    }
}
