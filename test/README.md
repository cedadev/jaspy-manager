# Running tests

## Pytest

Just do:

```
pytest
```

To log everything to the terminal do:

```
pytest --capture=no
```

## What are we testing?

There are two types of tests:

 - `core` tests: checking that `jaspy` works properly.
 - `environment` tests: tests for specific packages in a `jaspy` environment
