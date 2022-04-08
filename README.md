# k8_utils
Kubernetes utility scripts

## Installation
- Run `setup.sh` to add aliases, initialize your Ruby home and install dependencies.
- If already use ruby and have your environment setup, you can ignore this step

## KB usage

- KB is used to select your context and your namespace for future kubernetes commands
```
Usage: example.rb [options]
    -c, --context                    only set the namespace
    -n, --namespace                  only select the namespace for current context
    -h, --help                       prints this help
    -i, --info                       prints context
```
- Tip: you can start typing to context or namespace name to filter results.


## CL usage
- Use CL to exec into a docker container or kubernetes pod
```
Usage: wrapper.sh [options]
   -c   select kubernetes context first
   -l   login to osprey
   -d   exec into docker container
   -k   exec into kubernetes pod
   -m   select a mode to exec into a pod/container
```

