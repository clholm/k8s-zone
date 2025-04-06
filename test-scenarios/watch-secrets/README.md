a quick demo to observe `watch`ing `secrets`

some code/manifests are llm-generated

instructions:
```
./run-demo.sh
```

in another terminal, run the watch script to watch for changes
to `secrets` in the `secrets-watch-demo` namespace:

```
./watch-secrets.sh
```

when you're done, run the cleanup script!

```
./cleanup.sh
```