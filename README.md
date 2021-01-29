# tunneling-mapper

Docker image that creates iptables forward rules based on a mapping file.

## Motivation

TBD

## How it works

TBD

## Usage

First of all, it's necessary to provide a `mapping.yml` file that contains the definition of mappings.
The structure of the `mapping.yml` file looks as follows:

```YAML
mappings:
  - description: String
    acceptPort: int
    routeTo:
      ip: String
      port: int
```

All fields are required.
You can find more details about the format in [2iq/tunneling-mapping-parser/README.md#mapping-file](https://github.com/2iq/tunneling-mapping-parser/blob/main/README.md#mapping-file).
This file needs to be present in `/workdir/mapping.yml` inside of a container.
You can directly run a container by mounting a mapping file or create an own image.

Regardless of which way you're going, the container requires `NET_ADMIN` capability.

### Direct use

Once you have `mapping.yml` in current directory you can start new container with this command:

```shell
docker run --rm --cap-add=NET_ADMIN -v ${PWD}/mapping.yml:/workdir/mapping.yml -p 5432:5432 x2iq/tunneling-mapper
```

In this example, we're publishing container port 5432 to host.
Of course, you should adjust port publishing parameters to your needs.

### Create new image

You can also create a new image, as shown in the following example:

```Dockerfile
FROM x2iq/tunneling-mapper:1.0

COPY mapping.yml /workdir/mapping.yml
```

That's it.
Above is the most straightforward workable example of Dockerfile for a custom image.
Image creation didn't require any particular parameter:

```shell
docker build -t my-custom-tunneling-mapper .
```

Running is same as before without mounting mapping file:

```shell
docker run --rm --cap-add=NET_ADMIN -p 5432:5432 my-custom-tunneling-mapper
```
