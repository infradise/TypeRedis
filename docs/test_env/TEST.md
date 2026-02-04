# dart test

```sh
dart test --concurrency=1
# 00:24 +178 ~3: All other tests passed!
```

```sh
dart test --exclude-tags example --concurrency=1
# 00:07 +138 ~3: All other tests passed!
```

```sh
dart test --tags example
# 00:17 +40: All tests passed! 
```

# Investigate the problem

```sh
dart test test/{testcase}.dart -r expanded
```