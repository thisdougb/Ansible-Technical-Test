# Technical Test

This task should demonstrate your grasp of key DevOps skills, such as working with source control, automation, orchestration and software configuration management.

## Task
a) Launch 3 separate linux nodes using the tool/distro of your choice
* 2 x application nodes 
* 1 x web node

b) Using a configuration management tool (contractors MUST use Chef or Ansible)
* Deploy the sample application to the application nodes
* Install Nginx on the web node and balance requests to the application nodes in a round-robin fashion 
* Demonstrate the round-robin mechanism is working correctly

## Goal

Sending a HTTP request to the web node should return the response
```
Hi there, I'm served from <application node hostname>!
```

## Considerations
* Share your work on a public git repo
* Include a README.md with clear and concise instructions Invocation should be a one line command string
* Take care not to over engineer a solution

## Bonus point
For changes to the sample code, automate the build and delivery to the environment.

## Sample application code (Go)
```
package main
import (
        "fmt"
        "net/http"
        "os"
)
func handler(w http.ResponseWriter, r *http.Request) {
        h, _ := os.Hostname()
        fmt.Fprintf(w, "Hi there, I'm served from %s!", h)
}
func main() {
}
http.HandleFunc("/", handler)
http.ListenAndServe(":8484", nil)
```
