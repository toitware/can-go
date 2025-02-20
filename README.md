# :electric_plug: CAN Go

[![PkgGoDev][pkg-badge]][pkg]
[![GoReportCard][report-badge]][report]
[![Codecov][codecov-badge]][codecov]

[pkg-badge]: https://pkg.go.dev/badge/github.com/toitware/can-go
[pkg]: https://pkg.go.dev/github.com/toitware/can-go
[report-badge]: https://goreportcard.com/badge/github.com/toitware/can-go
[report]: https://goreportcard.com/report/github.com/toitware/can-go
[codecov-badge]: https://codecov.io/gh/einride/can-go/branch/master/graph/badge.svg
[codecov]: https://codecov.io/gh/einride/can-go

CAN toolkit for Go programmers.

can-go makes use of the Linux SocketCAN abstraction for CAN communication.
(See the [SocketCAN][socketcan] documentation for more details).

[socketcan]: https://www.kernel.org/doc/Documentation/networking/can.txt

## Examples

### Receiving CAN frames

Receiving CAN frames from a socketcan interface.

```go
func main() {
    // Error handling omitted to keep example simple
    conn, _ := socketcan.DialContext(context.Background(), "can", "can0")

    recv := socketcan.NewReceiver(conn)
    for recv.Receive() {
        frame := recv.Frame()
        fmt.Println(frame.String())
    }
}
```

### Sending CAN frames/messages

Sending CAN frames to a socketcan interface.

```go
func main() {
	// Error handling omitted to keep example simple

	conn, _ := socketcan.DialContext(context.Background(), "can", "can0")

	frame := can.Frame{}
	tx := socketcan.NewTransmitter(conn)
    _ = tx.TransmitFrame(context.Background(), frame)
}
```

### Generating Go code from a DBC file

It is possible to generate Go code from a `.dbc` file.

```
$ go run github.com/toitware/can-go/cmd/cantool generate <dbc file root folder> <output folder>
```

In order to generate Go code that makes sense, we currently perform some
validations when parsing the DBC file so there may need to be some changes
on the DBC file to make it work

After generating Go code we can marshal a message to a frame:

```go
// import etruckcan "github.com/myproject/myrepo/gen"

auxMsg := etruckcan.NewAuxiliary().SetHeadLights(etruckcan.Auxiliary_HeadLights_LowBeam)
frame := auxMsg.Frame()
```

Or unmarshal a frame to a message:

```go
// import etruckcan "github.com/myproject/myrepo/gen"

// Error handling omitted for simplicity
_ := recv.Receive()
frame := recv.Frame()

var auxMsg *etruckcan.Auxiliary
_ = auxMsg.UnmarshalFrame(frame)

```
